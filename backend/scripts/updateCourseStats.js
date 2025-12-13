// 更新课程统计数据脚本
const pool = require('../config/database');

async function updateCourseStats() {
  try {
    console.log('📊 开始更新课程统计数据...\n');
    
    // 获取所有课程
    const [courses] = await pool.execute(`
      SELECT course_id, course_name, teacher_user_id 
      FROM course 
      ORDER BY course_id
    `);
    
    console.log(`找到 ${courses.length} 门课程需要更新统计数据\n`);
    
    for (const course of courses) {
      try {
        console.log(`🔄 更新课程: ${course.course_name} (ID: ${course.course_id})`);
        
        // 1. 计算学生人数
        const [studentStats] = await pool.execute(`
          SELECT COUNT(DISTINCT user_id) as student_count
          FROM user_course 
          WHERE course_id = ? AND is_enrolled = 1
        `, [course.course_id]);
        
        const studentCount = studentStats[0]?.student_count || 0;
        
        // 2. 计算评分统计
        const [ratingStats] = await pool.execute(`
          SELECT 
            AVG(rating) as avg_rating,
            COUNT(*) as rating_count
          FROM course_review 
          WHERE course_id = ?
        `, [course.course_id]);
        
        const avgRating = ratingStats[0]?.avg_rating || 0;
        const ratingCount = ratingStats[0]?.rating_count || 0;
        
        // 3. 更新课程表
        await pool.execute(`
          UPDATE course 
          SET 
            student_count = ?,
            rating = ?,
            rating_count = ?
          WHERE course_id = ?
        `, [
          studentCount,
          Math.round(avgRating * 10) / 10, // 保留一位小数
          ratingCount,
          course.course_id
        ]);
        
        console.log(`  ✅ 学生: ${studentCount}人, 评分: ${Math.round(avgRating * 10) / 10} (${ratingCount}条评价)`);
        
      } catch (error) {
        console.error(`  ❌ 更新课程 ${course.course_name} 失败:`, error.message);
      }
    }
    
    console.log('\n📈 统计数据更新完成！');
    
    // 显示更新后的结果
    const [updatedCourses] = await pool.execute(`
      SELECT 
        course_name,
        student_count,
        rating,
        rating_count
      FROM course 
      WHERE student_count > 0 OR rating > 0
      ORDER BY student_count DESC, rating DESC
    `);
    
    console.log('\n📊 更新后的课程统计:');
    console.table(updatedCourses);
    
  } catch (error) {
    console.error('❌ 更新统计数据失败:', error);
  } finally {
    process.exit(0);
  }
}

// 运行脚本
updateCourseStats();