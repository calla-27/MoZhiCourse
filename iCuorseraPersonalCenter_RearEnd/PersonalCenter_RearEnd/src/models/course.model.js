import { pool } from '../config/database.js';

class CourseModel {
  // 根据ID查找课程
  static async findById(courseId) {
    const [rows] = await pool.query(
      `SELECT 
        c.*,
        cc.category_name,
        u.user_name as teacher_name
      FROM t_course c
      LEFT JOIN t_course_category cc ON c.category_id = cc.category_id
      LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
      WHERE c.course_id = ?`,
      [courseId]
    );
    return rows[0];
  }

  // 创建课程
  static async create(courseData) {
    const {
      course_name,
      course_desc,
      cover_img,
      category_id,
      teacher_user_id,
      difficulty_level,
      course_duration,
      is_online = 0
    } = courseData;

    const [result] = await pool.query(
      `INSERT INTO t_course 
      (course_name, course_desc, cover_img, category_id, teacher_user_id, difficulty_level, course_duration, is_online)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [course_name, course_desc, cover_img, category_id, teacher_user_id, difficulty_level, course_duration, is_online]
    );

    return result.insertId;
  }

  // 更新课程信息
  static async update(courseId, courseData) {
    const fields = [];
    const values = [];

    const allowedFields = [
      'course_name',
      'course_desc',
      'cover_img',
      'category_id',
      'difficulty_level',
      'course_duration',
      'is_online'
    ];

    allowedFields.forEach(field => {
      if (courseData[field] !== undefined) {
        fields.push(`${field} = ?`);
        values.push(courseData[field]);
      }
    });

    if (fields.length === 0) return false;

    values.push(courseId);
    const [result] = await pool.query(
      `UPDATE t_course SET ${fields.join(', ')} WHERE course_id = ?`,
      values
    );

    return result.affectedRows > 0;
  }

  // 删除课程
  static async delete(courseId) {
    const [result] = await pool.query(
      'DELETE FROM t_course WHERE course_id = ?',
      [courseId]
    );
    return result.affectedRows > 0;
  }

  // 检查课程是否属于某个教师
  static async isOwnedByTeacher(courseId, teacherId) {
    const [rows] = await pool.query(
      'SELECT course_id FROM t_course WHERE course_id = ? AND teacher_user_id = ?',
      [courseId, teacherId]
    );
    return rows.length > 0;
  }
}

export default CourseModel;