import request from '@/utils/request'

// 课程相关API
export const getCourseDetail = (courseId) => {
  // 后端: /api/course/:courseId  =>  前端路径: /course/:courseId
  return request.get(`/course/${courseId}`) 
}

export const getCourseChapters = (courseId) => {
  // 后端: /api/course/:courseId/chapters  =>  前端路径: /course/:courseId/chapters
  return request.get(`/course/${courseId}/chapters`) 
}

export const getCourseStats = (courseId) => {
  // 后端: /api/course/:courseId/stats => 前端路径: /course/:courseId/stats
  return request.get(`/course/${courseId}/stats`)
}

export const getCourseProgress = (courseId) => {
  // ⚠️ 注意：此接口 (/courses/:courseId/progress) 在您的后端 API 列表中未明确列出。
  // 如果后端没有此路由，前端调用将失败。
  // 为保持前端原有结构，暂时保留，但路径需要修正为 /course/...
  return request.get(`/course/${courseId}/progress`)
}

// 视频相关API (后端路径前缀为 /api/course/video/)
export const getVideoDetail = (videoId) => {
  // 后端: /api/course/video/:videoId  =>  前端路径: /course/video/:videoId
  return request.get(`/course/video/${videoId}`) 
}

export const getVideoProgress = (videoId) => {
  // 后端: /api/course/video/:videoId/progress  =>  前端路径: /course/video/${videoId}/progress
  return request.get(`/course/video/${videoId}/progress`)
}

export const updateVideoProgress = (data) => {
  // 后端: POST /api/course/video/progress  =>  前端路径: /course/video/progress
  return request.post('/course/video/progress', data)
}

export const recordLearningBehavior = (data) => {
  // 后端: POST /api/course/video/behavior  =>  前端路径: /course/video/behavior
  return request.post('/course/video/behavior', data)
}

// AI助手相关API (假设后端路径使用 /api/ai/ 前缀)
export const getAISummary = (videoId) => {
  return request.get(`/ai/videos/${videoId}/summary`)
}

export const getAIHighlights = (videoId) => {
  return request.get(`/ai/videos/${videoId}/highlights`)
}

export const getAIQuiz = (videoId) => {
  return request.get(`/ai/videos/${videoId}/quiz`)
}

export const submitAIQuestion = (data) => {
  return request.post('/ai/chat', data)
}

