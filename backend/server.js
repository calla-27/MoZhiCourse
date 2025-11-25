// server.js
const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const { testConnection } = require('./config/database');
const errorHandler = require('./middleware/errorHandler');

// 路由
const authRoutes = require('./routes/auth');
const courseRoutes = require('./routes/courses');
const categoryRoutes = require('./routes/categories');
const reviewRoutes = require('./routes/reviews');
const teacherRoutes = require('./routes/teachers');
const commentRoutes = require('./routes/commentRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// 允许的跨域来源
const defaultOrigins = ['http://localhost:3000', 'http://localhost:8080'];
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim()).filter(Boolean)
  : defaultOrigins;

// 通用中间件
app.use(cors({
  origin: allowedOrigins,
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 日志中间件
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// 静态资源
app.use('/videos', express.static(path.join(__dirname, 'public/videos')));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// API 路由
app.use('/api/auth', authRoutes);
app.use('/api/courses', courseRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/teachers', teacherRoutes);
app.use('/api/comment', commentRoutes);

// 模拟用户数据（兼容旧接口）
app.get('/api/user/:userId', (req, res) => {
  const { userId } = req.params;
  res.json({
    code: 200,
    message: '成功',
    data: {
      user_id: parseInt(userId, 10),
      user_name: '李小明',
      email: 'student1@icoursera.com',
      occupation: '大学生',
      learning_goal: '学习Python编程',
      role: 'learner'
    }
  });
});

// 根路径 - API 文档首页
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: '🎓 欢迎使用课程中心API',
    version: '1.0.0',
    documentation: {
      '认证接口': '/api/auth',
      '课程接口': '/api/courses',
      '分类接口': '/api/categories',
      '评价接口': '/api/reviews',
      '评论接口': '/api/comment',
      '讲师接口': '/api/teachers',
      '健康检查': '/api/health'
    }
  });
});

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: '服务运行正常',
    timestamp: new Date().toISOString()
  });
});

// 404 处理
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: '接口不存在',
    path: req.path,
    tip: '请访问 http://localhost:3000/ 查看可用的API接口列表'
  });
});

// 错误处理中间件
app.use(errorHandler);

// 启动服务器
const startServer = async () => {
  try {
    // await testConnection();

    app.listen(PORT, () => {
      console.log(`
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🎓 课程中心后端服务已启动                      ║
║                                                   ║
║     服务地址: http://localhost:${PORT}              ║
║     环境: ${process.env.NODE_ENV || 'development'}                       ║
║     数据库: ${process.env.DB_NAME}                     ║
║                                                   ║
║     API文档:                                       ║
║     - 认证: /api/auth                              ║
║     - 课程: /api/courses                           ║
║     - 分类: /api/categories                        ║
║     - 评价: /api/reviews                           ║
║     - 评论: /api/comment                           ║
║     - 讲师: /api/teachers                          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
      `);
    });
  } catch (error) {
    console.error('服务器启动失败:', error);
    process.exit(1);
  }
};

startServer();

module.exports = app;
