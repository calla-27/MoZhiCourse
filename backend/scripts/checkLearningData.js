// 检查学习数据脚本
const pool = require('../config/database');

async function checkLearningData() {
  try {
    console.log('🔍 检查学习数据状态...\n');
    
    // 1. 检查learning_detail表的数据
    console.log('📊 Learning Detail 表数据:');
    const [learningDetail] = await pool.execute(`
      SELECT 
        user_id,
        course_id,
        COUNT(*) as record_count,
        SUM(learn_duration) as total_minutes,
        MAX(complete_rate) as max_progress
      FROM learning_detail 
      GROUP BY user_id, course_id
      ORDER BY total_minutes DESC
      LIMIT 10
    `);
    
    console.table(learningDetail);
    
    // 2. 检查user_course表的数据
    console.log('\n📊 User Course 表数据:');
    const [userCourse] = await pool.execute(`
      SELECT 
        uc.user_id,
        uc.course_id,
        c.course_name,
        uc.total_learn_duration,
        uc.progress,
        uc.last_learn_time
      FROM user_course uc
      LEFT JOIN course c ON uc.course_id = c.course_id
      WHERE uc.is_enrolled = 1
      ORDER BY uc.total_learn_duration DESC
      LIMIT 10
    `);
    
    console.table(userCourse);
    
    // 3. 检查特定课程的学生数据（课程ID 21）
    console.log('\n📊 课程21的学生数据:');
    const [course21Students] = await pool.execute(`
      SELECT 
        u.user_name,
        uc.total_learn_duration as total_watch_time,
        uc.progress as completed_percent,
        ROUND((uc.total_learn_duration || 0) / 60, 2) as total_watch_hours
      FROM user_course uc
      JOIN user u ON uc.user_id = u.user_id
      WHERE uc.course_id = 21 AND uc.is_enrolled = 1
      ORDER BY uc.total_learn_duration DESC
    `);
    
    console.table(course21Students);
    
    // 4. 检查数据不一致的情况
    console.log('\n🔍 检查数据一致性:');
    const [inconsistentData] = await pool.execute(`
      SELECT 
        ld.user_id,
        ld.course_id,
        SUM(ld.learn_duration) as learning_detail_total,
        uc.total_learn_duration as user_course_total,
        (SUM(ld.learn_duration) - IFNULL(uc.total_learn_duration, 0)) as difference
      FROM learning_detail ld
      LEFT JOIN user_course uc ON ld.user_id = uc.user_id AND ld.course_id = uc.course_id
      GROUP BY ld.user_id, ld.course_id
      HAVING ABS(difference) > 1
      ORDER BY ABS(difference) DESC
      LIMIT 5
    `);
    
    if (inconsistentData.length > 0) {
      console.log('⚠️ 发现数据不一致:');
      console.table(inconsistentData);
    } else {
      console.log('✅ 数据一致性检查通过');
    }
    
  } catch (error) {
    console.error('❌ 检查数据失败:', error);
  } finally {
    process.exit(0);
  }
}

// 运行检查
checkLearningData();