// 为学情分析添加测试数据
const mysql = require('mysql2/promise');

// 数据库配置
const dbConfig = {
  host: '127.0.0.1',
  user: 'root',
  password: '123456',
  database: 'mzcourse',
  charset: 'utf8mb4'
};

async function addTestData() {
  let connection;
  
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('📊 连接数据库成功');

    // 1. 添加更多学生用户
    console.log('👥 添加学生用户...');
    const students = [
      { user_name: '张三', email: 'student1@test.com', password_hash: '$2b$10$example1', role: 'learner' },
      { user_name: '李四', email: 'student2@test.com', password_hash: '$2b$10$example2', role: 'learner' },
      { user_name: '王五', email: 'student3@test.com', password_hash: '$2b$10$example3', role: 'learner' },
      { user_name: '赵六', email: 'student4@test.com', password_hash: '$2b$10$example4', role: 'learner' },
      { user_name: '钱七', email: 'student5@test.com', password_hash: '$2b$10$example5', role: 'learner' },
      { user_name: '孙八', email: 'student6@test.com', password_hash: '$2b$10$example6', role: 'learner' },
      { user_name: '周九', email: 'student7@test.com', password_hash: '$2b$10$example7', role: 'learner' },
      { user_name: '吴十', email: 'student8@test.com', password_hash: '$2b$10$example8', role: 'learner' }
    ];

    for (const student of students) {
      await connection.execute(
        `INSERT IGNORE INTO user (user_name, email, password_hash, role, register_time, created_at) 
         VALUES (?, ?, ?, ?, NOW(), NOW())`,
        [student.user_name, student.email, student.password_hash, student.role]
      );
    }

    // 获取新添加的学生ID
    const [studentRows] = await connection.execute(
      `SELECT user_id, user_name FROM user WHERE role = 'learner' ORDER BY user_id`
    );
    console.log(`✅ 学生用户数量: ${studentRows.length}`);

    // 2. 为教师ID=15的课程添加学生报名记录
    console.log('📚 添加学生课程报名记录...');
    const [teacherCourses] = await connection.execute(
      `SELECT course_id, course_name FROM course WHERE teacher_user_id = 15`
    );
    
    console.log(`📖 教师课程数量: ${teacherCourses.length}`);

    for (const course of teacherCourses) {
      // 每个课程随机选择5-8个学生报名
      const enrollCount = Math.floor(Math.random() * 4) + 5; // 5-8个学生
      const selectedStudents = studentRows.slice(0, enrollCount);
      
      for (const student of selectedStudents) {
        await connection.execute(
          `INSERT IGNORE INTO user_course (user_id, course_id, enroll_time, progress, is_enrolled) 
           VALUES (?, ?, NOW(), ?, 1)`,
          [student.user_id, course.course_id, Math.floor(Math.random() * 100)]
        );
      }
      console.log(`📝 课程 "${course.course_name}" 添加了 ${enrollCount} 个学生`);
    }

    // 3. 添加学生课程表现数据
    console.log('📈 添加学生课程表现数据...');
    for (const course of teacherCourses) {
      const [enrolledStudents] = await connection.execute(
        `SELECT user_id FROM user_course WHERE course_id = ?`,
        [course.course_id]
      );

      for (const student of enrolledStudents) {
        // 生成随机的表现数据
        const completionRate = Math.floor(Math.random() * 40) + 60; // 60-100%
        const masteryLevel = Math.floor(Math.random() * 30) + 70; // 70-100%
        const efficiencyScore = Math.floor(Math.random() * 25) + 65; // 65-90%
        const avgFocusDuration = Math.floor(Math.random() * 30) + 20; // 20-50分钟
        const totalStudyTime = Math.floor(Math.random() * 300) + 100; // 100-400分钟

        await connection.execute(
          `INSERT INTO student_course_performance 
           (user_id, course_id, analysis_period, completion_rate, mastery_level, 
            efficiency_score, avg_focus_duration, total_study_time, chapter_progress, created_at) 
           VALUES (?, ?, 'weekly', ?, ?, ?, ?, ?, ?, NOW())
           ON DUPLICATE KEY UPDATE
           completion_rate = VALUES(completion_rate),
           mastery_level = VALUES(mastery_level),
           efficiency_score = VALUES(efficiency_score),
           avg_focus_duration = VALUES(avg_focus_duration),
           total_study_time = VALUES(total_study_time),
           updated_at = NOW()`,
          [
            student.user_id, course.course_id, completionRate, masteryLevel,
            efficiencyScore, avgFocusDuration, totalStudyTime,
            JSON.stringify({
              progress_rate: completionRate,
              total_chapters: Math.floor(Math.random() * 5) + 3,
              completed_chapters: Math.floor(Math.random() * 3) + 1
            })
          ]
        );
      }
    }

    // 4. 添加大量学习行为数据
    console.log('🎯 添加学习行为数据...');
    const behaviorTypes = [
      'play', 'pause', 'seek_forward', 'seek_backward', 'speed_up', 'speed_down',
      'note_taking', 'question_ask', 'discussion', 'bookmark', 'replay',
      'focus_lost', 'focus_regain', 'chapter_complete', 'quiz_attempt', 'resource_download'
    ];

    const behaviorData = {
      'play': { action: 'start' },
      'pause': { reason: 'user' },
      'seek_forward': { skip_duration: 30 },
      'seek_backward': { rewind_duration: 15 },
      'speed_up': { new_speed: 1.5, old_speed: 1 },
      'speed_down': { new_speed: 0.75, old_speed: 1 },
      'note_taking': { note_type: 'text', note_length: 50 },
      'question_ask': { question_type: 'text' },
      'discussion': { discussion_type: 'comment' },
      'bookmark': { bookmark_position: 300 },
      'replay': { replay_duration: 60 },
      'focus_lost': { lost_at_position: 500 },
      'focus_regain': { focus_lost_duration: 30000 },
      'chapter_complete': { completion_rate: 100 },
      'quiz_attempt': { quiz_type: 'multiple_choice' },
      'resource_download': { resource_type: 'pdf' }
    };

    // 为每个课程的每个学生生成学习行为
    for (const course of teacherCourses) {
      const [enrolledStudents] = await connection.execute(
        `SELECT user_id FROM user_course WHERE course_id = ?`,
        [course.course_id]
      );

      const [chapters] = await connection.execute(
        `SELECT chapter_id FROM course_chapter WHERE course_id = ?`,
        [course.course_id]
      );

      for (const student of enrolledStudents) {
        // 每个学生生成50-100个学习行为
        const behaviorCount = Math.floor(Math.random() * 51) + 50;
        
        for (let i = 0; i < behaviorCount; i++) {
          const behaviorType = behaviorTypes[Math.floor(Math.random() * behaviorTypes.length)];
          const chapterId = chapters.length > 0 ? chapters[Math.floor(Math.random() * chapters.length)].chapter_id : null;
          const duration = Math.floor(Math.random() * 120); // 0-120秒
          const videoPosition = Math.floor(Math.random() * 1200); // 0-1200秒

          await connection.execute(
            `INSERT INTO learning_behaviors 
             (user_id, course_id, chapter_id, behavior_type, behavior_data, duration, video_position, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, DATE_SUB(NOW(), INTERVAL ? DAY))`,
            [
              student.user_id, course.course_id, chapterId, behaviorType,
              JSON.stringify(behaviorData[behaviorType]), duration, videoPosition,
              Math.floor(Math.random() * 30) // 过去30天内的随机时间
            ]
          );
        }
      }
      console.log(`🎯 课程 "${course.course_name}" 添加了学习行为数据`);
    }

    // 5. 更新行为统计表
    console.log('📊 更新行为统计表...');
    await connection.execute(`
      INSERT INTO behavior_statistics (teacher_id, course_id, behavior_name, behavior_count, behavior_weight)
      SELECT 
        c.teacher_user_id,
        lb.course_id,
        CASE lb.behavior_type
          WHEN 'play' THEN '开始学习'
          WHEN 'pause' THEN '暂停思考'
          WHEN 'seek_forward' THEN '快进跳跃'
          WHEN 'seek_backward' THEN '回看复习'
          WHEN 'speed_up' THEN '加速播放'
          WHEN 'speed_down' THEN '减速细听'
          WHEN 'note_taking' THEN '记录笔记'
          WHEN 'question_ask' THEN '提出问题'
          WHEN 'discussion' THEN '参与讨论'
          WHEN 'bookmark' THEN '添加书签'
          WHEN 'replay' THEN '重复播放'
          WHEN 'focus_lost' THEN '注意力分散'
          WHEN 'focus_regain' THEN '重新专注'
          WHEN 'chapter_complete' THEN '章节完成'
          WHEN 'quiz_attempt' THEN '尝试测验'
          WHEN 'resource_download' THEN '下载资源'
          ELSE lb.behavior_type
        END as behavior_name,
        COUNT(*) as behavior_count,
        (COUNT(*) * 100.0 / (
          SELECT COUNT(*) 
          FROM learning_behaviors lb2 
          JOIN course c2 ON lb2.course_id = c2.course_id 
          WHERE c2.teacher_user_id = c.teacher_user_id AND lb2.course_id = lb.course_id
        )) as behavior_weight
      FROM learning_behaviors lb
      JOIN course c ON lb.course_id = c.course_id
      WHERE c.teacher_user_id = 15
      GROUP BY c.teacher_user_id, lb.course_id, lb.behavior_type
      ON DUPLICATE KEY UPDATE
        behavior_count = VALUES(behavior_count),
        behavior_weight = VALUES(behavior_weight),
        last_updated = CURRENT_TIMESTAMP
    `);

    // 6. 生成总体统计数据（course_id = NULL）
    await connection.execute(`
      INSERT INTO behavior_statistics (teacher_id, course_id, behavior_name, behavior_count, behavior_weight)
      SELECT 
        c.teacher_user_id,
        NULL as course_id,
        CASE lb.behavior_type
          WHEN 'play' THEN '开始学习'
          WHEN 'pause' THEN '暂停思考'
          WHEN 'seek_forward' THEN '快进跳跃'
          WHEN 'seek_backward' THEN '回看复习'
          WHEN 'speed_up' THEN '加速播放'
          WHEN 'speed_down' THEN '减速细听'
          WHEN 'note_taking' THEN '记录笔记'
          WHEN 'question_ask' THEN '提出问题'
          WHEN 'discussion' THEN '参与讨论'
          WHEN 'bookmark' THEN '添加书签'
          WHEN 'replay' THEN '重复播放'
          WHEN 'focus_lost' THEN '注意力分散'
          WHEN 'focus_regain' THEN '重新专注'
          WHEN 'chapter_complete' THEN '章节完成'
          WHEN 'quiz_attempt' THEN '尝试测验'
          WHEN 'resource_download' THEN '下载资源'
          ELSE lb.behavior_type
        END as behavior_name,
        COUNT(*) as behavior_count,
        (COUNT(*) * 100.0 / (
          SELECT COUNT(*) 
          FROM learning_behaviors lb2 
          JOIN course c2 ON lb2.course_id = c2.course_id 
          WHERE c2.teacher_user_id = c.teacher_user_id
        )) as behavior_weight
      FROM learning_behaviors lb
      JOIN course c ON lb.course_id = c.course_id
      WHERE c.teacher_user_id = 15
      GROUP BY c.teacher_user_id, lb.behavior_type
      ON DUPLICATE KEY UPDATE
        behavior_count = VALUES(behavior_count),
        behavior_weight = VALUES(behavior_weight),
        last_updated = CURRENT_TIMESTAMP
    `);

    console.log('✅ 测试数据添加完成！');
    
    // 显示统计信息
    const [stats] = await connection.execute(`
      SELECT 
        (SELECT COUNT(*) FROM user WHERE role = 'learner') as total_students,
        (SELECT COUNT(*) FROM user_course uc JOIN course c ON uc.course_id = c.course_id WHERE c.teacher_user_id = 15) as total_enrollments,
        (SELECT COUNT(*) FROM learning_behaviors lb JOIN course c ON lb.course_id = c.course_id WHERE c.teacher_user_id = 15) as total_behaviors,
        (SELECT COUNT(*) FROM behavior_statistics WHERE teacher_id = 15) as total_statistics
    `);
    
    console.log('📊 数据统计:');
    console.log(`   学生总数: ${stats[0].total_students}`);
    console.log(`   课程报名数: ${stats[0].total_enrollments}`);
    console.log(`   学习行为数: ${stats[0].total_behaviors}`);
    console.log(`   行为统计数: ${stats[0].total_statistics}`);

  } catch (error) {
    console.error('❌ 添加测试数据失败:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('📊 数据库连接已关闭');
    }
  }
}

// 运行脚本
addTestData();