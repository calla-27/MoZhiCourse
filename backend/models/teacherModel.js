const { pool } = require('../config/database');

const getTopTeachers = async (limit) => {
  const [teachers] = await pool.query(
    `SELECT 
       u.user_id,
       u.user_name,
       u.avatar_url,
       u.user_intro,
       u.occupation,
       COUNT(DISTINCT c.course_id) AS course_count,
       ROUND(AVG(c.rating), 1) AS avg_rating,
       SUM(c.student_count) AS total_students,
       SUM(c.rating_count) AS total_reviews
     FROM user u
     INNER JOIN course c ON u.user_id = c.teacher_user_id
     WHERE u.role = 'instructor' AND c.is_online = 1
     GROUP BY u.user_id
     HAVING avg_rating >= 4.0
     ORDER BY avg_rating DESC, total_students DESC
     LIMIT ?`,
    [parseInt(limit, 10)]
  );

  return teachers;
};

module.exports = {
  getTopTeachers
};
