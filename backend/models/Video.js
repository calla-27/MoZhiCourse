// models/Video.js
const { pool } = require('../config/database');

class Video {
  // 获取视频详情
  static async getById(videoId) {
    const [videos] = await pool.execute(
      `SELECT 
        cv.video_id,
        cv.video_title,
        cv.video_url,
        cv.video_desc,
        cv.duration_seconds,
        cv.order_index,
        cv.created_time,
        cc.chapter_id,
        cc.chapter_title,
        cc.course_id,
        c.course_name,
        u.user_name as teacher_name
       FROM t_course_video cv
       LEFT JOIN t_course_chapter cc ON cv.chapter_id = cc.chapter_id
       LEFT JOIN t_course c ON cc.course_id = c.course_id
       LEFT JOIN t_user u ON c.teacher_user_id = u.user_id
       WHERE cv.video_id = ?`,
      [videoId]
    );
    return videos[0];
  }

  // 获取学习进度
  static async getProgress(userId, videoId) {
    const [progress] = await pool.execute(
      `SELECT 
        complete_rate as progress,
        current_position as currentTime
       FROM t_learning_detail 
       WHERE user_id = ? AND video_id = ?
       ORDER BY learn_time DESC 
       LIMIT 1`,
      [userId, videoId]
    );
    return progress[0] || { progress: 0, currentTime: 0 };
  }

  // 更新学习进度
  static async updateProgress(userId, videoId, progress, currentTime, duration) {
    // 获取课程ID
    const [courseInfo] = await pool.execute(
      `SELECT cc.course_id 
       FROM t_course_video cv
       LEFT JOIN t_course_chapter cc ON cv.chapter_id = cc.chapter_id
       WHERE cv.video_id = ?`,
      [videoId]
    );

    const courseId = courseInfo[0]?.course_id;

    await pool.execute(
      `INSERT INTO t_learning_detail 
       (user_id, course_id, video_id, learn_duration, complete_rate, current_position) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [userId, courseId, videoId, duration * (progress / 100), progress, currentTime]
    );
  }

  // 记录学习行为
  static async recordBehavior(userId, courseId, videoId, behaviorData) {
    const { behaviorType, currentTime, playSpeed = 1.0 } = behaviorData;
    
    await pool.execute(
      `INSERT INTO t_user_behavior 
       (user_id, course_id, video_id, behavior_type, current_time, play_speed) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [userId, courseId, videoId, behaviorType, currentTime, playSpeed]
    );
  }
}

module.exports = Video;