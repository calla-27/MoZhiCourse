const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());

// 引入数据库连接
const { pool, testConnection, healthCheck, getStats } = require('./config/database');

// 引入路由
const communityRoutes = require('./routes/community');

// 使用路由
app.use('/api/community', communityRoutes);

// 简单的健康检查
app.get('/health', (req, res) => {
    res.json({ status: 'OK', message: '服务运行正常' });
});

// 数据库健康检查
app.get('/health/db', async (req, res) => {
    try {
        const result = await healthCheck();
        res.json(result);
    } catch (error) {
        res.status(500).json({ 
            status: 'unhealthy', 
            error: error.message,
            timestamp: new Date().toISOString()
        });
    }
});

// 数据库统计信息
app.get('/api/stats', async (req, res) => {
    try {
        const stats = await getStats();
        res.json({
            success: true,
            data: stats
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '获取统计信息失败: ' + error.message
        });
    }
});

// 测试数据库连接
app.get('/test-db', async (req, res) => {
    const isConnected = await testConnection();
    if (isConnected) {
        res.json({ status: '数据库连接正常' });
    } else {
        res.status(500).json({ status: '数据库连接失败' });
    }
});

// 启动服务器
app.listen(PORT, async () => {
    console.log(`🚀 服务运行在端口 ${PORT}`);
    console.log(`📍 健康检查: http://localhost:${PORT}/health`);
    console.log(`📍 数据库检查: http://localhost:${PORT}/health/db`);
    console.log(`📍 社区API: http://localhost:${PORT}/api/community`);
    
    // 测试数据库连接
    await testConnection();
});

// 修改获取帖子评论的接口，简化查询，去掉点赞相关逻辑
app.get('/api/community/comments/post/:postId', async (req, res) => {
  try {
    const { postId } = req.params;
    const { comment_type } = req.query;
    
    console.log('获取帖子评论请求:', { postId, comment_type });
    
    let query = `
      SELECT 
        pc.comment_id,
        pc.post_id,
        pc.user_id,
        pc.content,
        pc.create_time,
        pc.comment_type,
        u.user_name
      FROM t_post_comment pc
      LEFT JOIN t_user u ON pc.user_id = u.user_id
      WHERE pc.post_id = ?
    `;
    
    const params = [postId];
    
    // 添加评论类型过滤
    if (comment_type) {
      query += ` AND pc.comment_type = ?`;
      params.push(comment_type);
    }
    
    query += ` ORDER BY pc.create_time ASC`;
    
    console.log('执行查询:', query, '参数:', params);
    
    const [comments] = await db.query(query, params);
    console.log(`获取到 ${comments.length} 条评论`, comments);
    
    res.json({
      success: true,
      data: comments
    });
    
  } catch (error) {
    console.error('获取评论失败:', error);
    res.status(500).json({
      success: false,
      message: '获取评论失败'
    });
  }
});