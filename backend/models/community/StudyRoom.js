const { execute } = require('../../config/database');

class StudyRoom {
    // 创建自习室
    static async create(roomData) {
        const params = [
        roomData.room_name,
        roomData.description,
        roomData.creator_id,
        roomData.max_participants || 50,
        roomData.schedule_time || null,  
        roomData.tags ? JSON.stringify(roomData.tags) : '[]',
        roomData.rules || null        
    ];

    console.log('创建自习室SQL参数:', params);
    
        const [result] = await execute(
            'INSERT INTO study_room (room_name, description, creator_id, max_participants, schedule_time, tags, rules) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [roomData.room_name, roomData.description, roomData.creator_id, roomData.max_participants, roomData.schedule_time, JSON.stringify(roomData.tags), roomData.rules]
        );
        return result.insertId;
    }

    // 获取自习室列表
    static async findAll() {
        const [rows] = await execute(`
            SELECT sr.*, u.user_name as creator_name,
                   COUNT(rm.member_id) as online_count
            FROM study_room sr
            LEFT JOIN user u ON sr.creator_id = u.user_id
            LEFT JOIN room_member rm ON sr.room_id = rm.room_id AND rm.leave_time IS NULL
            WHERE sr.status = 'open'
            GROUP BY sr.room_id
            ORDER BY sr.create_time DESC
        `);
        return rows;
    }

    // 加入自习室
    static async joinRoom(roomId, userId) {
        // 检查是否已经在自习室中
        const [existing] = await execute(
            'SELECT * FROM room_member WHERE room_id = ? AND user_id = ? AND leave_time IS NULL',
            [roomId, userId]
        );

        if (existing.length > 0) {
            throw new Error('用户已在自习室中');
        }

        const [result] = await execute(
            'INSERT INTO room_member (room_id, user_id) VALUES (?, ?)',
            [roomId, userId]
        );

        // 更新自习室当前人数
        await execute(
            'UPDATE study_room SET current_participants = current_participants + 1 WHERE room_id = ?',
            [roomId]
        );

        return result.insertId;
    }
}

module.exports = StudyRoom;