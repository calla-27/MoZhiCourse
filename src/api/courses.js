import service from '@/utils/request'

// 获取课程列表
export const getCourses = (params = {}) => {
  return service.get('/courses', { params })
}

// 获取推荐课程
export const getRecommendedCourses = (limit = 6) => {
  return service.get('/courses/recommended', {
    params: { limit }
  })
}

// 获取热门课程
export const getPopularCourses = (limit = 6) => {
  return service.get('/courses/popular', {
    params: { limit }
  })
}

// 获取最新课程
export const getNewestCourses = (limit = 6) => {
  return service.get('/courses/newest', {
    params: { limit }
  })
}

// 获取课程详情
export const getCourseDetail = (courseId) => {
  return service.get(`/courses/${courseId}`)
}

// 获取相关课程
export const getRelatedCourses = (courseId, limit = 4) => {
  return service.get(`/courses/${courseId}/related`, {
    params: { limit }
  })
}

// 报名课程
export const enrollCourse = (courseId) => {
  return service.post(`/courses/${courseId}/enroll`)
}

// 收藏/取消收藏课程
export const toggleFavorite = (courseId) => {
  return service.post(`/courses/${courseId}/favorite`)
}

// 更新学习进度
export const updateProgress = (courseId, progress) => {
  return service.put(`/courses/${courseId}/progress`, {
    progress
  })
}

// 获取用户课程列表
export const getUserCourses = (type = 'all') => {
  return service.get('/courses/user/courses', {
    params: { type }
  })
}

// 获取课程章节
export const getCourseChapters = (courseId) => {
  return service.get(`/courses/${courseId}/chapters`)
}

// 获取所有分类
export const getCategories = () => {
  return service.get('/categories')
}

// 获取顶级分类
export const getTopCategories = () => {
  return service.get('/categories/top')
}

// 获取分类详情
export const getCategoryDetail = (categoryId) => {
  return service.get(`/categories/${categoryId}`)
}

// 获取明星讲师
export const getTopTeachers = (limit = 6) => {
  return service.get('/teachers/top', {
    params: { limit }
  })
}

// 获取课程评价
export const getCourseReviews = (courseId) => {
  return service.get(`/reviews/course/${courseId}`)
}

// 添加课程评价
export const addCourseReview = (courseId, reviewData) => {
  return service.post(`/reviews/course/${courseId}`, reviewData)
}

// 更新课程评价
export const updateReview = (reviewId, reviewData) => {
  return service.put(`/reviews/${reviewId}`, reviewData)
}

// 删除课程评价
export const deleteReview = (reviewId) => {
  return service.delete(`/reviews/${reviewId}`)
}

export default {
  getCourses,
  getRecommendedCourses,
  getPopularCourses,
  getNewestCourses,
  getCourseDetail,
  getRelatedCourses,
  enrollCourse,
  toggleFavorite,
  updateProgress,
  getUserCourses,
  getCourseChapters,
  getCategories,
  getTopCategories,
  getCategoryDetail,
  getTopTeachers,
  getCourseReviews,
  addCourseReview,
  updateReview,
  deleteReview
}