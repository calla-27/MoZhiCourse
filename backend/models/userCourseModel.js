const { pool } = require('../config/database');

const getEnrollment = async (userId, courseId) => {
  const [rows] = await pool.query(
    'SELECT id, is_favorite, progress FROM t_user_course WHERE user_id = ? AND course_id = ?',
    [userId, courseId]
  );

  return rows;
};

const createEnrollment = async (userId, courseId) => {
  await pool.query(
    'INSERT INTO t_user_course (user_id, course_id, enroll_time) VALUES (?, ?, NOW())',
    [userId, courseId]
  );
};

const setFavoriteStatus = async (userId, courseId, isFavorite) => {
  await pool.query(
    'UPDATE t_user_course SET is_favorite = ? WHERE user_id = ? AND course_id = ?',
    [isFavorite, userId, courseId]
  );
};

const updateEnrollmentProgress = async (userId, courseId, progress) => {
  await pool.query(
    'UPDATE t_user_course SET progress = ?, last_learn_time = NOW() WHERE user_id = ? AND course_id = ?',
    [progress, userId, courseId]
  );
};

const getUserCourses = async (userId, type) => {
  let whereCondition = 'uc.user_id = ?';
  const params = [userId];

  if (type === 'learning') {
    whereCondition += ' AND uc.progress > 0 AND uc.progress < 100';
  } else if (type === 'favorite') {
    whereCondition += ' AND uc.is_favorite = 1';
  } else if (type === 'completed') {
    whereCondition += ' AND uc.progress = 100';
  }

  const [rows] = await pool.query(
    `SELECT 
       c.course_id, c.course_name, c.cover_img, c.course_duration,
       c.difficulty_level, c.rating,
       uc.progress, uc.enroll_time, uc.last_learn_time, uc.is_favorite,
       u.user_name AS teacher_name
     FROM t_user_course uc
     INNER JOIN t_course c ON uc.course_id = c.course_id
     LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
     WHERE ${whereCondition}
     ORDER BY uc.last_learn_time DESC, uc.enroll_time DESC`,
    params
  );

  return rows;
};

module.exports = {
  getEnrollment,
  createEnrollment,
  setFavoriteStatus,
  updateEnrollmentProgress,
  getUserCourses
};
