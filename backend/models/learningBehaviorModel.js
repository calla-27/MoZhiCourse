const db = require('../config/database');

class LearningBehaviorModel {
  // 记录学习行为
  static async recordBehavior(behaviorData) {
    const {
      user_id,
      course_id,
      chapter_id,
      behavior_type,
      behavior_data,
      duration = 0,
      video_position = 0
    } = behaviorData;

    const query = `
      INSERT INTO learning_behaviors 
      (user_id, course_id, chapter_id, behavior_type, behavior_data, duration, video_position)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    try {
      const [result] = await db.execute(query, [
        user_id, course_id, chapter_id, behavior_type, 
        JSON.stringify(behavior_data), duration, video_position
      ]);
      return { success: true, id: result.insertId };
    } catch (error) {
      console.error('记录学习行为失败:', error);
      throw error;
    }
  }

  // 批量记录学习行为
  static async recordBehaviors(behaviors) {
    const query = `
      INSERT INTO learning_behaviors 
      (user_id, course_id, chapter_id, behavior_type, behavior_data, duration, video_position)
      VALUES ?
    `;

    const values = behaviors.map(b => [
      b.user_id, b.course_id, b.chapter_id, b.behavior_type,
      JSON.stringify(b.behavior_data), b.duration || 0, b.video_position || 0
    ]);

    try {
      const [result] = await db.execute(query, [values]);
      return { success: true, affectedRows: result.affectedRows };
    } catch (error) {
      console.error('批量记录学习行为失败:', error);
      throw error;
    }
  }

  // 获取教师课程的学习行为统计（用于词云）
  static async getBehaviorStatistics(teacherId, courseId = null) {
    let query = `
      SELECT 
        lb.behavior_type,
        COUNT(*) as count,
        AVG(lb.duration) as avg_duration,
        COUNT(DISTINCT lb.user_id) as user_count
      FROM learning_behaviors lb
      JOIN course c ON lb.course_id = c.course_id
      WHERE c.teacher_user_id = ?
    `;
    
    const params = [teacherId];
    
    if (courseId) {
      query += ' AND lb.course_id = ?';
      params.push(courseId);
    }
    
    query += `
      GROUP BY lb.behavior_type
      ORDER BY count DESC
    `;

    try {
      const [rows] = await db.execute(query, params);
      return rows;
    } catch (error) {
      console.error('获取行为统计失败:', error);
      throw error;
    }
  }

  // 生成词云数据
  static async generateWordCloudData(teacherId, courseId = null) {
    try {
      console.log('📊 生成词云数据 - teacherId:', teacherId, 'courseId:', courseId);
      
      // 从behavior_statistics表获取数据，并聚合重复的行为名称
      let query = `
        SELECT 
          behavior_name,
          SUM(behavior_count) as total_count,
          AVG(behavior_weight) as avg_weight
        FROM behavior_statistics 
        WHERE teacher_id = ?
      `;
      
      const params = [teacherId];
      
      if (courseId) {
        query += ' AND course_id = ?';
        params.push(courseId);
      } else {
        query += ' AND course_id IS NULL';
      }
      
      query += ' GROUP BY behavior_name ORDER BY total_count DESC';
      
      console.log('📊 执行查询:', query, '参数:', params);
      const [rows] = await db.execute(query, params);
      console.log('📊 查询结果行数:', rows.length);
      
      if (rows.length === 0) {
        console.log('📊 behavior_statistics表中没有数据，尝试从learning_behaviors表生成');
        const behaviorData = await this.generateWordCloudFromBehaviors(teacherId, courseId);
        
        // 如果learning_behaviors也没有数据，且是查询课程数据，则使用总体数据
        if (behaviorData.length === 0 && courseId) {
          console.log('📊 课程没有数据，使用总体数据作为参考');
          return await this.generateWordCloudData(teacherId, null);
        }
        
        return behaviorData;
      }
      
      // 转换为词云格式
      const wordCloudData = rows.map(row => ({
        name: row.behavior_name,
        value: Math.max(Math.round(row.avg_weight || row.total_count), 10),
        count: row.total_count,
        weight: row.avg_weight
      }));
      
      console.log('📊 从behavior_statistics表获取词云数据:', wordCloudData);
      return wordCloudData;
      
    } catch (error) {
      console.error('生成词云数据失败:', error);
      throw error;
    }
  }

  // 从learning_behaviors表生成词云数据（备用方案）
  static async generateWordCloudFromBehaviors(teacherId, courseId = null) {
    try {
      const behaviorStats = await this.getBehaviorStatistics(teacherId, courseId);
      
      if (behaviorStats.length === 0) {
        console.log('📊 没有找到学习行为数据');
        return [];
      }
      
      // 行为类型映射到中文名称
      const behaviorNameMap = {
        'play': '开始学习',
        'pause': '暂停思考',
        'seek_forward': '快进跳跃',
        'seek_backward': '回看复习',
        'speed_up': '加速播放',
        'speed_down': '减速细听',
        'note_taking': '记录笔记',
        'question_ask': '提出问题',
        'discussion': '参与讨论',
        'bookmark': '添加书签',
        'replay': '重复播放',
        'focus_lost': '注意力分散',
        'focus_regain': '重新专注',
        'chapter_complete': '章节完成',
        'quiz_attempt': '尝试测验',
        'resource_download': '下载资源'
      };

      // 计算权重并生成词云数据
      const maxCount = Math.max(...behaviorStats.map(b => b.count));
      
      const wordCloudData = behaviorStats.map(behavior => {
        const name = behaviorNameMap[behavior.behavior_type] || behavior.behavior_type;
        const weight = Math.round((behavior.count / maxCount) * 100);
        
        return {
          name: name,
          value: Math.max(weight, 10), // 最小值为10，确保显示
          count: behavior.count,
          userCount: behavior.user_count,
          avgDuration: Math.round(behavior.avg_duration || 0)
        };
      });

      return wordCloudData;
    } catch (error) {
      console.error('从learning_behaviors生成词云数据失败:', error);
      return [];
    }
  }

  // 更新行为统计表
  static async updateBehaviorStatistics(teacherId) {
    try {
      // 行为类型映射到中文名称
      const behaviorNameMap = {
        'play': '开始学习',
        'pause': '暂停思考',
        'seek_forward': '快进跳跃',
        'seek_backward': '回看复习',
        'speed_up': '加速播放',
        'speed_down': '减速细听',
        'note_taking': '记录笔记',
        'question_ask': '提出问题',
        'discussion': '参与讨论',
        'bookmark': '添加书签',
        'replay': '重复播放',
        'focus_lost': '注意力分散',
        'focus_regain': '重新专注',
        'chapter_complete': '章节完成',
        'quiz_attempt': '尝试测验',
        'resource_download': '下载资源'
      };

      // 1. 生成按课程分组的统计数据
      const courseQuery = `
        INSERT INTO behavior_statistics (teacher_id, course_id, behavior_name, behavior_count, behavior_weight)
        SELECT 
          c.teacher_user_id,
          lb.course_id,
          CASE lb.behavior_type
            WHEN 'play' THEN '开始学习'
            WHEN 'pause' THEN '暂停思考'
            WHEN 'seek_forward' THEN '快进跳跃'
            WHEN 'seek_backward' THEN '回看复习'
            WHEN 'speed_up' THEN '加速播放'
            WHEN 'speed_down' THEN '减速细听'
            WHEN 'note_taking' THEN '记录笔记'
            WHEN 'question_ask' THEN '提出问题'
            WHEN 'discussion' THEN '参与讨论'
            WHEN 'bookmark' THEN '添加书签'
            WHEN 'replay' THEN '重复播放'
            WHEN 'focus_lost' THEN '注意力分散'
            WHEN 'focus_regain' THEN '重新专注'
            WHEN 'chapter_complete' THEN '章节完成'
            WHEN 'quiz_attempt' THEN '尝试测验'
            WHEN 'resource_download' THEN '下载资源'
            ELSE lb.behavior_type
          END as behavior_name,
          COUNT(*) as behavior_count,
          (COUNT(*) * 100.0 / (
            SELECT COUNT(*) 
            FROM learning_behaviors lb2 
            JOIN course c2 ON lb2.course_id = c2.course_id 
            WHERE c2.teacher_user_id = c.teacher_user_id AND lb2.course_id = lb.course_id
          )) as behavior_weight
        FROM learning_behaviors lb
        JOIN course c ON lb.course_id = c.course_id
        WHERE c.teacher_user_id = ?
        GROUP BY c.teacher_user_id, lb.course_id, lb.behavior_type
        ON DUPLICATE KEY UPDATE
          behavior_count = VALUES(behavior_count),
          behavior_weight = VALUES(behavior_weight),
          last_updated = CURRENT_TIMESTAMP
      `;

      // 2. 生成总体统计数据（course_id = NULL）
      const overallQuery = `
        INSERT INTO behavior_statistics (teacher_id, course_id, behavior_name, behavior_count, behavior_weight)
        SELECT 
          c.teacher_user_id,
          NULL as course_id,
          CASE lb.behavior_type
            WHEN 'play' THEN '开始学习'
            WHEN 'pause' THEN '暂停思考'
            WHEN 'seek_forward' THEN '快进跳跃'
            WHEN 'seek_backward' THEN '回看复习'
            WHEN 'speed_up' THEN '加速播放'
            WHEN 'speed_down' THEN '减速细听'
            WHEN 'note_taking' THEN '记录笔记'
            WHEN 'question_ask' THEN '提出问题'
            WHEN 'discussion' THEN '参与讨论'
            WHEN 'bookmark' THEN '添加书签'
            WHEN 'replay' THEN '重复播放'
            WHEN 'focus_lost' THEN '注意力分散'
            WHEN 'focus_regain' THEN '重新专注'
            WHEN 'chapter_complete' THEN '章节完成'
            WHEN 'quiz_attempt' THEN '尝试测验'
            WHEN 'resource_download' THEN '下载资源'
            ELSE lb.behavior_type
          END as behavior_name,
          COUNT(*) as behavior_count,
          (COUNT(*) * 100.0 / (
            SELECT COUNT(*) 
            FROM learning_behaviors lb2 
            JOIN course c2 ON lb2.course_id = c2.course_id 
            WHERE c2.teacher_user_id = c.teacher_user_id
          )) as behavior_weight
        FROM learning_behaviors lb
        JOIN course c ON lb.course_id = c.course_id
        WHERE c.teacher_user_id = ?
        GROUP BY c.teacher_user_id, lb.behavior_type
        ON DUPLICATE KEY UPDATE
          behavior_count = VALUES(behavior_count),
          behavior_weight = VALUES(behavior_weight),
          last_updated = CURRENT_TIMESTAMP
      `;

      // 执行课程统计
      const [courseResult] = await db.execute(courseQuery, [teacherId]);
      console.log('📊 课程统计更新完成，影响行数:', courseResult.affectedRows);

      // 执行总体统计
      const [overallResult] = await db.execute(overallQuery, [teacherId]);
      console.log('📊 总体统计更新完成，影响行数:', overallResult.affectedRows);

      return { 
        success: true, 
        courseRows: courseResult.affectedRows,
        overallRows: overallResult.affectedRows
      };
    } catch (error) {
      console.error('更新行为统计失败:', error);
      throw error;
    }
  }

  // 获取学习行为趋势
  static async getBehaviorTrend(teacherId, courseId = null, days = 30) {
    let query = `
      SELECT 
        DATE(lb.created_at) as date,
        lb.behavior_type,
        COUNT(*) as count
      FROM learning_behaviors lb
      JOIN course c ON lb.course_id = c.course_id
      WHERE c.teacher_user_id = ? 
        AND lb.created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)
    `;
    
    const params = [teacherId, days];
    
    if (courseId) {
      query += ' AND lb.course_id = ?';
      params.push(courseId);
    }
    
    query += `
      GROUP BY DATE(lb.created_at), lb.behavior_type
      ORDER BY date DESC, count DESC
    `;

    try {
      const [rows] = await db.execute(query, params);
      return rows;
    } catch (error) {
      console.error('获取行为趋势失败:', error);
      throw error;
    }
  }
}

module.exports = LearningBehaviorModel;