const { pool } = require('../../config/database');

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
       FROM course_video cv
       LEFT JOIN course_chapter cc ON cv.chapter_id = cc.chapter_id
       LEFT JOIN course c ON cc.course_id = c.course_id
       LEFT JOIN user u ON c.teacher_user_id = u.user_id
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
       FROM learning_detail 
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
       FROM course_video cv
       LEFT JOIN course_chapter cc ON cv.chapter_id = cc.chapter_id
       WHERE cv.video_id = ?`,
      [videoId]
    );

    const courseId = courseInfo[0]?.course_id;

    await pool.execute(
      `INSERT INTO learning_detail 
       (user_id, course_id, video_id, learn_duration, complete_rate, current_position, learn_time) 
       VALUES (?, ?, ?, ?, ?, ?, NOW())`,
      [userId, courseId, videoId, duration * (progress / 100), progress, currentTime]
    );
  }

  // 记录学习行为
  static async recordBehavior(userId, videoId, behaviorData) {
    const { behaviorType, currentTime, playSpeed = 1.0, duration = 0 } = behaviorData;
    
    // 获取课程ID
    const [courseInfo] = await pool.execute(
      `SELECT cc.course_id 
       FROM course_video cv
       LEFT JOIN course_chapter cc ON cv.chapter_id = cc.chapter_id
       WHERE cv.video_id = ?`,
      [videoId]
    );

    const courseId = courseInfo[0]?.course_id;
    
    if (!courseId) {
      throw new Error('无法找到视频对应的课程');
    }

    // 记录到 user_behavior 表
    await pool.execute(
      `INSERT INTO user_behavior 
       (user_id, course_id, video_id, behavior_type, current_time, play_speed, behavior_time) 
       VALUES (?, ?, ?, ?, ?, ?, NOW())`,
      [userId, courseId, videoId, behaviorType, currentTime, playSpeed]
    );

    // 如果是播放相关行为，同时记录到 learning_detail
    if (['play', 'pause', 'complete', 'seek'].includes(behaviorType)) {
      const learnDuration = behaviorType === 'play' ? 5 : 0; // 播放时记录5秒学习时长
      const completeRate = duration > 0 ? (currentTime / duration) * 100 : 0;
      
      await pool.execute(
        `INSERT INTO learning_detail 
         (user_id, course_id, video_id, learn_duration, complete_rate, current_position, learn_time) 
         VALUES (?, ?, ?, ?, ?, ?, NOW())`,
        [userId, courseId, videoId, learnDuration, completeRate, currentTime]
      );
    }
  }

  // 批量记录学习行为（优化性能）
  static async recordBehaviorsBatch(userId, videoId, behaviors) {
    // 获取课程ID
    const [courseInfo] = await pool.execute(
      `SELECT cc.course_id 
       FROM course_video cv
       LEFT JOIN course_chapter cc ON cv.chapter_id = cc.chapter_id
       WHERE cv.video_id = ?`,
      [videoId]
    );

    const courseId = courseInfo[0]?.course_id;
    
    if (!courseId) {
      throw new Error('无法找到视频对应的课程');
    }

    const connection = await pool.getConnection();
    
    try {
      await connection.beginTransaction();

      // 批量插入行为记录
      for (const behavior of behaviors) {
        const { behaviorType, currentTime, playSpeed = 1.0, duration = 0 } = behavior;
        
        await connection.execute(
          `INSERT INTO user_behavior 
           (user_id, course_id, video_id, behavior_type, current_time, play_speed, behavior_time) 
           VALUES (?, ?, ?, ?, ?, ?, NOW())`,
          [userId, courseId, videoId, behaviorType, currentTime, playSpeed]
        );

        // 记录学习详情
        if (['play', 'pause', 'complete', 'seek'].includes(behaviorType)) {
          const learnDuration = behaviorType === 'play' ? 5 : 0;
          const completeRate = duration > 0 ? (currentTime / duration) * 100 : 0;
          
          await connection.execute(
            `INSERT INTO learning_detail 
             (user_id, course_id, video_id, learn_duration, complete_rate, current_position, learn_time) 
             VALUES (?, ?, ?, ?, ?, ?, NOW())`,
            [userId, courseId, videoId, learnDuration, completeRate, currentTime]
          );
        }
      }

      await connection.commit();
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  // 获取用户视频学习统计
  static async getUserVideoStats(userId, videoId) {
    const [stats] = await pool.execute(
      `SELECT 
        COUNT(*) as total_behaviors,
        SUM(learn_duration) as total_learn_duration,
        MAX(complete_rate) as max_complete_rate,
        MAX(learn_time) as last_learn_time
       FROM learning_detail 
       WHERE user_id = ? AND video_id = ?`,
      [userId, videoId]
    );

    const [behaviorStats] = await pool.execute(
      `SELECT 
        behavior_type,
        COUNT(*) as count
       FROM user_behavior 
       WHERE user_id = ? AND video_id = ?
       GROUP BY behavior_type`,
      [userId, videoId]
    );

    return {
      ...stats[0],
      behavior_breakdown: behaviorStats
    };
  }
}

module.exports = Video;