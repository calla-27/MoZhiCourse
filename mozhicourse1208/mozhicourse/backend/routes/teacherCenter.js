const express = require('express');
const router = express.Router();
const teacherCenterController = require('../controllers/teacherCenterController');
const personalCenterController = require('../controllers/personalCenterController');
const { authMiddleware, checkRole } = require('../middleware/auth');
const { uploadAvatar } = require('../middleware/upload');

// 所有教师中心路由都需要教师权限
const requireTeacher = [authMiddleware, checkRole('instructor', 'teacher')];

// ==================== 教师信息相关 ====================
// 获取教师个人信息（复用个人中心的接口）
router.get('/profile', authMiddleware, personalCenterController.getUserProfile);

// 更新教师信息（复用个人中心的接口）
router.put('/profile', authMiddleware, personalCenterController.updateUserProfile);

// 上传头像（复用个人中心的接口）
router.post('/avatar', authMiddleware, uploadAvatar, personalCenterController.uploadAvatar);

// 修改密码（复用个人中心的接口）
router.put('/password', authMiddleware, personalCenterController.changePassword);

// ==================== 教师统计相关 ====================
// 获取教师统计数据
router.get('/stats', requireTeacher, teacherCenterController.getTeacherStats);

// ==================== 课程管理相关 ====================
// 获取教师课程列表
router.get('/courses', requireTeacher, teacherCenterController.getTeacherCourses);

// 创建新课程
router.post('/courses', requireTeacher, teacherCenterController.createCourse);

// 更新课程信息
router.put('/courses/:courseId', requireTeacher, teacherCenterController.updateCourse);

// 删除课程
router.delete('/courses/:courseId', requireTeacher, teacherCenterController.deleteCourse);

// ==================== 学生管理相关 ====================
// 获取课程学生列表
router.get('/courses/:courseId/students', requireTeacher, teacherCenterController.getCourseStudents);

module.exports = router;
