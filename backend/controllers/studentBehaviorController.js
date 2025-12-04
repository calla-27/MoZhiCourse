// controllers/studentBehaviorController.js
const { pool } = require('../config/database');

exports.getBehaviorOverview = async (req, res) => {
  try {
    console.log('\n=== 📊 GET BEHAVIOR OVERVIEW START ===');
    console.log('用户ID:', req.user.userId);
    
    const userId = req.user.userId;
    
    // 1. 获取用户已报名课程 - 根据您的数据库结构调整
    const [enrolledCourses] = await pool.query(`
      SELECT 
        c.course_id,
        c.course_name,
        c.course_desc,
        c.teacher_user_id,
        c.category_id,
        c.cover_img,
        c.difficulty_level,
        c.course_duration,
        c.student_count,
        c.rating,
        uc.enroll_time,
        uc.progress,
        uc.last_learn_time,
        uc.total_learn_duration,
        uc.is_completed,
        uc.completed_time
      FROM user_course uc
      JOIN course c ON uc.course_id = c.course_id
      WHERE uc.user_id = ? 
        AND uc.is_enrolled = 1
      ORDER BY uc.last_learn_time DESC
    `, [userId]);
    
    console.log('✅ 获取到已报名课程:', enrolledCourses.length, '门');
    
    // 2. 如果有学生课程表现数据，获取它
    let coursePerformanceData = [];
    if (enrolledCourses.length > 0) {
      const courseIds = enrolledCourses.map(course => course.course_id);
      const [performanceRows] = await pool.query(`
        SELECT 
          course_id,
          completion_rate,
          mastery_level,
          efficiency_score,
          avg_focus_duration,
          total_study_time
        FROM student_course_performance 
        WHERE user_id = ? AND course_id IN (?)
      `, [userId, courseIds]);
      
      coursePerformanceData = performanceRows;
    }

    // 3. 计算学习概览数据
    let totalStudyMinutes = 0;
    let totalProgress = 0;
    let totalMasteryLevel = 0;
    let courseCount = 0;

    enrolledCourses.forEach(course => {
      const performance = coursePerformanceData.find(p => p.course_id === course.course_id);
      
      // 1. 学习总时长：使用 performance 表的数据，如果没有则使用 user_course 表的数据
      // 同时确保两个数据源都有合理值
      let courseStudyTime = 0;
      
      if (performance && performance.total_study_time) {
        courseStudyTime = performance.total_study_time;
      } else if (course.total_learn_duration) {
        courseStudyTime = course.total_learn_duration;
      }
      
      // 调试输出每门课程的学习时长
      console.log(`课程 ${course.course_name} 学习时长: 
        performance.total_study_time = ${performance?.total_study_time || 0}, 
        course.total_learn_duration = ${course.total_learn_duration || 0}, 
        最终取值 = ${courseStudyTime}`);
      
      totalStudyMinutes += courseStudyTime;
      
      // 2. 学习进度
      const courseProgress = course.progress || 0;
      totalProgress += courseProgress;
      
      // 3. 知识掌握度
      const courseMastery = performance?.mastery_level || 0;
      totalMasteryLevel += courseMastery;
      
      courseCount++;
    });

    // 避免除零
    if (courseCount === 0) {
      courseCount = 1;
    }

    // 4. 计算活跃天数
    const [activeDaysRows] = await pool.query(`
      SELECT COUNT(DISTINCT DATE(learn_time)) as active_days
      FROM learning_detail 
      WHERE user_id = ? 
        AND learn_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    `, [userId]);

    // 5. 计算日均学习时长
    const dailyAverageMinutes = activeDaysRows[0]?.active_days > 0 
      ? Math.round(totalStudyMinutes / activeDaysRows[0].active_days) 
      : 0;

    // 6. 构建概览数据对象（只有一个 overview 定义）
    const overview = {
      // 核心三个指标
      total_study_minutes: totalStudyMinutes,                 // 学习总时长（分钟）
      avg_progress: Math.round(totalProgress / courseCount),  // 平均学习进度（%）
      avg_mastery_level: Math.round(totalMasteryLevel / courseCount), // 平均知识掌握度（%）
      
      // 辅助信息
      active_days: activeDaysRows[0]?.active_days || 0,       // 活跃天数
      analyzed_courses: enrolledCourses.length,               // 已分析课程数
      daily_average_minutes: dailyAverageMinutes,            // 日均学习时长
      
      // 兼容性字段（保持原有字段名）
      avg_completion_rate: Math.round(totalProgress / courseCount)
    };

    console.log('计算后的概览数据:', {
      total_study_minutes: totalStudyMinutes,
      avg_progress: Math.round(totalProgress / courseCount),
      avg_mastery_level: Math.round(totalMasteryLevel / courseCount),
      course_count: courseCount,
      active_days: activeDaysRows[0]?.active_days || 0
    });

    // 7. 获取学习风格分析 - 使用正确的表名
    const [learningStyleRows] = await pool.query(`
      SELECT 
        learning_style_type, 
        style_score, 
        analysis_date 
      FROM student_learning_style 
      WHERE user_id = ?
      ORDER BY analysis_date DESC 
      LIMIT 1
    `, [userId]);
    
    let learningStyle = null;
    if (learningStyleRows.length > 0) {
      learningStyle = learningStyleRows[0];
    } else {
      // 如果没有学习风格数据，返回默认值
      learningStyle = {
        learning_style_type: '分析中...',
        style_score: '{}',
        analysis_date: new Date()
      };
    }
    
    console.log('✅ 学习风格数据获取完成');
    
    // 8. 获取用户倍速使用概况
    const speedOverview = await getUserSpeedOverview(userId);
    
    // 6. 返回真实数据
    const responseData = {
      enrolledCourses,
      overview,
      learningStyle,
      coursePerformance: coursePerformanceData,
      speedOverview  // 添加倍速数据
    };
    
    console.log('=== 📊 GET BEHAVIOR OVERVIEW END ===\n');
    
    res.json({
      success: true,
      data: responseData
    });
    
  } catch (error) {
    console.error('❌ 获取学情概览失败:', error);
    
    res.status(500).json({
      success: false,
      message: '获取学情概览失败',
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};

// 获取用户已报名课程列表
exports.getEnrolledCourses = async (req, res) => {
  try {
    console.log('\n=== 📚 GET ENROLLED COURSES START ===');
    const userId = req.user.userId;
    
    // 在 getEnrolledCourses 函数中，确保正确获取学习时长数据
const [courses] = await pool.query(`
  SELECT 
    c.course_id,
    c.course_name,
    c.course_desc,
    c.cover_img,
    c.difficulty_level,
    c.student_count,
    c.rating,
    uc.progress,
    uc.last_learn_time,
    uc.total_learn_duration,
    uc.is_completed,
    COALESCE(sp.completion_rate, 0) as completion_rate,
    COALESCE(sp.mastery_level, 0) as mastery_level,
    COALESCE(sp.efficiency_score, 0) as efficiency_score,
    COALESCE(sp.total_study_time, uc.total_learn_duration, 0) as total_study_time
  FROM user_course uc
  JOIN course c ON uc.course_id = c.course_id
  LEFT JOIN student_course_performance sp ON uc.user_id = sp.user_id AND uc.course_id = sp.course_id
  WHERE uc.user_id = ? 
    AND uc.is_enrolled = 1
  ORDER BY uc.last_learn_time DESC
`, [userId]);
    
    console.log('✅ 获取到报名课程:', courses.length, '门');
    console.log('=== 📚 GET ENROLLED COURSES END ===\n');
    
    res.json({
      success: true,
      data: courses
    });
    
  } catch (error) {
    console.error('❌ 获取报名课程失败:', error);
    res.status(500).json({
      success: false,
      message: '获取报名课程失败',
      error: error.message
    });
  }
};

// 获取课程详细分析
exports.getCourseAnalysis = async (req, res) => {
  try {
    const userId = req.user.userId;
    const courseId = req.params.courseId;
    
    console.log(`📊 获取课程分析 - 用户ID: ${userId}, 课程ID: ${courseId}`);
    
    // 1. 获取课程基本信息
    const [courseInfoRows] = await pool.query(`
      SELECT 
        c.course_id,
        c.course_name,
        c.course_desc,
        c.cover_img,
        c.difficulty_level,
        c.course_duration,
        c.student_count,
        c.rating,
        u.user_name as teacher_name,
        cat.category_name,
        uc.progress,
        uc.last_learn_time,
        uc.total_learn_duration
      FROM user_course uc
      JOIN course c ON uc.course_id = c.course_id
      JOIN user u ON c.teacher_user_id = u.user_id
      LEFT JOIN course_category cat ON c.category_id = cat.category_id
      WHERE uc.user_id = ? AND uc.course_id = ?
    `, [userId, courseId]);
    
    if (courseInfoRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '课程不存在或您未报名此课程'
      });
    }
    
    const courseInfo = courseInfoRows[0];
    
    // 2. 获取章节进度
    const [chapterProgress] = await pool.query(`
      SELECT 
        cc.chapter_id,
        cc.chapter_title,
        cc.order_index,
        (
          SELECT COUNT(*) 
          FROM course_video cv 
          WHERE cv.chapter_id = cc.chapter_id
        ) as total_videos,
        (
          SELECT COUNT(DISTINCT ld.video_id)
          FROM learning_detail ld
          WHERE ld.user_id = ? 
            AND ld.video_id IN (
              SELECT video_id 
              FROM course_video 
              WHERE chapter_id = cc.chapter_id
            )
            AND ld.complete_rate >= 90
        ) as completed_videos,
        (
          SELECT COALESCE(SUM(ld.learn_duration), 0) / 60
          FROM learning_detail ld
          WHERE ld.user_id = ?
            AND ld.video_id IN (
              SELECT video_id 
              FROM course_video 
              WHERE chapter_id = cc.chapter_id
            )
        ) as study_duration_minutes
      FROM course_chapter cc
      WHERE cc.course_id = ?
      ORDER BY cc.order_index
    `, [userId, userId, courseId]);
    
    // 计算每个章节的进度率
    chapterProgress.forEach(chapter => {
        // 计算进度率
        chapter.progress_rate = chapter.total_videos > 0 
            ? Math.round((chapter.completed_videos / chapter.total_videos) * 100) 
            : 0;
        
        // 确保前端需要的字段存在
        chapter.chapter_progress_rate = chapter.progress_rate;  // 添加这个字段
        chapter.chapter_mastery = chapter.progress_rate;        // 添加掌握度字段
        });
    
    // 3. 获取专注度数据
    const [focusData] = await pool.query(`
      SELECT 
        DATE(session_date) as date,
        SUM(focus_duration) as total_focus,
        AVG(focus_rate) as avg_focus_rate,
        COUNT(*) as session_count
      FROM student_focus_analysis
      WHERE user_id = ? AND course_id = ?
        AND session_date >= DATE_SUB(NOW(), INTERVAL 15 DAY)
      GROUP BY DATE(session_date)
      ORDER BY date
    `, [userId, courseId]);
    
    // 4. 获取课程表现数据
    const [performanceRows] = await pool.query(`
      SELECT *
      FROM student_course_performance
      WHERE user_id = ? AND course_id = ?
      ORDER BY updated_at DESC
      LIMIT 1
    `, [userId, courseId]);
    
    // 5. 获取该课程的倍速使用情况
    const courseSpeedUsage = await getCourseSpeedUsage(userId, courseId);
    
    res.json({
      success: true,
      data: {
        courseInfo,
        chapterProgress,
        focusData: focusData || [],
        performance: performanceRows[0] || null,
        speedUsage: courseSpeedUsage  // 添加倍速数据
      }
    });
    
  } catch (error) {
    console.error('获取课程分析失败:', error);
    res.status(500).json({
      success: false,
      message: '获取课程分析失败',
      error: error.message
    });
  }
};

// 获取学习趋势数据
exports.getLearningTrend = async (req, res) => {
  try {
    const userId = req.user.userId;
    const days = parseInt(req.query.days) || 30; // 默认最近30天
    
    console.log(`📈 获取学习趋势 - 用户ID: ${userId}, 天数: ${days}`);
    
    // 获取学习时间趋势
    const [trendData] = await pool.query(`
      SELECT 
        DATE(learn_time) as date,
        SUM(learn_duration) as total_duration,
        COUNT(DISTINCT video_id) as videos_watched,
        AVG(complete_rate) as avg_completion_rate
      FROM learning_detail
      WHERE user_id = ? 
        AND learn_time >= DATE_SUB(NOW(), INTERVAL ? DAY)
      GROUP BY DATE(learn_time)
      ORDER BY date
    `, [userId, days]);
    
    // 获取专注度趋势
    const [focusTrend] = await pool.query(`
      SELECT 
        DATE(session_date) as date,
        AVG(focus_rate) as avg_focus_rate,
        SUM(focus_duration) as total_focus_duration
      FROM student_focus_analysis
      WHERE user_id = ? 
        AND session_date >= DATE_SUB(NOW(), INTERVAL ? DAY)
      GROUP BY DATE(session_date)
      ORDER BY date
    `, [userId, days]);
    
    res.json({
      success: true,
      data: {
        studyTrend: trendData,
        focusTrend: focusTrend,
        days: days
      }
    });
    
  } catch (error) {
    console.error('获取学习趋势失败:', error);
    res.status(500).json({
      success: false,
      message: '获取学习趋势失败',
      error: error.message
    });
  }
};

// 获取学习建议
exports.getLearningSuggestions = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    console.log(`💡 获取学习建议 - 用户ID: ${userId}`);
    
    // 这里可以根据用户的学习数据生成个性化建议
    const suggestions = [
      {
        id: 1,
        type: 'focus_improvement',
        title: '提升专注度',
        content: '根据您的专注度数据，建议每天设定固定的学习时间段，避免频繁切换任务。',
        priority: 'high'
      },
      {
        id: 2,
        type: 'course_completion',
        title: '完成未结课程',
        content: '您有几门课程的完成率较低，建议先集中精力完成一门课程的学习。',
        priority: 'medium'
      },
      {
        id: 3,
        type: 'learning_style',
        title: '个性化学习',
        content: '根据您的学习风格分析，视觉型学习材料可能更适合您。',
        priority: 'low'
      }
    ];
    
    res.json({
      success: true,
      data: suggestions
    });
    
  } catch (error) {
    console.error('获取学习建议失败:', error);
    res.status(500).json({
      success: false,
      message: '获取学习建议失败',
      error: error.message
    });
  }
};

// 更新学习目标进度
exports.updateGoalProgress = async (req, res) => {
  try {
    const userId = req.user.userId;
    const goalId = req.params.goalId;
    const { progress_value } = req.body;
    
    console.log(`🎯 更新学习目标进度 - 用户ID: ${userId}, 目标ID: ${goalId}, 进度: ${progress_value}`);
    
    // 验证目标是否存在且属于当前用户
    const [goalRows] = await pool.query(`
      SELECT * FROM student_learning_goal 
      WHERE id = ? AND user_id = ?
    `, [goalId, userId]);
    
    if (goalRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '学习目标不存在'
      });
    }
    
    // 更新目标进度
    const [result] = await pool.query(`
      UPDATE student_learning_goal 
      SET current_value = ?,
          progress_rate = ROUND((? / target_value) * 100, 2),
          updated_at = NOW()
      WHERE id = ? AND user_id = ?
    `, [progress_value, progress_value, goalId, userId]);
    
    if (result.affectedRows === 0) {
      return res.status(500).json({
        success: false,
        message: '更新失败'
      });
    }
    
    res.json({
      success: true,
      message: '学习目标进度更新成功'
    });
    
  } catch (error) {
    console.error('更新学习目标进度失败:', error);
    res.status(500).json({
      success: false,
      message: '更新学习目标进度失败',
      error: error.message
    });
  }
};

// ==================== 新增：倍速播放相关功能 ====================

// 获取倍速播放使用情况
// controllers/studentBehaviorController.js 中的 getPlaybackSpeedUsage 函数
exports.getPlaybackSpeedUsage = async (req, res) => {
  try {
    const userId = req.user.userId;
    const rawCourseId = req.query.courseId;
    
    console.log(`⚡ 获取倍速使用情况 - 用户ID: ${userId}, 课程ID: ${rawCourseId || 'overall'}`);

    // 更健壮的 courseId 处理
    let courseId = null;
    if (rawCourseId && rawCourseId !== 'overall' && rawCourseId !== 'null' && rawCourseId !== 'undefined') {
      const parsed = parseInt(rawCourseId, 10);
      if (!isNaN(parsed)) {
        courseId = parsed;
      }
    }

    console.log(`处理后的课程ID: ${courseId || '全部课程'}`);

    // 使用 learning_detail 表来查询倍速数据
    let query = `
      SELECT 
        play_speed,
        COUNT(*) as usage_count,
        SUM(learn_duration) as total_duration
      FROM learning_detail
      WHERE user_id = ? 
        AND play_speed IS NOT NULL 
        AND play_speed > 0
    `;

    const params = [userId];

    if (courseId) {
      query += ' AND course_id = ?';
      params.push(courseId);
    } else {
      query += ' AND course_id IS NOT NULL';
    }

    query += ' GROUP BY play_speed ORDER BY play_speed';

    console.log('执行SQL查询:', query);
    console.log('查询参数:', params);

    const [rows] = await pool.query(query, params);
    
    console.log('查询结果行数:', rows.length);
    console.log('查询结果:', rows);

    // 如果没有数据，返回空数组
    if (!rows || rows.length === 0) {
      console.log('没有查询到倍速使用数据');
      return res.json({
        success: true,
        data: {
          usage: [],
          total: 0,
          averageSpeed: 1.0,
          mostUsedSpeed: { speed: 1.0, count: 0 },
          distribution: []
        }
      });
    }

    // 处理数据
    const usage = rows.map(row => {
      const speed = parseFloat(row.play_speed);
      const count = Number(row.usage_count) || 0;
      
      return {
        speed: isNaN(speed) ? 1.0 : speed,
        count: count,
        total_duration: row.total_duration || 0
      };
    });

    // 计算统计数据
    const total = usage.reduce((sum, item) => sum + item.count, 0);
    const averageSpeed = calculateAverageSpeed(usage);
    const mostUsedSpeed = getMostUsedSpeed(usage);
    const distribution = calculateSpeedDistribution(usage);

    console.log('处理后的使用数据:', {
      usageCount: usage.length,
      total: total,
      averageSpeed: averageSpeed,
      mostUsedSpeed: mostUsedSpeed
    });

    res.json({
      success: true,
      data: {
        usage: usage,
        total: total,
        averageSpeed: averageSpeed,
        mostUsedSpeed: mostUsedSpeed,
        distribution: distribution
      }
    });
  } catch (error) {
    console.error('获取倍速使用情况失败:', error);
    console.error('错误堆栈:', error.stack);
    
    res.status(500).json({
      success: false,
      message: '获取倍速使用情况失败',
      error: process.env.NODE_ENV === 'development' ? error.message : '服务器内部错误',
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
};

// 获取课程倍速偏好
exports.getCourseSpeedPreference = async (req, res) => {
  try {
    const userId = req.user.userId;
    const courseId = req.params.courseId;

    console.log(`📚 获取课程倍速偏好 - 用户ID: ${userId}, 课程ID: ${courseId}`);

    const [rows] = await pool.query(`
      SELECT 
        play_speed,
        COUNT(*) as usage_count,
        AVG(focus_rate) as avg_focus_rate,
        AVG(complete_rate) as avg_completion_rate
      FROM user_behavior ub
      LEFT JOIN learning_detail ld ON ub.user_id = ld.user_id 
        AND ub.video_id = ld.video_id
        AND DATE(ub.timestamp) = DATE(ld.learn_time)
      WHERE ub.user_id = ? 
        AND ub.course_id = ? 
        AND ub.behavior_type = 'speed_change'
      GROUP BY play_speed
      ORDER BY usage_count DESC
    `, [userId, courseId]);

    res.json({
      success: true,
      data: {
        preferences: rows,
        courseId: courseId
      }
    });
  } catch (error) {
    console.error('获取课程倍速偏好失败:', error);
    res.status(500).json({
      success: false,
      message: '获取课程倍速偏好失败',
      error: error.message
    });
  }
};

// 获取用户个人倍速习惯统计
exports.getUserSpeedHabits = async (req, res) => {
  try {
    const userId = req.user.userId;
    const period = req.query.period || '30d';
    const days = period === '7d' ? 7 : period === '30d' ? 30 : 90;

    console.log(`⏰ 获取用户倍速习惯 - 用户ID: ${userId}, 周期: ${period}`);

    // 获取倍速使用趋势
    const [speedTrend] = await pool.query(`
      SELECT 
        DATE(timestamp) as date,
        AVG(play_speed) as avg_speed,
        COUNT(*) as speed_changes,
        MIN(play_speed) as min_speed,
        MAX(play_speed) as max_speed
      FROM user_behavior
      WHERE user_id = ? 
        AND behavior_type = 'speed_change'
        AND timestamp >= DATE_SUB(NOW(), INTERVAL ? DAY)
      GROUP BY DATE(timestamp)
      ORDER BY date
    `, [userId, days]);

    // 获取不同时段的倍速偏好
    const [timeSlotPref] = await pool.query(`
      SELECT 
        HOUR(timestamp) as hour_of_day,
        AVG(play_speed) as avg_speed,
        COUNT(*) as usage_count
      FROM user_behavior
      WHERE user_id = ? 
        AND behavior_type = 'speed_change'
        AND timestamp >= DATE_SUB(NOW(), INTERVAL ? DAY)
      GROUP BY HOUR(timestamp)
      ORDER BY hour_of_day
    `, [userId, days]);

    // 获取最常用的倍速设置
    const [mostUsedSpeeds] = await pool.query(`
      SELECT 
        play_speed,
        COUNT(*) as usage_count
      FROM user_behavior
      WHERE user_id = ? 
        AND behavior_type = 'speed_change'
        AND timestamp >= DATE_SUB(NOW(), INTERVAL ? DAY)
      GROUP BY play_speed
      ORDER BY usage_count DESC
      LIMIT 5
    `, [userId, days]);

    res.json({
      success: true,
      data: {
        speedTrend,
        timeSlotPreference: timeSlotPref,
        mostUsedSpeeds,
        period: period
      }
    });
  } catch (error) {
    console.error('获取用户倍速习惯失败:', error);
    res.status(500).json({
      success: false,
      message: '获取用户倍速习惯失败',
      error: error.message
    });
  }
};

// 获取倍速与学习效果关联分析
exports.getSpeedLearningCorrelation = async (req, res) => {
  try {
    const userId = req.user.userId;
    const rawCourseId = req.query.courseId;
    const courseId = !Number.isNaN(parseInt(rawCourseId, 10)) ? parseInt(rawCourseId, 10) : null;

    console.log(`📈 获取倍速与学习效果关联 - 用户ID: ${userId}, 课程ID: ${courseId || '全部'}`);

    let query = `
      SELECT 
        ub.play_speed,
        COUNT(*) as session_count,
        AVG(ld.focus_rate) as avg_focus_rate,
        AVG(ld.complete_rate) as avg_completion_rate,
        AVG(ld.learn_duration) as avg_duration,
        COUNT(DISTINCT DATE(ub.timestamp)) as study_days
      FROM user_behavior ub
      LEFT JOIN learning_detail ld ON ub.user_id = ld.user_id 
        AND ub.video_id = ld.video_id
        AND DATE(ub.timestamp) = DATE(ld.learn_time)
      WHERE ub.user_id = ? 
        AND ub.behavior_type = 'speed_change'
    `;

    const params = [userId];

    if (courseId) {
      query += ' AND ub.course_id = ?';
      params.push(courseId);
    }

    query += ' GROUP BY ub.play_speed ORDER BY ub.play_speed';

    const [rows] = await pool.query(query, params);

    // 计算相关性分析
    const analysis = analyzeSpeedLearningCorrelation(rows);

    res.json({
      success: true,
      data: {
        rawData: rows,
        analysis: analysis,
        courseId: courseId
      }
    });
  } catch (error) {
    console.error('获取倍速与学习效果关联失败:', error);
    res.status(500).json({
      success: false,
      message: '获取倍速与学习效果关联失败',
      error: error.message
    });
  }
};

// 批量获取多个课程倍速数据
exports.getBatchSpeedAnalysis = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { courseIds } = req.body;

    if (!Array.isArray(courseIds) || courseIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: '请提供有效的课程ID数组'
      });
    }

    console.log(`📊 批量获取课程倍速分析 - 用户ID: ${userId}, 课程数: ${courseIds.length}`);

    const results = await Promise.all(
      courseIds.map(async (courseId) => {
        try {
          const [speedData] = await pool.query(`
            SELECT 
              play_speed,
              COUNT(*) as usage_count
            FROM user_behavior
            WHERE user_id = ? 
              AND course_id = ?
              AND behavior_type = 'speed_change'
            GROUP BY play_speed
          `, [userId, courseId]);

          const [courseInfo] = await pool.query(`
            SELECT course_name FROM course WHERE course_id = ?
          `, [courseId]);

          return {
            courseId,
            courseName: courseInfo[0]?.course_name || `课程${courseId}`,
            speedData: speedData,
            totalChanges: speedData.reduce((sum, item) => sum + item.usage_count, 0),
            averageSpeed: calculateAverageSpeed(speedData)
          };
        } catch (error) {
          console.error(`处理课程 ${courseId} 时出错:`, error);
          return {
            courseId,
            courseName: `课程${courseId}`,
            speedData: [],
            totalChanges: 0,
            averageSpeed: 1.0,
            error: error.message
          };
        }
      })
    );

    // 计算整体统计数据
    const overallStats = {
      totalCourses: results.length,
      totalSpeedChanges: results.reduce((sum, item) => sum + item.totalChanges, 0),
      averageSpeedAcrossCourses: results.length > 0 
        ? results.reduce((sum, item) => sum + item.averageSpeed, 0) / results.length 
        : 0
    };

    res.json({
      success: true,
      data: {
        results,
        overallStats
      }
    });
  } catch (error) {
    console.error('批量获取课程倍速分析失败:', error);
    res.status(500).json({
      success: false,
      message: '批量获取课程倍速分析失败',
      error: error.message
    });
  }
};

// ==================== 辅助函数 ====================
// 修改 getCourseSpeedUsage 辅助函数
async function getCourseSpeedUsage(userId, courseId) {
  try {
    const [rows] = await pool.query(`
      SELECT 
        play_speed,
        COUNT(*) as usage_count,
        SUM(learn_duration) as total_duration
      FROM learning_detail
      WHERE user_id = ? 
        AND course_id = ?
        AND play_speed IS NOT NULL
        AND play_speed > 0
      GROUP BY play_speed
      ORDER BY play_speed
    `, [userId, courseId]);

    return rows.map(row => ({
      speed: parseFloat(row.play_speed),
      count: row.usage_count,
      total_duration: row.total_duration
    }));
  } catch (error) {
    console.error('获取课程倍速使用情况失败:', error);
    return [];
  }
}

// 修改 getUserSpeedOverview 辅助函数
async function getUserSpeedOverview(userId) {
  try {
    // 获取整体倍速使用数据 - 从 learning_detail 表
    const [overallUsage] = await pool.query(`
      SELECT 
        AVG(play_speed) as average_speed,
        COUNT(*) as total_changes,
        MIN(play_speed) as min_speed,
        MAX(play_speed) as max_speed,
        SUM(learn_duration) as total_duration
      FROM learning_detail
      WHERE user_id = ? 
        AND play_speed IS NOT NULL
        AND play_speed > 0
    `, [userId]);

    // 获取最常用的3个倍速
    const [topSpeeds] = await pool.query(`
      SELECT 
        play_speed,
        COUNT(*) as usage_count,
        SUM(learn_duration) as total_duration
      FROM learning_detail
      WHERE user_id = ? 
        AND play_speed IS NOT NULL
        AND play_speed > 0
      GROUP BY play_speed
      ORDER BY usage_count DESC
      LIMIT 3
    `, [userId]);

    // 获取倍速使用趋势（最近7天）
    const [trendData] = await pool.query(`
      SELECT 
        DATE(learn_time) as date,
        AVG(play_speed) as avg_speed,
        COUNT(*) as changes_count,
        SUM(learn_duration) as total_duration
      FROM learning_detail
      WHERE user_id = ? 
        AND play_speed IS NOT NULL
        AND play_speed > 0
        AND learn_time >= DATE_SUB(NOW(), INTERVAL 7 DAY)
      GROUP BY DATE(learn_time)
      ORDER BY date
    `, [userId]);

    return {
      overall: overallUsage[0] || {
        average_speed: 1.0,
        total_changes: 0,
        min_speed: 1.0,
        max_speed: 1.0,
        total_duration: 0
      },
      topSpeeds: topSpeeds,
      trend: trendData
    };
  } catch (error) {
    console.error('获取用户倍速概况失败:', error);
    return null;
  }
}

// 计算平均倍速（辅助函数）
function calculateAverageSpeed(usageData) {
  if (!usageData || usageData.length === 0) return 1.0;
  
  const totalWeight = usageData.reduce((sum, item) => sum + item.count, 0);
  if (totalWeight === 0) return 1.0;
  
  const weightedSum = usageData.reduce((sum, item) => {
    return sum + (item.speed * item.count);
  }, 0);
  
  return weightedSum / totalWeight;
}

// 获取最常用倍速（辅助函数）
function getMostUsedSpeed(usageData) {
  if (!usageData || usageData.length === 0) return { speed: 1.0, count: 0 };
  
  return usageData.reduce((max, item) => {
    return item.count > max.count ? item : max;
  }, { speed: 1.0, count: 0 });
}

// 计算倍速分布百分比（辅助函数）
function calculateSpeedDistribution(usageData) {
  if (!usageData || usageData.length === 0) return [];
  
  const total = usageData.reduce((sum, item) => sum + item.count, 0);
  if (total === 0) return [];
  
  return usageData.map(item => ({
    speed: item.speed,
    count: item.count,
    percentage: Math.round((item.count / total) * 100)
  }));
}

// 分析倍速与学习效果的相关性（辅助函数）
function analyzeSpeedLearningCorrelation(data) {
  if (!data || data.length < 2) {
    return {
      correlation: '数据不足',
      suggestions: ['需要更多数据来进行相关性分析']
    };
  }
  
  // 提取数据点
  const speeds = data.map(item => parseFloat(item.play_speed));
  const focusRates = data.map(item => parseFloat(item.avg_focus_rate) || 0);
  const completionRates = data.map(item => parseFloat(item.avg_completion_rate) || 0);
  
  // 计算相关性（简单实现）
  const focusCorrelation = calculateCorrelation(speeds, focusRates);
  const completionCorrelation = calculateCorrelation(speeds, completionRates);
  
  // 生成建议
  const suggestions = [];
  
  if (focusCorrelation < -0.5) {
    suggestions.push('高倍速可能影响专注度，建议在重要内容学习时使用正常速度');
  }
  
  if (completionCorrelation < -0.3) {
    suggestions.push('过高倍速可能降低学习完成率，建议根据学习内容调整速度');
  }
  
  if (focusCorrelation > 0.3) {
    suggestions.push('您对某些速度的专注度较高，可以继续保持这些速度的学习');
  }
  
  return {
    focusCorrelation: focusCorrelation.toFixed(2),
    completionCorrelation: completionCorrelation.toFixed(2),
    suggestions: suggestions.length > 0 ? suggestions : ['倍速与学习效果无明显相关性，保持当前学习习惯即可']
  };
}

// 计算相关系数（辅助函数）
function calculateCorrelation(x, y) {
  if (x.length !== y.length || x.length < 2) return 0;
  
  const n = x.length;
  const sumX = x.reduce((a, b) => a + b, 0);
  const sumY = y.reduce((a, b) => a + b, 0);
  const sumXY = x.reduce((sum, xi, i) => sum + xi * y[i], 0);
  const sumX2 = x.reduce((sum, xi) => sum + xi * xi, 0);
  const sumY2 = y.reduce((sum, yi) => sum + yi * yi, 0);
  
  const numerator = n * sumXY - sumX * sumY;
  const denominator = Math.sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
  
  return denominator !== 0 ? numerator / denominator : 0;
}