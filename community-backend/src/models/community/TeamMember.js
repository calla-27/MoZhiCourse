// src/models/community/TeamMember.js
const { execute } = require('../../config/database');

class TeamMember {
    // 添加小组成员
    static async addMember(teamId, userId, role = 'member') {
        const [result] = await execute(
            'INSERT INTO t_team_member (team_id, user_id, role, status) VALUES (?, ?, ?, ?)',
            [teamId, userId, role, 'active']
        );
        return result.insertId;
    }

    // 获取小组成员列表
    static async getTeamMembers(teamId) {
        const [rows] = await execute(`
            SELECT tm.*, u.user_name, u.avatar_url
            FROM t_team_member tm
            LEFT JOIN t_user u ON tm.user_id = u.user_id
            WHERE tm.team_id = ? AND tm.status = 'active'
            ORDER BY 
                CASE tm.role 
                    WHEN 'leader' THEN 1 
                    ELSE 2 
                END,
                tm.join_time
        `, [teamId]);
        return rows;
    }

    // 检查用户是否已在小组中
    static async isUserInTeam(teamId, userId) {
        const [rows] = await execute(
            'SELECT * FROM t_team_member WHERE team_id = ? AND user_id = ? AND status = "active"',
            [teamId, userId]
        );
        return rows.length > 0;
    }

    // 更新成员状态
    static async updateMemberStatus(teamId, userId, status) {
        const [result] = await execute(
            'UPDATE t_team_member SET status = ? WHERE team_id = ? AND user_id = ?',
            [status, teamId, userId]
        );
        return result.affectedRows > 0;
    }

    // 移除成员
    static async removeMember(teamId, userId) {
        const [result] = await execute(
            'DELETE FROM t_team_member WHERE team_id = ? AND user_id = ?',
            [teamId, userId]
        );
        return result.affectedRows > 0;
    }

    // 获取用户加入的小组
    static async getUserTeams(userId) {
        const [rows] = await execute(`
            SELECT st.*, tm.role, tm.join_time
            FROM t_team_member tm
            LEFT JOIN t_study_team st ON tm.team_id = st.team_id
            WHERE tm.user_id = ? AND tm.status = 'active' AND st.status = 'active'
            ORDER BY tm.join_time DESC
        `, [userId]);
        return rows;
    }
}

module.exports = TeamMember;