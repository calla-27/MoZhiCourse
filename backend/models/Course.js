// models/Course.js
const db = require('../config/database');

class Course {
  // 获取课程详情
  static async getById(courseId) {
    const [courses] = await db.execute(
      `SELECT 
        c.course_id,
        c.course_name,
        c.course_desc,
        c.cover_img,
        c.difficulty_level,
        c.course_duration,
        c.is_online,
        c.created_time,
        u.user_name as teacher_name,
        cc.category_name
       FROM t_course c
       LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
       LEFT JOIN t_course_category cc ON c.category_id = cc.category_id
       WHERE c.course_id = ?`,
      [courseId]
    );
    return courses[0];
  }

  // 获取所有课程
  static async getAll() {
    const [courses] = await db.execute(
      `SELECT 
        course_id, 
        course_name, 
        course_desc, 
        cover_img, 
        created_time
       FROM t_course 
       ORDER BY created_time DESC`
    );
    return courses;
  }
}

module.exports = Course;