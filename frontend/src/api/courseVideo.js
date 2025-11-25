import request from '@/utils/request'

// 课程相关API
export const getCourseDetail = (courseId) => {
  // 后端: GET /api/courses/:courseId
  return request.get(`/courses/${courseId}`)
}

export const getAllCourses = () => {
  // 后端: GET /api/courses/
  return request.get('/courses')
}

export const searchCourses = (keyword) => {
  // 后端: GET /api/courses/search?q=keyword
  return request.get('/courses/search', { params: { q: keyword } })
}

export const getCourseChapters = (courseId) => {
  // 后端: GET /api/courses/:courseId/chapters
  return request.get(`/courses/${courseId}/chapters`)
}

export const getCourseStats = (courseId) => {
  // 后端: GET /api/courses/:courseId/stats
  return request.get(`/courses/${courseId}/stats`)
}

// 课程收藏相关
export const getCourseFavoriteStatus = (courseId) => {
  // 后端: GET /api/courses/:courseId/favorite
  return request.get(`/courses/${courseId}/favorite`)
}

export const toggleCourseFavorite = (courseId, isFavorite) => {
  // 后端: POST /api/courses/:courseId/favorite
  return request.post(`/courses/${courseId}/favorite`, { isFavorite })
}

// 获取课程评价列表
export const getCourseReviews = (courseId, limit = 10) => {
  // 后端: GET /api/courses/:courseId/reviews
  return request.get(`/courses/${courseId}/reviews`, { params: { limit } })
}

// 提交课程评价
export const submitCourseReview = (courseId, rating, reviewContent) => {
  // 后端: POST /api/courses/:courseId/reviews
  return request.post(`/courses/${courseId}/reviews`, { rating, reviewContent })
}

// 获取相关课程推荐
export const getRelatedCourses = (courseId, limit = 4) => {
  // 后端: GET /api/courses/:courseId/related
  return request.get(`/courses/${courseId}/related`, { params: { limit } })
}

export const getCourseProgress = (courseId) => {
  // 当前后端未实现课程整体进度接口，仅预留占位
  return request.get(`/courses/${courseId}/progress`)
}

// 视频相关API (后端路径前缀为 /api/courses/video/...)
export const getVideoDetail = (videoId) => {
  // 后端: GET /api/courses/video/:videoId
  return request.get(`/courses/video/${videoId}`)
}

export const getVideoProgress = (videoId) => {
  // 后端: GET /api/courses/video/:videoId/progress
  return request.get(`/courses/video/${videoId}/progress`)
}

export const updateVideoProgress = (data) => {
  // 后端: POST /api/courses/video/progress
  return request.post('/courses/video/progress', data)
}

export const recordLearningBehavior = (data) => {
  // 后端: POST /api/courses/video/behavior
  return request.post('/courses/video/behavior', data)
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

