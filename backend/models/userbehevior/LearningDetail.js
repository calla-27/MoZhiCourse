const { pool } = require('../config/database');

class LearningDetail {
  // 记录学习详情
  static async recordLearningDetail(learningData) {
    const {
      userId,
      courseId,
      videoId,
      learnDuration,
      playSpeed = 1.00,
      pauseCount = 0,
      completeRate = 0.00,
      currentPosition = 0
    } = learningData;

    const sql = `
      INSERT INTO learning_detail 
        (user_id, course_id, video_id, learn_time, learn_duration, play_speed, pause_count, complete_rate, current_position)
      VALUES (?, ?, ?, NOW(), ?, ?, ?, ?, ?)
    `;
    
    const params = [userId, courseId, videoId, learnDuration, playSpeed, pauseCount, completeRate, currentPosition];
    
    try {
      const [result] = await pool.execute(sql, params);
      return result.insertId;
    } catch (error) {
      console.error('记录学习详情失败:', error);
      throw error;
    }
  }

  // 更新学习进度
  static async updateLearningProgress(userId, courseId, videoId, progressData) {
    const {
      currentPosition,
      completeRate,
      learnDuration = 0
    } = progressData;

    // 先检查是否已存在记录
    const checkSql = `
      SELECT learn_id FROM learning_detail 
      WHERE user_id = ? AND course_id = ? AND video_id = ? 
      ORDER BY learn_time DESC LIMIT 1
    `;
    
    const [existing] = await pool.execute(checkSql, [userId, courseId, videoId]);
    
    if (existing.length > 0) {
      // 更新现有记录
      const updateSql = `
        UPDATE learning_detail 
        SET current_position = ?, complete_rate = ?, learn_duration = learn_duration + ?
        WHERE learn_id = ?
      `;
      await pool.execute(updateSql, [currentPosition, completeRate, learnDuration, existing[0].learn_id]);
    } else {
      // 创建新记录
      await this.recordLearningDetail({
        userId,
        courseId,
        videoId,
        learnDuration,
        currentPosition,
        completeRate
      });
    }
  }

  // 获取用户视频学习进度
  static async getVideoProgress(userId, videoId) {
    const sql = `
      SELECT 
        current_position,
        complete_rate,
        learn_duration,
        learn_time
      FROM learning_detail 
      WHERE user_id = ? AND video_id = ? 
      ORDER BY learn_time DESC 
      LIMIT 1
    `;
    
    const [rows] = await pool.execute(sql, [userId, videoId]);
    return rows.length > 0 ? rows[0] : null;
  }

  // 获取用户课程学习统计
  static async getCourseLearningStats(userId, courseId) {
    const sql = `
      SELECT 
        video_id,
        MAX(complete_rate) as max_complete_rate,
        SUM(learn_duration) as total_learn_duration,
        MAX(learn_time) as last_learn_time
      FROM learning_detail 
      WHERE user_id = ? AND course_id = ?
      GROUP BY video_id
    `;
    
    const [rows] = await pool.execute(sql, [userId, courseId]);
    return rows;
  }
}

module.exports = LearningDetail;