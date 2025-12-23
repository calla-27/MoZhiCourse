const { execute } = require('../config/database');

class LearningTrendModel {
  // 获取指定类型的趋势数据
  static async getTrendDataByType(teacherId, analysisType) {
    try {
      console.log(`📊 获取趋势数据: teacherId=${teacherId}, analysisType=${analysisType}`);
      
      // 生成模拟的8周趋势数据
      const trendData = [];
      
      for (let week = 1; week <= 8; week++) {
        // 基于分析类型生成不同的数据模式
        let baseCompletion, baseInteraction, baseMastery, baseFocus;
        
        if (analysisType === 'overall') {
          // 总体数据 - 稳步上升趋势
          baseCompletion = 72 + week * 2 + Math.random() * 4;
          baseInteraction = 68 + week * 1.5 + Math.random() * 3;
          baseMastery = 65 + week * 1.8 + Math.random() * 3;
          baseFocus = 22 + week * 0.8 + Math.random() * 2;
        } else if (analysisType.startsWith('course-')) {
          // 课程数据 - 根据课程ID生成不同模式
          const courseId = analysisType.split('-')[1];
          const courseVariation = parseInt(courseId) % 3;
          
          switch (courseVariation) {
            case 0: // 数据结构课程 - 难度较高，前期低后期高
              baseCompletion = 60 + week * 3 + Math.random() * 5;
              baseInteraction = 65 + week * 2 + Math.random() * 4;
              baseMastery = 62 + week * 2.5 + Math.random() * 4;
              baseFocus = 20 + week * 1.2 + Math.random() * 3;
              break;
            case 1: // 机器学习课程 - 稳定增长
              baseCompletion = 70 + week * 2.5 + Math.random() * 3;
              baseInteraction = 72 + week * 1.8 + Math.random() * 3;
              baseMastery = 68 + week * 2 + Math.random() * 3;
              baseFocus = 24 + week * 0.9 + Math.random() * 2;
              break;
            default: // Web开发课程 - 实践性强，互动高
              baseCompletion = 75 + week * 2 + Math.random() * 4;
              baseInteraction = 78 + week * 1.5 + Math.random() * 3;
              baseMastery = 70 + week * 2.2 + Math.random() * 3;
              baseFocus = 26 + week * 0.7 + Math.random() * 2;
          }
        } else {
          // 默认数据
          baseCompletion = 70 + week * 2 + Math.random() * 3;
          baseInteraction = 68 + week * 1.5 + Math.random() * 3;
          baseMastery = 66 + week * 1.8 + Math.random() * 3;
          baseFocus = 23 + week * 0.8 + Math.random() * 2;
        }
        
        trendData.push({
          week_number: week,
          completion_rate: Math.min(95, Math.max(50, Math.round(baseCompletion * 10) / 10)),
          interaction_rate: Math.min(95, Math.max(50, Math.round(baseInteraction * 10) / 10)),
          mastery_rate: Math.min(95, Math.max(50, Math.round(baseMastery * 10) / 10)),
          focus_duration: Math.min(35, Math.max(15, Math.round(baseFocus * 10) / 10))
        });
      }
      
      console.log(`📊 生成了 ${trendData.length} 周的趋势数据`);
      return trendData;
      
    } catch (error) {
      console.error('获取趋势数据失败:', error);
      throw error;
    }
  }

  // 获取趋势概览
  static async getTrendOverview(teacherId) {
    try {
      console.log(`📈 获取趋势概览: teacherId=${teacherId}`);
      
      // 生成概览数据
      const overviewData = [
        {
          period: '本周',
          completion_rate: 82.5,
          interaction_rate: 78.3,
          mastery_rate: 75.8,
          focus_duration: 26.2
        },
        {
          period: '上周',
          completion_rate: 79.2,
          interaction_rate: 75.1,
          mastery_rate: 72.4,
          focus_duration: 24.8
        },
        {
          period: '本月',
          completion_rate: 80.1,
          interaction_rate: 76.5,
          mastery_rate: 73.9,
          focus_duration: 25.3
        }
      ];
      
      return overviewData;
      
    } catch (error) {
      console.error('获取趋势概览失败:', error);
      throw error;
    }
  }

  // 获取最新统计数据
  static async getLatestStats(teacherId) {
    try {
      console.log(`📈 获取最新统计: teacherId=${teacherId}`);
      
      // 获取教师的课程列表
      const [courses] = await execute(`
        SELECT course_id, course_name FROM course WHERE teacher_user_id = ?
      `, [teacherId]);
      
      const latestStats = [];
      
      // 总体统计
      latestStats.push({
        analysis_type: 'overall',
        completion_rate: 82.5,
        interaction_rate: 78.3,
        mastery_rate: 75.8,
        focus_duration: 26.2
      });
      
      // 各课程统计
      courses.forEach((course, index) => {
        const variation = index % 3;
        let stats;
        
        switch (variation) {
          case 0:
            stats = { completion_rate: 79.2, interaction_rate: 75.1, mastery_rate: 72.4, focus_duration: 24.8 };
            break;
          case 1:
            stats = { completion_rate: 85.3, interaction_rate: 81.7, mastery_rate: 78.9, focus_duration: 27.5 };
            break;
          default:
            stats = { completion_rate: 83.1, interaction_rate: 79.4, mastery_rate: 76.2, focus_duration: 25.9 };
        }
        
        latestStats.push({
          analysis_type: `course-${course.course_id}`,
          ...stats
        });
      });
      
      return latestStats;
      
    } catch (error) {
      console.error('获取最新统计失败:', error);
      throw error;
    }
  }
}

module.exports = LearningTrendModel;