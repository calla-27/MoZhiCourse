// models/Course.js
const { pool } = require('../config/database');

class Course {
  // 获取课程详情（包含讲师完整信息）
  static async getById(courseId) {
    const [courses] = await pool.execute(
      `SELECT 
        c.course_id,
        c.course_name,
        c.course_desc,
        c.cover_img,
        c.difficulty_level,
        c.course_duration,
        c.is_online,
        c.created_time,
        c.student_count,
        c.rating,
        c.rating_count,
        c.category_id,
        u.user_id as teacher_user_id,
        u.user_name as teacher_name,
        u.user_intro as teacher_intro,
        u.occupation as teacher_occupation,
        u.avatar_url as teacher_avatar,
        cc.category_name
       FROM t_course c
       LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
       LEFT JOIN t_course_category cc ON c.category_id = cc.category_id
       WHERE c.course_id = ?`,
      [courseId]
    );
    return courses[0];
  }

  // 获取所有课程
  static async getAll() {
    const [courses] = await pool.execute(
      `SELECT 
        c.course_id, 
        c.course_name, 
        c.course_desc, 
        c.cover_img,
        c.difficulty_level,
        c.created_time,
        u.user_name as teacher_name,
        COUNT(DISTINCT ld.user_id) as student_count
       FROM t_course c
       LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
       LEFT JOIN t_learning_detail ld ON c.course_id = ld.course_id
       GROUP BY c.course_id
       ORDER BY c.created_time DESC`
    );
    return courses;
  }

  // 搜索课程
  static async search(keyword) {
    const [courses] = await pool.execute(
      `SELECT 
        c.course_id, 
        c.course_name, 
        c.course_desc, 
        c.cover_img,
        c.difficulty_level,
        c.created_time,
        u.user_name as teacher_name,
        COUNT(DISTINCT ld.user_id) as student_count
       FROM t_course c
       LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
       LEFT JOIN t_learning_detail ld ON c.course_id = ld.course_id
       WHERE c.course_name LIKE ? OR c.course_desc LIKE ?
       GROUP BY c.course_id
       ORDER BY c.created_time DESC`,
      [`%${keyword}%`, `%${keyword}%`]
    );
    return courses;
  }

  static async getStats(courseId) {
    const [[participantRow]] = await pool.execute(
      `SELECT COUNT(DISTINCT user_id) AS participatingUsers
       FROM t_learning_detail
       WHERE course_id = ?`,
      [courseId]
    );

    const [[commentRow]] = await pool.execute(
      `SELECT COUNT(*) AS totalComments
       FROM t_video_comment vc
       LEFT JOIN t_course_video cv ON vc.video_id = cv.video_id
       LEFT JOIN t_course_chapter cc ON cv.chapter_id = cc.chapter_id
       WHERE cc.course_id = ?`,
      [courseId]
    );

    const participatingUsers = participantRow?.participatingUsers ?? 0;
    const totalComments = commentRow?.totalComments ?? 0;

    return {
      participatingUsers,
      totalComments,
    };
  }

  // 查询用户是否收藏某课程
  static async getFavoriteStatus(userId, courseId) {
    const [rows] = await pool.execute(
      `SELECT is_favorite
       FROM t_user_course
       WHERE user_id = ? AND course_id = ?`,
      [userId, courseId]
    );

    if (!rows.length) return false;
    return rows[0].is_favorite === 1;
  }

  // 设置用户课程收藏状态
  static async setFavoriteStatus(userId, courseId, isFavorite) {
    // 先尝试更新，如果没有记录再插入
    const [result] = await pool.execute(
      `UPDATE t_user_course
       SET is_favorite = ?, updated_at = CURRENT_TIMESTAMP
       WHERE user_id = ? AND course_id = ?`,
      [isFavorite ? 1 : 0, userId, courseId]
    );

    if (result.affectedRows === 0) {
      await pool.execute(
        `INSERT INTO t_user_course (user_id, course_id, is_favorite, enroll_time, created_at, updated_at)
         VALUES (?, ?, ?, NOW(), NOW(), NOW())`,
        [userId, courseId, isFavorite ? 1 : 0]
      );
    }

    return isFavorite;
  }

  // 获取课程评价（优先从课程评价表获取，如果没有则聚合视频评论）
  static async getCourseReviews(courseId, limit = 10) {
    // 先尝试从课程评价表获取
    try {
      const [courseReviews] = await pool.execute(
        `SELECT 
          cr.review_id as comment_id,
          cr.review_content as comment_content,
          cr.rating,
          cr.created_time,
          u.user_id,
          u.user_name,
          u.occupation,
          u.avatar_url
         FROM t_course_review cr
         INNER JOIN t_user u ON cr.user_id = u.user_id
         WHERE cr.course_id = ?
         ORDER BY cr.created_time DESC
         LIMIT ?`,
        [courseId, limit]
      );
      
      if (courseReviews.length > 0) {
        return courseReviews;
      }
    } catch (err) {
      console.log('课程评价表不存在，尝试从视频评论聚合');
    }
    
    // 如果课程评价表没有数据，从视频评论聚合
    const [reviews] = await pool.execute(
      `SELECT 
        vc.comment_id,
        vc.comment_content,
        vc.created_time,
        u.user_id,
        u.user_name,
        u.occupation,
        u.avatar_url
       FROM t_video_comment vc
       INNER JOIN t_course_video cv ON vc.video_id = cv.video_id
       INNER JOIN t_course_chapter cc ON cv.chapter_id = cc.chapter_id
       INNER JOIN t_user u ON vc.user_id = u.user_id
       WHERE cc.course_id = ?
       ORDER BY vc.created_time DESC
       LIMIT ?`,
      [courseId, limit]
    );
    return reviews;
  }

  // 提交课程评价
  static async submitCourseReview(userId, courseId, rating, reviewContent) {
    const [result] = await pool.execute(
      `INSERT INTO t_course_review (user_id, course_id, rating, review_content, created_time)
       VALUES (?, ?, ?, ?, NOW())`,
      [userId, courseId, rating, reviewContent]
    );
    return result.insertId;
  }

  // 获取相关课程推荐（同分类的其他课程）
  static async getRelatedCourses(courseId, categoryId, limit = 4) {
    const [courses] = await pool.execute(
      `SELECT 
        c.course_id,
        c.course_name,
        c.course_desc,
        c.cover_img,
        c.difficulty_level,
        c.rating,
        u.user_name as teacher_name,
        c.student_count
       FROM t_course c
       LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
       WHERE c.category_id = ? AND c.course_id != ? AND c.is_online = 1
       ORDER BY c.rating DESC, c.student_count DESC
       LIMIT ?`,
      [categoryId, courseId, limit]
    );
    return courses;
  }
}

module.exports = Course;