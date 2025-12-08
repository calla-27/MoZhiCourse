// controllers/coursevideo/videoController.js
const Video = require('../../models/coursevideo/Video');
const { successResponse, errorResponse } = require('../../utils/response');

class VideoController {
  // 获取视频详情
  static async getVideo(req, res) {
    try {
      const { videoId } = req.params;
      console.log(`🎬 获取视频详情: ${videoId}`);
      
      const video = await Video.getById(videoId);
      
      if (!video) {
        return res.status(404).json(errorResponse('视频不存在'));
      }
      
      console.log(`✅ 找到视频: ${video.video_title}`);
      
      res.json(successResponse(video));
    } catch (error) {
      console.error('获取视频详情失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }

  // 获取视频学习进度
  static async getProgress(req, res) {
    try {
      const { videoId } = req.params;
      const userId = req.user.userId;
      
      console.log(`📊 获取视频进度: userId=${userId}, videoId=${videoId}`);
      
      const progress = await Video.getProgress(userId, videoId);
      
      res.json(successResponse(progress));
    } catch (error) {
      console.error('获取视频进度失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }

  // 更新学习进度
  static async updateProgress(req, res) {
    try {
      const { videoId, currentTime, progress, duration = 0 } = req.body;
      const userId = req.user.userId;
      
      console.log(`🔄 更新学习进度:`, {
        userId, videoId, currentTime, progress, duration
      });
      
      if (!videoId || currentTime === undefined || progress === undefined) {
        return res.status(400).json(errorResponse('缺少必要参数'));
      }
      
      await Video.updateProgress(userId, videoId, progress, currentTime, duration);
      
      res.json(successResponse({ message: '进度更新成功' }));
    } catch (error) {
      console.error('更新学习进度失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }

  // 记录学习行为
  static async recordBehavior(req, res) {
    try {
      const { 
        videoId, 
        behaviorType, 
        currentTime = 0, 
        playSpeed = 1.00,
        duration = 0
      } = req.body;
      
      const userId = req.user.userId;
      
      console.log(`📝 记录学习行为:`, {
        userId, videoId, behaviorType, currentTime, playSpeed, duration
      });
      
      if (!videoId || !behaviorType) {
        return res.status(400).json(errorResponse('缺少必要参数: videoId 和 behaviorType'));
      }
      
      // 验证视频是否存在
      const video = await Video.getById(videoId);
      if (!video) {
        return res.status(404).json(errorResponse('视频不存在'));
      }
      
      // 记录行为
      await Video.recordBehavior(userId, videoId, {
        behaviorType,
        currentTime,
        playSpeed,
        duration
      });
      
      res.json(successResponse({ 
        message: '行为记录成功',
        behaviorType,
        currentTime 
      }));
    } catch (error) {
      console.error('记录学习行为失败:', error);
      res.status(500).json(errorResponse('服务器内部错误: ' + error.message));
    }
  }

  // 批量记录学习行为（可选功能）
  static async recordBehaviorsBatch(req, res) {
    try {
      const { videoId, behaviors = [] } = req.body;
      const userId = req.user.userId;
      
      console.log(`📝 批量记录学习行为:`, {
        userId, videoId, behaviorCount: behaviors.length
      });
      
      if (!videoId || !Array.isArray(behaviors) || behaviors.length === 0) {
        return res.status(400).json(errorResponse('缺少必要参数'));
      }
      
      // 验证视频是否存在
      const video = await Video.getById(videoId);
      if (!video) {
        return res.status(404).json(errorResponse('视频不存在'));
      }
      
      // 使用批量记录方法
      await Video.recordBehaviorsBatch(userId, videoId, behaviors);
      
      res.json(successResponse({ 
        message: '批量行为记录成功',
        count: behaviors.length
      }));
    } catch (error) {
      console.error('批量记录学习行为失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }

  // 获取用户视频学习统计
  static async getUserVideoStats(req, res) {
    try {
      const { videoId } = req.params;
      const userId = req.user.userId;
      
      console.log(`📈 获取用户视频统计: userId=${userId}, videoId=${videoId}`);
      
      const stats = await Video.getUserVideoStats(userId, videoId);
      
      res.json(successResponse(stats));
    } catch (error) {
      console.error('获取用户视频统计失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }
}

module.exports = VideoController;