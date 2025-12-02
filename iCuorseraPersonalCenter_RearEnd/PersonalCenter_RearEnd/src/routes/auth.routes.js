import express from 'express';
import { body, validationResult } from 'express-validator';
import AuthService from '../services/auth.service.js';

const router = express.Router();

// 注册
router.post('/register',
  [
    body('user_name').trim().notEmpty().withMessage('用户名不能为空'),
    body('phone').matches(/^1[3-9]\d{9}$/).withMessage('手机号格式不正确'),
    body('email').isEmail().withMessage('邮箱格式不正确'),
    body('password').isLength({ min: 6 }).withMessage('密码至少6位'),
    body('role').optional().isIn(['learner', 'instructor']).withMessage('角色类型错误')
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          status: 'error',
          errors: errors.array()
        });
      }

      const result = await AuthService.register(req.body);
      res.status(201).json({
        status: 'success',
        message: '注册成功',
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

// 登录
router.post('/login',
  [
    body('phone').matches(/^1[3-9]\d{9}$/).withMessage('手机号格式不正确'),
    body('password').notEmpty().withMessage('密码不能为空')
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          status: 'error',
          errors: errors.array()
        });
      }

      const result = await AuthService.login(req.body);
      res.json({
        status: 'success',
        message: '登录成功',
        data: result
      });
    } catch (error) {
      res.status(401).json({
        status: 'error',
        message: error.message
      });
    }
  }
);

export default router;