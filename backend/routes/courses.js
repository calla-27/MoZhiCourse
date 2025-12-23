// routes/courses.js
const express = require('express');
const router = express.Router();
const CourseController = require('../controllers/courseController');
const VideoController = require('../controllers/coursevideo/videoController');
const LikeController = require('../controllers/likeController');
const { authMiddleware } = require('../middleware/auth');

// 课程相关路由
router.get('/search', CourseController.searchCourses);
router.get('/', CourseController.getAllCourses);
router.get('/:courseId', CourseController.getCourse);
router.get('/:courseId/chapters', CourseController.getChapters);
router.get('/:courseId/stats', CourseController.getStats);
router.get('/:courseId/favorite', authMiddleware, CourseController.getFavoriteStatus);
router.post('/:courseId/favorite', authMiddleware, CourseController.toggleFavorite);
router.get('/:courseId/reviews', CourseController.getCourseReviews);
router.post('/:courseId/reviews', authMiddleware, CourseController.submitCourseReview);
router.get('/:courseId/related', CourseController.getRelatedCourses);

// 点赞和收藏路由
router.get('/:courseId/like-status', authMiddleware, LikeController.getCourseLikeStatus);
router.post('/:courseId/like', authMiddleware, LikeController.toggleCourseLike);
router.get('/:courseId/favorite-status', authMiddleware, LikeController.getCourseFavoriteStatus);
router.post('/:courseId/favorite-toggle', authMiddleware, LikeController.toggleCourseFavorite);

// 视频相关路由
router.get('/video/:videoId', VideoController.getVideo);
router.get('/video/:videoId/progress', authMiddleware, VideoController.getProgress);
router.post('/video/progress', authMiddleware, VideoController.updateProgress);
// 确保行为记录路由正确配置
router.post('/video/behavior', authMiddleware, VideoController.recordBehavior);
// 添加批量记录路由
router.post('/video/behaviors/batch', authMiddleware, VideoController.recordBehaviorsBatch);

// 视频评论路由
const CommentController = require('../controllers/commentController');
router.get('/videos/:videoId/comments', CommentController.getComments);
router.post('/videos/:videoId/comments', authMiddleware, CommentController.postComment);
router.post('/comments/:commentId/like', authMiddleware, CommentController.likeComment);
router.delete('/comments/:commentId', authMiddleware, CommentController.deleteComment);

module.exports = router;