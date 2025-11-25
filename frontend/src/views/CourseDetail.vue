<template>
  <div class="course-detail">
    <!-- 课程头部 -->
    <section class="course-header">
      <div class="container">
        <div class="course-info">
          <span class="course-category">{{ course.categoryName }}</span>
          <h1>{{ course.title }}</h1>
          <p class="course-description">{{ course.description }}</p>
          <div class="course-meta">
            <div class="meta-item">
              <i class="fas fa-star"></i>
              <span>{{ course.rating }} ({{ course.reviewCount }} 评价)</span>
            </div>
            <div class="meta-item">
              <i class="fas fa-users"></i>
              <span>{{ course.studentCount }} 名学生</span>
            </div>
            <div class="meta-item">
              <i class="fas fa-clock"></i>
              <span>{{ course.duration }} 小时</span>
            </div>
            <div class="meta-item">
              <i class="fas fa-signal"></i>
              <span>{{ course.difficulty }}</span>
            </div>
          </div>
          <div class="course-actions">
            <button class="btn btn-primary" @click="goToFirstVideo">
              <i class="fas fa-play"></i>
              开始学习
            </button>
            <button 
              class="btn btn-secondary" 
              :class="{ 'btn-secondary-active': isFavorite }" 
              @click="toggleFavorite"
            >
              <i :class="isFavorite ? 'fas fa-heart' : 'far fa-heart'"></i>
              收藏
            </button>
          </div>
        </div>
      </div>
    </section>

    <div class="container">
      <!-- 标签页 -->
      <div class="tabs">
        <div 
          v-for="tab in tabs" 
          :key="tab.id"
          class="tab" 
          :class="{ active: activeTab === tab.id }"
          @click="activeTab = tab.id"
        >
          {{ tab.name }}
        </div>
      </div>

      <!-- 课程介绍 -->
      <div v-if="activeTab === 'overview'" class="tab-content">
        <div class="content-section">
          <h2 class="section-title">课程介绍</h2>
          <div class="course-overview">
            <div class="overview-content">
              <p>本课程专为编程零基础的学习者设计，通过生动有趣的案例和实践项目，带你轻松入门Python编程世界。</p>
              
              <h3>学习目标</h3>
              <ul>
                <li>掌握Python基础语法和编程概念</li>
                <li>理解变量、数据类型、运算符的使用</li>
                <li>学会使用条件语句和循环控制程序流程</li>
                <li>掌握函数的定义和使用方法</li>
              </ul>
              
              <div class="features-grid">
                <div class="feature-item">
                  <div class="feature-icon">
                    <i class="fas fa-laptop-code"></i>
                  </div>
                  <h4>实战驱动</h4>
                  <p>通过真实项目学习编程</p>
                </div>
                <div class="feature-item">
                  <div class="feature-icon">
                    <i class="fas fa-graduation-cap"></i>
                  </div>
                  <h4>循序渐进</h4>
                  <p>系统学习路径</p>
                </div>
                <div class="feature-item">
                  <div class="feature-icon">
                    <i class="fas fa-comments"></i>
                  </div>
                  <h4>社区支持</h4>
                  <p>互动交流学习</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 课程大纲 -->
      <div v-if="activeTab === 'curriculum'" class="tab-content">
        <div class="content-section">
          <h2 class="section-title">课程大纲</h2>
          <div class="curriculum-content">
            <div 
              v-for="chapter in chapters" 
              :key="chapter.id"
              class="chapter" 
              :class="{ active: chapter.isOpen }"
            >
              <div class="chapter-header" @click="toggleChapter(chapter.id)">
                <div class="chapter-title">
                  <i :class="chapter.isOpen ? 'fas fa-chevron-down' : 'fas fa-chevron-right'"></i>
                  <span>{{ chapter.title }}</span>
                </div>
                <span>{{ chapter.lessonCount }}个视频</span>
              </div>
              <div class="chapter-content">
                <div 
                  v-for="lesson in chapter.lessons" 
                  :key="lesson.id"
                  class="lesson"
                >
                  <div class="lesson-icon">
                    <i class="fas fa-play-circle"></i>
                  </div>
                  <div class="lesson-info">
                    <div class="lesson-title">{{ lesson.title }}</div>
                    <div class="lesson-meta">{{ lesson.duration }}分钟</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 讲师介绍 -->
      <div v-if="activeTab === 'instructor'" class="tab-content">
        <div class="content-section">
          <h2 class="section-title">讲师介绍</h2>
          <div class="instructor-card">
            <div class="instructor-avatar" v-if="!instructor.avatar">{{ instructor.name ? instructor.name.charAt(0) : '讲' }}</div>
            <img v-else :src="instructor.avatar" class="instructor-avatar-img" alt="讲师头像">
            <div class="instructor-info">
              <h3>{{ instructor.name }}</h3>
              <div class="instructor-title">{{ instructor.title }}</div>
              <p style="margin-bottom: 15px; line-height: 1.5;">
                {{ instructor.intro }}
              </p>
              <div class="instructor-stats">
                <div class="stat">
                  <div class="stat-value">{{ course.rating }}/5.0</div>
                  <div class="stat-label">讲师评分</div>
                </div>
                <div class="stat">
                  <div class="stat-value">{{ course.studentCount }}</div>
                  <div class="stat-label">学生人数</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 学生评价 -->
      <div v-if="activeTab === 'reviews'" class="tab-content">
        <div class="content-section">
          <h2 class="section-title">学生评价</h2>
          
          <!-- 评价表单 -->
          <div class="review-form">
            <h3 class="form-title">发表你的评价</h3>
            <div class="rating-selector">
              <label>课程评分：</label>
              <div class="stars">
                <i 
                  v-for="star in 5" 
                  :key="star"
                  class="star-icon"
                  :class="star <= newRating ? 'fas fa-star active' : 'far fa-star'"
                  @click="newRating = star"
                ></i>
              </div>
            </div>
            <div class="review-input">
              <label>评价内容：</label>
              <textarea 
                v-model="newReviewContent" 
                placeholder="请分享你对这门课程的看法和建议..."
                rows="4"
                maxlength="500"
              ></textarea>
              <div class="char-count">{{ newReviewContent.length }}/500</div>
            </div>
            <button 
              class="btn-submit" 
              @click="handleSubmitReview"
              :disabled="isSubmitting || !newReviewContent.trim()"
            >
              {{ isSubmitting ? '提交中...' : '提交评价' }}
            </button>
          </div>
          
          <div class="reviews-grid">
            <div 
              v-for="review in reviews" 
              :key="review.id"
              class="review-card"
            >
              <div class="review-header">
                <div class="reviewer">
                  <div class="reviewer-avatar">{{ review.avatar }}</div>
                  <div>
                    <div style="font-weight: 600;">{{ review.name }}</div>
                    <div style="font-size: 0.8rem; color: #5f6368;">{{ review.job }}</div>
                  </div>
                </div>
                <div class="rating">
                  <i v-for="n in 5" :key="n" class="fas fa-star"></i>
                </div>
              </div>
              <div class="review-content">
                {{ review.content }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 相关课程 -->
      <div class="content-section">
        <h2 class="section-title">相关课程推荐</h2>
        <div class="related-courses">
          <CourseCard 
            v-for="relatedCourse in relatedCourses" 
            :key="relatedCourse.id"
            :course="relatedCourse"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import CourseCard from '@/components/course/CourseCard.vue'
import { 
  getCourseDetail, 
  getCourseChapters,
  getCourseFavoriteStatus,
  toggleCourseFavorite,
  getCourseReviews,
  getRelatedCourses,
  submitCourseReview
} from '@/api/courseVideo'

const route = useRoute()
const router = useRouter()
const activeTab = ref('overview')
const isFavorite = ref(false)

const tabs = ref([
  { id: 'overview', name: '课程介绍' },
  { id: 'curriculum', name: '课程大纲' },
  { id: 'instructor', name: '讲师介绍' },
  { id: 'reviews', name: '学生评价' }
])

const course = ref({
  id: null,
  title: '',
  description: '',
  rating: 0,
  reviewCount: 0,
  studentCount: '0',
  duration: 0,
  difficulty: '',
  categoryName: ''
})

const instructor = ref({
  name: '',
  title: '',
  intro: '',
  avatar: ''
})

const chapters = ref([])

const reviews = ref([])

const relatedCourses = ref([])

// 新评价表单
const newRating = ref(5)
const newReviewContent = ref('')
const isSubmitting = ref(false)

const toggleChapter = (chapterId) => {
  const chapter = chapters.value.find(ch => ch.id === chapterId)
  if (chapter) {
    chapter.isOpen = !chapter.isOpen
  }
}

const loadCourseData = async () => {
  const courseId = route.params.courseId || route.params.id
  if (!courseId) return

  try {
    const [courseRes, chaptersRes] = await Promise.all([
      getCourseDetail(courseId),
      getCourseChapters(courseId)
    ])

    // Axios 拦截器已返回 response.data，这里再取一层 .data 才是后端封装的实际数据
    const c = (courseRes && courseRes.data) || courseRes || {}
    course.value = {
      id: c.course_id,
      title: c.course_name || '未命名课程',
      description: c.course_desc || '',
      rating: c.rating || 0,
      reviewCount: c.rating_count || 0,
      studentCount: String(c.student_count || 0),
      duration: c.course_duration || 0,
      difficulty: c.difficulty_level || '初级',
      categoryName: c.category_name || '未分类'
    }

    // 解析讲师信息
    instructor.value = {
      name: c.teacher_name || '未知讲师',
      title: c.teacher_occupation || '讲师',
      intro: c.teacher_intro || '暂无介绍',
      avatar: c.teacher_avatar || ''
    }

    const rawChapters = (chaptersRes && chaptersRes.data) || chaptersRes || []
    chapters.value = rawChapters.map((ch, index) => {
      const videos = ch.videos || []
      return {
        id: ch.chapter_id,
        title: ch.chapter_title,
        lessonCount: videos.length,
        isOpen: index === 0,
        lessons: videos.map(v => ({
          id: v.video_id,
          title: v.video_title,
          duration: Math.round((v.duration_seconds || 0) / 60) || 0
        }))
      }
    })

    // 加载当前用户是否已收藏（需要登录，若未登录会在控制台报 401，可忽略）
    try {
      const favRes = await getCourseFavoriteStatus(courseId)
      const favData = (favRes && favRes.data) || favRes || {}
      if (typeof favData.isFavorite === 'boolean') {
        isFavorite.value = favData.isFavorite
      } else if (favData.data && typeof favData.data.isFavorite === 'boolean') {
        isFavorite.value = favData.data.isFavorite
      }
    } catch (err) {
      console.warn('获取课程收藏状态失败（可能未登录）:', err?.response?.status)
    }

    // 加载课程评价
    try {
      const reviewsRes = await getCourseReviews(courseId, 10)
      const reviewsData = (reviewsRes && reviewsRes.data) || reviewsRes || []
      reviews.value = (Array.isArray(reviewsData) ? reviewsData : reviewsData.data || []).map(r => ({
        id: r.comment_id,
        name: r.user_name,
        job: r.occupation || '学员',
        avatar: r.user_name ? r.user_name.charAt(0) : '用',
        content: r.comment_content,
        rating: r.rating || 5
      }))
    } catch (err) {
      console.warn('获取课程评价失败:', err)
    }

    // 加载相关课程推荐
    try {
      const relatedRes = await getRelatedCourses(courseId, 4)
      const relatedData = (relatedRes && relatedRes.data) || relatedRes || []
      const courses = Array.isArray(relatedData) ? relatedData : relatedData.data || []
      relatedCourses.value = courses.map(rc => ({
        id: rc.course_id,
        title: rc.course_name,
        description: rc.course_desc,
        instructor: rc.teacher_name || '未知讲师',
        students: String(rc.student_count || 0),
        rating: rc.rating || 0,
        difficulty: rc.difficulty_level || '初级',
        image: rc.cover_img
          ? (rc.cover_img.startsWith('http')
              ? `url(${rc.cover_img})`
              : `url(http://localhost:4000${rc.cover_img})`)
          : 'linear-gradient(135deg, #667eea, #764ba2)'
      }))
    } catch (err) {
      console.warn('获取相关课程失败:', err)
    }
  } catch (error) {
    console.error('加载课程详情失败:', error)
  }
}

const goToFirstVideo = () => {
  if (!course.value.id || !chapters.value.length) return
  const firstChapter = chapters.value[0]
  const firstLesson = firstChapter.lessons && firstChapter.lessons[0]
  if (!firstLesson) return

  router.push(`/course/${course.value.id}/video/${firstLesson.id}`)
}

const toggleFavorite = async () => {
  if (!course.value.id) return

  try {
    const targetStatus = !isFavorite.value
    const res = await toggleCourseFavorite(course.value.id, targetStatus)
    const data = (res && res.data) || res || {}
    const final =
      typeof data.isFavorite === 'boolean'
        ? data.isFavorite
        : data.data && typeof data.data.isFavorite === 'boolean'
          ? data.data.isFavorite
          : targetStatus

    isFavorite.value = final
  } catch (error) {
    console.error('更新收藏状态失败:', error)
  }
}

// 提交课程评价
const handleSubmitReview = async () => {
  if (!course.value.id || !newReviewContent.value.trim()) return
  
  isSubmitting.value = true
  try {
    await submitCourseReview(course.value.id, newRating.value, newReviewContent.value.trim())
    
    // 清空表单
    newRating.value = 5
    newReviewContent.value = ''
    
    // 重新加载评价列表
    const reviewsRes = await getCourseReviews(course.value.id, 10)
    const reviewsData = (reviewsRes && reviewsRes.data) || reviewsRes || []
    reviews.value = (Array.isArray(reviewsData) ? reviewsData : reviewsData.data || []).map(r => ({
      id: r.comment_id,
      name: r.user_name,
      job: r.occupation || '学员',
      avatar: r.user_name ? r.user_name.charAt(0) : '用',
      content: r.comment_content,
      rating: r.rating || 5
    }))
    
    alert('评价提交成功！')
  } catch (error) {
    console.error('提交评价失败:', error)
    if (error.response?.status === 401) {
      alert('请先登录后再发表评价')
    } else {
      alert('评价提交失败，请稍后重试')
    }
  } finally {
    isSubmitting.value = false
  }
}

onMounted(() => {
  loadCourseData()
})

watch(
  () => route.params.courseId,
  () => {
    isFavorite.value = false
    loadCourseData()
  }
)
</script>

<style scoped>
.course-detail {
  min-height: 100vh;
}

/* 课程头部样式 */
.course-header {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  padding: 40px 0;
  margin-bottom: 30px;
}

.course-info {
  max-width: 800px;
}

.course-category {
  background: rgba(255,255,255,0.2);
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.8rem;
  display: inline-block;
  margin-bottom: 15px;
}

.course-info h1 {
  font-size: 2rem;
  margin-bottom: 10px;
}

.course-description {
  font-size: 1rem;
  margin-bottom: 20px;
  opacity: 0.9;
  line-height: 1.5;
}

.course-meta {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.9rem;
}

.course-actions {
  display: flex;
  gap: 12px;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 6px;
}

.btn-primary {
  background: #1a73e8;
  color: white;
}

.btn-primary:hover {
  background: #0d5bb9;
}

.btn-secondary {
  background: rgba(255,255,255,0.2);
  color: white;
  border: 1px solid rgba(255,255,255,0.3);
}

.btn-secondary:hover {
  background: rgba(255,255,255,0.3);
}

.btn-secondary-active {
  background: #ffc107;
  color: #202124;
  border-color: #ffc107;
}

/* 标签页样式 */
.tabs {
  display: flex;
  background: white;
  border-radius: 10px;
  padding: 8px;
  margin-bottom: 25px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  overflow-x: auto;
}

.tab {
  padding: 12px 20px;
  cursor: pointer;
  border-radius: 6px;
  transition: all 0.3s ease;
  white-space: nowrap;
  font-size: 0.9rem;
}

.tab.active {
  background: #e8f0fe;
  color: #1a73e8;
  font-weight: 600;
}

/* 内容区域样式 */
.content-section {
  background: white;
  border-radius: 10px;
  padding: 20px;
  margin-bottom: 25px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.section-title {
  font-size: 1.3rem;
  margin-bottom: 20px;
  color: #202124;
}

/* 课程介绍样式 */
.course-overview {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
}

.overview-content {
  line-height: 1.6;
}

.overview-content h3 {
  margin: 15px 0 8px;
  color: #202124;
  font-size: 1rem;
}

.overview-content ul {
  margin-left: 20px;
  margin-bottom: 15px;
}

.overview-content li {
  margin-bottom: 5px;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
  margin-top: 15px;
}

.feature-item {
  text-align: center;
  padding: 15px;
  background: white;
  border-radius: 6px;
}

.feature-icon {
  font-size: 1.5rem;
  color: #1a73e8;
  margin-bottom: 8px;
}

.feature-item h4 {
  font-size: 0.9rem;
  margin-bottom: 5px;
}

.feature-item p {
  font-size: 0.8rem;
  color: #5f6368;
}

/* 章节样式 */
.chapter {
  margin-bottom: 20px;
  border: 1px solid #dadce0;
  border-radius: 8px;
  overflow: hidden;
}

.chapter-header {
  background: #f8f9fa;
  padding: 15px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chapter-title {
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.95rem;
}

.chapter-content {
  padding: 0;
  max-height: 0;
  overflow: hidden;
  transition: all 0.3s ease;
}

.chapter.active .chapter-content {
  padding: 15px;
  max-height: 1000px;
}

.lesson {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid #dadce0;
}

.lesson:last-child {
  border-bottom: none;
}

.lesson-icon {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: #e8f0fe;
  color: #1a73e8;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
}

.lesson-info {
  flex: 1;
}

.lesson-title {
  font-weight: 500;
  margin-bottom: 2px;
  font-size: 0.9rem;
}

.lesson-meta {
  font-size: 0.8rem;
  color: #5f6368;
}

/* 讲师信息样式 */
.instructor-card {
  display: flex;
  gap: 15px;
  align-items: center;
}

.instructor-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: linear-gradient(135deg, #1a73e8, #6c8ef5);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.2rem;
  font-weight: bold;
}

.instructor-avatar-img {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  object-fit: cover;
}

.instructor-info h3 {
  font-size: 1.1rem;
  margin-bottom: 5px;
}

.instructor-title {
  color: #1a73e8;
  margin-bottom: 8px;
  font-size: 0.9rem;
}

.instructor-stats {
  display: flex;
  gap: 15px;
}

.stat {
  text-align: center;
}

.stat-value {
  font-size: 1rem;
  font-weight: bold;
  color: #1a73e8;
}

.stat-label {
  font-size: 0.8rem;
  color: #5f6368;
}

/* 评价表单样式 */
.review-form {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 30px;
}

.form-title {
  font-size: 1.1rem;
  margin-bottom: 15px;
  color: #202124;
}

.rating-selector {
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.rating-selector label {
  font-weight: 500;
  color: #5f6368;
}

.stars {
  display: flex;
  gap: 5px;
}

.star-icon {
  font-size: 1.5rem;
  color: #dadce0;
  cursor: pointer;
  transition: all 0.2s ease;
}

.star-icon.active {
  color: #f9ab00;
}

.star-icon:hover {
  transform: scale(1.1);
}

.review-input {
  margin-bottom: 15px;
}

.review-input label {
  display: block;
  font-weight: 500;
  color: #5f6368;
  margin-bottom: 8px;
}

.review-input textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #dadce0;
  border-radius: 6px;
  font-size: 0.9rem;
  font-family: inherit;
  resize: vertical;
  min-height: 100px;
}

.review-input textarea:focus {
  outline: none;
  border-color: #1a73e8;
}

.char-count {
  text-align: right;
  font-size: 0.8rem;
  color: #5f6368;
  margin-top: 5px;
}

.btn-submit {
  background: #1a73e8;
  color: white;
  padding: 10px 24px;
  border: none;
  border-radius: 6px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-submit:hover:not(:disabled) {
  background: #0d5bb9;
}

.btn-submit:disabled {
  background: #dadce0;
  cursor: not-allowed;
}

/* 评价列表样式 */
.reviews-grid {
  display: grid;
  gap: 15px;
}

.review-card {
  padding: 15px;
  border: 1px solid #dadce0;
  border-radius: 8px;
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 10px;
}

.reviewer {
  display: flex;
  align-items: center;
  gap: 8px;
}

.reviewer-avatar {
  width: 35px;
  height: 35px;
  border-radius: 50%;
  background: #1a73e8;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 0.9rem;
}

.rating {
  color: #f9ab00;
  font-size: 0.9rem;
}

.review-content {
  color: #202124;
  line-height: 1.5;
  font-size: 0.9rem;
}

/* 相关课程样式 */
.related-courses {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 25px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

@media (max-width: 768px) {
  .course-meta {
    gap: 15px;
  }
  
  .course-actions {
    flex-direction: column;
  }
  
  .features-grid {
    grid-template-columns: 1fr;
  }
  
  .related-courses {
    grid-template-columns: 1fr;
  }
}
</style>