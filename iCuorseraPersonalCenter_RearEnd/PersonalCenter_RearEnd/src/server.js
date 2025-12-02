import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { testConnection } from './config/database.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8080;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件服务
app.use('/uploads', express.static('uploads'));

// 请求日志中间件（放在路由之前）
app.use((req, res, next) => {
  console.log(`📨 ${req.method} ${req.path}`);
  next();
});

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'success', 
    message: 'Personal Center API is running',
    timestamp: new Date().toISOString()
  });
});

// 导入路由
console.log('🔄 开始导入路由...');

import authRoutes from './routes/auth.routes.js';
console.log('✅ authRoutes 导入成功');

import userRoutes from './routes/user.routes.js';
console.log('✅ userRoutes 导入成功');

import studentRoutes from './routes/student.routes.js';
console.log('✅ studentRoutes 导入成功');

import teacherRoutes from './routes/teacher.routes.js';
console.log('✅ teacherRoutes 导入成功');

// 注册路由
console.log('🔄 开始注册路由...');
app.use('/api/auth', authRoutes);
console.log('✅ /api/auth 路由已注册');

app.use('/api/user', userRoutes);
console.log('✅ /api/user 路由已注册');

app.use('/api/student', studentRoutes);
console.log('✅ /api/student 路由已注册');

app.use('/api/teacher', teacherRoutes);
console.log('✅ /api/teacher 路由已注册');

// 列出所有注册的路由
console.log('\n📋 已注册的路由：');
app._router.stack.forEach((middleware) => {
  if (middleware.route) {
    console.log(`  ${Object.keys(middleware.route.methods)} ${middleware.route.path}`);
  } else if (middleware.name === 'router') {
    middleware.handle.stack.forEach((handler) => {
      if (handler.route) {
        const path = middleware.regexp.toString().replace('/^\\', '').replace('\\/?(?=\\/|$)/i', '');
        console.log(`  ${Object.keys(handler.route.methods)} ${path}${handler.route.path}`);
      }
    });
  }
});

// 404 处理
app.use('*', (req, res) => {
  console.log('❌ 404 - Route not found:', req.method, req.originalUrl);
  res.status(404).json({ 
    status: 'error', 
    message: 'Route not found',
    path: req.originalUrl,
    method: req.method
  });
});

// 全局错误处理
app.use((err, req, res, next) => {
  console.error('❌ Error:', err);
  res.status(err.status || 500).json({
    status: 'error',
    message: err.message || 'Internal server error'
  });
});

// 启动服务器
const startServer = async () => {
  try {
    await testConnection();
    app.listen(PORT, () => {
      console.log('\n🎉 ========================');
      console.log(`🚀 服务器运行在 http://localhost:${PORT}`);
      console.log(`📚 健康检查: http://localhost:${PORT}/api/health`);
      console.log(`📝 注册接口: POST http://localhost:${PORT}/api/auth/register`);
      console.log(`🔐 登录接口: POST http://localhost:${PORT}/api/auth/login`);
      console.log('🎉 ========================\n');
    });
  } catch (error) {
    console.error('❌ 服务器启动失败:', error);
    process.exit(1);
  }
};

startServer();