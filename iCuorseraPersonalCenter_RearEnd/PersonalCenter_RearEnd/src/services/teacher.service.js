import { pool } from '../config/database.js';
import CourseModel from '../models/course.model.js';

class TeacherService {
  // ========== 原有功能（保持不变）==========
  
  // 获取教师的所有课程
  static async getCourses(teacherId) {
    const [courses] = await pool.query(
      `SELECT 
        c.*,
        cc.category_name,
        (SELECT COUNT(*) FROM t_user_enrollment WHERE course_id = c.course_id) as student_count,
        (SELECT AVG(overall_score) FROM t_course_review WHERE course_id = c.course_id) as avg_rating
      FROM t_course c
      LEFT JOIN t_course_category cc ON c.category_id = cc.category_id
      WHERE c.teacher_user_id = ?
      ORDER BY c.is_online DESC, c.course_id DESC`,
      [teacherId]
    );
    return courses;
  }

  // 获取课程的学生列表
  static async getCourseStudents(teacherId, courseId) {
    // 验证课程是否属于该教师
    const [course] = await pool.query(
      'SELECT course_id FROM t_course WHERE course_id = ? AND teacher_user_id = ?',
      [courseId, teacherId]
    );

    if (course.length === 0) {
      throw new Error('无权访问该课程');
    }

    const [students] = await pool.query(
      `SELECT 
        u.user_id,
        u.user_name,
        u.email,
        e.enroll_time,
        e.learn_progress,
        e.status
      FROM t_user_enrollment e
      JOIN t_user u ON e.user_id = u.user_id
      WHERE e.course_id = ?
      ORDER BY e.enroll_time DESC`,
      [courseId]
    );

    return students;
  }

  // 获取教学统计数据
  static async getTeachingStats(teacherId) {
    const [stats] = await pool.query(
      `SELECT 
        COUNT(DISTINCT c.course_id) as total_courses,
        COUNT(DISTINCT e.user_id) as total_students,
        COALESCE(SUM(c.course_duration), 0) as total_duration,
        COALESCE(AVG(r.overall_score), 0) as avg_rating
      FROM t_course c
      LEFT JOIN t_user_enrollment e ON c.course_id = e.course_id
      LEFT JOIN t_course_review r ON c.course_id = r.course_id
      WHERE c.teacher_user_id = ?`,
      [teacherId]
    );

    return stats[0] || {
      total_courses: 0,
      total_students: 0,
      total_duration: 0,
      avg_rating: 0
    };
  }

  // 创建新课程
  static async createCourse(teacherId, courseData) {
    // 验证必填字段
    const { course_name, category_id, difficulty_level } = courseData;

    if (!course_name) {
      throw new Error('课程名称不能为空');
    }

    if (!category_id) {
      throw new Error('请选择课程分类');
    }

    if (!difficulty_level || !['beginner', 'intermediate', 'advanced'].includes(difficulty_level)) {
      throw new Error('请选择有效的难度级别');
    }

    // 设置教师ID
    const newCourseData = {
      ...courseData,
      teacher_user_id: teacherId,
      is_online: courseData.is_online || 0  // 默认未上线
    };

    // 创建课程
    const courseId = await CourseModel.create(newCourseData);

    // 返回创建的课程信息
    const course = await CourseModel.findById(courseId);

    return {
      message: '课程创建成功',
      course
    };
  }

  // 更新课程信息
  static async updateCourse(teacherId, courseId, courseData) {
    // 验证课程所有权
    const isOwner = await CourseModel.isOwnedByTeacher(courseId, teacherId);
    if (!isOwner) {
      throw new Error('无权修改该课程');
    }

    // 更新课程
    const success = await CourseModel.update(courseId, courseData);
    if (!success) {
      throw new Error('更新失败');
    }

    // 返回更新后的课程信息
    const course = await CourseModel.findById(courseId);

    return {
      message: '课程更新成功',
      course
    };
  }

  // 删除课程
  static async deleteCourse(teacherId, courseId) {
    // 验证课程所有权
    const isOwner = await CourseModel.isOwnedByTeacher(courseId, teacherId);
    if (!isOwner) {
      throw new Error('无权删除该课程');
    }

    // 检查是否有学生报名
    const [enrollments] = await pool.query(
      'SELECT COUNT(*) as count FROM t_user_enrollment WHERE course_id = ?',
      [courseId]
    );

    if (enrollments[0].count > 0) {
      throw new Error('该课程已有学生报名，无法删除');
    }

    // 删除课程
    const success = await CourseModel.delete(courseId);
    if (!success) {
      throw new Error('删除失败');
    }

    return { message: '课程删除成功' };
  }

  // 发布/下线课程
  static async toggleCourseStatus(teacherId, courseId) {
    // 验证课程所有权
    const isOwner = await CourseModel.isOwnedByTeacher(courseId, teacherId);
    if (!isOwner) {
      throw new Error('无权修改该课程');
    }

    // 获取当前状态
    const course = await CourseModel.findById(courseId);
    if (!course) {
      throw new Error('课程不存在');
    }

    // 切换状态
    const newStatus = course.is_online === 1 ? 0 : 1;
    await CourseModel.update(courseId, { is_online: newStatus });

    return {
      message: newStatus === 1 ? '课程已发布' : '课程已下线',
      is_online: newStatus
    };
  }
}

export default TeacherService;