// 为test课程添加测试数据
const pool = require('../config/database');

async function addTestCourseData() {
  try {
    console.log('🎯 为test课程添加测试数据...\n');
    
    // 1. 首先查找test课程的ID和教师ID
    const [testCourse] = await pool.execute(`
      SELECT course_id, teacher_user_id, course_name 
      FROM course 
      WHERE course_name LIKE '%test%' 
      ORDER BY created_time DESC 
      LIMIT 1
    `);
    
    if (testCourse.length === 0) {
      console.log('❌ 未找到test课程');
      return;
    }
    
    const courseId = testCourse[0].course_id;
    const teacherId = testCourse[0].teacher_user_id;
    console.log(`📚 找到课程: ${testCourse[0].course_name} (ID: ${courseId})`);
    
    // 2. 查找一些学生用户（排除教师）
    const [students] = await pool.execute(`
      SELECT user_id, user_name 
      FROM user 
      WHERE role = 'learner' AND user_id != ?
      LIMIT 5
    `, [teacherId]);
    
    console.log(`👥 找到 ${students.length} 个学生用户`);
    
    // 3. 为课程添加学生报名记录
    for (const student of students) {
      try {
        // 生成随机的学习数据
        const progress = Math.floor(Math.random() * 100) + 1; // 1-100%
        const totalDuration = Math.floor(Math.random() * 300) + 60; // 60-360分钟
        
        await pool.execute(`
          INSERT INTO user_course (user_id, course_id, progress, total_learn_duration, enroll_time, last_learn_time, is_enrolled)
          VALUES (?, ?, ?, ?, DATE_SUB(NOW(), INTERVAL ? DAY), NOW(), 1)
          ON DUPLICATE KEY UPDATE 
          progress = VALUES(progress),
          total_learn_duration = VALUES(total_learn_duration),
          is_enrolled = 1
        `, [student.user_id, courseId, progress, totalDuration, Math.floor(Math.random() * 30)]);
        
        console.log(`✅ 添加学生 ${student.user_name}: 进度${progress}%, 时长${totalDuration}分钟`);
        
        // 4. 添加学习详细记录
        for (let i = 0; i < 5; i++) {
          await pool.execute(`
            INSERT INTO learning_detail (user_id, course_id, video_id, learn_time, learn_duration, complete_rate, current_position)
            VALUES (?, ?, 41, DATE_SUB(NOW(), INTERVAL ? HOUR), ?, ?, ?)
          `, [
            student.user_id, 
            courseId, 
            Math.floor(Math.random() * 24), // 随机小时
            Math.floor(Math.random() * 60) + 10, // 10-70分钟
            Math.floor(Math.random() * 100), // 0-100%
            Math.floor(Math.random() * 1000) // 随机位置
          ]);
        }
        
      } catch (error) {
        console.log(`⚠️ 添加学生 ${student.user_name} 数据失败:`, error.message);
      }
    }
    
    // 5. 添加课程评价
    const ratings = [4.5, 5.0, 4.0, 4.8, 3.5];
    const reviews = [
      '课程内容很棒，老师讲解清晰！',
      '学到了很多实用的知识，推荐！',
      '内容丰富，但希望能有更多实践案例',
      '非常好的课程，值得学习',
      '老师很专业，课程质量很高'
    ];
    
    for (let i = 0; i < Math.min(students.length, ratings.length); i++) {
      try {
        await pool.execute(`
          INSERT INTO course_review (course_id, user_id, rating, review_text, created_time)
          VALUES (?, ?, ?, ?, DATE_SUB(NOW(), INTERVAL ? DAY))
          ON DUPLICATE KEY UPDATE 
          rating = VALUES(rating),
          review_text = VALUES(review_text)
        `, [courseId, students[i].user_id, ratings[i], reviews[i], Math.floor(Math.random() * 15)]);
        
        console.log(`⭐ 添加评价: ${students[i].user_name} - ${ratings[i]}星`);
      } catch (error) {
        console.log(`⚠️ 添加评价失败:`, error.message);
      }
    }
    
    // 6. 更新课程统计信息
    const [stats] = await pool.execute(`
      SELECT 
        COUNT(DISTINCT uc.user_id) as student_count,
        AVG(cr.rating) as avg_rating,
        COUNT(cr.review_id) as review_count
      FROM course c
      LEFT JOIN user_course uc ON c.course_id = uc.course_id AND uc.is_enrolled = 1
      LEFT JOIN course_review cr ON c.course_id = cr.course_id
      WHERE c.course_id = ?
    `, [courseId]);
    
    if (stats.length > 0) {
      await pool.execute(`
        UPDATE course 
        SET student_count = ?, rating = ?, rating_count = ?
        WHERE course_id = ?
      `, [
        stats[0].student_count || 0,
        Math.round((stats[0].avg_rating || 0) * 10) / 10,
        stats[0].review_count || 0,
        courseId
      ]);
      
      console.log(`📊 更新课程统计: 学生${stats[0].student_count}人, 评分${Math.round((stats[0].avg_rating || 0) * 10) / 10}, 评价${stats[0].review_count}条`);
    }
    
    // 7. 添加一些讨论/评论数据（如果有视频的话）
    const [videos] = await pool.execute(`
      SELECT cv.video_id 
      FROM course_video cv
      JOIN course_chapter cc ON cv.chapter_id = cc.chapter_id
      WHERE cc.course_id = ?
      LIMIT 3
    `, [courseId]);
    
    if (videos.length > 0) {
      const comments = [
        '这个知识点很重要，需要多练习',
        '老师讲得很清楚，谢谢！',
        '有没有相关的练习题？',
        '这部分内容有点难理解',
        '很实用的内容，学会了！'
      ];
      
      for (let i = 0; i < Math.min(videos.length, students.length); i++) {
        try {
          await pool.execute(`
            INSERT INTO video_comment (video_id, user_id, comment_text, created_time)
            VALUES (?, ?, ?, DATE_SUB(NOW(), INTERVAL ? HOUR))
          `, [
            videos[i].video_id,
            students[i % students.length].user_id,
            comments[i % comments.length],
            Math.floor(Math.random() * 48)
          ]);
          
          console.log(`💬 添加视频评论: 视频${videos[i].video_id}`);
        } catch (error) {
          console.log(`⚠️ 添加评论失败:`, error.message);
        }
      }
    }
    
    console.log('\n🎉 test课程数据添加完成！');
    
  } catch (error) {
    console.error('❌ 添加测试数据失败:', error);
  } finally {
    process.exit(0);
  }
}

// 运行脚本
addTestCourseData();