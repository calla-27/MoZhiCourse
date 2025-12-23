// src/controllers/community/messageController.js
const mysql = require('mysql2');
const { execute } = require('../../config/database');

const messageController = {
    // 创建自习室留言 - 修改为 room_message 表
    createMessage: async (req, res) => {
        try {
            const { roomId } = req.params;
            const { user_id, content } = req.body;

            console.log('创建自习室留言请求:', { roomId, user_id });

            if (!user_id || !content) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID和留言内容为必填项'
                });
            }

            // 验证用户是否存在
            const [userExists] = await execute(
                'SELECT user_id, user_name FROM user WHERE user_id = ?',
                [user_id]
            );

            if (userExists.length === 0) {
                return res.status(400).json({
                    success: false,
                    message: '用户不存在或已被禁用'
                });
            }

            // 验证自习室是否存在
            const [roomExists] = await execute(
                'SELECT room_id FROM study_room WHERE room_id = ? AND status IN ("open", "active")',
                [roomId]
            );

            if (roomExists.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: '自习室不存在或已关闭'
                });
            }

            // 重要修改：插入到 room_message 表，而不是 community_message
            const [result] = await execute(
                'INSERT INTO room_message (room_id, user_id, content, message_type) VALUES (?, ?, ?, "text")',
                [roomId, user_id, content]
            );

            // 获取刚创建的留言详情
            const [messages] = await execute(`
                SELECT rm.*, u.user_name, u.avatar_url
                FROM room_message rm
                LEFT JOIN user u ON rm.user_id = u.user_id
                WHERE rm.message_id = ?
            `, [result.insertId]);

            const createdMessage = messages[0] || {};
            console.log('自习室留言创建成功:', { 
                messageId: result.insertId, 
                roomId, 
                user_id,
                userName: createdMessage.user_name
            });

            res.status(201).json({
                success: true,
                message: '留言发送成功',
                data: createdMessage
            });
        } catch (error) {
            console.error('创建自习室留言错误:', error);
            
            if (error.code === 'ER_NO_REFERENCED_ROW_2') {
                return res.status(400).json({
                    success: false,
                    message: '关联数据不存在，请检查自习室ID或用户ID'
                });
            }
            
            res.status(500).json({
                success: false,
                message: '留言发送失败: ' + error.message,
                error: process.env.NODE_ENV === 'development' ? error.stack : undefined
            });
        }
    },

    // 获取自习室留言 - 修改为 room_message 表
    getRoomMessages: async (req, res) => {
    try {
        const { roomId } = req.params;
        const { page = 1, limit = 50 } = req.query;

        console.log('获取自习室留言请求:', { roomId, page, limit });

        // 确保参数是数字类型
        const pageNum = parseInt(page, 10);
        const limitNum = parseInt(limit, 10);
        const offset = (pageNum - 1) * limitNum;

        // 验证参数有效性
        if (isNaN(pageNum) || isNaN(limitNum) || pageNum < 1 || limitNum < 1) {
            return res.status(400).json({
                success: false,
                message: '分页参数无效'
            });
        }

        // 方法1：使用字符串拼接（避免参数类型问题）
        const sql = `
            SELECT rm.*, u.user_name, u.avatar_url
            FROM room_message rm
            LEFT JOIN user u ON rm.user_id = u.user_id
            WHERE rm.room_id = ${parseInt(roomId, 10)}
            ORDER BY rm.create_time DESC
            LIMIT ${limitNum} OFFSET ${offset}
        `;

        console.log('执行的SQL:', sql);

        const [messages] = await execute(sql);

        // 获取总条数
        const [countResult] = await execute(
            'SELECT COUNT(*) as total FROM room_message WHERE room_id = ?',
            [parseInt(roomId, 10)]
        );

        const total = countResult[0] ? Number(countResult[0].total) : 0;

        console.log('获取自习室留言成功:', { 
            roomId, 
            count: messages ? messages.length : 0, 
            total 
        });

        res.json({
            success: true,
            data: messages || [],
            pagination: {
                page: pageNum,
                limit: limitNum,
                total: total
            }
        });
    } catch (error) {
        console.error('获取自习室留言错误:', error);
        res.status(500).json({
            success: false,
            message: '获取留言失败: ' + error.message
        });
    }
},

    // ===================== 组队学习：小组留言 - 保持不变 =====================

    // 创建小组留言（按 team_id）- 保持使用 community_message 表
    createTeamComment: async (req, res) => {
        try {
            const { teamId } = req.params;
            const { user_id, content } = req.body;

            if (!user_id || !content) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID和留言内容为必填项'
                });
            }

            // 验证用户是否存在
            const [userExists] = await execute(
                'SELECT user_id FROM user WHERE user_id = ?',
                [user_id]
            );
            if (userExists.length === 0) {
                return res.status(400).json({
                    success: false,
                    message: '用户不存在或已被禁用'
                });
            }

            // 小组留言仍然使用 community_message 表
            const [result] = await execute(
                'INSERT INTO community_message (team_id, sender_id, content, message_type) VALUES (?, ?, ?, "team")',
                [teamId, user_id, content]
            );

            const [rows] = await execute(`
                SELECT cm.*, u.user_name, u.avatar_url
                FROM community_message cm
                LEFT JOIN user u ON cm.sender_id = u.user_id
                WHERE cm.message_id = ?
            `, [result.insertId]);

            res.status(201).json({
                success: true,
                message: '留言发送成功',
                data: rows[0]
            });
        } catch (error) {
            console.error('创建小组留言错误:', error);
            res.status(500).json({
                success: false,
                message: '创建小组留言失败: ' + error.message
            });
        }
    },

    // 获取小组留言（按 team_id）- 保持使用 community_message 表
    getTeamComments: async (req, res) => {
        try {
            const { teamId } = req.params;

            const [rows] = await execute(`
                SELECT cm.*, u.user_name, u.avatar_url
                FROM community_message cm
                LEFT JOIN user u ON cm.sender_id = u.user_id
                WHERE cm.team_id = ? AND cm.message_type = 'team'
                ORDER BY cm.create_time DESC
            `, [teamId]);

            res.json({
                success: true,
                data: rows
            });
        } catch (error) {
            console.error('获取小组留言错误:', error);
            res.status(500).json({
                success: false,
                message: '获取小组留言失败: ' + error.message
            });
        }
    },

    // 删除留言 - 需要区分是自习室留言还是小组留言
    deleteMessage: async (req, res) => {
        try {
            const { messageId } = req.params;
            const { user_id, message_type = 'room' } = req.body; // 添加消息类型参数

            console.log('删除留言请求:', { messageId, user_id, message_type });

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            let tableName, idField;
            if (message_type === 'room') {
                tableName = 'room_message';
                idField = 'user_id';
            } else {
                tableName = 'community_message';
                idField = 'sender_id';
            }

            // 验证用户是否有权限删除（只能删除自己的留言）
            const [message] = await execute(
                `SELECT * FROM ${tableName} WHERE message_id = ? AND ${idField} = ?`,
                [messageId, user_id]
            );

            if (message.length === 0) {
                return res.status(403).json({
                    success: false,
                    message: '无权删除该留言'
                });
            }

            const [result] = await execute(
                `DELETE FROM ${tableName} WHERE message_id = ?`,
                [messageId]
            );

            if (result.affectedRows > 0) {
                console.log('留言删除成功:', { messageId, message_type });
                res.json({
                    success: true,
                    message: '留言删除成功'
                });
            } else {
                res.status(404).json({
                    success: false,
                    message: '留言不存在'
                });
            }
        } catch (error) {
            console.error('删除留言错误:', error);
            res.status(500).json({
                success: false,
                message: '删除留言失败: ' + error.message
            });
        }
    }
};

module.exports = messageController;