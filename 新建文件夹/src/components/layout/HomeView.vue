<template>
  <div class="search-results">
    <div class="container">
      <div class="search-meta" v-if="searchQuery || hasSearched">
        <span class="result-count">找到 {{ searchResults.length }} 个相关结果</span>
        <span v-if="searchQuery" class="search-keyword">关键词: "{{ searchQuery }}"</span>
      </div>

      <!-- 搜索建议（无搜索结果时显示） -->
      <div v-if="!searchQuery && !hasSearched" class="suggestions-section">
        <!-- 轮播图展示5分课程 -->
        <CourseCarousel 
          v-if="topRatedCourses && topRatedCourses.length" 
          :courses="topRatedCourses" 
        />
        
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

        <!-- 中间静态精选卡片区域 -->
        <div class="featured-section">
          <h2 class="section-title">精选课程</h2>
          <div class="courses-grid">
            <CourseCard 
              v-for="course in featuredCourses" 
              :key="course.id"
              :course="course"
            />
          </div>
        </div>

        <!-- 下方全部推荐课程列表 -->
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
import CourseCard from '@/components/course/CourseCard.vue'
import CourseCarousel from '@/components/course/CourseCarousel.vue'
import Footer from '@/components/layout/Footer.vue'

defineProps({
  searchQuery: String,
  searchResults: Array,
  isLoading: Boolean,
  hasSearched: Boolean,
  sortBy: String,
  popularTags: Array,
  featuredCourses: Array,
  recommendedCourses: Array,
  sortedResults: Array,
  topRatedCourses: Array
})

defineEmits(['update:sort-by', 'search-by-tag', 'clear-search', 'perform-search'])
</script>

<style scoped>
/* 搜索结果容器 */
.search-results {
  background: #f8f9fa;
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

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

.featured-section {
  margin: 40px 0;
}

.featured-section .section-title {
  margin-bottom: 30px;
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
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
  width: 100%;
}

@media (min-width: 1200px) {
  .courses-grid {
    grid-template-columns: repeat(3, 1fr);
    max-width: 100%;
  }
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