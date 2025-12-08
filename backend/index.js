const express = require('express');
const cors = require('cors');
const courseRoutes = require('./routes/course');

const app = express();

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件服务 - 用于提供视频文件
app.use('/videos', express.static('public/videos'));

// 路由
app.use('/api/course', courseRoutes);

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
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
  console.log(`服务器运行在端口 ${PORT}`);
});