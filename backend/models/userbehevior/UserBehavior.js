const { pool } = require('../config/database');

class UserBehavior {
  // 记录用户行为
  static async recordBehavior(behaviorData) {
    const {
      userId,
      courseId,
      videoId,
      behaviorType,
      currentTime = 0,
      playSpeed = 1.00,
      stayDuration = 0,
      keyword = null
    } = behaviorData;

    const sql = `
      INSERT INTO user_behavior 
        (user_id, course_id, video_id, behavior_type, keyword, behavior_time, stay_duration, current_time, play_speed)
      VALUES (?, ?, ?, ?, ?, NOW(), ?, ?, ?)
    `;
    
    const params = [userId, courseId, videoId, behaviorType, keyword, stayDuration, currentTime, playSpeed];
    
    try {
      const [result] = await pool.execute(sql, params);
      return result.insertId;
    } catch (error) {
      console.error('记录用户行为失败:', error);
      throw error;
    }
  }

  // 获取用户的学习行为统计
  static async getUserBehaviorStats(userId, courseId = null) {
    let sql = `
      SELECT 
        behavior_type,
        COUNT(*) as count,
        MAX(behavior_time) as last_time
      FROM user_behavior 
      WHERE user_id = ?
    `;
    
    const params = [userId];
    
    if (courseId) {
      sql += ' AND course_id = ?';
      params.push(courseId);
    }
    
    sql += ' GROUP BY behavior_type';
    
    const [rows] = await pool.execute(sql, params);
    return rows;
  }
}

module.exports = UserBehavior;