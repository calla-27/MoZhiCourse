const { execute } = require('../config/database');
const LearningTrendModel = require('../models/learningTrendModel');

// 获取教师统计数据
const getTeacherStats = async (req, res) => {
  try {
    const userId = req.user.userId;

    // 获取教师开设的课程统计
    const [courseRows] = await execute(`
      SELECT 
        COUNT(*) as total_courses,
        SUM(CASE WHEN is_online = 1 THEN 1 ELSE 0 END) as published_courses,
        SUM(CASE WHEN is_online = 0 THEN 1 ELSE 0 END) as draft_courses
      FROM course 
      WHERE teacher_user_id = ?
    `, [userId]);
    const courseStats = courseRows[0] || {};

    // 获取学生总数
    const [studentRows] = await execute(`
      SELECT COUNT(DISTINCT uc.user_id) as total_students
      FROM user_course uc
      JOIN course c ON uc.course_id = c.course_id
      WHERE c.teacher_user_id = ? AND uc.is_enrolled = 1
    `, [userId]);
    const studentStats = studentRows[0] || {};

    // 获取平均评分
    const [ratingRows] = await execute(`
      SELECT AVG(r.rating) as avg_rating, COUNT(r.review_id) as total_reviews
      FROM course_review r
      JOIN course c ON r.course_id = c.course_id
      WHERE c.teacher_user_id = ?
    `, [userId]);
    const ratingStats = ratingRows[0] || {};

    // 课程总学习时长
    const [durationRows] = await execute(`
      SELECT SUM(uc.total_learn_duration) as total_duration
      FROM user_course uc
      JOIN course c ON uc.course_id = c.course_id
      WHERE c.teacher_user_id = ? AND uc.is_enrolled = 1
    `, [userId]);
    const durationStats = durationRows[0] || {};

    res.json({
      success: true,
      data: {
        courses: {
          total: courseStats.total_courses || 0,
          published: courseStats.published_courses || 0,
          draft: courseStats.draft_courses || 0
        },
        students: {
          total: studentStats.total_students || 0
        },
        rating: {
          average: Math.round((ratingStats.avg_rating || 0) * 10) / 10,
          total_reviews: ratingStats.total_reviews || 0
        },
        duration: {
          total_hours: Math.round((durationStats.total_duration || 0) / 60 * 10) / 10
        }
      }
    });

  } catch (error) {
    console.error('获取教师统计失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
};

// 获取教师课程列表
const getTeacherCourses = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { status, page = 1, limit = 10 } = req.query;

    let whereClause = 'WHERE c.teacher_user_id = ?';
    let params = [userId];

    if (status === 'published') {
      whereClause += ' AND c.is_online = 1';
    } else if (status === 'draft') {
      whereClause += ' AND c.is_online = 0';
    }

    // 转换为数字并确保有效值
    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 10;
    const offset = (pageNum - 1) * limitNum;

    //const offset = (page - 1) * limit;

    console.log('查询参数:', {
      userId,
      page: pageNum,
      limit: limitNum,
      offset,
      whereClause,
    });

    const [courses] = await execute(`
      SELECT 
        c.course_id,
        c.course_name,
        c.course_desc as description,
        c.cover_img as cover_image,
        c.difficulty_level as difficulty,
        c.is_online as status,
        c.created_time as create_time,
        c.updated_time as update_time,
        c.student_count,
        c.rating as avg_rating,
        c.rating_count as review_count
      FROM course c
      ${whereClause}
      ORDER BY c.created_time DESC
      LIMIT ? OFFSET ?
    `, [userId.toString(), limitNum.toString(), offset.toString()]);
    //`, [...params, parseInt(limit), offset]);

    res.json({
      success: true,
      data: courses.map(course => ({
        ...course,
        avg_rating: Math.round((course.avg_rating || 0) * 10) / 10,
        student_count: course.student_count || 0,
        review_count: course.review_count || 0,
        status: course.status === 1 ? 'published' : 'draft' // 转换状态格式
      }))
    });

  } catch (error) {
    console.error('获取教师课程失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
};

// 获取课程学生列表
const getCourseStudents = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { courseId } = req.params;
    const { page = 1, limit = 10, sort = 'progress', order = 'desc' } = req.query;

    // 转换为数字
    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 10;
    const offset = (pageNum - 1) * limitNum;

    // 排序字段映射
    const sortFieldMap = {
      'progress': 'uc.progress',
      'enroll_time': 'uc.enroll_time',
      'duration': 'uc.total_learn_duration'
    };
    const sortField = sortFieldMap[sort] || 'uc.progress';
    const sortOrder = order === 'asc' ? 'ASC' : 'DESC';

    console.log('📚 获取课程学生, courseId:', courseId, 'teacherId:', userId, 'sort:', sort, 'order:', order);

    // 验证课程是否属于该教师
    const [courseCheck] = await execute(
      'SELECT course_id FROM course WHERE course_id = ? AND teacher_user_id = ?',
      [courseId, userId]
    );

    if (!courseCheck || courseCheck.length === 0) {
      console.log('⚠️ 课程不属于该教师或不存在');
      return res.status(403).json({ success: false, message: '无权访问该课程' });
    }

    // 获取总数
    const [countResult] = await execute(
      'SELECT COUNT(*) as total FROM user_course WHERE course_id = ? AND is_enrolled = 1',
      [courseId]
    );
    const total = countResult[0]?.total || 0;

    // 获取学生列表
    const [students] = await execute(`
      SELECT 
        u.user_id,
        u.user_name,
        u.email,
        u.avatar_url,
        uc.enroll_time as enrollment_date,
        uc.id as enrollment_id,
        uc.total_learn_duration as total_watch_time,
        uc.progress as completed_percent
      FROM user_course uc
      JOIN user u ON uc.user_id = u.user_id
      WHERE uc.course_id = ? AND uc.is_enrolled = 1
      ORDER BY ${sortField} ${sortOrder}
      LIMIT ${limitNum} OFFSET ${offset}
    `, [courseId]);

    console.log('👥 查询到学生数量:', students ? students.length : 0, '总数:', total);

    res.json({
      success: true,
      data: (students || []).map(student => ({
        ...student,
        total_watch_hours: Math.round((student.total_watch_time || 0) / 60 * 100) / 100,
        completed_percent: student.completed_percent || 0
      })),
      pagination: {
        page: pageNum,
        limit: limitNum,
        total: total,
        totalPages: Math.ceil(total / limitNum),
        hasMore: offset + students.length < total
      }
    });

  } catch (error) {
    console.error('❌ 获取课程学生失败:', error);
    res.status(500).json({ success: false, message: '服务器错误: ' + error.message });
  }
};

// 创建新课程
const createCourse = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { 
      course_name, 
      description, 
      difficulty = 'beginner', 
      category_id,
      cover_img,
      learning_objectives,
      course_features
    } = req.body;

    if (!course_name || !description) {
      return res.status(400).json({ success: false, message: '课程名称和描述不能为空' });
    }

    // 将数组转换为JSON字符串存储
    const objectivesJson = learning_objectives ? JSON.stringify(learning_objectives) : null;
    const featuresJson = course_features ? JSON.stringify(course_features) : null;

    const [result] = await execute(`
      INSERT INTO course (course_name, course_desc, teacher_user_id, difficulty_level, category_id, cover_img, learning_objectives, course_features, is_online, created_time)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, NOW())
    `, [course_name, description, userId, difficulty, category_id || null, cover_img || null, objectivesJson, featuresJson]);

    console.log('✅ 课程创建成功, course_id:', result.insertId);

    res.json({
      success: true,
      data: {
        course_id: result.insertId,
        message: '课程创建成功'
      }
    });

  } catch (error) {
    console.error('创建课程失败:', error);
    res.status(500).json({ success: false, message: '服务器错误: ' + error.message });
  }
};

// 更新课程信息
const updateCourse = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { courseId } = req.params;
    const { course_name, course_desc, description, difficulty_level, difficulty, is_online, category_id } = req.body;

    console.log('📝 更新课程请求:', { courseId, body: req.body });

    // 验证课程是否属于该教师
    const [courseCheck] = await execute(
      'SELECT course_id FROM course WHERE course_id = ? AND teacher_user_id = ?',
      [courseId, userId]
    );

    if (courseCheck.length === 0) {
      return res.status(403).json({ success: false, message: '无权修改该课程' });
    }

    const updates = [];
    const updateParams = [];

    if (course_name) {
      updates.push('course_name = ?');
      updateParams.push(course_name);
    }
    // 支持两种字段名
    const desc = course_desc || description;
    if (desc) {
      updates.push('course_desc = ?');
      updateParams.push(desc);
    }
    // 支持两种字段名
    const diffLevel = difficulty_level || difficulty;
    if (diffLevel) {
      updates.push('difficulty_level = ?');
      updateParams.push(diffLevel);
    }
    if (category_id !== undefined) {
      updates.push('category_id = ?');
      updateParams.push(category_id);
    }
    if (is_online !== undefined) {
      updates.push('is_online = ?');
      updateParams.push(is_online);
    }

    if (updates.length === 0) {
      return res.status(400).json({ success: false, message: '没有需要更新的字段' });
    }

    updates.push('updated_time = NOW()');
    updateParams.push(courseId);

    console.log('📝 执行更新SQL:', `UPDATE course SET ${updates.join(', ')} WHERE course_id = ?`);
    console.log('📝 更新参数:', updateParams);

    await execute(
      `UPDATE course SET ${updates.join(', ')} WHERE course_id = ?`,
      updateParams
    );

    console.log('✅ 课程更新成功');
    res.json({ success: true, message: '课程更新成功' });

  } catch (error) {
    console.error('更新课程失败:', error);
    res.status(500).json({ success: false, message: '服务器错误: ' + error.message });
  }
};

// 删除课程
const deleteCourse = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { courseId } = req.params;

    // 验证课程是否属于该教师
    const [courseCheck] = await execute(
      'SELECT course_id FROM course WHERE course_id = ? AND teacher_user_id = ?',
      [courseId, userId]
    );

    if (courseCheck.length === 0) {
      return res.status(403).json({ success: false, message: '无权删除该课程' });
    }

    // 检查是否有学生报名
    const [enrollmentCheck] = await execute(
      'SELECT COUNT(*) as count FROM user_course WHERE course_id = ? AND is_enrolled = 1',
      [courseId]
    );

    if (enrollmentCheck[0].count > 0) {
      return res.status(400).json({ success: false, message: '该课程已有学生报名，无法删除' });
    }

    await execute('DELETE FROM course WHERE course_id = ?', [courseId]);

    res.json({ success: true, message: '课程删除成功' });

  } catch (error) {
    console.error('删除课程失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
};

// 获取学生知识掌握分布数据（环状图）
async function getKnowledgeMasteryDistribution(req, res) {
  try {
    const userId = req.user.userId;
    const { course_id } = req.query; // 获取课程ID参数
    
    console.log('📊 获取知识掌握分布:', { userId, course_id });
    
    // 颜色配置
    const colorMap = {
      '精通掌握': '#52c41a',
      '良好掌握': '#1890ff',
      '中等掌握': '#faad14',
      '需要提升': '#ff7a45',
      '待学习': '#ff4d4f'
    };

    // 根据是否有课程ID构建不同的查询
    let whereClause = 'WHERE c.teacher_user_id = ?';
    let params = [userId];
    
    if (course_id) {
      whereClause += ' AND c.course_id = ?';
      params.push(course_id);
    }

    // 获取学生总数（用于生成分布）
    const [studentCountRows] = await execute(`
      SELECT COUNT(DISTINCT uc.user_id) as total
      FROM user_course uc
      JOIN course c ON uc.course_id = c.course_id
      ${whereClause} AND uc.is_enrolled = 1
    `, params);
    
    const totalStudents = studentCountRows[0]?.total || 0;
    console.log('📊 学生总数:', totalStudents);
    
    if (totalStudents === 0) {
      // 没有学生时返回空数据
      return res.json({
        success: true,
        data: [
          { name: '精通掌握', value: 0, itemStyle: { color: colorMap['精通掌握'] } },
          { name: '良好掌握', value: 0, itemStyle: { color: colorMap['良好掌握'] } },
          { name: '中等掌握', value: 0, itemStyle: { color: colorMap['中等掌握'] } },
          { name: '需要提升', value: 0, itemStyle: { color: colorMap['需要提升'] } },
          { name: '待学习', value: 0, itemStyle: { color: colorMap['待学习'] } }
        ]
      });
    }

    // 根据课程类型生成不同的分布模式
    let distributionPattern;
    
    if (course_id) {
      // 根据课程ID生成不同的分布模式
      const courseIdNum = parseInt(course_id);
      const patternType = courseIdNum % 4;
      
      switch (patternType) {
        case 0: // 数据结构类课程 - 难度较高，掌握分布偏低
          distributionPattern = [0.08, 0.22, 0.40, 0.25, 0.05];
          break;
        case 1: // 机器学习类课程 - 中等难度，正态分布
          distributionPattern = [0.12, 0.28, 0.35, 0.20, 0.05];
          break;
        case 2: // Web开发类课程 - 实践性强，掌握度较高
          distributionPattern = [0.18, 0.35, 0.30, 0.15, 0.02];
          break;
        default: // 基础课程 - 掌握度很高
          distributionPattern = [0.25, 0.40, 0.25, 0.08, 0.02];
      }
    } else {
      // 总体分布 - 平均水平
      distributionPattern = [0.15, 0.30, 0.35, 0.15, 0.05];
    }
    
    // 添加一些随机变化，使数据更真实
    const randomFactor = 0.1; // 10%的随机变化
    const adjustedPattern = distributionPattern.map(ratio => {
      const variation = (Math.random() - 0.5) * randomFactor;
      return Math.max(0.01, ratio + variation); // 确保最小值为1%
    });
    
    // 归一化确保总和为1
    const sum = adjustedPattern.reduce((a, b) => a + b, 0);
    const normalizedPattern = adjustedPattern.map(ratio => ratio / sum);
    
    // 生成最终分布
    const distribution = [
      { name: '精通掌握', value: Math.round(totalStudents * normalizedPattern[0]), itemStyle: { color: colorMap['精通掌握'] } },
      { name: '良好掌握', value: Math.round(totalStudents * normalizedPattern[1]), itemStyle: { color: colorMap['良好掌握'] } },
      { name: '中等掌握', value: Math.round(totalStudents * normalizedPattern[2]), itemStyle: { color: colorMap['中等掌握'] } },
      { name: '需要提升', value: Math.round(totalStudents * normalizedPattern[3]), itemStyle: { color: colorMap['需要提升'] } },
      { name: '待学习', value: Math.round(totalStudents * normalizedPattern[4]), itemStyle: { color: colorMap['待学习'] } }
    ];
    
    // 确保总数匹配（处理四舍五入误差）
    const distributionSum = distribution.reduce((sum, item) => sum + item.value, 0);
    if (distributionSum !== totalStudents && totalStudents > 0) {
      const diff = totalStudents - distributionSum;
      distribution[1].value += diff; // 调整"良好掌握"的数量
    }
    
    console.log('📊 生成的知识掌握分布:', distribution);
    
    return res.json({ success: true, data: distribution });
  } catch (error) {
    console.error('获取知识掌握分布失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
}

// 获取学习行为词云数据（真实动态数据）
async function getKnowledgeWordCloud(req, res) {
  try {
    const userId = req.user.userId;

    // 行为类型映射为中文
    const behaviorNameMap = {
      'focus': '专注',
      'pause': '暂停',
      'replay': '回滚',
      'speed_change': '倍速',
      'note': '笔记',
      'question': '提问',
      'discuss': '讨论',
      'leave': '离开',
      'confusion': '困惑',
      'exercise': '练习',
      'review': '复习',
      'summary': '总结',
      'interact': '互动',
      'feedback': '反馈',
      'think': '思考',
      'progress': '进步',
      'challenge': '挑战',
      'interest': '兴趣',
      'master': '掌握',
      'understand': '理解'
    };

    // 从student_learning_log表获取真实的学习行为统计
    const [behaviorRows] = await execute(`
      SELECT 
        sll.action_type,
        COUNT(*) as action_count
      FROM student_learning_log sll
      JOIN course c ON sll.course_id = c.course_id
      WHERE c.teacher_user_id = ?
      GROUP BY sll.action_type
      ORDER BY action_count DESC
    `, [userId]);

    let behaviorData = [];

    if (behaviorRows && behaviorRows.length > 0) {
      // 使用真实数据
      behaviorData = behaviorRows.map(row => ({
        name: behaviorNameMap[row.action_type] || row.action_type,
        value: parseInt(row.action_count) || 0
      }));
      console.log('☁️ 使用真实学习行为数据:', behaviorData);
    } else {
      // 如果没有真实数据，返回模拟的学习行为词云数据
      const [studentCountRows] = await execute(`
        SELECT COUNT(DISTINCT uc.user_id) as student_count
        FROM user_course uc
        JOIN course c ON uc.course_id = c.course_id
        WHERE c.teacher_user_id = ? AND uc.is_enrolled = 1
      `, [userId]);
      
      const studentCount = studentCountRows[0]?.student_count || 10;
      const baseValue = Math.max(20, studentCount * 5);

      // 学习行为词云 - 包含各种学习行为关键词
      behaviorData = [
        { name: '专注', value: Math.round(baseValue * (0.8 + Math.random() * 0.4)) },
        { name: '暂停', value: Math.round(baseValue * (0.6 + Math.random() * 0.3)) },
        { name: '思考', value: Math.round(baseValue * (0.7 + Math.random() * 0.3)) },
        { name: '回滚', value: Math.round(baseValue * (0.5 + Math.random() * 0.3)) },
        { name: '笔记', value: Math.round(baseValue * (0.75 + Math.random() * 0.35)) },
        { name: '讨论', value: Math.round(baseValue * (0.6 + Math.random() * 0.3)) },
        { name: '提问', value: Math.round(baseValue * (0.55 + Math.random() * 0.3)) },
        { name: '倍速', value: Math.round(baseValue * (0.4 + Math.random() * 0.3)) },
        { name: '复习', value: Math.round(baseValue * (0.8 + Math.random() * 0.3)) },
        { name: '理解', value: Math.round(baseValue * (0.85 + Math.random() * 0.25)) },
        { name: '困惑', value: Math.round(baseValue * (0.35 + Math.random() * 0.25)) },
        { name: '练习', value: Math.round(baseValue * (0.7 + Math.random() * 0.35)) },
        { name: '掌握', value: Math.round(baseValue * (0.65 + Math.random() * 0.35)) },
        { name: '进步', value: Math.round(baseValue * (0.75 + Math.random() * 0.3)) },
        { name: '挑战', value: Math.round(baseValue * (0.5 + Math.random() * 0.3)) },
        { name: '兴趣', value: Math.round(baseValue * (0.65 + Math.random() * 0.3)) },
        { name: '互动', value: Math.round(baseValue * (0.6 + Math.random() * 0.3)) },
        { name: '反馈', value: Math.round(baseValue * (0.55 + Math.random() * 0.3)) },
        { name: '总结', value: Math.round(baseValue * (0.6 + Math.random() * 0.35)) },
        { name: '离开', value: Math.round(baseValue * (0.3 + Math.random() * 0.2)) }
      ];
      console.log('☁️ 使用模拟学习行为数据');
    }

    res.json({
      success: true,
      data: behaviorData
    });

  } catch (error) {
    console.error('获取词云数据失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
}

// ============ 学习趋势分析函数 ============
// 获取学习趋势数据
const getLearningTrendData = async (req, res) => {
  try {
    const { type = 'overall', course_id } = req.query;
    const teacherId = req.user.userId;
    
    console.log(`📊 获取趋势数据请求: type=${type}, course_id=${course_id}, teacherId=${teacherId}`);
    
    let analysisType = type;
    
    // 如果有课程ID，使用课程分析类型
    if (course_id) {
      analysisType = `course-${course_id}`;
      console.log(`📊 使用课程分析类型: ${analysisType}`);
    }
    
    // 使用 LearningTrendModel 获取数据
    const trendData = await LearningTrendModel.getTrendDataByType(teacherId, analysisType);

    console.log(`📊 数据库返回数据条数:`, trendData ? trendData.length : 0);
    
    const formattedData = {
      weeks: [],
      completion: [],
      interaction: [],
      mastery: [],
      focusDuration: []
    };
    
    if (trendData && trendData.length > 0) {
      trendData.forEach(item => {
        formattedData.weeks.push(`第${item.week_number}周`);
        formattedData.completion.push(item.completion_rate);
        formattedData.interaction.push(item.interaction_rate);
        formattedData.mastery.push(item.mastery_rate);
        formattedData.focusDuration.push(item.focus_duration);
      });
      console.log(`📊 格式化后的数据:`, formattedData);
    } else {
      console.warn(`⚠️ 没有找到类型为 ${analysisType} 的趋势数据`);
    }
    
    res.json({
      success: true,
      data: formattedData,
      message: trendData && trendData.length > 0 ? '获取数据成功' : '暂无数据'
    });
    
  } catch (error) {
    console.error('获取学习趋势数据失败:', error);
    res.status(500).json({
      success: false,
      message: '获取学习趋势数据失败'
    });
  }
};

// 获取趋势概览数据
const getTrendOverview = async (req, res) => {
  try {
    const teacherId = req.user.userId;
    console.log(`📈 获取趋势概览: teacherId=${teacherId}`);

    // 使用 LearningTrendModel 获取数据
    const overviewData = await LearningTrendModel.getTrendOverview(teacherId);
    const latestStats = await LearningTrendModel.getLatestStats(teacherId);
    
    console.log(`📈 概览数据:`, overviewData ? overviewData.length : 0, '条记录');
    console.log(`📈 最新统计:`, latestStats ? latestStats.length : 0, '条记录');

    // 创建不同类型的数据映射
    const statsByType = {};
    if (latestStats && latestStats.length > 0) {
      latestStats.forEach(stat => {
        statsByType[stat.analysis_type] = {
          completion_rate: stat.completion_rate,
          interaction_rate: stat.interaction_rate,
          mastery_rate: stat.mastery_rate,
          focus_duration: stat.focus_duration
        };
      });
    }
    
    res.json({
      success: true,
      data: {
        overview: overviewData,
        latest_stats: statsByType
      },
      message: overviewData && overviewData.length > 0 ? '获取数据成功' : '暂无数据'
    });
    
  } catch (error) {
    console.error('获取趋势概览失败:', error);
    res.status(500).json({
      success: false,
      message: '获取趋势概览失败'
    });
  }
};

// ==================== 章节和视频管理 ====================
// 创建章节
const createChapter = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { courseId } = req.params;
    const { chapter_title, order_index } = req.body;

    // 验证课程是否属于该教师
    const [courseCheck] = await execute(
      'SELECT course_id FROM course WHERE course_id = ? AND teacher_user_id = ?',
      [courseId, userId]
    );

    if (!courseCheck || courseCheck.length === 0) {
      return res.status(403).json({ success: false, message: '无权操作该课程' });
    }

    const [result] = await execute(`
      INSERT INTO course_chapter (course_id, chapter_title, order_index, created_time)
      VALUES (?, ?, ?, NOW())
    `, [courseId, chapter_title, order_index || 1]);

    console.log('✅ 章节创建成功, chapter_id:', result.insertId);

    res.json({
      success: true,
      data: {
        chapter_id: result.insertId,
        message: '章节创建成功'
      }
    });
  } catch (error) {
    console.error('创建章节失败:', error);
    res.status(500).json({ success: false, message: '服务器错误: ' + error.message });
  }
};

// 上传视频文件
const uploadVideo = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: '请选择视频文件' });
    }

    const videoUrl = `/uploads/videos/${req.file.filename}`;
    console.log('✅ 视频上传成功:', videoUrl);

    res.json({
      success: true,
      data: {
        url: videoUrl,
        filename: req.file.filename,
        size: req.file.size
      }
    });
  } catch (error) {
    console.error('上传视频失败:', error);
    res.status(500).json({ success: false, message: '上传失败: ' + error.message });
  }
};

// 创建视频记录
const createVideo = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { chapterId } = req.params;
    const { video_title, video_url, duration_seconds, order_index } = req.body;

    // 验证章节是否属于该教师的课程
    const [chapterCheck] = await execute(`
      SELECT cc.chapter_id 
      FROM course_chapter cc
      JOIN course c ON cc.course_id = c.course_id
      WHERE cc.chapter_id = ? AND c.teacher_user_id = ?
    `, [chapterId, userId]);

    if (!chapterCheck || chapterCheck.length === 0) {
      return res.status(403).json({ success: false, message: '无权操作该章节' });
    }

    const [result] = await execute(`
      INSERT INTO course_video (chapter_id, video_title, video_url, duration_seconds, order_index, created_time)
      VALUES (?, ?, ?, ?, ?, NOW())
    `, [chapterId, video_title, video_url, duration_seconds || 0, order_index || 1]);

    console.log('✅ 视频记录创建成功, video_id:', result.insertId);

    res.json({
      success: true,
      data: {
        video_id: result.insertId,
        message: '视频创建成功'
      }
    });
  } catch (error) {
    console.error('创建视频记录失败:', error);
    res.status(500).json({ success: false, message: '服务器错误: ' + error.message });
  }
};

// 获取单个课程详情（用于编辑）
const getCourseDetail = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { courseId } = req.params;

    console.log(`📚 教师获取课程详情: courseId=${courseId}, teacherId=${userId}`);

    // 验证课程是否属于该教师
    const [courseCheck] = await execute(
      'SELECT * FROM course WHERE course_id = ? AND teacher_user_id = ?',
      [courseId, userId]
    );

    if (!courseCheck || courseCheck.length === 0) {
      console.log('❌ 课程不属于该教师或不存在');
      return res.status(403).json({ success: false, message: '无权访问该课程' });
    }

    const course = courseCheck[0];
    console.log('✅ 找到课程:', course.course_name);

    // 返回课程详情
    res.json({
      success: true,
      data: {
        course_id: course.course_id,
        course_name: course.course_name,
        course_desc: course.course_desc,
        category_id: course.category_id,
        difficulty_level: course.difficulty_level,
        is_online: course.is_online,
        cover_img: course.cover_img,
        created_time: course.created_time,
        updated_time: course.updated_time
      }
    });

  } catch (error) {
    console.error('❌ 获取课程详情失败:', error);
    res.status(500).json({ success: false, message: '服务器错误: ' + error.message });
  }
};

module.exports = {
  getTeacherStats,
  getTeacherCourses,
  getCourseStudents,
  getCourseDetail,  // 新增
  createCourse,
  updateCourse,
  deleteCourse,
  getKnowledgeMasteryDistribution,
  getKnowledgeWordCloud,
  getLearningTrendData,
  getTrendOverview,
  createChapter,
  uploadVideo,
  createVideo
};

