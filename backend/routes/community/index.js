// backend/routes/community/index.js
const express = require('express');
const router = express.Router();

const teamRoutes = require('./teamRoutes');
const roomRoutes = require('./roomRoutes');
const postRoutes = require('./postRoutes');
const messageRoutes = require('./messageRoutes');
const taskRoutes = require('./taskRoutes');
const commentRoutes = require('./commentRoutes');
const { authMiddleware } = require('../../middleware/auth'); // 导入认证中间件

// 使用路由 - 暂时移除认证中间件进行测试
router.use('/teams', teamRoutes);        // 学习小组
router.use('/rooms', roomRoutes);        // 自习室
router.use('/posts', postRoutes);        // 帖子
router.use('/messages', messageRoutes);  // 消息
router.use('/comments', commentRoutes);  // 评论管理
router.use('/', taskRoutes);             // 任务管理

// 社区首页路由 - 不需要认证
router.get('/', (req, res) => {
  res.json({
    success: true,
    message: '社区模块API',
    endpoints: {
      '学习小组': '/api/community/teams',
      '自习室': '/api/community/rooms',
      '帖子管理': '/api/community/posts',
      '消息管理': '/api/community/messages',
      '任务管理': '/api/community/tasks'
    },
    categories: {
      '公共讨论区': 'discussion',
      '名师答疑': 'question', 
      '互助学习': 'help'
    }
  });
});

module.exports = router;