import express from 'express';
import multer from 'multer';
import path from 'path';
import { authenticate } from '../middleware/auth.middleware.js';
import UserService from '../services/user.service.js';

const router = express.Router();

// 配置头像上传
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/avatars/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'avatar-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(new Error('只允许上传图片文件'));
    }
  }
});

// 获取当前用户信息
router.get('/profile', authenticate, async (req, res) => {
  try {
    const profile = await UserService.getUserProfile(req.user.userId);
    res.json({
      status: 'success',
      data: profile
    });
  } catch (error) {
    res.status(404).json({
      status: 'error',
      message: error.message
    });
  }
});

// 更新用户信息
router.put('/profile', authenticate, async (req, res) => {
  try {
    const updatedProfile = await UserService.updateProfile(req.user.userId, req.body);
    res.json({
      status: 'success',
      message: '更新成功',
      data: updatedProfile
    });
  } catch (error) {
    res.status(400).json({
      status: 'error',
      message: error.message
    });
  }
});

// 上传头像
router.post('/avatar', authenticate, upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        status: 'error',
        message: '请选择要上传的图片'
      });
    }

    const result = await UserService.updateAvatar(req.user.userId, req.file.filename);
    res.json({
      status: 'success',
      message: '头像上传成功',
      data: result
    });
  } catch (error) {
    res.status(400).json({
      status: 'error',
      message: error.message
    });
  }
});

export default router;