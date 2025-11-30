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

// 热门搜索标签（考公 / 考研热门话题）
const popularTags = ref([
  '公务员考试',
  '行测数量关系',
  '申论写作',
  '国考省考真题',
  '公考面试',
  '考研高等数学',
  '考研英语',
  '考研政治'
])

// 精选课程数据（从后端动态获取）
const featuredCourses = ref([])

// 推荐课程数据（从后端加载）
const recommendedCourses = ref([])

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
  return {
    id: course.course_id,
    title: course.course_name,
    description: course.course_desc,
    instructor: course.teacher_name || '未知讲师',
    students: course.student_count ? `${course.student_count}` : '0',
    rating: 4.5,
    difficulty: course.difficulty_level || '初级',
    // 封面图：直接保存为 cover_img，交给 CourseCard 里用 backgroundImage 渲染
    cover_img: course.cover_img
      ? (course.cover_img.startsWith('http')
          ? course.cover_img
          : `http://localhost:4000${course.cover_img}`)
      : null,
    // 兼容旧逻辑的渐变背景（当没有封面图时作为兜底）
    image: !course.cover_img
      ? 'linear-gradient(135deg, #667eea, #764ba2)'
      : null
  }
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
  isLoading.value = true
  try {
    const res = await getAllCourses()
    const courses = res.data || []
    
    // 先把有封面图的课程挑出来作为精品课程候选
    const withCover = courses.filter(c => !!c.cover_img)
    const withoutCover = courses.filter(c => !c.cover_img)

    // 精品课程：优先展示有封面图的课程（只展示6门）
    const featuredRaw = withCover.slice(0, 6)
    featuredCourses.value = featuredRaw.map(transformCourseData)

    // 剩余课程作为下面的推荐列表（有封面 + 无封面一起）
    const remaining = [
      ...withCover.slice(6),
      ...withoutCover
    ]
    recommendedCourses.value = remaining.slice(0, 20).map(transformCourseData)
  } catch (error) {
    console.error('❌ 加载课程失败:', error)
  } finally {
    isLoading.value = false
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