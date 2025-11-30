<template>
  <div class="search-results">
    <div class="container">
      <div class="search-meta" v-if="searchQuery || hasSearched">
        <span class="result-count">找到 {{ searchResults.length }} 个相关结果</span>
        <span v-if="searchQuery" class="search-keyword">关键词: "{{ searchQuery }}"</span>
      </div>

      <!-- 搜索建议（无搜索结果时显示） -->
      <div v-if="!searchQuery && !hasSearched" class="suggestions-section">
        <!-- 顶部轮播精选课程区域 -->
        <CourseCarousel :courses="featuredCourses" />

        <div class="popular-searches">
          <h3>热门搜索</h3>
          <div class="popular-tags">
            <span 
              v-for="tag in popularTags" 
              :key="tag"
              class="search-tag"
              @click="$emit('search-by-tag', tag)"
            >
              {{ tag }}
            </span>
          </div>
        </div>

<<<<<<< HEAD:frontend/src/components/layout/HomeView.vue
        <!-- 下方精选课程卡片区域 -->
        <div class="featured-section">
          <h2 class="section-title">精品课程</h2>
=======
        <!-- 中间静态精选卡片区域（你给出的 5 门课程） -->
        <div class="featured-section">
          <h2 class="section-title">精选课程</h2>
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba:frontend/src/views/SearchResults.vue
          <div class="courses-grid">
            <CourseCard 
              v-for="course in featuredCourses" 
              :key="course.id"
              :course="course"
            />
          </div>
        </div>

<<<<<<< HEAD:frontend/src/components/layout/HomeView.vue
        <!-- 下方全部推荐课程列表 -->
=======
        <!-- 下方全部推荐课程列表（后端数据） -->
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba:frontend/src/views/SearchResults.vue
        <div v-if="recommendedCourses.length > 0" class="all-courses-section">
          <h2 class="section-title">全部推荐课程</h2>
          <div class="courses-grid">
            <CourseCard 
              v-for="course in recommendedCourses" 
              :key="course.id"
              :course="course"
            />
          </div>
        </div>

        <!-- 加载状态 -->
        <div v-else-if="isLoading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在加载课程...</p>
        </div>
      </div>

      <!-- 搜索结果 -->
      <div v-else class="search-results-content">
        <!-- 加载状态 -->
        <div v-if="isLoading" class="loading-section">
          <div class="loading-spinner"></div>
          <p>正在搜索中...</p>
        </div>

        <!-- 无结果 -->
        <div v-else-if="searchResults.length === 0 && hasSearched" class="no-results">
          <div class="no-results-icon">
            <i class="fas fa-search"></i>
          </div>
          <h3>没有找到相关课程</h3>
          <p>建议您尝试其他关键词或浏览课程分类</p>
          <button class="btn-primary" @click="$emit('clear-search')">返回浏览课程</button>
        </div>

        <!-- 有结果 -->
        <div v-else-if="searchResults.length > 0" class="results-section">
          <div class="results-header">
            <h2 class="section-title">搜索结果</h2>
            <div class="sort-options">
              <select :value="sortBy" @change="$emit('update:sort-by', $event.target.value)" class="sort-select">
                <option value="relevance">按相关性</option>
                <option value="rating">按评分</option>
                <option value="students">按学习人数</option>
                <option value="newest">按最新发布</option>
              </select>
            </div>
          </div>

          <div class="results-grid">
            <CourseCard 
              v-for="course in sortedResults" 
              :key="course.id"
              :course="course"
            />
          </div>
        </div>
      </div>

      <!-- 推荐课程（搜索后显示） -->
      <div v-if="hasSearched && searchResults.length > 0" class="recommended-section">
        <h2 class="section-title">相关推荐</h2>
        <div class="courses-grid">
          <CourseCard 
            v-for="course in recommendedCourses" 
            :key="course.id"
            :course="course"
          />
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup>
<<<<<<< HEAD:frontend/src/components/layout/HomeView.vue
import CourseCard from '@/components/course/CourseCard.vue'
import CourseCarousel from '@/components/course/CourseCarousel.vue'
import Footer from '@/components/layout/Footer.vue'
=======
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Footer from '@/components/layout/Footer.vue'
import CourseCard from '@/components/course/CourseCard.vue'
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
  'Python', '机器学习', '前端开发', '数据分析', 
  'Linux', '系统管理', 'Ubuntu', '人工智能'
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
    // 这里必须返回合法的 CSS background 值
    image: course.cover_img 
      ? (course.cover_img.startsWith('http')
          ? `url(${course.cover_img})`
          : `url(http://localhost:4000${course.cover_img})`)
      : 'linear-gradient(135deg, #667eea, #764ba2)'
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

    // request.js 已把 axios 的 response.data 解包，这里的 res 就是 { code, message, data }
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
    
    // 精选课程取前5个
    featuredCourses.value = courses.slice(0, 5).map(transformCourseData)
    
    // 推荐课程取剩余的课程
    recommendedCourses.value = courses.slice(5, 13).map(transformCourseData)
  } catch (error) {
    console.error('❌ 加载课程失败:', error)
  } finally {
    isLoading.value = false
  }
}
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba:frontend/src/views/SearchResults.vue

defineProps({
  searchQuery: String,
  searchResults: Array,
  isLoading: Boolean,
  hasSearched: Boolean,
  sortBy: String,
  popularTags: Array,
  featuredCourses: Array,
  recommendedCourses: Array,
  sortedResults: Array
})

<<<<<<< HEAD:frontend/src/components/layout/HomeView.vue
defineEmits(['update:sort-by', 'search-by-tag', 'clear-search', 'perform-search'])
</script>

<style scoped>
/* 页面根容器样式 */
.search-results {
  background: #f5f5f5;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

=======
// 监听路由参数中的 q 变化（来自全局导航搜索）
watch(
  () => route.query.q,
  (newQ) => {
    if (typeof newQ === 'string' && newQ.trim()) {
      searchQuery.value = newQ.trim()
      performSearch()
    } else if (!newQ) {
      // 清空搜索时，恢复默认课程列表
      clearSearch()
    }
  }
)
</script>

<style scoped>
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba:frontend/src/views/SearchResults.vue
/* 顶部搜索结果信息条 */
.search-meta {
  padding-top: 20px;
  padding-bottom: 10px;
  display: flex;
  justify-content: flex-start;
  gap: 20px;
  flex-wrap: wrap;
  font-size: 0.9rem;
  color: #5f6368;
}

.result-count,
.search-keyword {
  opacity: 0.9;
}

/* 搜索建议 */
.suggestions-section {
  padding: 60px 0;
  text-align: center;
}

.popular-searches h3 {
  margin-bottom: 20px;
  color: #202124;
  font-size: 1.3rem;
}

.popular-tags {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 12px;
}

.search-tag {
  background: white;
  padding: 10px 20px;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #dadce0;
  font-size: 0.9rem;
}

.search-tag:hover {
  background: #1a73e8;
  color: white;
  border-color: #1a73e8;
}

/* 搜索结果 */
.search-results-content {
  padding: 40px 0;
}

.loading-section {
  text-align: center;
  padding: 60px 0;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #1a73e8;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.no-results {
  text-align: center;
  padding: 80px 0;
}

.no-results-icon {
  font-size: 4rem;
  color: #dadce0;
  margin-bottom: 20px;
}

.no-results h3 {
  margin-bottom: 10px;
  color: #202124;
}

.no-results p {
  color: #5f6368;
  margin-bottom: 30px;
}

.btn-primary {
  background: #1a73e8;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  transition: background 0.3s ease;
}

.btn-primary:hover {
  background: #0d5bb9;
}

/* 结果头部 */
.results-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  flex-wrap: wrap;
  gap: 20px;
}

.section-title {
  font-size: 1.5rem;
  color: #202124;
}

.sort-select {
  padding: 8px 16px;
  border: 1px solid #dadce0;
  border-radius: 6px;
  background: white;
  font-size: 0.9rem;
}

.results-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 25px;
  margin-bottom: 50px;
}

/* 推荐课程 */
.recommended-section {
  padding: 40px 0;
  border-top: 1px solid #dadce0;
}

.courses-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 25px;
}

.all-courses-section {
  padding: 40px 0 60px;
}

.all-courses-section .section-title {
  margin-bottom: 30px;
  text-align: center;
}

@media (max-width: 768px) {
  .results-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .results-grid,
  .courses-grid {
    grid-template-columns: 1fr;
  }
  
  .search-meta {
    flex-direction: column;
    gap: 10px;
  }
}
</style>