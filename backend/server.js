// server.js
const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

// ---------- 路由导入 ----------
const courseRoutes = require('./routes/courses');
const commentRoutes = require('./routes/commentRoutes'); // 评论区

// ---------- 创建实例 ----------
const app = express();

// ---------- 通用中间件 ----------
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080'],
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 请求日志
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// 静态资源
app.use('/videos', express.static(path.join(__dirname, 'public/videos')));

// ---------- API 路由 ----------
app.use('/api/course', courseRoutes);
app.use('/api/comment', commentRoutes); // 统一用 /api/comment

// ---------- 模拟用户 ----------
app.get('/api/user/:userId', (req, res) => {
  const { userId } = req.params;
  res.json({
    code: 200,
    message: '成功',
    data: {
      user_id: parseInt(userId),
      user_name: '李小明',
      email: 'student1@icoursera.com',
      occupation: '大学生',
      learning_goal: '学习Python编程',
      role: 'learner'
    }
  });
});

// ---------- 健康检查 ----------
app.get('/api/health', (_, res) => res.json({ status: 'OK', timestamp: new Date().toISOString() }));

// ---------- 404 / 500 ----------
app.use('*', (_, res) => res.status(404).json({ code: 404, message: '接口不存在' }));
app.use((err, _, res, __) => {
  console.error('服务器错误:', err);
  res.status(500).json({ code: 500, message: '服务器内部错误' });
});

// ---------- 启动 ----------
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`🚀 服务器运行在 http://localhost:${PORT}`);
  console.log(`📚 主要接口:`);
  console.log(`   GET  /api/health`);
  console.log(`   GET  /api/user/:userId`);
  console.log(`   GET  /api/course/xxx`);
  console.log(`   GET  /api/comment/videos/:videoId   ← 获取评论`);
  console.log(`   POST /api/comment                   ← 发布评论`);
  console.log(`   POST /api/comment/:commentId/like   ← 点赞评论`);
});