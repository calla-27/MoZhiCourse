// src/controllers/community/roomController.js
const StudyRoom = require('../../models/community/StudyRoom');
const RoomMember = require('../../models/community/RoomMember');
const { execute } = require('../../config/database');

const roomController = {
    // 创建自习室
    createRoom: async (req, res) => {
        try {
            const { room_name, description, max_participants, schedule_time, tags, rules, creator_id } = req.body;

            console.log('创建自习室请求:', { room_name, creator_id });

            // 1. 基础字段验证
            if (!room_name || !description || !creator_id) {
                return res.status(400).json({
                    success: false,
                    message: '自习室名称、描述和创建者ID为必填项',
                    required_fields: ['room_name', 'description', 'creator_id']
                });
            }

            // 2. 验证字段长度
            if (room_name.length < 2 || room_name.length > 100) {
                return res.status(400).json({
                    success: false,
                    message: '自习室名称长度应在2-100个字符之间'
                });
            }

            if (description.length < 10) {
                return res.status(400).json({
                    success: false,
                    message: '自习室描述应至少10个字符'
                });
            }

            // 3. 验证创建者是否存在
            const [userExists] = await execute(
                'SELECT user_id, user_name FROM t_user WHERE user_id = ? AND is_active = 1',
                [creator_id]
            );

            if (userExists.length === 0) {
                return res.status(400).json({
                    success: false,
                    message: '创建者用户不存在或已被禁用'
                });
            }

            // 4. 验证自习室名称是否重复
            const [roomExists] = await execute(
                'SELECT room_id FROM t_study_room WHERE room_name = ? AND status = "open"',
                [room_name]
            );

            if (roomExists.length > 0) {
                return res.status(400).json({
                    success: false,
                    message: '自习室名称已存在，请使用其他名称'
                });
            }

            // 5. 验证最大参与人数
            if (max_participants && (max_participants < 1 || max_participants > 200)) {
                return res.status(400).json({
                    success: false,
                    message: '自习室最大参与人数应在1-200人之间'
                });
            }

            // 6. 验证时间格式（简单验证）
            if (schedule_time && schedule_time.length > 50) {
                return res.status(400).json({
                    success: false,
                    message: '时间安排格式过长，请控制在50个字符以内'
                });
            }

            // 7. 验证标签格式
            if (tags && !Array.isArray(tags)) {
                return res.status(400).json({
                    success: false,
                    message: '标签格式错误，应为数组格式'
                });
            }

            // 8. 验证规则长度
            if (rules && rules.length > 1000) {
                return res.status(400).json({
                    success: false,
                    message: '自习室规则过长，请控制在1000个字符以内'
                });
            }

            // 9. 所有验证通过，创建自习室
            const roomId = await StudyRoom.create({
                room_name,
                description,
                creator_id,
                max_participants: max_participants || 50,
                schedule_time: schedule_time || null, 
                tags: tags || [],
                rules: rules || null               
            });

            console.log('自习室创建成功:', { roomId, room_name, creator_id });

            res.status(201).json({
                success: true,
                message: '自习室创建成功',
                data: { 
                    room_id: roomId,
                    room_name,
                    creator_id
                }
            });
        } catch (error) {
            console.error('创建自习室错误:', error);
            
            // 处理数据库约束错误
            if (error.code === 'ER_NO_REFERENCED_ROW_2') {
                return res.status(400).json({
                    success: false,
                    message: '关联数据不存在，请检查用户ID'
                });
            }
            
            res.status(500).json({
                success: false,
                message: '创建自习室失败: ' + error.message,
                error: process.env.NODE_ENV === 'development' ? error.stack : undefined
            });
        }
    },

    getRooms: async (req, res) => {
        try {
            const { page = 1, limit = 10, current_user_id } = req.query;
            
            const rooms = await StudyRoom.findAll();
            
            // 为每个自习室添加是否是当前用户创建的标志
            const roomsWithOwnership = rooms.map(room => ({
                ...room,
                is_owner: room.creator_id === parseInt(current_user_id)
            }));
            
            res.json({
                success: true,
                data: roomsWithOwnership,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total: rooms.length
                }
            });
        } catch (error) {
            console.error('获取自习室列表错误:', error);
            res.status(500).json({
                success: false,
                message: '获取自习室列表失败: ' + error.message
            });
        }
    },

    // 获取自习室详情
    getRoomDetail: async (req, res) => {
        try {
            const { roomId } = req.params;
            const { current_user_id } = req.query;
            
            // 获取自习室基本信息
            const [rooms] = await execute(`
                SELECT sr.*, u.user_name as creator_name, u.avatar_url as creator_avatar
                FROM t_study_room sr
                LEFT JOIN t_user u ON sr.creator_id = u.user_id
                WHERE sr.room_id = ?
            `, [roomId]);

            if (rooms.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: '自习室不存在'
                });
            }

            const room = rooms[0];

            // 获取在线成员
            const members = await RoomMember.getRoomMembers(roomId);

            // 获取当前在线人数
            const [onlineCount] = await execute(
                'SELECT COUNT(*) as count FROM t_room_member WHERE room_id = ? AND leave_time IS NULL',
                [roomId]
            );

            // 添加是否是当前用户创建的标志
            room.is_owner = room.creator_id === parseInt(current_user_id);

            res.json({
                success: true,
                data: {
                    ...room,
                    members,
                    online_count: onlineCount[0].count
                }
            });
        } catch (error) {
            console.error('获取自习室详情错误:', error);
            res.status(500).json({
                success: false,
                message: '获取自习室详情失败: ' + error.message
            });
        }
    },

    // 加入自习室
    joinRoom: async (req, res) => {
        try {
            const { roomId } = req.params;
            const { user_id } = req.body;

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            await StudyRoom.joinRoom(roomId, user_id);

            res.json({
                success: true,
                message: '加入自习室成功'
            });
        } catch (error) {
            console.error('加入自习室错误:', error);
            res.status(500).json({
                success: false,
                message: '加入自习室失败: ' + error.message
            });
        }
    },

    // 离开自习室
    leaveRoom: async (req, res) => {
        try {
            const { roomId } = req.params;
            const { user_id } = req.body;

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            const success = await RoomMember.leaveRoom(roomId, user_id);

            if (success) {
                res.json({
                    success: true,
                    message: '已离开自习室'
                });
            } else {
                res.status(400).json({
                    success: false,
                    message: '您不在该自习室中'
                });
            }
        } catch (error) {
            console.error('离开自习室错误:', error);
            res.status(500).json({
                success: false,
                message: '离开自习室失败: ' + error.message
            });
        }
    },

    // 更新自习室
    updateRoom: async (req, res) => {
        try {
            const { roomId } = req.params;
            const { room_name, description, max_participants, schedule_time, tags, rules, user_id } = req.body;

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            // 检查权限
            const [room] = await execute(
                'SELECT creator_id FROM t_study_room WHERE room_id = ?',
                [roomId]
            );

            if (room.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: '自习室不存在'
                });
            }

            if (room[0].creator_id !== parseInt(user_id)) {
                return res.status(403).json({
                    success: false,
                    message: '只有创建者才能更新自习室'
                });
            }

            // 这里需要实现更新自习室的逻辑
            res.json({
                success: true,
                message: '自习室更新成功'
            });
        } catch (error) {
            console.error('更新自习室错误:', error);
            res.status(500).json({
                success: false,
                message: '更新自习室失败: ' + error.message
            });
        }
    },

    // 删除自习室
    deleteRoom: async (req, res) => {
        try {
            const { roomId } = req.params;
            const { user_id } = req.body;

            console.log('删除自习室请求:', { roomId, user_id });

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            // 1. 检查自习室是否存在
            const [roomExists] = await execute(
                'SELECT room_id, creator_id FROM t_study_room WHERE room_id = ?',
                [roomId]
            );

            if (roomExists.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: '自习室不存在'
                });
            }

            const room = roomExists[0];

            // 2. 检查当前用户是否为创建者
            if (room.creator_id !== parseInt(user_id)) {
                return res.status(403).json({
                    success: false,
                    message: '只有创建者才能删除自习室'
                });
            }

            // 3. 先删除相关的留言记录（外键约束）
            await execute(
                'DELETE FROM t_room_message WHERE room_id = ?',
                [roomId]
            );

            // 4. 删除相关的成员记录
            await execute(
                'DELETE FROM t_room_member WHERE room_id = ?',
                [roomId]
            );

            // 5. 删除自习室
            const [result] = await execute(
                'DELETE FROM t_study_room WHERE room_id = ?',
                [roomId]
            );

            if (result.affectedRows > 0) {
                console.log('自习室删除成功:', { roomId });
                res.json({
                    success: true,
                    message: '自习室删除成功'
                });
            } else {
                res.status(404).json({
                    success: false,
                    message: '自习室不存在'
                });
            }
        } catch (error) {
            console.error('删除自习室错误:', error);
            res.status(500).json({
                success: false,
                message: '删除自习室失败: ' + error.message
            });
        }
    }
};

module.exports = roomController;