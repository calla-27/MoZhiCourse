// config/database.js
const mysql = require('mysql2/promise');
require('dotenv').config();

// 数据库连接配置
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'community',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    charset: 'utf8mb4',
    timezone: '+08:00'
};

// 创建连接池
const pool = mysql.createPool(dbConfig);

// 为了方便使用，创建一个直接的 execute 方法
const execute = (...args) => pool.execute(...args);

// 测试数据库连接
async function testConnection() {
    try {
        const connection = await pool.getConnection();
        console.log('✅ 数据库连接成功');
        console.log(`📍 数据库: ${dbConfig.database}`);
        connection.release();
        return true;
    } catch (error) {
        console.error('❌ 数据库连接失败:', error.message);
        if (error.code === 'ER_BAD_DB_ERROR') {
            console.log('💡 提示: 数据库不存在，请先运行: npm run db:init');
        } else if (error.code === 'ER_ACCESS_DENIED_ERROR') {
            console.log('💡 提示: 请检查数据库用户名和密码');
        }
        return false;
    }
}

// 健康检查
async function healthCheck() {
    try {
        const [rows] = await pool.execute('SELECT 1 as status');
        return {
            status: 'healthy',
            database: dbConfig.database,
            timestamp: new Date().toISOString()
        };
    } catch (error) {
        return {
            status: 'unhealthy',
            error: error.message,
            timestamp: new Date().toISOString()
        };
    }
}

// 获取数据库统计信息
async function getStats() {
    try {
        const [userCount] = await pool.execute('SELECT COUNT(*) as count FROM t_user');
        const [teamCount] = await pool.execute('SELECT COUNT(*) as count FROM t_study_team');
        const [roomCount] = await pool.execute('SELECT COUNT(*) as count FROM t_study_room');
        const [postCount] = await pool.execute('SELECT COUNT(*) as count FROM t_community_post');
        
        return {
            users: userCount[0].count,
            study_teams: teamCount[0].count,
            study_rooms: roomCount[0].count,
            posts: postCount[0].count
        };
    } catch (error) {
        console.error('获取统计信息失败:', error);
        return null;
    }
}

module.exports = {
    pool,
    execute,
    testConnection,
    healthCheck,
    getStats
};