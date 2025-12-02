import { pool } from '../config/database.js';

class AchievementModel {
  // 获取所有成就定义
  static async findAll() {
    const [rows] = await pool.query(
      `SELECT 
        achievement_id,
        name,
        description,
        icon_class,
        achievement_type,
        required_value,
        created_time
      FROM t_achievement
      ORDER BY achievement_type, achievement_id`
    );
    return rows;
  }

  // 获取用户已获得的成就
  static async findUserAchievements(userId) {
    const [rows] = await pool.query(
      `SELECT 
        a.achievement_id,
        a.name,
        a.description,
        a.icon_class,
        a.achievement_type,
        a.required_value,
        ua.earned_time,
        1 as is_earned
      FROM t_user_achievement ua
      JOIN t_achievement a ON ua.achievement_id = a.achievement_id
      WHERE ua.user_id = ?
      ORDER BY ua.earned_time DESC`,
      [userId]
    );
    return rows;
  }

  // 获取用户成就进度（所有成就+完成状态）
  static async getUserAchievementProgress(userId) {
    const [rows] = await pool.query(
      `SELECT 
        a.achievement_id,
        a.name,
        a.description,
        a.icon_class,
        a.achievement_type,
        a.required_value,
        ua.earned_time,
        CASE WHEN ua.user_achieve_id IS NOT NULL THEN 1 ELSE 0 END as is_earned
      FROM t_achievement a
      LEFT JOIN t_user_achievement ua ON a.achievement_id = ua.achievement_id AND ua.user_id = ?
      ORDER BY is_earned DESC, a.achievement_type, a.achievement_id`,
      [userId]
    );
    return rows;
  }

  // 检查用户是否已获得某个成就
  static async checkUserAchievement(userId, achievementId) {
    const [rows] = await pool.query(
      'SELECT user_achieve_id FROM t_user_achievement WHERE user_id = ? AND achievement_id = ?',
      [userId, achievementId]
    );
    return rows.length > 0;
  }

  // 授予用户成就
  static async grantAchievement(userId, achievementId) {
    try {
      const [result] = await pool.query(
        'INSERT INTO t_user_achievement (user_id, achievement_id) VALUES (?, ?)',
        [userId, achievementId]
      );
      return result.insertId;
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        throw new Error('该成就已获得');
      }
      throw error;
    }
  }
}

export default AchievementModel;