import request from '@/utils/request'

// 课程相关API
export const courseAPI = {
  // 获取主页数据
  getHomeData() {
    return request({
      url: '/home',
      method: 'get'
    })
  },

  // 获取课程列表
  getCourses(params) {
    return request({
      url: '/courses',
      method: 'get',
      params
    })
  },

  // 搜索课程
  searchCourses(keyword, params = {}) {
    return request({
      url: '/courses/search',
      method: 'get',
      params: { keyword, ...params }
    })
  },

  // 获取课程详情
  getCourseDetail(courseId) {
    return request({
      url: `/courses/${courseId}`,
      method: 'get'
    })
  },

  // 获取课程分类
  getCategories() {
    return request({
      url: '/categories',
      method: 'get'
    })
  },

  // 获取讲师列表
  getInstructors() {
    return request({
      url: '/instructors',
      method: 'get'
    })
  }
}

export default courseAPI