// config/database.js - 临时硬编码配置以进行测试
const mysql = require('mysql2/promise');
// require('dotenv').config();

const dbConfig = {
  host: '127.0.0.1',       
  port: 3306,
  user: 'root',
  password: '123456',
  database: 'mzcourse_merged',
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
    const [rows] = await pool.execute('SELECT COUNT(*) as count FROM t_course');
    console.log(`📊 数据库中有 ${rows[0].count} 个课程`);
  } catch (err) {
    console.error('❌ 数据库连接失败:', err.message);
    throw err;
  }
};

module.exports = {
  pool,
  testConnection,
};