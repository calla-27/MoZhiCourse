// controllers/courseController.js
const Course = require('../models/Course');
const Chapter = require('../models/Chapter');
const { successResponse, errorResponse, notFoundResponse } = require('../utils/response');

class CourseController {
  // 获取课程详情
  static async getCourse(req, res) {
    try {
      const { courseId } = req.params;
      console.log(`📚 获取课程详情: ${courseId}`);
      
      const course = await Course.getById(courseId);
      
      if (!course) {
        return res.status(404).json(notFoundResponse('课程不存在'));
      }
      
      console.log(`✅ 找到课程: ${course.course_name}`);
      
      res.json(successResponse(course));
    } catch (error) {
      console.error('获取课程详情失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }

  // 获取课程章节
  static async getChapters(req, res) {
    try {
      const { courseId } = req.params;
      console.log(`📖 获取课程章节: ${courseId}`);
      
      const chapters = await Chapter.getByCourseId(courseId);

      console.log(`找到 ${chapters.length} 个章节`);

      // 为每个章节获取视频
      for (let chapter of chapters) {
        const videos = await Chapter.getVideos(chapter.chapter_id);
        
        // 处理视频 URL - 转换为完整 URL
        chapter.videos = videos.map(video => {
          if (video.video_url && video.video_url.startsWith('/')) {
            video.video_url = `http://localhost:4000${video.video_url}`;
          }
          return video;
        });
        
        console.log(`章节 "${chapter.chapter_title}" 有 ${videos.length} 个视频`);
      }

      res.json(successResponse(chapters));
    } catch (error) {
      console.error('获取章节失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }

  // 获取所有课程
  static async getAllCourses(req, res) {
    try {
      console.log('📋 获取所有课程列表');
      
      const courses = await Course.getAll();
      
      console.log(`✅ 找到 ${courses.length} 个课程`);
      
      res.json(successResponse(courses));
    } catch (error) {
      console.error('获取课程列表失败:', error);
      res.status(500).json(errorResponse('服务器内部错误'));
    }
  }
}

module.exports = CourseController;