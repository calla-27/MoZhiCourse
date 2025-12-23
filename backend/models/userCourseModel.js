// models/UserCourseModel.js
const { pool } = require('../config/database');
const CourseStatsUpdater = require('../utils/courseStatsUpdater');

class UserCourseModel {
  // 获取用户课程关系
  static async getUserCourse(userId, courseId) {
    const [rows] = await pool.execute(
      `SELECT * FROM user_course WHERE user_id = ? AND course_id = ?`,
      [userId, courseId]
    );
    return rows[0];
  }

  // 用户报名课程
  static async enrollCourse(userId, courseId) {
    const existing = await this.getUserCourse(userId, courseId);
    if (existing) {
      return existing;
    }

    const [result] = await pool.execute(
      `INSERT INTO user_course (user_id, course_id, enroll_time) VALUES (?, ?, NOW())`,
      [userId, courseId]
    );

    // 实时更新课程统计数据
    await CourseStatsUpdater.onStudentEnroll(courseId, userId);

    return { id: result.insertId, user_id: userId, course_id: courseId };
  }

  // 获取用户的课程列表
  static async getUserCourses(userId, options = {}) {
    const {
      status = 'all', // all, learning, completed, favorite
      page = 1,
      limit = 10,
      search = ''
    } = options;

    const offset = (page - 1) * limit;
    let whereClause = 'uc.user_id = ?';
    const params = [userId];

    if (status === 'learning') {
      whereClause += ' AND uc.progress > 0 AND uc.progress < 100 AND uc.is_completed = 0';
    } else if (status === 'completed') {
      whereClause += ' AND uc.is_completed = 1';
    } else if (status === 'favorite') {
      whereClause += ' AND uc.is_favorite = 1';
    }

    if (search) {
      whereClause += ' AND (c.course_name LIKE ? OR c.course_desc LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    // 获取课程列表
    const [courses] = await pool.execute(
      `SELECT 
        uc.*,
        c.course_name,
        c.course_desc,
        c.cover_img,
        c.difficulty_level,
        c.course_duration,
        c.rating as course_rating,
        c.rating_count,
        c.student_count,
        u.user_name as teacher_name,
        u.avatar_url as teacher_avatar,
        cc.chapter_title as last_chapter_title,
        cv.video_title as last_video_title,
        -- 计算最近学习时间
        CASE 
          WHEN uc.last_learn_time IS NOT NULL THEN uc.last_learn_time
          ELSE uc.enroll_time
        END as recent_time
       FROM user_course uc
       LEFT JOIN course c ON uc.course_id = c.course_id
       LEFT JOIN user u ON c.teacher_user_id = u.user_id
       LEFT JOIN course_chapter cc ON uc.last_chapter_id = cc.chapter_id
       LEFT JOIN course_video cv ON uc.last_video_id = cv.video_id
       WHERE ${whereClause}
       ORDER BY recent_time DESC
       LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    // 获取总数
    const [countRows] = await pool.execute(
      `SELECT COUNT(*) as total 
       FROM user_course uc
       LEFT JOIN course c ON uc.course_id = c.course_id
       WHERE ${whereClause}`,
      params
    );

    return {
      courses,
      pagination: {
        total: countRows[0]?.total || 0,
        page,
        limit,
        totalPages: Math.ceil((countRows[0]?.total || 0) / limit)
      }
    };
  }

  // 更新学习进度
  static async updateProgress(userId, courseId, progressData) {
    const {
      progress,
      lastChapterId,
      lastVideoId,
      learnDuration = 0
    } = progressData;

    const updateFields = [];
    const updateValues = [];

    if (progress !== undefined) {
      updateFields.push('progress = ?');
      updateValues.push(progress);
      
      // 如果进度达到100%，标记为已完成
      if (progress >= 100) {
        updateFields.push('is_completed = 1');
        updateFields.push('completed_time = NOW()');
      }
    }

    if (lastChapterId !== undefined) {
      updateFields.push('last_chapter_id = ?');
      updateValues.push(lastChapterId);
    }

    if (lastVideoId !== undefined) {
      updateFields.push('last_video_id = ?');
      updateValues.push(lastVideoId);
    }

    if (learnDuration > 0) {
      updateFields.push('total_learn_duration = total_learn_duration + ?');
      updateValues.push(learnDuration);
      console.log(`📚 累加学习时长: +${learnDuration}秒`);
    }

    updateFields.push('last_learn_time = NOW()');
    updateFields.push('updated_at = NOW()');

    if (updateFields.length === 0) {
      return false;
    }

    const [result] = await pool.execute(
      `UPDATE user_course 
       SET ${updateFields.join(', ')}
       WHERE user_id = ? AND course_id = ?`,
      [...updateValues, userId, courseId]
    );

    return result.affectedRows > 0;
  }

  // 切换收藏状态
  static async toggleFavorite(userId, courseId, isFavorite = null) {
    // 如果未指定状态，则取反当前状态
    if (isFavorite === null) {
      const current = await this.getUserCourse(userId, courseId);
      if (!current) {
        // 如果课程关系不存在，先创建
        await this.enrollCourse(userId, courseId);
        isFavorite = true;
      } else {
        isFavorite = !current.is_favorite;
      }
    }

    const [result] = await pool.execute(
      `UPDATE user_course 
       SET is_favorite = ?, updated_at = NOW()
       WHERE user_id = ? AND course_id = ?`,
      [isFavorite ? 1 : 0, userId, courseId]
    );

    return isFavorite;
  }

  // 删除用户课程（取消报名）
  static async deleteUserCourse(userId, courseId) {
    const [result] = await pool.execute(
      `DELETE FROM user_course WHERE user_id = ? AND course_id = ?`,
      [userId, courseId]
    );

    if (result.affectedRows > 0) {
      // 实时更新课程统计数据
      await CourseStatsUpdater.onStudentUnenroll(courseId, userId);
    }

    return result.affectedRows > 0;
  }

  // 新增方法：获取用户所有已报名课程（简化的版本，用于学情分析）
  static async getAllEnrolledCourses(userId) {
    try {
      const [courses] = await pool.execute(
        `SELECT 
          uc.course_id,
          c.course_name,
          c.course_desc,
          c.cover_img,
          c.difficulty_level,
          c.category_id,
          cc.category_name,
          uc.progress,
          uc.last_learn_time,
          uc.is_completed,
          uc.is_favorite,
          uc.total_learn_duration,
          -- 从student_course_performance获取学习行为数据
          scp.completion_rate,
          scp.mastery_level,
          scp.efficiency_score,
          scp.avg_focus_duration,
          -- 从student_learning_style获取学习风格
          sls.learning_style_type
        FROM user_course uc
        LEFT JOIN course c ON uc.course_id = c.course_id
        LEFT JOIN course_category cc ON c.category_id = cc.category_id
        LEFT JOIN student_course_performance scp ON uc.user_id = scp.user_id AND uc.course_id = scp.course_id
        LEFT JOIN student_learning_style sls ON uc.user_id = sls.user_id
        WHERE uc.user_id = ? AND uc.is_enrolled = 1
        ORDER BY uc.last_learn_time DESC, uc.enroll_time DESC`,
        [userId]
      );
      
      return courses;
    } catch (error) {
      console.error('获取用户已报名课程失败:', error);
      throw error;
    }
  }

  // 获取用户的学习统计
  static async getUserLearningStats(userId) {
    const [stats] = await pool.execute(
      `SELECT 
        COUNT(*) as total_courses,
        SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_courses,
        SUM(CASE WHEN is_favorite = 1 THEN 1 ELSE 0 END) as favorite_courses,
        SUM(progress) as total_progress_sum,
        SUM(total_learn_duration) as total_learn_duration,
        AVG(CASE WHEN progress > 0 THEN progress ELSE NULL END) as avg_progress,
        MAX(last_learn_time) as last_learn_time
       FROM user_course 
       WHERE user_id = ?`,
      [userId]
    );

    const [recentCourses] = await pool.execute(
      `SELECT 
        uc.course_id,
        c.course_name,
        uc.progress,
        uc.last_learn_time
       FROM user_course uc
       LEFT JOIN course c ON uc.course_id = c.course_id
       WHERE uc.user_id = ? AND uc.last_learn_time IS NOT NULL
       ORDER BY uc.last_learn_time DESC
       LIMIT 5`,
      [userId]
    );

    const [activityData] = await pool.execute(
      `SELECT 
        DATE(last_learn_time) as learn_date,
        COUNT(*) as learn_count,
        SUM(total_learn_duration) as total_duration
       FROM user_course 
       WHERE user_id = ? AND last_learn_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
       GROUP BY DATE(last_learn_time)
       ORDER BY learn_date DESC`,
      [userId]
    );

    return {
      ...stats[0],
      recent_courses: recentCourses,
      activity_data: activityData,
      // 计算连续学习天数
      continuous_days: await this.calculateContinuousDays(userId)
    };
  }

  // 计算连续学习天数
  static async calculateContinuousDays(userId) {
    const [days] = await pool.execute(
      `WITH RECURSIVE dates AS (
        SELECT CURDATE() as date
        UNION ALL
        SELECT DATE_SUB(date, INTERVAL 1 DAY)
        FROM dates
        WHERE date >= CURDATE() - INTERVAL 30 DAY
      )
      SELECT COUNT(DISTINCT DATE(uc.last_learn_time)) as continuous_days
      FROM dates d
      LEFT JOIN user_course uc ON DATE(uc.last_learn_time) = d.date AND uc.user_id = ?
      WHERE d.date <= CURDATE()
      ORDER BY d.date DESC
      LIMIT 1`,
      [userId]
    );

    return days[0]?.continuous_days || 0;
  }

  // 获取用户收藏的课程
  static async getUserFavorites(userId, options = {}) {
    return this.getUserCourses(userId, { ...options, status: 'favorite' });
  }

  // 批量更新课程进度
  static async batchUpdateProgress(userId, progressUpdates) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();

      for (const update of progressUpdates) {
        const { courseId, ...progressData } = update;
        await this.updateProgress(userId, courseId, progressData);
      }

      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }
}

module.exports = UserCourseModel;