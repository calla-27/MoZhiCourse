const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function debugSQL() {
    console.log('🔍 开始调试 SQL 文件...');
    
    try {
        // 1. 连接数据库
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD
        });
        console.log('✅ 数据库连接成功');

        // 2. 读取 init.sql 文件
        const initSqlPath = path.join(__dirname, '../database/init.sql');
        const sqlContent = fs.readFileSync(initSqlPath, 'utf8');
        
        // 3. 按分号分割 SQL 语句
        const statements = sqlContent.split(';').filter(stmt => stmt.trim());
        
        console.log(`📝 找到 ${statements.length} 条 SQL 语句`);
        
        // 4. 逐条执行并检查
        for (let i = 0; i < statements.length; i++) {
            const stmt = statements[i].trim();
            if (!stmt) continue;
            
            console.log(`\n--- 执行第 ${i + 1} 条语句 ---`);
            console.log(stmt.substring(0, 100) + '...'); // 只显示前100字符
            
            try {
                await connection.execute(stmt + ';');
                console.log(`✅ 第 ${i + 1} 条语句执行成功`);
            } catch (error) {
                console.error(`❌ 第 ${i + 1} 条语句执行失败:`);
                console.error('错误信息:', error.message);
                console.error('错误代码:', error.code);
                console.error('失败语句:', stmt);
                break;
            }
        }
        
        await connection.end();
        
    } catch (error) {
        console.error('❌ 调试失败:', error.message);
    }
}

debugSQL();