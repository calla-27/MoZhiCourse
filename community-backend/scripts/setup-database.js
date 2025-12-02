const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

class DatabaseSetup {
    constructor() {
        this.config = {
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            multipleStatements: true
        };
    }

    async run() {
        let connection;
        try {
            console.log('🚀 开始初始化 Community 数据库...');
            
            // 1. 创建数据库连接
            connection = await mysql.createConnection(this.config);
            console.log('✅ 数据库连接成功');

            // 2. 读取SQL文件
            const initSqlPath = path.join(__dirname, '../database/init.sql');
            const testDataSqlPath = path.join(__dirname, '../database/test-data.sql');
            
            if (!fs.existsSync(initSqlPath)) {
                throw new Error(`初始化SQL文件不存在: ${initSqlPath}`);
            }
            
            const initSql = fs.readFileSync(initSqlPath, 'utf8');
            const testDataSql = fs.existsSync(testDataSqlPath) ? 
                fs.readFileSync(testDataSqlPath, 'utf8') : '';

            // 3. 分割SQL语句并分别执行
            console.log('📝 创建数据库和表结构...');
            
            // 分割SQL语句
            const initStatements = initSql.split(';').filter(stmt => stmt.trim());
            
            // 分别执行每个语句
            for (const statement of initStatements) {
                if (statement.trim()) {
                    try {
                        // 使用 query() 而不是 execute() 来执行 DDL 语句
                        await connection.query(statement + ';');
                    } catch (error) {
                        // 忽略索引已存在的错误
                        if (error.code === 'ER_DUP_KEYNAME' || error.code === 'ER_CANT_DROP_FIELD_OR_KEY') {
                            console.log(`⚠️  索引已存在，跳过: ${error.message.split('\n')[0]}`);
                            continue;
                        }
                        // 重新抛出其他错误
                        throw error;
                    }
                }
            }
            
            console.log('✅ 数据库和表结构创建完成');

            // 4. 插入测试数据（如果有）
            if (testDataSql) {
                console.log('📊 插入测试数据...');
                
                // 分割测试数据SQL语句
                const testDataStatements = testDataSql.split(';').filter(stmt => stmt.trim());
                
                // 分别执行每个语句
                for (const statement of testDataStatements) {
                    if (statement.trim()) {
                        await connection.query(statement + ';');
                    }
                }
                
                console.log('✅ 测试数据插入完成');
            }

            // 5. 验证数据
            console.log('\n🔍 验证数据...');
            
            // 切换到 community 数据库进行验证
            await connection.query('USE community');
            
            // 使用 query() 而不是 execute() 来执行查询
            const [users] = await connection.query('SELECT COUNT(*) as count FROM t_user');
            const [teams] = await connection.query('SELECT COUNT(*) as count FROM t_study_team');
            const [rooms] = await connection.query('SELECT COUNT(*) as count FROM t_study_room');
            const [posts] = await connection.query('SELECT COUNT(*) as count FROM t_community_post');
            const [courses] = await connection.query('SELECT COUNT(*) as count FROM t_course');

            console.log('\n🎉 Community 数据库初始化成功！');
            console.log('📊 数据统计:');
            console.log(`   👥 用户数量: ${users[0].count}`);
            console.log(`   📚 课程数量: ${courses[0].count}`);
            console.log(`   👨‍👩‍👧‍👦 学习小组: ${teams[0].count}`);
            console.log(`   🏫 自习室: ${rooms[0].count}`);
            console.log(`   💬 帖子数量: ${posts[0].count}`);
            console.log('\n📍 数据库名称: community');
            console.log('📍 服务地址: http://localhost:3000');

        } catch (error) {
            console.error('❌ 数据库初始化失败:', error.message);
            console.error('完整错误信息:', error);
            if (error.code === 'ER_ACCESS_DENIED_ERROR') {
                console.log('💡 提示: 请检查数据库用户名和密码是否正确');
            } else if (error.code === 'ECONNREFUSED') {
                console.log('💡 提示: 请确保MySQL服务正在运行');
            }
            process.exit(1);
        } finally {
            if (connection) {
                await connection.end();
            }
        }
    }
}

// 运行初始化
if (require.main === module) {
    const setup = new DatabaseSetup();
    setup.run();
}

module.exports = DatabaseSetup;