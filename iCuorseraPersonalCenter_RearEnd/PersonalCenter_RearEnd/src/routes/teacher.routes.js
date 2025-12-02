import express from 'express';
import { body, param, validationResult } from 'express-validator';
import { authenticate, requireRole } from '../middleware/auth.middleware.js';
import TeacherService from '../services/teacher.service.js';

const router = express.Router();

// 所有教师路由都需要认证和教师角色
router.use(authenticate);
router.use(requireRole('instructor'));

// ========== 统计相关路由 ==========

// 获取教学统计（放在最前面）
router.get('/stats', async (req, res) => {
  try {
    const stats = await TeacherService.getTeachingStats(req.user.userId);
    res.json({
      status: 'success',
      data: stats
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// ========== 课程相关路由（按具体到通用排序）==========

// 1. 获取课程的学生列表（最具体，包含 /students）
router.get('/courses/:courseId/students',
  [param('courseId').isInt().withMessage('课程ID必须是整数')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      const students = await TeacherService.getCourseStudents(
        req.user.userId,
        req.params.courseId
      );
      res.json({
        status: 'success',
        data: students
      });
    } catch (error) {
      res.status(403).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 2. 发布/下线课程（包含 /toggle）
router.patch('/courses/:courseId/toggle',
  [param('courseId').isInt().withMessage('课程ID必须是整数')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      const result = await TeacherService.toggleCourseStatus(
        req.user.userId,
        req.params.courseId
      );
      res.json({
        status: 'success',
        data: result
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 3. 更新课程信息（PUT /courses/:courseId）
router.put('/courses/:courseId',
  [
    param('courseId').isInt().withMessage('课程ID必须是整数'),
    body('course_name').optional().trim().notEmpty().withMessage('课程名称不能为空'),
    body('category_id').optional().isInt().withMessage('分类ID必须是整数'),
    body('difficulty_level').optional().isIn(['beginner', 'intermediate', 'advanced']).withMessage('难度级别无效'),
    body('course_duration').optional().isInt({ min: 0 }).withMessage('课程时长必须是正整数')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      const result = await TeacherService.updateCourse(
        req.user.userId,
        req.params.courseId,
        req.body
      );
      res.json({
        status: 'success',
        data: result
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 4. 删除课程（DELETE /courses/:courseId）
router.delete('/courses/:courseId',
  [param('courseId').isInt().withMessage('课程ID必须是整数')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      const result = await TeacherService.deleteCourse(
        req.user.userId,
        req.params.courseId
      );
      res.json({
        status: 'success',
        data: result
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 5. 获取我的课程列表（GET /courses）
router.get('/courses', async (req, res) => {
  try {
    const courses = await TeacherService.getCourses(req.user.userId);
    res.json({
      status: 'success',
      data: courses
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// 6. 创建新课程（POST /courses，放在最后）
router.post('/courses',
  [
    body('course_name').trim().notEmpty().withMessage('课程名称不能为空'),
    body('category_id').isInt().withMessage('请选择课程分类'),
    body('difficulty_level').isIn(['beginner', 'intermediate', 'advanced']).withMessage('请选择有效的难度级别'),
    body('course_desc').optional().trim(),
    body('cover_img').optional().trim(),
    body('course_duration').optional().isInt({ min: 0 }).withMessage('课程时长必须是正整数')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      const result = await TeacherService.createCourse(req.user.userId, req.body);
      res.status(201).json({
        status: 'success',
        data: result
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

export default router;