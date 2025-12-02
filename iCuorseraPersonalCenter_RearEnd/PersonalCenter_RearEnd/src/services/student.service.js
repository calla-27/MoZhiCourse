import { pool } from '../config/database.js';
import CommunityModel from '../models/community.model.js';
import AchievementModel from '../models/achievement.model.js';

class StudentService {
 // 获取学习统计数据（从实际数据计算）
  static async getLearningStats(userId) {
    const [enrollmentStats] = await pool.query(
      `SELECT 
        COUNT(*) as total_courses,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as courses_completed,
        SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as courses_in_progress
      FROM t_user_enrollment 
      WHERE user_id = ?`,
      [userId]
    );

    // 从学习详情表计算总学习时长
    const [learningTime] = await pool.query(
      `SELECT 
        COALESCE(SUM(learn_duration), 0) as total_seconds
      FROM t_learning_detail 
      WHERE user_id = ?`,
      [userId]
    );

    const totalHours = Math.floor(learningTime[0].total_seconds / 3600);

    // 计算连续学习天数（简化版，需要更复杂的逻辑）
    const [continuousDays] = await pool.query(
      `SELECT COUNT(DISTINCT DATE(learn_time)) as days
      FROM t_learning_detail 
      WHERE user_id = ?
      AND learn_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)`,
      [userId]
    );

    return {
      total_learning_hours: totalHours,
      courses_completed: enrollmentStats[0].courses_completed || 0,
      courses_in_progress: enrollmentStats[0].courses_in_progress || 0,
      total_courses: enrollmentStats[0].total_courses || 0,
      continuous_days: continuousDays[0].days || 0
    };
  }

  // 获取正在学习的课程
  static async getEnrolledCourses(userId, status = null) {
    let query = `
      SELECT 
        e.enrollment_id,
        e.learn_progress,
        e.status,
        e.enroll_time,
        c.course_id,
        c.course_name,
        c.cover_img,
        c.difficulty_level,
        c.course_duration,
        cc.category_name,
        u.user_name as teacher_name
      FROM t_user_enrollment e
      JOIN t_course c ON e.course_id = c.course_id
      LEFT JOIN t_course_category cc ON c.category_id = cc.category_id
      LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
      WHERE e.user_id = ?
    `;

    const params = [userId];

    if (status) {
      query += ' AND e.status = ?';
      params.push(status);
    }

    query += ' ORDER BY e.enroll_time DESC';

    const [courses] = await pool.query(query, params);
    return courses;
  }

  // 获取收藏的课程
  static async getFavoriteCourses(userId) {
    const [courses] = await pool.query(
      `SELECT 
        f.favorite_id,
        f.create_time,
        c.course_id,
        c.course_name,
        c.cover_img,
        c.difficulty_level,
        cc.category_name,
        u.user_name as teacher_name
      FROM t_user_favorite f
      JOIN t_course c ON f.course_id = c.course_id
      LEFT JOIN t_course_category cc ON c.category_id = cc.category_id
      LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
      WHERE f.user_id = ?
      ORDER BY f.create_time DESC`,
      [userId]
    );
    return courses;
  }

  // 添加收藏
  static async addFavorite(userId, courseId) {
    try {
      await pool.query(
        'INSERT INTO t_user_favorite (user_id, course_id) VALUES (?, ?)',
        [userId, courseId]
      );
      return { message: '收藏成功' };
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        throw new Error('已经收藏过该课程');
      }
      throw error;
    }
  }

  // 取消收藏
  static async removeFavorite(userId, courseId) {
    const [result] = await pool.query(
      'DELETE FROM t_user_favorite WHERE user_id = ? AND course_id = ?',
      [userId, courseId]
    );

    if (result.affectedRows === 0) {
      throw new Error('收藏记录不存在');
    }

    return { message: '取消收藏成功' };
  }

  // 报名课程
  static async enrollCourse(userId, courseId) {
    try {
      await pool.query(
        'INSERT INTO t_user_enrollment (user_id, course_id) VALUES (?, ?)',
        [userId, courseId]
      );
      return { message: '报名成功' };
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        throw new Error('已经报名过该课程');
      }
      throw error;
    }
  }

  // 更新学习进度
  static async updateProgress(userId, courseId, progress) {
    const [result] = await pool.query(
      `UPDATE t_user_enrollment 
       SET learn_progress = ?,
           status = CASE WHEN ? >= 100 THEN 'completed' ELSE 'in_progress' END
       WHERE user_id = ? AND course_id = ?`,
      [progress, progress, userId, courseId]
    );

    if (result.affectedRows === 0) {
      throw new Error('未找到报名记录');
    }

    return { message: '进度更新成功', progress };
  }

  // ==================== 新增功能 ====================

  /**
   * 获取社区相关数据
   * 
   * 功能说明：
   * 1. 获取用户参与的学习组队
   * 2. 获取用户加入的自习室
   * 3. 获取所有可用的组队（供用户浏览和加入）
   * 4. 获取所有可用的自习室（供用户浏览和加入）
   * 
   * @param {number} userId - 用户ID
   * @returns {Object} 社区数据对象
   */
  static async getCommunityData(userId) {
    // 1. 获取用户参与的组队
    // 调用 CommunityModel 的方法查询数据库
    const teams = await CommunityModel.findUserTeams(userId);
    
    // 2. 获取用户加入的自习室
    const rooms = await CommunityModel.findUserRooms(userId);
    
    // 3. 获取所有可用的组队（供浏览）
    const availableTeams = await CommunityModel.findAllTeams();
    
    // 4. 获取所有可用的自习室（供浏览）
    const availableRooms = await CommunityModel.findAllRooms();

    // 5. 返回整合后的数据
    return {
      // 我参与的组队
      my_teams: teams,
      
      // 我加入的自习室
      my_rooms: rooms,
      
      // 所有可加入的组队（包含成员数等信息）
      available_teams: availableTeams,
      
      // 所有可加入的自习室（包含在线人数等信息）
      available_rooms: availableRooms,
      
      // 统计信息
      stats: {
        teams_count: teams.length,      // 我参与的组队数量
        rooms_count: rooms.length        // 我加入的自习室数量
      }
    };
  }

  /**
   * 获取成就列表
   * 
   * 功能说明：
   * 1. 获取所有成就定义及用户的完成状态
   * 2. 按成就类型分组（学习类、社交类、其他）
   * 3. 统计用户已获得的成就数量和完成率
   * 
   * @param {number} userId - 用户ID
   * @returns {Object} 成就数据对象
   */
  static async getAchievements(userId) {
    // 1. 获取所有成就及用户完成状态
    // 这个方法会返回所有成就，并标记用户是否已获得
    const achievements = await AchievementModel.getUserAchievementProgress(userId);

    // 2. 按类型分组
    const grouped = {
      learning: [],  // 学习类成就（如：连续学习7天、完成10门课程等）
      social: [],    // 社交类成就（如：加入5个组队、邀请3个好友等）
      other: []      // 其他类型成就
    };

    // 遍历所有成就，根据类型分类
    achievements.forEach(achievement => {
      const type = achievement.achievement_type || 'other';
      
      // 如果该类型存在于分组对象中，添加到对应数组
      if (grouped[type]) {
        grouped[type].push(achievement);
      } else {
        // 如果是未知类型，放入 other 分类
        grouped.other.push(achievement);
      }
    });

    // 3. 统计已获得的成就数量
    const earnedCount = achievements.filter(a => a.is_earned === 1).length;
    const totalCount = achievements.length;

    // 4. 返回整合后的数据
    return {
      // 按类型分组的成就
      achievements: grouped,
      
      // 所有成就的平铺列表（方便前端使用）
      all_achievements: achievements,
      
      // 统计信息
      stats: {
        earned_count: earnedCount,                                          // 已获得成就数量
        total_count: totalCount,                                            // 总成就数量
        completion_rate: totalCount > 0 
          ? ((earnedCount / totalCount) * 100).toFixed(2)                   // 完成率（百分比）
          : 0
      }
    };
  }
}

export default StudentService;