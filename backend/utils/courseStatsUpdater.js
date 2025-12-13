// 课程统计数据更新工具
const pool = require('../config/database');

class CourseStatsUpdater {
  
  // 更新单个课程的统计数据
  static async updateCourseStats(courseId) {
    try {
      console.log(`📊 更新课程 ${courseId} 的统计数据`);
      
      // 1. 计算学生人数
      const [studentStats] = await pool.execute(`
        SELECT COUNT(DISTINCT user_id) as student_count
        FROM user_course 
        WHERE course_id = ? AND is_enrolled = 1
      `, [courseId]);
      
      const studentCount = studentStats[0]?.student_count || 0;
      
      // 2. 计算评分统计
      const [ratingStats] = await pool.execute(`
        SELECT 
          AVG(rating) as avg_rating,
          COUNT(*) as rating_count
        FROM course_review 
        WHERE course_id = ?
      `, [courseId]);
      
      const avgRating = ratingStats[0]?.avg_rating || 0;
      const ratingCount = ratingStats[0]?.rating_count || 0;
      
      // 3. 更新课程表
      await pool.execute(`
        UPDATE course 
        SET 
          student_count = ?,
          rating = ?,
          rating_count = ?,
          updated_time = NOW()
        WHERE course_id = ?
      `, [
        studentCount,
        Math.round(avgRating * 10) / 10, // 保留一位小数
        ratingCount,
        courseId
      ]);
      
      console.log(`✅ 课程 ${courseId} 统计更新: 学生${studentCount}人, 评分${Math.round(avgRating * 10) / 10} (${ratingCount}条)`);
      
      return {
        student_count: studentCount,
        rating: Math.round(avgRating * 10) / 10,
        rating_count: ratingCount
      };
      
    } catch (error) {
      console.error(`❌ 更新课程 ${courseId} 统计失败:`, error);
      throw error;
    }
  }
  
  // 学生报名时更新统计
  static async onStudentEnroll(courseId, userId) {
    try {
      console.log(`👥 学生 ${userId} 报名课程 ${courseId}`);
      await this.updateCourseStats(courseId);
    } catch (error) {
      console.error('学生报名统计更新失败:', error);
    }
  }
  
  // 学生取消报名时更新统计
  static async onStudentUnenroll(courseId, userId) {
    try {
      console.log(`👥 学生 ${userId} 取消报名课程 ${courseId}`);
      await this.updateCourseStats(courseId);
    } catch (error) {
      console.error('学生取消报名统计更新失败:', error);
    }
  }
  
  // 添加评价时更新统计
  static async onReviewAdded(courseId, userId, rating) {
    try {
      console.log(`⭐ 学生 ${userId} 为课程 ${courseId} 添加评价: ${rating}星`);
      await this.updateCourseStats(courseId);
    } catch (error) {
      console.error('评价统计更新失败:', error);
    }
  }
  
  // 更新评价时更新统计
  static async onReviewUpdated(courseId, userId, newRating) {
    try {
      console.log(`⭐ 学生 ${userId} 更新课程 ${courseId} 评价: ${newRating}星`);
      await this.updateCourseStats(courseId);
    } catch (error) {
      console.error('评价更新统计失败:', error);
    }
  }
  
  // 删除评价时更新统计
  static async onReviewDeleted(courseId, userId) {
    try {
      console.log(`⭐ 学生 ${userId} 删除课程 ${courseId} 评价`);
      await this.updateCourseStats(courseId);
    } catch (error) {
      console.error('评价删除统计更新失败:', error);
    }
  }
  
  // 批量更新所有课程统计（用于定期维护）
  static async updateAllCourseStats() {
    try {
      console.log('📊 批量更新所有课程统计数据');
      
      const [courses] = await pool.execute(`
        SELECT course_id FROM course ORDER BY course_id
      `);
      
      let successCount = 0;
      let failCount = 0;
      
      for (const course of courses) {
        try {
          await this.updateCourseStats(course.course_id);
          successCount++;
        } catch (error) {
          failCount++;
          console.error(`课程 ${course.course_id} 更新失败:`, error.message);
        }
      }
      
      console.log(`📈 批量更新完成: 成功${successCount}门, 失败${failCount}门`);
      return { success: successCount, failed: failCount };
      
    } catch (error) {
      console.error('批量更新课程统计失败:', error);
      throw error;
    }
  }
}

module.exports = CourseStatsUpdater;