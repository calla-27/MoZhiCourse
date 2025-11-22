// routes/courses.js
const express = require('express');
const router = express.Router();
const CourseController = require('../controllers/courseController');
const VideoController = require('../controllers/videoController');

// 课程相关路由
router.get('/', CourseController.getAllCourses);
router.get('/:courseId', CourseController.getCourse);
router.get('/:courseId/chapters', CourseController.getChapters);

// 视频相关路由
router.get('/video/:videoId', VideoController.getVideo);
router.get('/video/:videoId/progress', VideoController.getProgress);
router.post('/video/progress', VideoController.updateProgress);
router.post('/video/behavior', VideoController.recordBehavior);

module.exports = router;