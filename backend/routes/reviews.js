// 课程评价路由
const express = require('express');
const router = express.Router();
const ReviewController = require('../controllers/reviewController');
const { authMiddleware } = require('../middleware/auth');

// 获取课程评价列表（公开）
router.get('/course/:courseId', ReviewController.getCourseReviews);

// 获取用户对课程的评价（需要登录）
router.get('/course/:courseId/user', authMiddleware, ReviewController.getUserReview);

// 添加课程评价（需要登录）
router.post('/course/:courseId', authMiddleware, ReviewController.addReview);

// 更新评价（需要登录）
router.put('/:reviewId', authMiddleware, ReviewController.updateReview);

// 删除评价（需要登录）
router.delete('/:reviewId', authMiddleware, ReviewController.deleteReview);

module.exports = router;