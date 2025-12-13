const LearningBehaviorModel = require('../models/learningBehaviorModel');
const UserCourseModel = require('../models/userCourseModel');

// 记录单个学习行为
const recordBehavior = async (req, res) => {
    try {
      const { 
        course_id, 
        chapter_id, 
        behavior_type, 
        behavior_data, 
        duration, 
        video_position 
      } = req.body;
      
      const user_id = req.user.userId;

      // 确保用户已注册课程，如果没有则自动注册
      if (course_id) {
        const existingEnrollment = await UserCourseModel.getUserCourse(user_id, course_id);
        if (!existingEnrollment) {
          console.log(`📚 自动注册用户 ${user_id} 到课程 ${course_id}`);
          await UserCourseModel.enrollCourse(user_id, course_id);
        }
      }

      const behaviorData = {
        user_id,
        course_id,
        chapter_id,
        behavior_type,
        behavior_data,
        duration,
        video_position
      };

      const result = await LearningBehaviorModel.recordBehavior(behaviorData);
      
      // 如果是章节完成行为，更新课程进度
      if (behavior_type === 'chapter_complete' && course_id && chapter_id) {
        try {
          // 使用实际观看时间更新学习时长
          const actualWatchTime = behavior_data?.actual_watch_time || duration || 0;
          
          const progressData = {
            progress: behavior_data?.completion_rate || 100,
            lastChapterId: chapter_id,
            learnDuration: actualWatchTime // 使用实际观看时间（秒）
          };
          
          await UserCourseModel.updateProgress(user_id, course_id, progressData);
          console.log(`📈 更新课程进度: 用户${user_id}, 课程${course_id}, 进度${progressData.progress}%, 观看时长${actualWatchTime}秒`);
        } catch (progressError) {
          console.error('更新课程进度失败:', progressError);
          // 不影响行为记录的成功
        }
      }
      
      // 如果是学习时长记录行为，累加到总学习时长
      if (behavior_type === 'study_duration' && course_id) {
        try {
          const actualWatchTime = behavior_data?.actual_watch_seconds || duration || 0;
          
          if (actualWatchTime > 0) {
            const progressData = {
              learnDuration: actualWatchTime // 累加实际观看时间
            };
            
            await UserCourseModel.updateProgress(user_id, course_id, progressData);
            console.log(`⏱️ 累加学习时长: 用户${user_id}, 课程${course_id}, +${actualWatchTime}秒`);
          }
        } catch (progressError) {
          console.error('更新学习时长失败:', progressError);
        }
      }
      
      res.json({
        success: true,
        message: '学习行为记录成功',
        data: result
      });
    } catch (error) {
      console.error('记录学习行为失败:', error);
      res.status(500).json({
        success: false,
        message: '记录学习行为失败',
        error: error.message
      });
    }
};

// 批量记录学习行为
const recordBehaviors = async (req, res) => {
    try {
      const { behaviors } = req.body;
      const user_id = req.user.userId;

      // 为每个行为添加用户ID
      const behaviorList = behaviors.map(behavior => ({
        ...behavior,
        user_id
      }));

      // 检查并自动注册涉及的课程
      const courseIds = [...new Set(behaviorList.map(b => b.course_id).filter(Boolean))];
      for (const courseId of courseIds) {
        const existingEnrollment = await UserCourseModel.getUserCourse(user_id, courseId);
        if (!existingEnrollment) {
          console.log(`📚 自动注册用户 ${user_id} 到课程 ${courseId}`);
          await UserCourseModel.enrollCourse(user_id, courseId);
        }
      }

      const result = await LearningBehaviorModel.recordBehaviors(behaviorList);
      
      // 处理章节完成行为，更新课程进度
      const chapterCompleteBehaviors = behaviorList.filter(b => b.behavior_type === 'chapter_complete');
      for (const behavior of chapterCompleteBehaviors) {
        if (behavior.course_id && behavior.chapter_id) {
          try {
            const progressData = {
              progress: behavior.behavior_data?.completion_rate || 100,
              lastChapterId: behavior.chapter_id,
              learnDuration: behavior.duration || 0
            };
            
            await UserCourseModel.updateProgress(user_id, behavior.course_id, progressData);
            console.log(`📈 批量更新课程进度: 用户${user_id}, 课程${behavior.course_id}, 进度${progressData.progress}%`);
          } catch (progressError) {
            console.error('批量更新课程进度失败:', progressError);
            // 不影响行为记录的成功
          }
        }
      }
      
      res.json({
        success: true,
        message: '批量记录学习行为成功',
        data: result
      });
    } catch (error) {
      console.error('批量记录学习行为失败:', error);
      res.status(500).json({
        success: false,
        message: '批量记录学习行为失败',
        error: error.message
      });
    }
};

// 获取词云数据
const getWordCloudData = async (req, res) => {
    try {
      const teacher_id = req.user.userId;
      const { course_id } = req.query;

      console.log('📊 获取词云数据请求:', { teacher_id, course_id });

      const wordCloudData = await LearningBehaviorModel.generateWordCloudData(
        teacher_id, 
        course_id
      );
      
      console.log('📊 词云数据结果:', wordCloudData.length, '条记录');
      
      res.json({
        success: true,
        message: '获取词云数据成功',
        data: wordCloudData
      });
    } catch (error) {
      console.error('获取词云数据失败:', error);
      res.status(500).json({
        success: false,
        message: '获取词云数据失败',
        error: error.message
      });
    }
};

// 获取行为统计
const getBehaviorStatistics = async (req, res) => {
    try {
      const teacher_id = req.user.userId;
      const { course_id } = req.query;

      const statistics = await LearningBehaviorModel.getBehaviorStatistics(
        teacher_id, 
        course_id
      );
      
      res.json({
        success: true,
        message: '获取行为统计成功',
        data: statistics
      });
    } catch (error) {
      console.error('获取行为统计失败:', error);
      res.status(500).json({
        success: false,
        message: '获取行为统计失败',
        error: error.message
      });
    }
};

// 获取行为趋势
const getBehaviorTrend = async (req, res) => {
    try {
      const teacher_id = req.user.userId;
      const { course_id, days = 30 } = req.query;

      const trend = await LearningBehaviorModel.getBehaviorTrend(
        teacher_id, 
        course_id, 
        parseInt(days)
      );
      
      res.json({
        success: true,
        message: '获取行为趋势成功',
        data: trend
      });
    } catch (error) {
      console.error('获取行为趋势失败:', error);
      res.status(500).json({
        success: false,
        message: '获取行为趋势失败',
        error: error.message
      });
    }
};

// 更新行为统计
const updateStatistics = async (req, res) => {
    try {
      const teacher_id = req.user.userId;

      const result = await LearningBehaviorModel.updateBehaviorStatistics(teacher_id);
      
      res.json({
        success: true,
        message: '更新行为统计成功',
        data: result
      });
    } catch (error) {
      console.error('更新行为统计失败:', error);
      res.status(500).json({
        success: false,
        message: '更新行为统计失败',
        error: error.message
      });
    }
};

module.exports = {
  recordBehavior,
  recordBehaviors,
  getWordCloudData,
  getBehaviorStatistics,
  getBehaviorTrend,
  updateStatistics
};