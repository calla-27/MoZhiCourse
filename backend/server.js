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
const communityRoutes = require('./routes/community');
const personalCenterRoutes = require('./routes/personalCenter');
const teacherCenterRoutes = require('./routes/teacherCenter');
const userCoursesRoutes = require('./routes/userCourses'); // 新增：用户课程路由
const studentBehaviorRoutes = require('./routes/studentBehaviorRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// 允许的跨域来源
const defaultOrigins = [
  'http://localhost:3000', 
  'http://localhost:8080', 
  'http://localhost:8083',
  'http://127.0.0.1:3000',
  'http://127.0.0.1:8080', 
  'http://127.0.0.1:8083',
  'http://127.0.0.1:54435'  // Cascade浏览器预览地址
];
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim()).filter(Boolean)
  : defaultOrigins;

// 通用中间件
app.use(cors({
  origin: function (origin, callback) {
    // 允许没有origin的请求（如移动应用或Postman）
    if (!origin) return callback(null, true);
    
    // 检查是否在允许列表中
    if (allowedOrigins.indexOf(origin) !== -1) {
      return callback(null, true);
    }
    
    // 允许所有本地开发地址
    if (origin.match(/^http:\/\/(localhost|127\.0\.0\.1):\d+$/)) {
      return callback(null, true);
    }
    
    const msg = 'CORS策略不允许来自该源的请求: ' + origin;
    return callback(new Error(msg), false);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
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
app.use('/api/community', communityRoutes);
app.use('/api/personal', personalCenterRoutes);
app.use('/api/teacher', teacherCenterRoutes);
app.use('/api/user-courses', userCoursesRoutes); // 新增：用户课程路由
app.use('/api/student/behavior', studentBehaviorRoutes);

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
      '学习社区': '/api/community',
      '个人中心': '/api/personal',
      '教师中心': '/api/teacher',
      '用户课程管理': '/api/user-courses', // 新增
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
║     - 学习社区: /api/community                     ║
║     - 个人中心: /api/personal                      ║
║     - 用户课程: /api/user-courses                  ║
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