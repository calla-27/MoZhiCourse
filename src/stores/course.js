import { defineStore } from 'pinia'
import { ref } from 'vue'
import * as courseApi from '@/api/courses'

export const useCourseStore = defineStore('course', () => {
  const courses = ref([])
  const categories = ref([])
  const instructors = ref([])
  const recommendedCourses = ref([])
  const popularCourses = ref([])
  const newCourses = ref([])
  const loading = ref(false)

  // 获取课程列表
  const fetchCourses = async (params = {}) => {
    try {
      loading.value = true
      const response = await courseApi.getCourses(params)
      courses.value = response.courses || []
      return response
    } catch (error) {
      console.error('获取课程失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  // 获取推荐课程
  const fetchRecommendedCourses = async (limit = 6) => {
    try {
      const response = await courseApi.getRecommendedCourses(limit)
      recommendedCourses.value = response || []
      return response
    } catch (error) {
      console.error('获取推荐课程失败:', error)
      return []
    }
  }

  // 获取热门课程
  const fetchPopularCourses = async (limit = 6) => {
    try {
      const response = await courseApi.getPopularCourses(limit)
      popularCourses.value = response || []
      return response
    } catch (error) {
      console.error('获取热门课程失败:', error)
      return []
    }
  }

  // 获取最新课程
  const fetchNewCourses = async (limit = 6) => {
    try {
      const response = await courseApi.getNewestCourses(limit)
      newCourses.value = response || []
      return response
    } catch (error) {
      console.error('获取最新课程失败:', error)
      return []
    }
  }

// 获取分类
const fetchCategories = async () => {
  try {
    const response = await courseApi.getCategories()
    // 确保存储的是数组
    categories.value = Array.isArray(response) ? response : []
    return categories.value
  } catch (error) {
    console.error('获取分类失败:', error)
    categories.value = [] // 确保是空数组而不是undefined
    return []
  }
}

  // 获取明星讲师
  const fetchInstructors = async (limit = 6) => {
    try {
      const response = await courseApi.getTopTeachers(limit)
      instructors.value = response || []
      return response
    } catch (error) {
      console.error('获取讲师失败:', error)
      return []
    }
  }

  return {
    courses,
    categories,
    instructors,
    recommendedCourses,
    popularCourses,
    newCourses,
    loading,
    fetchCourses,
    fetchRecommendedCourses,
    fetchPopularCourses,
    fetchNewCourses,
    fetchCategories,
    fetchInstructors
  }
})