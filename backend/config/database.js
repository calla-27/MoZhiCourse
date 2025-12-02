// config/database.js - 从.env读取配置
const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || '127.0.0.1',       
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'mzcourse',
  charset: 'utf8mb4',
  connectionLimit: 10,
};

const pool = mysql.createPool(dbConfig);

// 测试数据库连接 (保留不变)
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('✅ 数据库连接成功');
    connection.release();

    // 测试查询
    const [rows] = await pool.execute('SELECT COUNT(*) as count FROM course');
    console.log(`📊 数据库中有 ${rows[0].count} 个课程`);
  } catch (err) {
    console.error('❌ 数据库连接失败:', err.message);
    throw err;
  }
};

// 封装execute函数
const execute = async (sql, params = []) => {
  try {
    return await pool.execute(sql, params);
  } catch (error) {
    console.error('数据库查询错误:', error);
    throw error;
  }
};

module.exports = {
  pool,
  testConnection,
  execute
};