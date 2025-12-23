const pool = require('../config/database');
const CourseStatsUpdater = require('../utils/courseStatsUpdater');

class ReviewController {
  
  // 获取课程评价列表
  static async getCourseReviews(req, res) {
    try {
      const { courseId } = req.params;
      const { page = 1, limit = 10 } = req.query;
      const offset = (page - 1) * limit;
      
      console.log(`📝 获取课程 ${courseId} 的评价列表`);
      
      const [reviews] = await pool.execute(`
        SELECT 
          cr.review_id,
          cr.rating,
          cr.review_text,
          cr.created_time,
          u.user_name,
          u.avatar_url
        FROM course_review cr
        LEFT JOIN user u ON cr.user_id = u.user_id
        WHERE cr.course_id = ?
        ORDER BY cr.created_time DESC
        LIMIT ? OFFSET ?
      `, [courseId, parseInt(limit), offset]);
      
      // 获取总数
      const [countResult] = await pool.execute(`
        SELECT COUNT(*) as total FROM course_review WHERE course_id = ?
      `, [courseId]);
      
      const total = countResult[0]?.total || 0;
      
      res.json({
        success: true,
        data: reviews,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          totalPages: Math.ceil(total / limit)
        }
      });
      
    } catch (error) {
      console.error('获取课程评价失败:', error);
      res.status(500).json({
        success: false,
        message: '获取评价失败'
      });
    }
  }
  
  // 获取用户对课程的评价
  static async getUserReview(req, res) {
    try {
      const { courseId } = req.params;
      const userId = req.user.userId;
      
      console.log(`👤 获取用户 ${userId} 对课程 ${courseId} 的评价`);
      
      const [reviews] = await pool.execute(`
        SELECT 
          review_id,
          rating,
          review_text,
          created_time
        FROM course_review
        WHERE course_id = ? AND user_id = ?
      `, [courseId, userId]);
      
      res.json({
        success: true,
        data: reviews[0] || null
      });
      
    } catch (error) {
      console.error('获取用户评价失败:', error);
      res.status(500).json({
        success: false,
        message: '获取评价失败'
      });
    }
  }
  
  // 添加课程评价
  static async addReview(req, res) {
    try {
      const { courseId } = req.params;
      const userId = req.user.userId;
      const { rating, reviewContent } = req.body;
      
      console.log(`⭐ 用户 ${userId} 为课程 ${courseId} 添加评价: ${rating}星`);
      
      // 验证评分范围
      if (!rating || rating < 1 || rating > 5) {
        return res.status(400).json({
          success: false,
          message: '评分必须在1-5星之间'
        });
      }
      
      // 检查用户是否已经评价过
      const [existing] = await pool.execute(`
        SELECT review_id FROM course_review WHERE course_id = ? AND user_id = ?
      `, [courseId, userId]);
      
      if (existing.length > 0) {
        return res.status(400).json({
          success: false,
          message: '您已经评价过这门课程了'
        });
      }
      
      // 检查用户是否报名了该课程
      const [enrollment] = await pool.execute(`
        SELECT user_id FROM user_course WHERE course_id = ? AND user_id = ? AND is_enrolled = 1
      `, [courseId, userId]);
      
      if (enrollment.length === 0) {
        return res.status(400).json({
          success: false,
          message: '只有报名的学生才能评价课程'
        });
      }
      
      // 添加评价
      const [result] = await pool.execute(`
        INSERT INTO course_review (course_id, user_id, rating, review_text, created_time)
        VALUES (?, ?, ?, ?, NOW())
      `, [courseId, userId, rating, reviewContent || '']);
      
      // 实时更新课程统计数据
      await CourseStatsUpdater.onReviewAdded(courseId, userId, rating);
      
      res.json({
        success: true,
        message: '评价添加成功',
        data: {
          reviewId: result.insertId,
          rating,
          reviewContent
        }
      });
      
    } catch (error) {
      console.error('添加评价失败:', error);
      res.status(500).json({
        success: false,
        message: '添加评价失败'
      });
    }
  }
  
  // 更新评价
  static async updateReview(req, res) {
    try {
      const { reviewId } = req.params;
      const userId = req.user.userId;
      const { rating, reviewContent } = req.body;
      
      console.log(`📝 用户 ${userId} 更新评价 ${reviewId}`);
      
      // 验证评分范围
      if (!rating || rating < 1 || rating > 5) {
        return res.status(400).json({
          success: false,
          message: '评分必须在1-5星之间'
        });
      }
      
      // 检查评价是否存在且属于当前用户
      const [existing] = await pool.execute(`
        SELECT course_id FROM course_review WHERE review_id = ? AND user_id = ?
      `, [reviewId, userId]);
      
      if (existing.length === 0) {
        return res.status(404).json({
          success: false,
          message: '评价不存在或无权限修改'
        });
      }
      
      const courseId = existing[0].course_id;
      
      // 更新评价
      await pool.execute(`
        UPDATE course_review 
        SET rating = ?, review_text = ?, updated_time = NOW()
        WHERE review_id = ? AND user_id = ?
      `, [rating, reviewContent || '', reviewId, userId]);
      
      // 实时更新课程统计数据
      await CourseStatsUpdater.onReviewUpdated(courseId, userId, rating);
      
      res.json({
        success: true,
        message: '评价更新成功'
      });
      
    } catch (error) {
      console.error('更新评价失败:', error);
      res.status(500).json({
        success: false,
        message: '更新评价失败'
      });
    }
  }
  
  // 删除评价
  static async deleteReview(req, res) {
    try {
      const { reviewId } = req.params;
      const userId = req.user.userId;
      
      console.log(`🗑️ 用户 ${userId} 删除评价 ${reviewId}`);
      
      // 检查评价是否存在且属于当前用户
      const [existing] = await pool.execute(`
        SELECT course_id FROM course_review WHERE review_id = ? AND user_id = ?
      `, [reviewId, userId]);
      
      if (existing.length === 0) {
        return res.status(404).json({
          success: false,
          message: '评价不存在或无权限删除'
        });
      }
      
      const courseId = existing[0].course_id;
      
      // 删除评价
      await pool.execute(`
        DELETE FROM course_review WHERE review_id = ? AND user_id = ?
      `, [reviewId, userId]);
      
      // 实时更新课程统计数据
      await CourseStatsUpdater.onReviewDeleted(courseId, userId);
      
      res.json({
        success: true,
        message: '评价删除成功'
      });
      
    } catch (error) {
      console.error('删除评价失败:', error);
      res.status(500).json({
        success: false,
        message: '删除评价失败'
      });
    }
  }
}

module.exports = ReviewController;