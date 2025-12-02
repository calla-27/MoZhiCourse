import express from 'express';
import { body, param, validationResult } from 'express-validator';
import { authenticate, requireRole } from '../middleware/auth.middleware.js';
import StudentService from '../services/student.service.js';
import CommunityModel from '../models/community.model.js';

const router = express.Router();

// 所有学生路由都需要认证和学生角色
router.use(authenticate);
router.use(requireRole('learner'));

// 获取学习统计
router.get('/stats', async (req, res) => {
  try {
    const stats = await StudentService.getLearningStats(req.user.userId);
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

// 获取我的课程
router.get('/courses', async (req, res) => {
  try {
    const { status } = req.query;
    const courses = await StudentService.getEnrolledCourses(req.user.userId, status);
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

// 获取收藏的课程
router.get('/favorites', async (req, res) => {
  try {
    const courses = await StudentService.getFavoriteCourses(req.user.userId);
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

// 添加收藏
router.post('/favorites/:courseId', async (req, res) => {
  try {
    const result = await StudentService.addFavorite(req.user.userId, req.params.courseId);
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
});

// 取消收藏
router.delete('/favorites/:courseId', async (req, res) => {
  try {
    const result = await StudentService.removeFavorite(req.user.userId, req.params.courseId);
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
});

// 报名课程
router.post('/enroll/:courseId', async (req, res) => {
  try {
    const result = await StudentService.enrollCourse(req.user.userId, req.params.courseId);
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
});

// 更新学习进度
router.put('/courses/:courseId/progress', async (req, res) => {
  try {
    const { progress } = req.body;
    const result = await StudentService.updateProgress(
      req.user.userId,
      req.params.courseId,
      progress
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
});

// 获取社区数据（组队、自习室）
router.get('/community', async (req, res) => {
  try {
    const data = await StudentService.getCommunityData(req.user.userId);
    res.json({
      status: 'success',
      data
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// 获取成就列表
router.get('/achievements', async (req, res) => {
  try {
    const data = await StudentService.getAchievements(req.user.userId);
    res.json({
      status: 'success',
      data
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

// 加入自习室
router.post('/community/rooms/:roomId/join',
  [param('roomId').isInt().withMessage('自习室ID必须是整数')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      await CommunityModel.joinRoom(req.user.userId, req.params.roomId);
      res.json({
        status: 'success',
        data: { message: '加入自习室成功' }
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 离开自习室
router.post('/community/rooms/:roomId/leave',
  [param('roomId').isInt().withMessage('自习室ID必须是整数')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      const success = await CommunityModel.leaveRoom(req.user.userId, req.params.roomId);
      if (!success) {
        return res.status(400).json({
          status: 'error',
          message: '未加入该自习室'
        });
      }
      res.json({
        status: 'success',
        data: { message: '离开自习室成功' }
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 获取自习室详情
router.get('/community/rooms/:roomId',
  [param('roomId').isInt().withMessage('自习室ID必须是整数')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      const room = await CommunityModel.findRoomById(req.params.roomId);
      if (!room) {
        return res.status(404).json({
          status: 'error',
          message: '自习室不存在'
        });
      }
      res.json({
        status: 'success',
        data: room
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 发表自习室留言
router.post('/community/rooms/:roomId/comments',
  [
    param('roomId').isInt().withMessage('自习室ID必须是整数'),
    body('content').trim().notEmpty().withMessage('留言内容不能为空')
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
      const commentId = await CommunityModel.addRoomComment(
        req.user.userId,
        req.params.roomId,
        req.body.content
      );
      res.json({
        status: 'success',
        data: {
          message: '留言发表成功',
          comment_id: commentId
        }
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 加入组队
router.post('/community/teams/:teamId/join',
  [param('teamId').isInt().withMessage('组队ID必须是整数')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      await CommunityModel.joinTeam(req.user.userId, req.params.teamId);
      res.json({
        status: 'success',
        data: { message: '加入组队成功' }
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 离开组队
router.post('/community/teams/:teamId/leave',
  [param('teamId').isInt().withMessage('组队ID必须是整数')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      const success = await CommunityModel.leaveTeam(req.user.userId, req.params.teamId);
      if (!success) {
        return res.status(400).json({
          status: 'error',
          message: '未加入该组队'
        });
      }
      res.json({
        status: 'success',
        data: { message: '离开组队成功' }
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

// 获取组队详情
router.get('/community/teams/:teamId',
  [param('teamId').isInt().withMessage('组队ID必须是整数')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        errors: errors.array()
      });
    }

    try {
      const team = await CommunityModel.findTeamById(req.params.teamId);
      if (!team) {
        return res.status(404).json({
          status: 'error',
          message: '组队不存在'
        });
      }
      res.json({
        status: 'success',
        data: team
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

export default router;