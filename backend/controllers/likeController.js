// controllers/likeController.js
const { pool } = require('../config/database');

class LikeController {
  // 切换课程收藏状态（使用user_course表）
  static async toggleCourseFavorite(req, res) {
    try {
      const { courseId } = req.params;
      const userId = req.user.userId;

      console.log('切换收藏状态:', { userId, courseId });

      // 检查用户是否已报名该课程
      const [existing] = await pool.execute(
        'SELECT id, is_favorite FROM user_course WHERE user_id = ? AND course_id = ?',
        [userId, courseId]
      );

      let isFavorited = false;

      if (existing.length > 0) {
        // 用户已报名，切换收藏状态
        const currentFavorite = existing[0].is_favorite;
        isFavorited = currentFavorite === 0 ? 1 : 0;
        
        await pool.execute(
          'UPDATE user_course SET is_favorite = ? WHERE user_id = ? AND course_id = ?',
          [isFavorited, userId, courseId]
        );
        
        console.log('更新收藏状态:', isFavorited);
      } else {
        // 用户未报名，先创建报名记录并设置为收藏
        await pool.execute(
          'INSERT INTO user_course (user_id, course_id, is_favorite, is_enrolled) VALUES (?, ?, 1, 0)',
          [userId, courseId]
        );
        
        isFavorited = 1;
        console.log('创建收藏记录');
      }

      // 统计该课程的总收藏数
      const [countResult] = await pool.execute(
        'SELECT COUNT(*) as count FROM user_course WHERE course_id = ? AND is_favorite = 1',
        [courseId]
      );
      
      const favoriteCount = countResult[0].count;

      res.json({
        success: true,
        data: {
          isFavorited: isFavorited === 1,
          favoriteCount: favoriteCount
        }
      });
    } catch (error) {
      console.error('切换收藏状态失败:', error);
      res.status(500).json({
        success: false,
        message: '操作失败: ' + error.message
      });
    }
  }

  // 获取课程收藏状态（使用user_course表）
  static async getCourseFavoriteStatus(req, res) {
    try {
      const { courseId } = req.params;
      const userId = req.user.userId;

      console.log('获取收藏状态:', { userId, courseId });

      // 查询用户是否收藏了该课程
      const [favoriteData] = await pool.execute(
        'SELECT is_favorite FROM user_course WHERE user_id = ? AND course_id = ?',
        [userId, courseId]
      );

      // 统计该课程的总收藏数
      const [countResult] = await pool.execute(
        'SELECT COUNT(*) as count FROM user_course WHERE course_id = ? AND is_favorite = 1',
        [courseId]
      );

      const isFavorited = favoriteData.length > 0 && favoriteData[0].is_favorite === 1;
      const favoriteCount = countResult[0].count;

      console.log('收藏状态结果:', { isFavorited, favoriteCount });

      res.json({
        success: true,
        data: {
          isFavorited: isFavorited,
          favoriteCount: favoriteCount
        }
      });
    } catch (error) {
      console.error('获取收藏状态失败:', error);
      res.status(500).json({
        success: false,
        message: '获取失败: ' + error.message
      });
    }
  }

  // 点赞功能 - 使用course_like表
  static async toggleCourseLike(req, res) {
    try {
      const { courseId } = req.params;
      const userId = req.user.userId;

      console.log('👍 切换点赞状态:', { userId, courseId });

      // 检查是否已经点赞
      const [existing] = await pool.execute(
        'SELECT id FROM course_like WHERE user_id = ? AND course_id = ?',
        [userId, courseId]
      );

      let isLiked = false;

      if (existing.length > 0) {
        // 已点赞，取消点赞
        await pool.execute(
          'DELETE FROM course_like WHERE user_id = ? AND course_id = ?',
          [userId, courseId]
        );
        isLiked = false;
        console.log('✅ 取消点赞成功');
      } else {
        // 未点赞，添加点赞
        await pool.execute(
          'INSERT INTO course_like (user_id, course_id, created_at) VALUES (?, ?, NOW())',
          [userId, courseId]
        );
        isLiked = true;
        console.log('✅ 添加点赞成功');
      }

      // 统计该课程的总点赞数
      const [countResult] = await pool.execute(
        'SELECT COUNT(*) as count FROM course_like WHERE course_id = ?',
        [courseId]
      );
      
      const likeCount = countResult[0].count;

      const response = {
        success: true,
        data: {
          isLiked: isLiked,
          likeCount: likeCount
        }
      };

      console.log('👍 返回响应:', response);
      res.json(response);
    } catch (error) {
      console.error('❌ 切换点赞状态失败:', error);
      res.status(500).json({
        success: false,
        message: '操作失败: ' + error.message
      });
    }
  }

  // 获取点赞状态
  static async getCourseLikeStatus(req, res) {
    try {
      const { courseId } = req.params;
      const userId = req.user.userId;

      console.log('获取点赞状态:', { userId, courseId });

      // 查询用户是否点赞了该课程
      const [likeData] = await pool.execute(
        'SELECT id FROM course_like WHERE user_id = ? AND course_id = ?',
        [userId, courseId]
      );

      // 统计该课程的总点赞数
      const [countResult] = await pool.execute(
        'SELECT COUNT(*) as count FROM course_like WHERE course_id = ?',
        [courseId]
      );

      const isLiked = likeData.length > 0;
      const likeCount = countResult[0].count;

      console.log('点赞状态结果:', { isLiked, likeCount });

      res.json({
        success: true,
        data: {
          isLiked: isLiked,
          likeCount: likeCount
        }
      });
    } catch (error) {
      console.error('获取点赞状态失败:', error);
      res.status(500).json({
        success: false,
        message: '获取失败: ' + error.message
      });
    }
  }
}

module.exports = LikeController;
