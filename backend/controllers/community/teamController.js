// src/controllers/community/teamController.js
const StudyTeam = require('../../models/community/StudyTeam');
const TeamMember = require('../../models/community/TeamMember');
const { execute } = require('../../config/database'); 

const teamController = {
    // 获取可用数据（课程和用户）
    getAvailableData: async (req, res) => {
        try {
            console.log('开始获取可用数据...');
            
            // 获取所有活跃用户
            const [users] = await execute(
                'SELECT user_id, user_name, email FROM user ORDER BY user_name'
            );
            
            // 获取所有课程
            const [courses] = await execute(
                'SELECT course_id, course_name, teacher_user_id FROM course ORDER BY course_name'
            );
            
            // 获取所有标签（从现有小组中提取）
            const [tagsResult] = await execute(
                'SELECT DISTINCT tags FROM study_team WHERE tags IS NOT NULL'
            );
            
            // 提取并去重标签
            const allTags = new Set();
            tagsResult.forEach(row => {
                if (!row.tags) return;

                try {
                    let tags = [];
    
                    // 尝试解析JSON格式
                    if (typeof row.tags === 'string' && row.tags.startsWith('[')) {
                        tags = JSON.parse(row.tags);
                    } 
                    // 处理逗号分隔的字符串格式
                    else if (typeof row.tags === 'string' && row.tags.includes(',')) {
                        tags = row.tags.split(',').map(tag => tag.trim()).filter(Boolean);
                    }
                    // 处理单个标签
                    else if (row.tags) {
                        tags = [row.tags.toString().trim()];
                    }
    
                    // 添加到集合中去重
                    tags.forEach(tag => {
                        if (tag && tag !== 'null' && tag !== 'undefined') {
                            allTags.add(tag);
                        }
                    });
                } catch (e) {
                    console.log('标签解析失败，跳过:', row.tags);
                }
            });

            // 转换为数组
            const uniqueTags = Array.from(allTags);
            
            console.log('获取可用数据成功:', {
                users: users.length,
                courses: courses.length,
                tags: uniqueTags.length
            });
            
            res.json({
                success: true,
                data: {
                    users,
                    courses,
                    tags: uniqueTags
                }
            });
        } catch (error) {
            console.error('获取可用数据错误:', error);
            res.status(500).json({
                success: false,
                message: '获取可用数据失败: ' + error.message,
                error: process.env.NODE_ENV === 'development' ? error.stack : undefined
            });
        }
    },

    // 创建学习小组
    createTeam: async (req, res) => {
        try {
            const { team_name, description, course_id, max_members, tags, creator_id } = req.body;

            console.log('创建学习小组请求:', { team_name, creator_id, course_id });

            // 1. 基础字段验证
            if (!team_name || !description || !creator_id) {
                return res.status(400).json({
                    success: false,
                    message: '小组名称、描述和创建者ID为必填项',
                    required_fields: ['team_name', 'description', 'creator_id']
                });
            }

            // 2. 验证字段长度
            if (team_name.length < 2 || team_name.length > 100) {
                return res.status(400).json({
                    success: false,
                    message: '小组名称长度应在2-100个字符之间'
                });
            }

            if (description.length < 10) {
                return res.status(400).json({
                    success: false,
                    message: '小组描述应至少10个字符'
                });
            }

            // 3. 验证创建者是否存在
            const [userExists] = await execute(
                'SELECT user_id, user_name FROM user WHERE user_id = ?',
                [creator_id]
            );

            if (userExists.length === 0) {
                return res.status(400).json({
                    success: false,
                    message: '创建者用户不存在或已被禁用',
                    available_users: '/api/community/teams/available-data'
                });
            }

            // 4. 如果提供了课程ID，验证课程是否存在
            if (course_id) {
                const [courseExists] = await execute(
                    'SELECT course_id, course_name FROM course WHERE course_id = ?',
                    [course_id]
                );

                if (courseExists.length === 0) {
                    return res.status(400).json({
                        success: false,
                        message: '指定的课程不存在',
                        available_courses: '/api/community/teams/available-data'
                    });
                }
            }

            // 5. 验证小组名称是否已存在
            const [teamExists] = await execute(
                'SELECT team_id FROM study_team WHERE team_name = ? AND status = "active"',
                [team_name]
            );

            if (teamExists.length > 0) {
                return res.status(400).json({
                    success: false,
                    message: '小组名称已存在，请使用其他名称'
                });
            }

            // 6. 验证最大成员数
            if (max_members && (max_members < 2 || max_members > 50)) {
                return res.status(400).json({
                    success: false,
                    message: '小组最大成员数应在2-50人之间'
                });
            }

            // 7. 所有验证通过，创建小组
            const teamId = await StudyTeam.create({
                team_name,
                description,
                course_id,
                creator_id,
                max_members: max_members || 10,
                tags: tags || []
            });

            // 创建者自动加入小组
            await TeamMember.addMember(teamId, creator_id, 'leader');

            console.log('学习小组创建成功:', { teamId, team_name });

            res.status(201).json({
                success: true,
                message: '学习小组创建成功',
                data: { 
                    team_id: teamId,
                    team_name,
                    creator_id 
                }
            });
        } catch (error) {
            console.error('创建学习小组错误:', error);
            
            // 处理数据库约束错误
            if (error.code === 'ER_NO_REFERENCED_ROW_2') {
                return res.status(400).json({
                    success: false,
                    message: '关联数据不存在，请检查课程ID或用户ID',
                    help: '请调用 /api/community/teams/available-data 获取可用数据'
                });
            }
            
            res.status(500).json({
                success: false,
                message: '创建学习小组失败: ' + error.message,
                error: process.env.NODE_ENV === 'development' ? error.stack : undefined
            });
        }
    },

    // 获取学习小组列表
    getTeams: async (req, res) => {
        try {
            const { course_id, page = 1, limit = 10, current_user_id } = req.query;
            const filters = {};

            if (course_id) {
                filters.course_id = course_id;
            }

            const teams = await StudyTeam.findAll(filters);

            // 确保teams是数组，然后为每个小组添加是否是当前用户创建的标志
            const teamsArray = Array.isArray(teams) ? teams : [];
            const teamsWithOwnership = teamsArray.map(team => ({
                ...team,
                is_owner: team.creator_id === parseInt(current_user_id)
            }));

            res.json({
                success: true,
                data: teamsWithOwnership,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total: teamsArray.length
                }
            });
        } catch (error) {
            console.error('获取小组列表错误:', error);
            res.status(500).json({
                success: false,
                message: '获取学习小组列表失败: ' + error.message
            });
        }
    },

// 获取小组详情
getTeamDetail: async (req, res) => {
    try {
        const { teamId } = req.params;
        const { current_user_id } = req.query;

        // 使用联合查询，一次性获取所有需要的数据
        const [teamQueryResult] = await execute(`
            SELECT 
                st.team_id,
                st.team_name,
                st.description,
                st.tags,
                st.creator_id,
                st.max_members,
                st.current_members,  -- 新增：成员人数字段
                st.status,
                -- 计算任务完成率
                CASE 
                    WHEN total_tasks > 0 THEN 
                        ROUND((completed_tasks * 100.0 / total_tasks), 1)
                    ELSE 0 
                END as completion_rate,
                -- 计算任务完成量（已完成任务数）
                COALESCE(completed_tasks, 0) as completed_tasks,
                -- 总任务数
                COALESCE(total_tasks, 0) as total_tasks
            FROM study_team st
            LEFT JOIN (
                SELECT 
                    team_id,
                    COUNT(*) as total_tasks,
                    SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_tasks
                FROM team_task 
                WHERE team_id = ?
                GROUP BY team_id
            ) tt ON st.team_id = tt.team_id
            WHERE st.team_id = ?
        `, [teamId, teamId]);

        if (teamQueryResult.length === 0) {
            return res.status(404).json({
                success: false,
                message: '学习小组不存在'
            });
        }

        const teamData = teamQueryResult[0];

        // 获取成员列表
        const members = await TeamMember.getTeamMembers(teamId);

        // 当前用户 ID
        const currentUserId = current_user_id ? parseInt(current_user_id) : null;

        // 标记是否为创建者
        teamData.is_owner = currentUserId ? (teamData.creator_id === currentUserId) : false;

        // 当前用户是否在小组中
        let isJoined = false;
        if (currentUserId && Array.isArray(members)) {
            isJoined = members.some(m => m.user_id === currentUserId);
        }

        // 解析标签
        let tags = [];
        if (teamData.tags) {
            try {
                if (typeof teamData.tags === 'string' && teamData.tags.startsWith('[')) {
                    tags = JSON.parse(teamData.tags);
                } else if (typeof teamData.tags === 'string' && teamData.tags.includes(',')) {
                    tags = teamData.tags.split(',').map(tag => tag.trim()).filter(Boolean);
                } else if (teamData.tags) {
                    tags = [teamData.tags.toString().trim()];
                }
            } catch (e) {
                console.log('标签解析失败:', e);
                tags = [];
            }
        }

        // 格式化返回数据
        const responseData = {
            team_id: teamData.team_id,
            team_name: teamData.team_name,
            description: teamData.description,
            tags: tags,
            creator_id: teamData.creator_id,
            max_members: teamData.max_members,
            current_members: teamData.current_members || 0,  // 成员人数
            completion_rate: teamData.completion_rate || 0,  // 任务完成率
            completed_tasks: teamData.completed_tasks || 0,  // 任务完成量
            total_tasks: teamData.total_tasks || 0,          // 总任务数
            status: teamData.status,
            is_owner: teamData.is_owner,
            is_joined: isJoined,
            members: members || []
        };

        console.log('小组详情数据:', {
            team_name: responseData.team_name,
            current_members: responseData.current_members,
            completion_rate: responseData.completion_rate,
            completed_tasks: responseData.completed_tasks,
            total_tasks: responseData.total_tasks
        });

        res.json({
            success: true,
            data: responseData
        });
    } catch (error) {
        console.error('获取小组详情错误:', error);
        res.status(500).json({
            success: false,
            message: '获取小组详情失败: ' + error.message
        });
    }
},

    // 申请加入小组
    joinTeam: async (req, res) => {
        try {
            const { teamId } = req.params;
            const { user_id } = req.body;

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            // 检查小组是否存在
            const team = await StudyTeam.findById(teamId);
            if (!team) {
                return res.status(404).json({
                    success: false,
                    message: '学习小组不存在'
                });
            }

            // 检查用户是否已在小组中
            const [existingMember] = await execute(
                'SELECT member_id FROM team_member WHERE team_id = ? AND user_id = ?',
                [teamId, user_id]
            );

            if (existingMember && existingMember.length > 0) {
                return res.status(400).json({
                    success: false,
                    message: '您已在该学习小组中'
                });
            }

            // 检查小组是否已满
            const members = await TeamMember.getTeamMembers(teamId);
            const currentMembers = Array.isArray(members) ? members.length : 0;
            
            if (currentMembers >= team.max_members) {
                return res.status(400).json({
                    success: false,
                    message: '该学习小组人数已满'
                });
            }

            // 加入小组
            await TeamMember.addMember(teamId, user_id, 'member');

            res.json({
                success: true,
                message: '已成功加入学习小组'
            });
        } catch (error) {
            console.error('加入小组错误:', error);
            res.status(500).json({
                success: false,
                message: '加入学习小组失败: ' + error.message
            });
        }
    },

    // 离开小组
    leaveTeam: async (req, res) => {
        try {
            const { teamId } = req.params;
            const { user_id } = req.body;

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            const success = await TeamMember.removeMember(teamId, user_id);

            if (success) {
                res.json({
                    success: true,
                    message: '已成功离开学习小组'
                });
            } else {
                res.status(400).json({
                    success: false,
                    message: '您不在该学习小组中'
                });
            }
        } catch (error) {
            console.error('离开小组错误:', error);
            res.status(500).json({
                success: false,
                message: '离开学习小组失败: ' + error.message
            });
        }
    },

    // 更新小组信息
    updateTeam: async (req, res) => {
        try {
            const { teamId } = req.params;
            const { team_name, description, max_members, tags, user_id } = req.body;

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            const team = await StudyTeam.findById(teamId);
            if (!team) {
                return res.status(404).json({
                    success: false,
                    message: '学习小组不存在'
                });
            }

            // 检查权限
            if (team.creator_id !== parseInt(user_id)) {
                return res.status(403).json({
                    success: false,
                    message: '只有创建者才能更新小组信息'
                });
            }

            const success = await StudyTeam.update(teamId, {
                team_name,
                description,
                max_members,
                tags
            });

            if (success) {
                res.json({
                    success: true,
                    message: '学习小组更新成功'
                });
            } else {
                res.status(400).json({
                    success: false,
                    message: '学习小组更新失败'
                });
            }
        } catch (error) {
            console.error('更新小组错误:', error);
            res.status(500).json({
                success: false,
                message: '更新学习小组失败: ' + error.message
            });
        }
    },

    // 删除小组
    deleteTeam: async (req, res) => {
        try {
            const { teamId } = req.params;
            const { user_id } = req.body;

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            // 1. 检查小组是否存在
            const [teamExists] = await execute(
                'SELECT team_id, creator_id FROM study_team WHERE team_id = ?',
                [teamId]
            );

            if (teamExists.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: '学习小组不存在'
                });
            }

            const team = teamExists[0];

            // 2. 检查当前用户是否为创建者
            if (team.creator_id !== parseInt(user_id)) {
                return res.status(403).json({
                    success: false,
                    message: '只有创建者才能删除小组'
                });
            }

            // 3. 先删除相关的任务记录
            await execute(
                'DELETE FROM team_task WHERE team_id = ?',
                [teamId]
            );

            // 4. 删除小组成员记录
            await execute(
                'DELETE FROM team_member WHERE team_id = ?',
                [teamId]
            );

            // 5. 删除小组
            const [result] = await execute(
                'DELETE FROM study_team WHERE team_id = ?',
                [teamId]
            );

            if (result.affectedRows > 0) {
                res.json({
                    success: true,
                    message: '学习小组删除成功'
                });
            } else {
                res.status(404).json({
                    success: false,
                    message: '学习小组不存在'
                });
            }
        } catch (error) {
            console.error('删除小组错误:', error);
            res.status(500).json({
                success: false,
                message: '删除学习小组失败: ' + error.message
            });
        }
    },

    // 获取用户加入的小组
    getUserTeams: async (req, res) => {
        try {
            const { userId } = req.params;
            
            if (!userId) {
                return res.status(400).json({
                    success: false,
                    message: '用户ID为必填项'
                });
            }

            const teams = await TeamMember.getUserTeams(userId);

            res.json({
                success: true,
                data: teams
            });
        } catch (error) {
            console.error('获取用户小组错误:', error);
            res.status(500).json({
                success: false,
                message: '获取用户小组失败: ' + error.message
            });
        }
    }
};

module.exports = teamController;