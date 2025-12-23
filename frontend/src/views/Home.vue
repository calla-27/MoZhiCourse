<!-- 课程中心 首页 -->
<template>
  <HomeView
    :search-query="searchQuery"
    :search-results="searchResults"
    :is-loading="isLoading"
    :has-searched="hasSearched"
    :sort-by="sortBy"
    :popular-tags="popularTags"
    :featured-courses="featuredCourses"
    :recommended-courses="recommendedCourses"
    :sorted-results="sortedResults"
    :top-rated-courses="topRatedCourses"
    :hot-instructors="hotInstructors"
    @update:sort-by="sortBy = $event"
    @search-by-tag="searchByTag"
    @clear-search="clearSearch"
    @perform-search="performSearch"
  />
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import HomeView from '@/components/layout/HomeView.vue'
import { searchCourses, getAllCourses } from '@/api/courseVideo'

const route = useRoute()
const router = useRouter()

const searchQuery = ref('')
const searchResults = ref([])
const isLoading = ref(false)
const hasSearched = ref(false)
const sortBy = ref('relevance')

// 热门搜索标签
const popularTags = ref([
  '考公务员', '考研', '四六级', '教师资格证', 
  '会计师', '建造师', '法考', '医师资格'
])

// 精选课程数据（从后端动态获取）
const featuredCourses = ref([])

// 推荐课程数据（从后端加载）
const recommendedCourses = ref([])

// 5分课程数据（轮播图使用）
const topRatedCourses = ref([])

// 热门讲师数据
const hotInstructors = ref([])

// 计算排序后的结果
const sortedResults = computed(() => {
  const results = [...searchResults.value]
  switch (sortBy.value) {
    case 'rating':
      return results.sort((a, b) => b.rating - a.rating)
    case 'students':
      return results.sort((a, b) => parseInt(b.students) - parseInt(a.students))
    case 'newest':
      return results.sort((a, b) => b.id - a.id)
    default:
      return results
  }
})

// 将后端数据转换为前端格式
const transformCourseData = (course) => {
  console.log(' 转换课程数据:', course)
  
  const transformed = {
    id: course.course_id,
    title: course.course_name,
    description: course.course_desc,
    instructor: course.teacher_name || '未知讲师',
    students: course.student_count ? `${course.student_count}` : '0',
    rating: course.avg_rating || course.rating || 4.5,
    difficulty: course.difficulty_level || '初级',
    cover_img: course.cover_img, // 轮播图需要这个字段
    image: course.cover_img 
      ? (course.cover_img.startsWith('http')
          ? course.cover_img
          : `http://localhost:4000${course.cover_img}`)
      : null
  }
  
  console.log(' 转换后的数据:', transformed)
  return transformed
}

// 执行搜索
const performSearch = async () => {
  if (!searchQuery.value.trim()) return

  isLoading.value = true
  hasSearched.value = true

  try {
    const res = await searchCourses(searchQuery.value.trim())
    console.log('🔍 搜索接口返回:', res)

    const courses = res.data || []
    console.log('📚 课程数组:', courses)

    searchResults.value = courses.map(transformCourseData)

    if (searchResults.value.length > 0) {
      const allRes = await getAllCourses()
      const allCourses = allRes.data || []
      recommendedCourses.value = allCourses
        .filter(c => !searchResults.value.some(sc => sc.id === c.course_id))
        .slice(0, 4)
        .map(transformCourseData)
    }
  } catch (error) {
    console.error('❌ 搜索课程失败:', error)
  } finally {
    isLoading.value = false
  }
}

// 通过标签搜索
const searchByTag = (tag) => {
  searchQuery.value = tag
  performSearch()
}

// 清空搜索
const clearSearch = () => {
  searchQuery.value = ''
  searchResults.value = []
  hasSearched.value = false
  loadAllCourses()
}

// 加载所有课程（首页显示）
const loadAllCourses = async () => {
  console.log('🚀 开始加载课程数据...')
  isLoading.value = true
  try {
    let courses = []
    try {
      console.log('📡 尝试获取后端数据...')
      const res = await getAllCourses()
      courses = res.data || []
      console.log('📊 后端返回课程数量:', courses.length)
    } catch (apiError) {
      console.log('📡 后端API暂不可用')
    }
    
    console.log('📚 最终使用的课程数据:', courses)
    
    // 筛选高评分课程用于轮播图（评分>=4.5的课程）
    const highRatedCourses = courses.filter(course => 
      course.avg_rating >= 4.5 || course.rating >= 4.5 || course.course_name.includes('速成')
    ).slice(0, 3)
    
    console.log('⭐ 高评分课程:', highRatedCourses)
    
    topRatedCourses.value = highRatedCourses.length > 0 
      ? highRatedCourses.map(transformCourseData)
      : courses.slice(0, 3).map(transformCourseData)
    
    featuredCourses.value = courses.slice(0, 5).map(transformCourseData)
    recommendedCourses.value = courses.length > 6 
      ? courses.slice(6, 14).map(transformCourseData)
      : courses.map(transformCourseData) // 如果课程不够，重复显示
      
    console.log('🎯 轮播图课程数量:', topRatedCourses.value.length)
    console.log('🌟 精选课程数量:', featuredCourses.value.length)
    console.log('💡 推荐课程数量:', recommendedCourses.value.length)
    
    // 加载热门讲师
    await loadHotInstructors()
  } catch (error) {
    console.error('❌ 加载课程失败:', error)
    recommendedCourses.value = []
  } finally {
    isLoading.value = false
    console.log('✅ 课程数据加载完成')
  }
}

// 加载热门讲师
const loadHotInstructors = async () => {
  try {
    console.log('👨‍🏫 开始加载热门讲师...')
    
    const API_BASE = 'http://localhost:4000'
    const token = localStorage.getItem('token')
    
    // 请求4位讲师
    const res = await fetch(`${API_BASE}/api/teachers/top?limit=4`, {
      headers: token ? { 'Authorization': `Bearer ${token}` } : {}
    })
    
    console.log('📡 讲师接口响应状态:', res.status)
    
    if (!res.ok) {
      console.log('⚠️ 讲师接口返回错误，状态码:', res.status)
      return
    }
    
    const data = await res.json()
    console.log('📊 讲师接口返回数据:', data)
    
    if (data.success && data.data && data.data.length > 0) {
      hotInstructors.value = data.data.map(teacher => {
        const instructorData = {
          id: teacher.user_id,
          name: teacher.user_name,
          bio: teacher.bio || teacher.occupation || '优秀讲师',
          avatar: teacher.avatar 
            ? (teacher.avatar.startsWith('http') 
                ? teacher.avatar 
                : `${API_BASE}${teacher.avatar}`)
            : null,
          students: teacher.student_count || 0,
          courses: teacher.course_count || 0
        }
        console.log('👤 处理讲师数据:', instructorData)
        return instructorData
      })
      
      console.log('✅ 成功加载', hotInstructors.value.length, '位讲师（按学生数量排序）')
      console.log('📋 讲师列表:', hotInstructors.value)
    } else {
      console.log('⚠️ 没有讲师数据')
    }
    
  } catch (error) {
    console.error('❌ 加载讲师失败:', error)
  }
}

// 初始化
onMounted(() => {
  if (route.query.q) {
    searchQuery.value = route.query.q
    performSearch()
  } else {
    loadAllCourses()
  }
})

// 监听路由参数中的 q 变化（来自全局导航搜索）
watch(
  () => route.query.q,
  (newQ) => {
    if (typeof newQ === 'string' && newQ.trim()) {
      searchQuery.value = newQ.trim()
      performSearch()
    } else if (!newQ) {
      clearSearch()
    }
  }
)
</script>

<style>
:root{
  --mz-primary: rgb(66,180,246);
  --mz-primary-dark: #12a7d9;
  /* 更柔和的垂直渐变背景，提供轻微层次感 */
  --page-bg: linear-gradient(180deg, #fbfdff 0%, #f6fbff 40%, #f2f8ff 100%);
  --page-hero-accent: rgba(66,180,246,0.06);
}

.search-results {
  background: var(--page-bg);
  /* 轻微内阴影让内容区悬浮感更好 */
  box-shadow: inset 0 1px 0 rgba(255,255,255,0.6);
}

.section-title { color: #073b6b; }

.courses-grid { gap: 22px; }

/* 兼容 CourseCard 的外层样式 */
.course-card .card-shell{ background: #f9fbfe; }

</style>