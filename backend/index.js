const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

// 导入路由
const courseRoutes = require('./routes/courses');

const app = express();

// 中间件
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:5173', 'http://127.0.0.1:8080', 'http://127.0.0.1:3000'],
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 请求日志中间件
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// 静态文件服务 - 用于提供视频文件
app.use('/videos', express.static(path.join(__dirname, 'public/videos')));

// 路由
app.use('/api/course', courseRoutes);

// 模拟用户信息
app.get('/api/user/:userId', (req, res) => {
  const { userId } = req.params;
  
  // 模拟用户数据 - 对应你的数据库中的用户ID 2
  const mockUser = {
    user_id: parseInt(userId),
    user_name: '李小明',
    email: 'student1@icoursera.com',
    occupation: '大学生',
    learning_goal: '学习Python编程',
    role: 'learner'
  };
  
  res.json({
    code: 200,
    message: '成功',
    data: mockUser
  });
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'mzcourse-backend',
    database: 'connected'
  });
});

// 404 处理
app.use('*', (req, res) => {
  res.status(404).json({
    code: 404,
    message: '接口不存在'
  });
});

// 错误处理中间件
app.use((err, req, res, next) => {
  console.error('服务器错误:', err);
  res.status(500).json({
    code: 500,
    message: '服务器内部错误'
  });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`🚀 服务器运行在 http://localhost:${PORT}`);
  console.log(`📚 API文档:`);
  console.log(`   GET  /health - 健康检查`);
  console.log(`   GET  /api/user/:userId - 获取用户信息`);
  console.log(`   GET  /api/course/:courseId - 获取课程详情`);
  console.log(`   GET  /api/course/:courseId/chapters - 获取章节列表`);
  console.log(`   GET  /api/course/video/:videoId - 获取视频详情`);
  console.log(`   GET  /api/course/video/:videoId/progress - 获取学习进度`);
  console.log(`   POST /api/course/video/progress - 更新学习进度`);
  console.log(`   POST /api/course/video/behavior - 记录学习行为`);
});