const express = require('express');
const router = express.Router();
const personalCenterController = require('../controllers/personalCenterController');
const { authMiddleware } = require('../middleware/auth');
const StudentService = require('../services/studentService');

// 获取用户个人信息
router.get('/profile', authMiddleware, personalCenterController.getUserProfile);

// 更新用户信息
router.put('/profile', authMiddleware, personalCenterController.updateUserProfile);

// 获取用户课程列表
router.get('/courses', authMiddleware, async (req, res) => {
  try {
    const { status } = req.query;
    const courses = await StudentService.getEnrolledCourses(req.user.userId, status);
    res.json({ success: true, data: courses });
  } catch (error) {
    console.error('获取课程列表失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
});

// 获取学习统计
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    const stats = await StudentService.getLearningStats(req.user.userId);
    res.json({ success: true, data: stats });
  } catch (error) {
    console.error('获取学习统计失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
});

// 获取收藏课程
router.get('/favorites', authMiddleware, async (req, res) => {
  try {
    const courses = await StudentService.getFavoriteCourses(req.user.userId);
    res.json({ success: true, data: courses });
  } catch (error) {
    console.error('获取收藏课程失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
});

// 切换收藏状态
router.post('/favorites/:courseId/toggle', authMiddleware, async (req, res) => {
  try {
    const result = await StudentService.toggleFavorite(req.user.userId, req.params.courseId);
    res.json({ success: true, data: result });
  } catch (error) {
    console.error('切换收藏失败:', error);
    res.status(400).json({ success: false, message: error.message });
  }
});

// 报名课程
router.post('/enroll/:courseId', authMiddleware, async (req, res) => {
  try {
    const result = await StudentService.enrollCourse(req.user.userId, req.params.courseId);
    res.json({ success: true, data: result });
  } catch (error) {
    console.error('报名课程失败:', error);
    res.status(400).json({ success: false, message: error.message });
  }
});

// 获取成就列表
router.get('/achievements', authMiddleware, async (req, res) => {
  try {
    const achievements = await StudentService.getAchievements(req.user.userId);
    res.json({ success: true, data: achievements });
  } catch (error) {
    console.error('获取成就列表失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
});

// 获取推荐课程
router.get('/recommendations', authMiddleware, async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    const courses = await StudentService.getRecommendedCourses(req.user.userId, parseInt(limit));
    res.json({ success: true, data: courses });
  } catch (error) {
    console.error('获取推荐课程失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
});

// 获取社区数据
router.get('/community', authMiddleware, personalCenterController.getCommunityData);

module.exports = router;
