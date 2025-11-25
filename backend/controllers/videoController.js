// controllers/videoController.js
const Video = require('../models/Video');
const { successResponse, errorResponse, notFoundResponse } = require('../utils/response');

class VideoController {
  // 获取视频详情
  static async getVideo(req, res) {
    try {
      const { videoId } = req.params;
      console.log(`🎬 获取视频详情: ${videoId}`);
      
      const video = await Video.getById(videoId);
      
      if (!video) {
        return res.status(404).json(notFoundResponse('视频不存在'));
      }

      // 处理视频 URL - 转换为完整 URL
      if (video.video_url && video.video_url.startsWith('/')) {
        video.video_url = `http://localhost:4000${video.video_url}`;
      }

      console.log(`✅ 找到视频: ${video.video_title}`, `URL: ${video.video_url}`);
      
      res.json(successResponse(video));
    } catch (error) {
      console.error('获取视频详情失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }

  // 获取学习进度
  static async getProgress(req, res) {
    try {
      const { videoId } = req.params;
      const userId = req.user.userId; // 从认证中间件获取真实用户ID
      
      console.log(`📊 获取视频进度: videoId=${videoId}, userId=${userId}`);
      
      const progress = await Video.getProgress(userId, videoId);
      
      console.log(`✅ 学习进度: ${progress.progress}%`);
      
      res.json(successResponse(progress));
    } catch (error) {
      console.error('获取学习进度失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }

  // 更新学习进度
  static async updateProgress(req, res) {
    try {
      const { videoId, progress, currentTime, duration } = req.body;
      const userId = req.user.userId; // 从认证中间件获取真实用户ID
      
      console.log(`🔄 更新学习进度: videoId=${videoId}, progress=${progress}%`);
      
      await Video.updateProgress(userId, videoId, progress, currentTime, duration);
      
      res.json(successResponse(null, '进度更新成功'));
    } catch (error) {
      console.error('更新学习进度失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }

  // 记录学习行为
  static async recordBehavior(req, res) {
    try {
      const { videoId, courseId, behaviorType, currentTime, playSpeed } = req.body;
      const userId = req.user.userId; // 从认证中间件获取真实用户ID
      
      console.log(`📝 记录学习行为: ${behaviorType} at ${currentTime}s`);
      
      await Video.recordBehavior(userId, courseId, videoId, {
        behaviorType,
        currentTime,
        playSpeed
      });

      res.json(successResponse(null, '行为记录成功'));
    } catch (error) {
      console.error('记录学习行为失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }
}

module.exports = VideoController;