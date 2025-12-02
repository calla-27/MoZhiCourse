import request from '@/utils/request'

export default {
  // 获取概览数据（包含课程列表）
  getOverview() {
    return request({
      url: '/student/behavior/overview',
      method: 'get'
    })
  },

  // 获取学习建议
  getLearningSuggestions() {
    return request({
      url: '/student/behavior/suggestions',
      method: 'get'
    })
  },

  // 获取课程详细分析
  getCourseAnalysis(courseId) {
    return request({
      url: `/student/behavior/course/${courseId}`,
      method: 'get'
    })
  },

  // 获取学习趋势
  getLearningTrend(period = '7d') {
    return request({
      url: '/student/behavior/trend',
      method: 'get',
      params: { period }
    })
  },

  // 更新目标进度
  updateGoalProgress(goalId, currentValue) {
    return request({
      url: `/student/behavior/goal/${goalId}`,
      method: 'put',
      data: { currentValue }
    })
  }
}