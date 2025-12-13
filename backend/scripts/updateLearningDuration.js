// 更新学习时长数据
const mysql = require('mysql2/promise');

// 数据库配置
const dbConfig = {
  host: '127.0.0.1',
  user: 'root',
  password: '123456',
  database: 'mzcourse',
  charset: 'utf8mb4'
};

async function updateLearningDuration() {
  let connection;
  
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('📊 连接数据库成功');

    // 1. 基于学习行为数据计算学习时长
    console.log('⏱️ 开始计算学习时长...');
    
    // 获取所有有学习行为的用户课程组合
    const [userCourses] = await connection.execute(`
      SELECT DISTINCT lb.user_id, lb.course_id
      FROM learning_behaviors lb
      JOIN user_course uc ON lb.user_id = uc.user_id AND lb.course_id = uc.course_id
      WHERE uc.is_enrolled = 1
    `);
    
    console.log(`📚 找到 ${userCourses.length} 个用户课程组合需要更新学习时长`);
    
    for (const { user_id, course_id } of userCourses) {
      // 计算该用户在该课程的学习时长
      const [durationData] = await connection.execute(`
        SELECT 
          COUNT(*) as total_behaviors,
          SUM(CASE WHEN behavior_type = 'play' THEN 1 ELSE 0 END) as play_count,
          SUM(CASE WHEN behavior_type = 'chapter_complete' THEN duration ELSE 0 END) as chapter_duration,
          SUM(duration) as total_duration_seconds
        FROM learning_behaviors 
        WHERE user_id = ? AND course_id = ?
      `, [user_id, course_id]);
      
      const stats = durationData[0];
      
      // 基于行为数据估算学习时长（分钟）
      let estimatedDuration = 0;
      
      // 方法1：基于播放次数估算（每次播放平均15分钟）
      estimatedDuration += stats.play_count * 15;
      
      // 方法2：基于章节完成时长
      if (stats.chapter_duration > 0) {
        estimatedDuration += Math.round(stats.chapter_duration / 60); // 转换为分钟
      }
      
      // 方法3：基于总行为数量估算（每个行为平均2分钟）
      estimatedDuration += stats.total_behaviors * 2;
      
      // 添加一些随机变化，使数据更真实
      const randomFactor = 0.2; // 20%的随机变化
      const variation = (Math.random() - 0.5) * randomFactor;
      estimatedDuration = Math.round(estimatedDuration * (1 + variation));
      
      // 确保最小值和最大值合理
      estimatedDuration = Math.max(10, Math.min(estimatedDuration, 300)); // 10分钟到5小时
      
      // 更新user_course表的学习时长
      await connection.execute(`
        UPDATE user_course 
        SET total_learn_duration = ?, 
            last_learn_time = NOW(),
            updated_at = NOW()
        WHERE user_id = ? AND course_id = ?
      `, [estimatedDuration * 60, user_id, course_id]); // 转换为秒存储
      
      console.log(`✅ 更新用户${user_id}课程${course_id}学习时长: ${estimatedDuration}分钟`);
    }

    // 2. 更新学生课程表现数据
    console.log('📈 更新学生课程表现数据...');
    
    for (const { user_id, course_id } of userCourses) {
      // 获取更新后的学习时长
      const [courseData] = await connection.execute(`
        SELECT total_learn_duration, progress 
        FROM user_course 
        WHERE user_id = ? AND course_id = ?
      `, [user_id, course_id]);
      
      if (courseData.length > 0) {
        const { total_learn_duration, progress } = courseData[0];
        const durationMinutes = Math.round(total_learn_duration / 60);
        
        // 基于学习时长和进度计算表现指标
        const completionRate = Math.min(progress || 0, 100);
        const masteryLevel = Math.min(completionRate * 0.8 + Math.random() * 20, 100);
        const efficiencyScore = Math.min(60 + (durationMinutes / 10) + Math.random() * 30, 100);
        const avgFocusDuration = Math.min(20 + (durationMinutes / 20) + Math.random() * 15, 60);
        
        // 更新或插入学生课程表现数据
        await connection.execute(`
          INSERT INTO student_course_performance 
          (user_id, course_id, analysis_period, completion_rate, mastery_level, 
           efficiency_score, avg_focus_duration, total_study_time, chapter_progress, created_at, updated_at) 
          VALUES (?, ?, 'weekly', ?, ?, ?, ?, ?, ?, NOW(), NOW())
          ON DUPLICATE KEY UPDATE
          completion_rate = VALUES(completion_rate),
          mastery_level = VALUES(mastery_level),
          efficiency_score = VALUES(efficiency_score),
          avg_focus_duration = VALUES(avg_focus_duration),
          total_study_time = VALUES(total_study_time),
          updated_at = NOW()
        `, [
          user_id, course_id, completionRate, masteryLevel,
          efficiencyScore, avgFocusDuration, durationMinutes,
          JSON.stringify({
            progress_rate: completionRate,
            total_chapters: Math.floor(Math.random() * 5) + 3,
            completed_chapters: Math.floor(completionRate / 25)
          })
        ]);
      }
    }

    // 3. 生成章节进度数据（用于知识掌握分布）
    console.log('📖 生成章节进度数据...');
    
    // 获取所有章节
    const [chapters] = await connection.execute(`
      SELECT cc.chapter_id, cc.course_id, c.teacher_user_id
      FROM course_chapter cc
      JOIN course c ON cc.course_id = c.course_id
      WHERE c.teacher_user_id = 15
    `);
    
    for (const chapter of chapters) {
      // 获取该课程的学生
      const [students] = await connection.execute(`
        SELECT uc.user_id
        FROM user_course uc
        WHERE uc.course_id = ? AND uc.is_enrolled = 1
      `, [chapter.course_id]);
      
      for (const student of students) {
        // 生成章节进度（基于课程整体进度）
        const [courseProgress] = await connection.execute(`
          SELECT progress FROM user_course 
          WHERE user_id = ? AND course_id = ?
        `, [student.user_id, chapter.course_id]);
        
        const baseProgress = courseProgress[0]?.progress || 0;
        const chapterProgress = Math.min(baseProgress + (Math.random() - 0.5) * 30, 100);
        const progressRate = Math.max(0, chapterProgress);
        
        // 插入章节进度数据
        await connection.execute(`
          INSERT INTO chapter_progress (user_id, chapter_id, progress_rate, completed, last_updated)
          VALUES (?, ?, ?, ?, NOW())
          ON DUPLICATE KEY UPDATE
          progress_rate = VALUES(progress_rate),
          completed = VALUES(completed),
          last_updated = NOW()
        `, [student.user_id, chapter.chapter_id, progressRate, progressRate >= 100 ? 1 : 0]);
      }
    }

    console.log('✅ 学习时长和进度数据更新完成！');
    
    // 显示更新统计
    const [stats] = await connection.execute(`
      SELECT 
        (SELECT COUNT(*) FROM user_course WHERE total_learn_duration > 0) as updated_courses,
        (SELECT AVG(total_learn_duration/60) FROM user_course WHERE total_learn_duration > 0) as avg_duration_minutes,
        (SELECT COUNT(*) FROM student_course_performance) as performance_records,
        (SELECT COUNT(*) FROM chapter_progress) as chapter_progress_records
    `);
    
    console.log('📊 更新统计:');
    console.log(`   已更新学习时长的课程: ${stats[0].updated_courses}`);
    console.log(`   平均学习时长: ${Math.round(stats[0].avg_duration_minutes)}分钟`);
    console.log(`   课程表现记录: ${stats[0].performance_records}`);
    console.log(`   章节进度记录: ${stats[0].chapter_progress_records}`);

  } catch (error) {
    console.error('❌ 更新学习时长失败:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('📊 数据库连接已关闭');
    }
  }
}

// 运行脚本
updateLearningDuration();