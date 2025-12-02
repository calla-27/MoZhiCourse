<template>
  <div class="course-detail">
    <!-- 课程头部 -->
    <section class="course-header">
      <div class="container">
        <div class="course-info">
          <span class="course-category">编程开发</span>
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
            <button class="btn btn-primary">
              <i class="fas fa-play"></i>
              开始学习
            </button>
            <button class="btn btn-secondary">
              <i class="far fa-heart"></i>
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
              <p>
                本课程专为编程零基础的学习者设计，通过生动有趣的案例和实践项目，带你轻松入门Python编程世界。
              </p>

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
                  <i
                    :class="
                      chapter.isOpen
                        ? 'fas fa-chevron-down'
                        : 'fas fa-chevron-right'
                    "
                  ></i>
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
            <div class="instructor-avatar">张</div>
            <div class="instructor-info">
              <h3>张老师</h3>
              <div class="instructor-title">高级软件工程师</div>
              <p style="margin-bottom: 15px; line-height: 1.5">
                拥有8年Python开发经验，曾在多家知名互联网公司担任技术负责人。
              </p>
              <div class="instructor-stats">
                <div class="stat">
                  <div class="stat-value">4.8/5.0</div>
                  <div class="stat-label">讲师评分</div>
                </div>
                <div class="stat">
                  <div class="stat-value">24,589</div>
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
          <div class="reviews-grid">
            <div v-for="review in reviews" :key="review.id" class="review-card">
              <div class="review-header">
                <div class="reviewer">
                  <div class="reviewer-avatar">{{ review.avatar }}</div>
                  <div>
                    <div style="font-weight: 600">{{ review.name }}</div>
                    <div style="font-size: 0.8rem; color: #5f6368">
                      {{ review.job }}
                    </div>
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
    <div v-if="currentCourse">
      <h1>{{ currentCourse.title }}</h1>

      <!-- 课程内容区域 -->
      <div class="course-content">
        <!-- 视频播放器 -->
        <div class="video-player" v-if="currentVideo">
          <video
            ref="videoPlayer"
            :src="currentVideo.url"
            @play="onVideoPlay"
            @pause="onVideoPause"
            @timeupdate="onVideoTimeUpdate"
            @ended="onVideoEnded"
          ></video>
        </div>

        <!-- 测验组件 -->
        <div class="quiz-section" v-if="currentQuiz">
          <button @click="startQuiz">开始测验</button>
          <button @click="submitQuiz" :disabled="!quizAnswers">提交答案</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { trackStudySession } from '@/utils/tracking'

const route = useRoute()
const currentCourse = ref(null)
const currentVideo = ref(null)
const currentQuiz = ref(null)
const videoPlayer = ref(null)

// 学习会话计时
const studyStartTime = ref(null)
const totalStudyTime = ref(0)

// 视频播放计时
const videoStartTime = ref(null)
const totalVideoTime = ref(0)

// 页面加载时开始学习会话
onMounted(async () => {
  await loadCourseData(route.params.id)
  
  // 开始学习埋点
  trackStudySession.start(currentCourse.value.id, currentCourse.value.title)
  studyStartTime.value = new Date()
  
  // 页面访问埋点
  trackStudySession.pageView('course_detail', currentCourse.value.id)
})

// 页面离开时结束学习会话
onUnmounted(() => {
  if (studyStartTime.value) {
    const endTime = new Date()
    const duration = Math.round((endTime - studyStartTime.value) / 1000) // 转换为秒
    
    // 计算学习进度（这里需要根据你的业务逻辑计算）
    const progress = calculateLearningProgress()
    
    // 结束学习埋点
    trackStudySession.end(
      currentCourse.value.id, 
      currentCourse.value.title, 
      duration, 
      progress
    )
  }
})

// 视频播放事件
const onVideoPlay = () => {
  videoStartTime.value = new Date()
  console.log('视频开始播放')
}

const onVideoPause = () => {
  if (videoStartTime.value) {
    const pauseTime = new Date()
    const watchDuration = Math.round((pauseTime - videoStartTime.value) / 1000)
    totalVideoTime.value += watchDuration
    
    // 视频观看埋点
    trackStudySession.videoWatch(
      currentCourse.value.id,
      currentVideo.value.id,
      totalVideoTime.value,
      currentVideo.value.duration
    )
  }
}

const onVideoTimeUpdate = () => {
  // 每30秒上报一次观看进度
  const currentTime = Math.floor(videoPlayer.value.currentTime)
  if (currentTime > 0 && currentTime % 30 === 0) {
    trackStudySession.videoWatch(
      currentCourse.value.id,
      currentVideo.value.id,
      currentTime,
      videoPlayer.value.duration
    )
  }
}

const onVideoEnded = () => {
  if (videoStartTime.value) {
    const endTime = new Date()
    const watchDuration = Math.round((endTime - videoStartTime.value) / 1000)
    totalVideoTime.value += watchDuration
    
    // 视频观看完成埋点
    trackStudySession.videoWatch(
      currentCourse.value.id,
      currentVideo.value.id,
      totalVideoTime.value,
      currentVideo.value.duration
    )
  }
}

// 测验相关埋点
const startQuiz = () => {
  trackStudySession.quizComplete(
    currentCourse.value.id,
    currentQuiz.value.id,
    0, // 初始分数为0
    currentQuiz.value.totalScore
  )
}

const submitQuiz = (score) => {
  trackStudySession.quizComplete(
    currentCourse.value.id,
    currentQuiz.value.id,
    score,
    currentQuiz.value.totalScore
  )
}

// 加载课程数据（根据你的实际API调整）
const loadCourseData = async (courseId) => {
  try {
    // 这里调用你的课程API
    // const response = await fetchCourseById(courseId)
    // currentCourse.value = response.data
    
    // 模拟数据
    currentCourse.value = {
      id: courseId,
      title: 'Vue.js 高级课程',
      description: '学习Vue.js高级特性'
    }
    
    currentVideo.value = {
      id: 'video_1',
      url: '/videos/sample.mp4',
      duration: 1800 // 30分钟，单位秒
    }
  } catch (error) {
    console.error('加载课程数据失败:', error)
  }
}

// 计算学习进度（需要根据你的业务逻辑实现）
const calculateLearningProgress = () => {
  // 这里根据视频观看进度、测验完成情况等计算总体进度
  return 65 // 返回0-100的进度值
}
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
  background: rgba(255, 255, 255, 0.2);
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
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* 标签页样式 */
.tabs {
  display: flex;
  background: white;
  border-radius: 10px;
  padding: 8px;
  margin-bottom: 25px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
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
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
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

/* 评价样式 */
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