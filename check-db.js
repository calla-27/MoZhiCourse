// 检查数据库中的课程数据
const mysql = require('mysql2/promise');

async function checkDatabase() {
  let connection;
  try {
    // 创建数据库连接
    connection = await mysql.createConnection({
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: '123456',
      database: 'mzcourse'
    });

    console.log('✅ 数据库连接成功');

    // 查询课程表
    const [courses] = await connection.execute('SELECT * FROM course LIMIT 5');
    console.log('📚 课程表数据:');
    console.log('课程数量:', courses.length);
    
    if (courses.length > 0) {
      console.log('第一个课程的数据结构:');
      console.log(JSON.stringify(courses[0], null, 2));
    } else {
      console.log('❌ 课程表中没有数据');
    }

    // 查询分类表
    const [categories] = await connection.execute('SELECT * FROM course_category LIMIT 5');
    console.log('\n📂 分类表数据:');
    console.log('分类数量:', categories.length);
    
    if (categories.length > 0) {
      categories.forEach(cat => {
        console.log(`- ${cat.category_name} (ID: ${cat.category_id})`);
      });
    }

  } catch (error) {
    console.error('❌ 数据库操作失败:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

checkDatabase();