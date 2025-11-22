// config/database.js - 移除无效的 MySQL 配置选项
const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '123456',
  database: process.env.DB_NAME || 'mzcourse',
  charset: 'utf8mb4',
  connectionLimit: 10,
  // 移除 acquireTimeout 和 timeout
};

const pool = mysql.createPool(dbConfig);

// 测试数据库连接
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('✅ 数据库连接成功');
    connection.release();
    
    // 测试查询
    const [rows] = await pool.execute('SELECT COUNT(*) as count FROM t_course');
    console.log(`📊 数据库中有 ${rows[0].count} 个课程`);
  } catch (err) {
    console.error('❌ 数据库连接失败:', err.message);
  }
};

testConnection();

module.exports = pool;