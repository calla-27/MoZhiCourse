const { execute } = require('../config/database');

// 获取教师统计数据
const getTeacherStats = async (req, res) => {
  try {
    const userId = req.user.userId;

    // 获取教师开设的课程统计
    const [courseStats] = await execute(`
      SELECT 
        COUNT(*) as total_courses,
        SUM(CASE WHEN status = 'published' THEN 1 ELSE 0 END) as published_courses,
        SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft_courses
      FROM course 
      WHERE instructor_id = ?
    `, [userId]);

    // 获取学生总数
    const [studentStats] = await execute(`
      SELECT COUNT(DISTINCT e.user_id) as total_students
      FROM enrollment e
      JOIN course c ON e.course_id = c.course_id
      WHERE c.instructor_id = ?
    `, [userId]);

    // 获取平均评分
    const [ratingStats] = await execute(`
      SELECT AVG(r.rating) as avg_rating, COUNT(r.review_id) as total_reviews
      FROM review r
      JOIN course c ON r.course_id = c.course_id
      WHERE c.instructor_id = ?
    `, [userId]);

    // 获取总收入（如果有价格字段）
    const [revenueStats] = await execute(`
      SELECT SUM(c.price) as total_revenue
      FROM enrollment e
      JOIN course c ON e.course_id = c.course_id
      WHERE c.instructor_id = ? AND c.price > 0
    `, [userId]);

    res.json({
      success: true,
      data: {
        courses: {
          total: courseStats[0].total_courses || 0,
          published: courseStats[0].published_courses || 0,
          draft: courseStats[0].draft_courses || 0
        },
        students: {
          total: studentStats[0].total_students || 0
        },
        rating: {
          average: Math.round((ratingStats[0].avg_rating || 0) * 10) / 10,
          total_reviews: ratingStats[0].total_reviews || 0
        },
        revenue: {
          total: revenueStats[0].total_revenue || 0
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

    let whereClause = 'WHERE c.instructor_id = ?';
    let params = [userId];

    if (status) {
      whereClause += ' AND c.status = ?';
      params.push(status);
    }

    const offset = (page - 1) * limit;

    const [courses] = await execute(`
      SELECT 
        c.course_id,
        c.course_name,
        c.description,
        c.cover_image,
        c.price,
        c.difficulty,
        c.status,
        c.create_time,
        c.update_time,
        COUNT(DISTINCT e.user_id) as student_count,
        AVG(r.rating) as avg_rating,
        COUNT(DISTINCT r.review_id) as review_count
      FROM course c
      LEFT JOIN enrollment e ON c.course_id = e.course_id
      LEFT JOIN review r ON c.course_id = r.course_id
      ${whereClause}
      GROUP BY c.course_id
      ORDER BY c.create_time DESC
      LIMIT ? OFFSET ?
    `, [...params, parseInt(limit), offset]);

    res.json({
      success: true,
      data: courses.map(course => ({
        ...course,
        avg_rating: Math.round((course.avg_rating || 0) * 10) / 10,
        student_count: course.student_count || 0,
        review_count: course.review_count || 0
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
    const { page = 1, limit = 20 } = req.query;

    // 验证课程是否属于该教师
    const [courseCheck] = await execute(
      'SELECT course_id FROM course WHERE course_id = ? AND instructor_id = ?',
      [courseId, userId]
    );

    if (courseCheck.length === 0) {
      return res.status(403).json({ success: false, message: '无权访问该课程' });
    }

    const offset = (page - 1) * limit;

    const [students] = await execute(`
      SELECT 
        u.user_id,
        u.user_name,
        u.email,
        u.avatar_url,
        e.enrollment_date,
        e.enrollment_id,
        COALESCE(SUM(p.watch_duration), 0) as total_watch_time,
        COUNT(DISTINCT p.lesson_id) as completed_lessons
      FROM enrollment e
      JOIN user u ON e.user_id = u.user_id
      LEFT JOIN progress p ON e.enrollment_id = p.enrollment_id
      WHERE e.course_id = ?
      GROUP BY e.enrollment_id, u.user_id
      ORDER BY e.enrollment_date DESC
      LIMIT ? OFFSET ?
    `, [courseId, parseInt(limit), offset]);

    res.json({
      success: true,
      data: students.map(student => ({
        ...student,
        total_watch_hours: Math.round((student.total_watch_time || 0) / 3600 * 100) / 100,
        completed_lessons: student.completed_lessons || 0
      }))
    });

  } catch (error) {
    console.error('获取课程学生失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
};

// 创建新课程
const createCourse = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { course_name, description, price = 0, difficulty = 'beginner', category_id } = req.body;

    if (!course_name || !description) {
      return res.status(400).json({ success: false, message: '课程名称和描述不能为空' });
    }

    const [result] = await execute(`
      INSERT INTO course (course_name, description, instructor_id, price, difficulty, category_id, status, create_time)
      VALUES (?, ?, ?, ?, ?, ?, 'draft', NOW())
    `, [course_name, description, userId, price, difficulty, category_id]);

    res.json({
      success: true,
      data: {
        course_id: result.insertId,
        message: '课程创建成功'
      }
    });

  } catch (error) {
    console.error('创建课程失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
};

// 更新课程信息
const updateCourse = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { courseId } = req.params;
    const { course_name, description, price, difficulty, status } = req.body;

    // 验证课程是否属于该教师
    const [courseCheck] = await execute(
      'SELECT course_id FROM course WHERE course_id = ? AND instructor_id = ?',
      [courseId, userId]
    );

    if (courseCheck.length === 0) {
      return res.status(403).json({ success: false, message: '无权修改该课程' });
    }

    const updates = [];
    const params = [];

    if (course_name) {
      updates.push('course_name = ?');
      params.push(course_name);
    }
    if (description) {
      updates.push('description = ?');
      params.push(description);
    }
    if (price !== undefined) {
      updates.push('price = ?');
      params.push(price);
    }
    if (difficulty) {
      updates.push('difficulty = ?');
      params.push(difficulty);
    }
    if (status) {
      updates.push('status = ?');
      params.push(status);
    }

    if (updates.length === 0) {
      return res.status(400).json({ success: false, message: '没有需要更新的字段' });
    }

    updates.push('update_time = NOW()');
    params.push(courseId);

    await execute(
      `UPDATE course SET ${updates.join(', ')} WHERE course_id = ?`,
      params
    );

    res.json({ success: true, message: '课程更新成功' });

  } catch (error) {
    console.error('更新课程失败:', error);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
};

// 删除课程
const deleteCourse = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { courseId } = req.params;

    // 验证课程是否属于该教师
    const [courseCheck] = await execute(
      'SELECT course_id FROM course WHERE course_id = ? AND instructor_id = ?',
      [courseId, userId]
    );

    if (courseCheck.length === 0) {
      return res.status(403).json({ success: false, message: '无权删除该课程' });
    }

    // 检查是否有学生报名
    const [enrollmentCheck] = await execute(
      'SELECT COUNT(*) as count FROM enrollment WHERE course_id = ?',
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

module.exports = {
  getTeacherStats,
  getTeacherCourses,
  getCourseStudents,
  createCourse,
  updateCourse,
  deleteCourse
};
