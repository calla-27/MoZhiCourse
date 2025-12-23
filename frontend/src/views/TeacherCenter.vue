<!-- frontend/src/views/TeacherCenter.vue -->
<template>
  <div class="teacher-center-wrapper">
    <div class="teacher-center">
      <!-- 教师头部 -->
      <div class="container">
        <div class="profile-header">
          <!-- 背景装饰 -->
          <div class="profile-bg-decoration">
            <div class="decoration-circle circle-1"></div>
            <div class="decoration-circle circle-2"></div>
            <div class="decoration-circle circle-3"></div>
          </div>
          
          <!-- 左侧头像区域 -->
          <div class="profile-left">
            <div class="profile-avatar" @click="showAvatar = true">
              <img v-if="user.avatarUrl" :src="user.avatarUrl" alt="教师头像" />
              <span v-else>{{ user.userName?.charAt(0) || '教' }}</span>
              <div class="online-indicator"></div>
              <div class="avatar-edit-overlay">
                <i class="fas fa-camera"></i>
              </div>
            </div>
            <div class="user-level">
              <i class="fas fa-chalkboard-teacher"></i>
              <span>认证教师</span>
            </div>
          </div>

          <!-- 右侧信息区域 -->
          <div class="profile-info">
            <div class="profile-name-row">
              <h1>{{ user.userName || '教师' }}</h1>
              <div class="user-badges">
                <span class="badge badge-teacher"><i class="fas fa-award"></i> 优秀讲师</span>
                <span class="badge badge-verified"><i class="fas fa-check-circle"></i> 已认证</span>
              </div>
            </div>
            
            <div class="user-title">{{ teacherStats.title || 'Python高级工程师 · 全栈开发专家' }}</div>
            
            <div class="profile-bio-wrapper">
              <span class="quote-mark quote-left">"</span>
              <p class="profile-bio">{{ teacherStats.description || '专注于编程教育和软件开发，拥有丰富的教学经验，致力于帮助每一位学生成长' }}</p>
              <span class="quote-mark quote-right">"</span>
            </div>

            <!-- 快捷统计 -->
            <div class="profile-quick-stats">
              <div class="quick-stat">
                <i class="fas fa-book-open"></i>
                <span class="stat-num">{{ teacherStats.courses?.total || 0 }}</span>
                <span class="stat-unit">门课程</span>
              </div>
              <div class="quick-stat">
                <i class="fas fa-star"></i>
                <span class="stat-num">{{ teacherStats.rating?.average || '0.0' }}</span>
                <span class="stat-unit">总评分</span>
              </div>
              <div class="quick-stat">
                <i class="fas fa-comments"></i>
                <span class="stat-num">{{ teacherStats.rating?.total_reviews || 0 }}</span>
                <span class="stat-unit">评价数</span>
              </div>
              <div class="quick-stat">
                <i class="fas fa-heart"></i>
                <span class="stat-num">{{ Math.round((teacherStats.rating?.average || 0) * 20) }}%</span>
                <span class="stat-unit">满意度</span>
              </div>
            </div>
          </div>

          <!-- 操作按钮 -->
          <button class="edit-profile-btn" @click="showEditProfile = true" title="编辑个人资料">
            <i class="fas fa-user-edit"></i>
          </button>
          <button class="settings-btn" @click="showSettings = true" title="账户设置">
            <i class="fas fa-cog"></i>
          </button>
        </div>
      </div>

      <!-- 标签页导航 -->
      <div class="container">
        <div class="tabs">
          <div 
            v-for="t in tabs" 
            :key="t.key" 
            class="tab" 
            :class="{ active: activeTab === t.key }" 
            @click="activeTab = t.key"
          >
            <span>{{ t.label }}</span>
          </div>
        </div>
      </div>

      <!-- 内容区域 -->
      <div class="container">
        <!-- 1. 课程管理 -->
        <section v-if="activeTab === 'courses'" class="content-section">
          <div class="section-header">
            <div class="section-title">
              <i class="fas fa-graduation-cap"></i>
              <span>我的课程</span>
            </div>
            <div class="section-actions">
              <button class="more-btn">
                查看全部 <i class="fas fa-chevron-right"></i>
              </button>
              <button class="btn btn-secondary refresh-btn" @click="refreshCourseData" :disabled="loadingCourses">
                <i class="fas fa-sync-alt" :class="{ 'fa-spin': loadingCourses }"></i> 
                {{ loadingCourses ? '刷新中...' : '刷新' }}
              </button>
              <button class="btn btn-primary" @click="createNewCourse">
                <i class="fas fa-plus"></i> 创建新课程
              </button>
            </div>
          </div>
          
          <div class="courses-grid" v-if="teacherCourses.length">
            <div v-for="c in teacherCourses" :key="c.course_id" class="course-card">
              <!-- 课程封面图片 -->
              <div class="course-cover">
                <img 
                  v-if="c.cover_image" 
                  :src="getCoverUrl(c.cover_image)" 
                  :alt="c.course_name"
                  @error="handleImageError"
                />
                <div v-else class="cover-placeholder">
                  <i class="fas fa-book-open"></i>
                </div>
                <!-- 难度标签 - 左上角 -->
                <span class="difficulty-tag" :class="getDifficultyClass(c.difficulty)">
                  {{ getDifficultyText(c.difficulty) }}
                </span>
                <!-- 发布状态标签 - 右上角 -->
                <span class="status-tag" :class="c.status === 'published' ? 'published' : 'draft'">
                  {{ c.status === 'published' ? '已发布' : '草稿' }}
                </span>
              </div>
              
              <div class="course-card-body">
                <div class="course-card-header">
                  <div class="course-info">
                    <h3 class="course-title">{{ c.course_name }}</h3>
                    <div class="course-category">{{ c.category_name || '编程开发' }}</div>
                  </div>
                </div>
                
                <div class="course-stats-row">
                  <div class="course-stat">
                    <div class="course-stat-icon">
                      <i class="fas fa-users"></i>
                    </div>
                    <div class="course-stat-value">{{ c.student_count || 0 }}</div>
                  </div>
                  <div class="course-stat">
                    <div class="course-stat-icon star">
                      <i class="fas fa-star"></i>
                    </div>
                    <div class="course-stat-value">{{ c.avg_rating || '0.0' }}</div>
                  </div>
                  <div class="course-stat">
                    <div class="course-stat-icon comment">
                      <i class="fas fa-comments"></i>
                    </div>
                    <div class="course-stat-value">{{ c.review_count || 0 }}</div>
                  </div>
                </div>
                
                <div class="course-card-actions">
                  <!-- 编辑按钮 -->
                  <button class="action-btn primary" @click="editCourse(c.course_id)">
                    <i class="fas fa-edit"></i> 编辑
                  </button>
                  <!-- 发布/下架按钮 -->
                  <template v-if="c.status !== 'published'">
                    <button class="action-btn success" @click="publishCourse(c)">
                      <i class="fas fa-rocket"></i> 发布
                    </button>
                  </template>
                  <template v-else>
                    <button class="action-btn warning" @click="toggleCourseStatus(c)">
                      <i class="fas fa-eye-slash"></i> 下架
                    </button>
                  </template>
                  <!-- 删除按钮 -->
                  <button class="action-btn outline danger" @click="confirmDeleteCourse(c)">
                    <i class="fas fa-trash-alt"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 空状态 -->
          <div v-else class="empty-state">
            <div class="empty-icon"><i class="fas fa-book-open"></i></div>
            <p>还没有创建任何课程</p>
            <span class="empty-hint">开始创建您的第一门课程，分享您的知识吧！</span>
            <button class="btn btn-primary" @click="createNewCourse">
              <i class="fas fa-plus"></i> 创建课程
            </button>
          </div>
        </section>

        <!-- 2. 学生管理 -->
        <section v-if="activeTab === 'students'" class="content-section">
          <div class="section-header">
            <div class="section-title">
              <i class="fas fa-users"></i>
              <span>学生管理</span>
              <span class="student-count-badge" v-if="studentPagination.total">{{ studentPagination.total }}人</span>
            </div>
            <div class="section-actions">
              <div class="sort-selector">
                <label>排序：</label>
                <select v-model="studentSort" @change="onSortChange" class="sort-select">
                  <option value="progress-desc">完成度 ↓</option>
                  <option value="progress-asc">完成度 ↑</option>
                  <option value="enroll_time-desc">报名时间 ↓</option>
                  <option value="enroll_time-asc">报名时间 ↑</option>
                  <option value="duration-desc">学习时长 ↓</option>
                </select>
              </div>
              <div class="course-selector">
                <label>选择课程：</label>
                <select v-model="selectedCourseId" @change="onCourseChange" class="course-select">
                  <option v-for="course in teacherCourses" :key="course.course_id" :value="course.course_id">
                    {{ course.course_name }}
                  </option>
                </select>
              </div>
            </div>
          </div>
          
          <div class="students-table-wrapper" v-if="students.length && !loadingStudents">
            <table class="students-table">
              <thead>
                <tr>
                  <th>学生信息</th>
                  <th>课程</th>
                  <th @click="toggleSort('progress')" class="sortable-th">
                    学习进度 
                    <i :class="getSortIcon('progress')"></i>
                  </th>
                  <th @click="toggleSort('duration')" class="sortable-th">
                    学习时长
                    <i :class="getSortIcon('duration')"></i>
                  </th>
                  <th>状态</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="s in students" :key="s.user_id">
                  <td>
                    <div class="student-info">
                      <div class="student-avatar">
                        <img v-if="s.avatar_url" :src="s.avatar_url" alt="" />
                        <span v-else>{{ s.user_name?.charAt(0) || '学' }}</span>
                      </div>
                      <div class="student-details">
                        <div class="student-name">{{ s.user_name }}</div>
                        <div class="student-email">{{ s.email || '未设置邮箱' }}</div>
                      </div>
                    </div>
                  </td>
                  <td><span class="course-tag">{{ currentCourseName }}</span></td>
                  <td>
                    <div class="progress-cell">
                      <div class="progress-bar">
                        <div class="progress-fill" :style="{ width: (s.completed_percent || 0) + '%' }"></div>
                      </div>
                      <span class="progress-text">{{ s.completed_percent || 0 }}%</span>
                    </div>
                  </td>
                  <td><span class="time-text">{{ s.total_watch_hours || 0 }} 小时</span></td>
                  <td>
                    <span class="status-badge" :class="getStatusClass(s.completed_percent)">
                      {{ getStatusText(s.completed_percent) }}
                    </span>
                  </td>
                  <td>
                    <button class="action-btn primary small" @click="goToStudentAnalysis(s.user_id)">
                      <i class="fas fa-chart-line"></i> 详情
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
            
            <!-- 展开更多按钮 -->
            <div class="load-more-wrapper" v-if="studentPagination.hasMore">
              <button class="load-more-btn" @click="loadMoreStudents" :disabled="loadingMore">
                <i :class="loadingMore ? 'fas fa-spinner fa-spin' : 'fas fa-chevron-down'"></i>
                {{ loadingMore ? '加载中...' : `展开更多 (${studentPagination.total - students.length}人)` }}
              </button>
            </div>
          </div>
          
          <!-- 加载状态 -->
          <div v-if="loadingStudents" class="loading-state">
            <i class="fas fa-spinner fa-spin"></i>
            <span>加载中...</span>
          </div>
          
          <!-- 空状态 -->
          <div v-else-if="!students.length" class="empty-state">
            <div class="empty-icon"><i class="fas fa-user-graduate"></i></div>
            <p>暂无学生数据</p>
            <span class="empty-hint">当有学生报名您的课程后，这里会显示学生信息</span>
          </div>
        </section>

        <!-- 3. 数据统计 -->
        <section v-if="activeTab === 'analytics'" class="content-section">
          <div class="section-header">
            <div class="section-title">
              <i class="fas fa-chart-pie"></i>
              <span>教学数据概览</span>
            </div>
            <button class="more-btn" @click="goToTeacherAnalysis">
              查看详情 <i class="fas fa-chevron-right"></i>
            </button>
          </div>
          
          <div class="stats-grid">
            <div class="stat-card courses">
              <div class="stat-card-icon"><i class="fas fa-book-open"></i></div>
              <div class="stat-card-content">
                <div class="stat-card-value">{{ teacherStats.courses?.total || 0 }}</div>
                <div class="stat-card-label">课程门数</div>
              </div>
            </div>
            <div class="stat-card rating">
              <div class="stat-card-icon"><i class="fas fa-star"></i></div>
              <div class="stat-card-content">
                <div class="stat-card-value">{{ teacherStats.rating?.average || '0.0' }}</div>
                <div class="stat-card-label">平均评分</div>
              </div>
            </div>
            <div class="stat-card reviews">
              <div class="stat-card-icon"><i class="fas fa-comments"></i></div>
              <div class="stat-card-content">
                <div class="stat-card-value">{{ teacherStats.rating?.total_reviews || 0 }}</div>
                <div class="stat-card-label">评价总数</div>
              </div>
            </div>
            <div class="stat-card satisfaction">
              <div class="stat-card-icon"><i class="fas fa-heart"></i></div>
              <div class="stat-card-content">
                <div class="stat-card-value">{{ Math.round((teacherStats.rating?.average || 0) * 20) }}%</div>
                <div class="stat-card-label">满意度</div>
              </div>
            </div>
          </div>
          
          <!-- 分析入口卡片 -->
          <div class="analysis-entry" @click="goToTeacherAnalysis">
            <div class="analysis-icon">
              <i class="fas fa-chart-bar"></i>
            </div>
            <div class="analysis-content">
              <h3>查看详细学情分析</h3>
              <p>深入了解学生知识掌握分布、学习行为分析、课程完成率等详细数据</p>
              <div class="analysis-features">
                <span><i class="fas fa-check"></i> 知识掌握分布</span>
                <span><i class="fas fa-check"></i> 学习行为词云</span>
                <span><i class="fas fa-check"></i> 课程完成率</span>
              </div>
            </div>
            <div class="analysis-arrow">
              <i class="fas fa-arrow-right"></i>
            </div>
          </div>
        </section>
      </div>
    </div>

    <!-- 弹窗组件 -->
    <AvatarModal v-model="showAvatar" @avatar-updated="handleAvatarUpdate" />
    <SettingsModal v-model="showSettings" />
    <EditProfileModal 
      v-model="showEditProfile"
      :user-name="user.userName"
      :email="user.email"
      :user-intro="user.userIntro"
      @save="handleProfileUpdate"
    />
    
    <!-- 课程设置弹窗 -->
    <div v-if="showCourseSettings" class="modal-overlay" @click.self="closeCourseSettings">
      <div class="course-settings-modal">
        <div class="modal-header">
          <h3><i class="fas fa-cog"></i> 课程设置</h3>
          <button class="close-btn" @click="closeCourseSettings">
            <i class="fas fa-times"></i>
          </button>
        </div>
        
        <div class="modal-body" v-if="selectedCourse">
          <div class="course-info-summary">
            <h4>{{ selectedCourse.course_name }}</h4>
            <span class="status-badge" :class="selectedCourse.status === 'published' ? 'status-active' : 'status-draft'">
              {{ selectedCourse.status === 'published' ? '已发布' : '草稿' }}
            </span>
          </div>
          
          <div class="settings-section">
            <h5><i class="fas fa-eye"></i> 发布状态</h5>
            <p class="section-desc">控制课程是否对学生可见</p>
            <button 
              class="settings-action-btn" 
              :class="selectedCourse.status === 'published' ? 'btn-warning' : 'btn-success'"
              @click="toggleCourseStatus(selectedCourse)"
            >
              <i :class="selectedCourse.status === 'published' ? 'fas fa-eye-slash' : 'fas fa-rocket'"></i>
              {{ selectedCourse.status === 'published' ? '下架课程' : '发布课程' }}
            </button>
          </div>
          
          <div class="settings-section">
            <h5><i class="fas fa-edit"></i> 编辑课程</h5>
            <p class="section-desc">修改课程信息、章节和视频内容</p>
            <button class="settings-action-btn btn-primary" @click="editCourse(selectedCourse.course_id); closeCourseSettings()">
              <i class="fas fa-pen"></i> 进入编辑
            </button>
          </div>
          
          <div class="settings-section">
            <h5><i class="fas fa-chart-bar"></i> 数据分析</h5>
            <p class="section-desc">查看课程学习数据和学生表现</p>
            <button class="settings-action-btn btn-info" @click="viewCourseData(selectedCourse.course_id); closeCourseSettings()">
              <i class="fas fa-chart-line"></i> 查看数据
            </button>
          </div>
          
          <div class="settings-section danger-zone">
            <h5><i class="fas fa-exclamation-triangle"></i> 危险操作</h5>
            <p class="section-desc">删除课程后无法恢复，已有学生报名的课程无法删除</p>
            <button class="settings-action-btn btn-danger" @click="handleDeleteCourse(selectedCourse)">
              <i class="fas fa-trash-alt"></i> 删除课程
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user.js'
import AvatarModal from '../components/AvatarModal.vue'
import SettingsModal from '../components/SettingsModal.vue'
import EditProfileModal from '../components/EditProfileModal.vue'
import {
  apiTeacherStats,
  apiTeacherCourses,
  apiTeacherStudents,
  apiUpdateCourse,
  apiDeleteCourse
} from '../api/teacher.js'

/* ---------- 基础 UI 状态 ---------- */
const router = useRouter()
const activeTab = ref('courses')
const showAvatar = ref(false)
const showSettings = ref(false)
const showEditProfile = ref(false)
const showCourseSettings = ref(false)
const selectedCourse = ref(null)

/* 顶部导航标签 */
const tabs = [
  { key: 'courses', label: '课程管理'},
  { key: 'students', label: '学生管理'},
  { key: 'analytics', label: '数据统计'}
]

/* 教师个人信息 */
const user = useUserStore()

/* ---------- 业务数据 ---------- */
const teacherStats = ref({})
const teacherCourses = ref([])
const students = ref([])
const loadingCourses = ref(false)
const currentCourseName = ref('')
const selectedCourseId = ref(null)
const loadingStudents = ref(false)
const loadingMore = ref(false)
const studentSort = ref('progress-desc')
const studentPagination = ref({
  page: 1,
  limit: 10,
  total: 0,
  totalPages: 0,
  hasMore: false
})

/* ---------- 初始化 ---------- */
onMounted(async () => {
  console.log('🎓 教师中心加载中...')
  
  try {
    if (!user.userId) {
      console.log('📝 获取用户信息...')
      await user.fetchUserProfile()
      console.log('✅ 用户信息获取完成:', user.userName)
    }

    console.log('📊 获取教学统计数据...')
    const statRes = await apiTeacherStats()
    teacherStats.value = statRes.data ?? {}
    console.log('✅ 教学统计:', teacherStats.value)

    console.log('📚 获取课程列表...')
    const courseRes = await apiTeacherCourses()
    teacherCourses.value = Array.isArray(courseRes.data)
      ? courseRes.data
      : (courseRes.data && courseRes.data.list) || []
    console.log('✅ 课程列表:', teacherCourses.value)

    if (teacherCourses.value.length) {
      // 默认选择第一门课程
      const firstCourse = teacherCourses.value[0]
      selectedCourseId.value = firstCourse.course_id
      currentCourseName.value = firstCourse.course_name
      // 加载第一门课程的学生
      await loadStudentsByCourse(firstCourse.course_id)
    } else {
      console.log('⚠️ 没有课程，跳过获取学生')
    }
    
    console.log('🎉 教师中心数据加载完成！')
  } catch (error) {
    console.error('❌ 教师中心数据加载失败:', error)
    teacherStats.value = {
      total_courses: 0,
      total_students: 0,
      average_rating: '0.0',
      completion_rate: '0'
    }
    teacherCourses.value = []
    students.value = []
  }
})

/* ---------- 事件处理 ---------- */
function createNewCourse() {
  router.push('/teacher/course-create')
}

// 刷新课程数据
async function refreshCourseData() {
  try {
    loadingCourses.value = true
    console.log('🔄 刷新课程数据...')
    
    // 重新获取课程列表
    const courseRes = await apiTeacherCourses()
    teacherCourses.value = Array.isArray(courseRes.data)
      ? courseRes.data
      : (courseRes.data && courseRes.data.list) || []
    
    console.log('✅ 课程数据刷新完成:', teacherCourses.value.length, '门课程')
    
    // 如果当前选中的课程还存在，保持选中状态
    if (selectedCourseId.value) {
      const currentCourse = teacherCourses.value.find(c => c.course_id === selectedCourseId.value)
      if (currentCourse) {
        currentCourseName.value = currentCourse.course_name
        // 刷新学生列表
        await loadStudents(selectedCourseId.value, studentSort.value, false)
      }
    }
    
  } catch (error) {
    console.error('❌ 刷新课程数据失败:', error)
  } finally {
    loadingCourses.value = false
  }
}

function editCourse(courseId) {
  router.push(`/teacher/course-edit/${courseId}`)
}

function goToTeacherAnalysis() {
  router.push('/teacher/analysis')
}

// 查看课程数据统计
function viewCourseData(courseId) {
  router.push({
    path: '/teacher/analysis',
    query: { courseId }
  })
}

// 打开课程设置弹窗
function openCourseSettings(course) {
  selectedCourse.value = { ...course }
  showCourseSettings.value = true
}

// 切换课程发布状态
async function toggleCourseStatus(course) {
  const newStatus = course.status === 'published' ? 0 : 1
  const statusText = newStatus === 1 ? '发布' : '下架'
  
  if (!confirm(`确定要${statusText}课程「${course.course_name}」吗？`)) {
    return
  }
  
  try {
    const res = await apiUpdateCourse(course.course_id, { is_online: newStatus })
    if (res.success) {
      // 更新本地状态
      const idx = teacherCourses.value.findIndex(c => c.course_id === course.course_id)
      if (idx !== -1) {
        teacherCourses.value[idx].status = newStatus === 1 ? 'published' : 'draft'
      }
      alert(`课程${statusText}成功！`)
    } else {
      alert(res.message || `${statusText}失败`)
    }
  } catch (error) {
    console.error('切换课程状态失败:', error)
    alert('操作失败，请重试')
  }
}

// 删除课程
async function handleDeleteCourse(course) {
  if (!confirm(`确定要删除课程「${course.course_name}」吗？\n注意：已有学生报名的课程无法删除。`)) {
    return
  }
  
  try {
    const res = await apiDeleteCourse(course.course_id)
    if (res.success) {
      // 从列表中移除
      teacherCourses.value = teacherCourses.value.filter(c => c.course_id !== course.course_id)
      showCourseSettings.value = false
      alert('课程删除成功！')
    } else {
      alert(res.message || '删除失败')
    }
  } catch (error) {
    console.error('删除课程失败:', error)
    alert('删除失败，请重试')
  }
}

// 关闭课程设置弹窗
function closeCourseSettings() {
  showCourseSettings.value = false
  selectedCourse.value = null
}

// 跳转到学生数据分析页面（只展示该学生在当前课程的数据）
function goToStudentAnalysis(studentId) {
  router.push({
    path: '/student/behavior',
    query: {
      viewAs: 'teacher',
      studentId,
      courseId: selectedCourseId.value,
      courseName: currentCourseName.value
    }
  })
}

// 根据课程ID加载学生列表
async function loadStudentsByCourse(courseId, append = false) {
  if (!courseId) return
  
  if (append) {
    loadingMore.value = true
  } else {
    loadingStudents.value = true
    studentPagination.value.page = 1
  }
  
  const [sort, order] = studentSort.value.split('-')
  const page = append ? studentPagination.value.page + 1 : 1
  
  console.log('👥 获取课程学生列表, courseId:', courseId, 'page:', page, 'sort:', sort)
  
  try {
    const stuRes = await apiTeacherStudents(courseId, {
      page,
      limit: 10,
      sort,
      order
    })
    console.log('📌 学生API返回:', stuRes)
    
    if (stuRes.success && stuRes.data) {
      const newStudents = Array.isArray(stuRes.data) ? stuRes.data : []
      if (append) {
        students.value = [...students.value, ...newStudents]
      } else {
        students.value = newStudents
      }
      // 更新分页信息
      if (stuRes.pagination) {
        studentPagination.value = stuRes.pagination
      }
    } else {
      if (!append) students.value = []
    }
    console.log('✅ 学生列表:', students.value.length, '总数:', studentPagination.value.total)
  } catch (error) {
    console.error('❌ 获取学生列表失败:', error)
    if (!append) students.value = []
  } finally {
    loadingStudents.value = false
    loadingMore.value = false
  }
}

// 加载更多学生
async function loadMoreStudents() {
  await loadStudentsByCourse(selectedCourseId.value, true)
}

// 课程切换时重新加载学生
async function onCourseChange() {
  const course = teacherCourses.value.find(c => c.course_id === selectedCourseId.value)
  if (course) {
    currentCourseName.value = course.course_name
    await loadStudentsByCourse(selectedCourseId.value)
  }
}

// 排序切换
async function onSortChange() {
  await loadStudentsByCourse(selectedCourseId.value)
}

// 点击表头排序
function toggleSort(field) {
  const [currentField, currentOrder] = studentSort.value.split('-')
  if (currentField === field) {
    studentSort.value = `${field}-${currentOrder === 'desc' ? 'asc' : 'desc'}`
  } else {
    studentSort.value = `${field}-desc`
  }
  onSortChange()
}

// 获取排序图标
function getSortIcon(field) {
  const [currentField, currentOrder] = studentSort.value.split('-')
  if (currentField === field) {
    return currentOrder === 'desc' ? 'fas fa-sort-down' : 'fas fa-sort-up'
  }
  return 'fas fa-sort'
}

// 获取状态样式
function getStatusClass(percent) {
  if (percent >= 80) return 'status-success'
  if (percent > 0) return 'status-active'
  return 'status-warning'
}

// 获取状态文本
function getStatusText(percent) {
  if (percent >= 80) return '优秀'
  if (percent >= 50) return '进行中'
  if (percent > 0) return '刚开始'
  return '未开始'
}

// 获取课程封面URL
function getCoverUrl(coverImage) {
  if (!coverImage) return ''
  if (coverImage.startsWith('http')) return coverImage
  return `http://localhost:4000${coverImage}`
}

// 图片加载失败处理
function handleImageError(e) {
  e.target.style.display = 'none'
  e.target.parentElement.innerHTML = '<div class="cover-placeholder"><i class="fas fa-book-open"></i></div>'
}

// 获取难度中文文本
function getDifficultyText(difficulty) {
  const difficultyMap = {
    'beginner': '入门',
    'elementary': '初级',
    'intermediate': '中级',
    'advanced': '高级',
    'expert': '专家'
  }
  return difficultyMap[difficulty] || difficulty || '未设置'
}

// 获取难度样式类
function getDifficultyClass(difficulty) {
  const classMap = {
    'beginner': 'difficulty-beginner',
    'elementary': 'difficulty-elementary',
    'intermediate': 'difficulty-intermediate',
    'advanced': 'difficulty-advanced',
    'expert': 'difficulty-expert'
  }
  return classMap[difficulty] || ''
}

// 发布课程
async function publishCourse(course) {
  if (!confirm(`确定要发布课程「${course.course_name}」吗？`)) {
    return
  }
  
  try {
    const res = await apiUpdateCourse(course.course_id, { is_online: 1 })
    if (res.success) {
      const idx = teacherCourses.value.findIndex(c => c.course_id === course.course_id)
      if (idx !== -1) {
        teacherCourses.value[idx].status = 'published'
      }
      alert('课程发布成功！')
    } else {
      alert(res.message || '发布失败')
    }
  } catch (error) {
    console.error('发布课程失败:', error)
    alert('发布失败，请重试')
  }
}

// 确认删除课程
async function confirmDeleteCourse(course) {
  if (!confirm(`确定要删除课程「${course.course_name}」吗？\n注意：已有学生报名的课程无法删除。`)) {
    return
  }
  
  try {
    const res = await apiDeleteCourse(course.course_id)
    if (res.success) {
      teacherCourses.value = teacherCourses.value.filter(c => c.course_id !== course.course_id)
      alert('课程删除成功！')
    } else {
      alert(res.message || '删除失败')
    }
  } catch (error) {
    console.error('删除课程失败:', error)
    alert('删除失败，请重试')
  }
}

const handleAvatarUpdate = (avatarUrl) => {
  user.updateAvatar(avatarUrl)
}

const handleProfileUpdate = async (profileData) => {
  try {
    await user.updateProfile(profileData)
    alert('个人资料更新成功')
  } catch (error) {
    alert('更新个人资料失败：' + error.message)
  }
}
</script>


<style scoped>
/* ===== 基础变量 ===== */
:root {
  --primary: #1a73e8;
  --primary-light: #e8f0fe;
  --primary-dark: #0d5bb9;
  --secondary: #34a853;
  --secondary-light: #e6f4ea;
  --warning: #f9ab00;
  --danger: #ea4335;
  --dark: #202124;
  --light: #f8f9fa;
  --gray: #5f6368;
  --gray-light: #80868b;
  --border: #dadce0;
  --shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  --shadow-hover: 0 8px 30px rgba(0, 0, 0, 0.12);
  --radius: 16px;
  --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

/* ===== 基础布局 ===== */
.teacher-center-wrapper {
  min-height: 100vh;
  background: linear-gradient(135deg, #f0f4ff 0%, #e8f0fe 50%, #f5f7fa 100%);
}

.teacher-center {
  padding-bottom: 40px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}

/* ===== 头部区域 ===== */
.profile-header {
  background: linear-gradient(135deg, #ffffff 0%, #f8faff 100%);
  border-radius: 24px;
  padding: 40px;
  margin: 30px 0;
  box-shadow: 0 10px 40px rgba(26, 115, 232, 0.1);
  display: flex;
  align-items: flex-start;
  gap: 35px;
  position: relative;
  overflow: hidden;
  border: 1px solid rgba(26, 115, 232, 0.08);
}

.profile-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 5px;
  background: linear-gradient(90deg, #1a73e8, #ff9800, #34a853, #ea4335);
  background-size: 300% 100%;
  animation: gradientMove 4s ease infinite;
}

@keyframes gradientMove {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

/* 背景装饰 */
.profile-bg-decoration {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  overflow: hidden;
}

.decoration-circle {
  position: absolute;
  border-radius: 50%;
  opacity: 0.05;
}

.circle-1 {
  width: 350px;
  height: 350px;
  background: linear-gradient(135deg, #1a73e8, #6c8ef5);
  top: -120px;
  right: -80px;
  animation: float 8s ease-in-out infinite;
}

.circle-2 {
  width: 250px;
  height: 250px;
  background: linear-gradient(135deg, #ff9800, #ffb74d);
  bottom: -100px;
  left: 15%;
  animation: float 6s ease-in-out infinite reverse;
}

.circle-3 {
  width: 180px;
  height: 180px;
  background: linear-gradient(135deg, #34a853, #66bb6a);
  top: 40%;
  right: 25%;
  animation: float 7s ease-in-out infinite 1s;
}

@keyframes float {
  0%, 100% { transform: translateY(0) scale(1); }
  50% { transform: translateY(-20px) scale(1.05); }
}

/* 左侧头像 */
.profile-left {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14px;
  flex-shrink: 0;
  z-index: 1;
}

.profile-avatar {
  width: 130px;
  height: 130px;
  border-radius: 50%;
  background: linear-gradient(135deg, #1a73e8, #ff9800, #34a853);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 2.8rem;
  font-weight: bold;
  position: relative;
  cursor: pointer;
  overflow: hidden;
  border: 5px solid white;
  box-shadow: 0 8px 30px rgba(26, 115, 232, 0.25),
              0 0 0 4px rgba(255, 152, 0, 0.15);
  transition: var(--transition);
}

.profile-avatar:hover {
  transform: scale(1.08);
  box-shadow: 0 12px 40px rgba(26, 115, 232, 0.35),
              0 0 0 6px rgba(255, 152, 0, 0.2);
}

.profile-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.online-indicator {
  position: absolute;
  bottom: 8px;
  right: 8px;
  width: 18px;
  height: 18px;
  background: #22c55e;
  border-radius: 50%;
  border: 3px solid white;
  box-shadow: 0 2px 8px rgba(34, 197, 94, 0.4);
  animation: pulse-online 2s infinite;
}

@keyframes pulse-online {
  0%, 100% { box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.4); }
  50% { box-shadow: 0 0 0 8px rgba(34, 197, 94, 0); }
}

.avatar-edit-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(26, 115, 232, 0.9), rgba(255, 152, 0, 0.9));
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  opacity: 0;
  transition: var(--transition);
  font-size: 1.5rem;
}

.profile-avatar:hover .avatar-edit-overlay {
  opacity: 1;
}

.user-level {
  display: flex;
  align-items: center;
  gap: 8px;
  background: linear-gradient(135deg, #ff9800, #f57c00);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 700;
  box-shadow: 0 4px 15px rgba(255, 152, 0, 0.35);
}

.user-level i {
  font-size: 1rem;
}

/* 右侧信息 */
.profile-info {
  flex: 1;
  min-width: 0;
  position: relative;
  z-index: 1;
}

.profile-name-row {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 10px;
}

.profile-info h1 {
  font-size: 2.2rem;
  color: var(--dark);
  font-weight: 800;
  margin: 0;
  background: linear-gradient(135deg, #1a73e8, #ff9800);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.user-badges {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
}

.badge-teacher {
  background: linear-gradient(135deg, #fff3e0, #ffe0b2);
  color: #e65100;
}

.badge-verified {
  background: linear-gradient(135deg, #e8f5e9, #c8e6c9);
  color: #2e7d32;
}

.badge i {
  font-size: 0.8rem;
}

.user-title {
  font-size: 1.15rem;
  color: #1a73e8;
  margin-bottom: 16px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
}

.user-title::before {
  content: '👨‍🏫';
  font-size: 1.1rem;
}

/* 个性签名 */
.profile-bio-wrapper {
  position: relative;
  margin: 20px 0;
  padding: 0 30px;
}

.quote-mark {
  position: absolute;
  font-size: 4rem;
  font-family: Georgia, serif;
  color: #1a73e8;
  opacity: 0.12;
  line-height: 1;
  user-select: none;
}

.quote-left {
  top: -10px;
  left: 0;
}

.quote-right {
  bottom: -30px;
  right: 0;
}

.profile-bio {
  color: var(--gray);
  position: relative;
  padding: 18px 24px;
  border-radius: 12px;
  background: linear-gradient(135deg, #f8fafc, #f1f5f9);
  border-left: 4px solid;
  border-image: linear-gradient(180deg, #1a73e8, #ff9800) 1;
  font-size: 1rem;
  line-height: 1.8;
  font-style: italic;
  margin: 0;
}

/* 快捷统计 */
.profile-quick-stats {
  display: flex;
  gap: 20px;
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px dashed var(--border);
  flex-wrap: wrap;
}

.quick-stat {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 18px;
  background: white;
  border-radius: 14px;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.06);
  transition: var(--transition);
  cursor: default;
}

.quick-stat:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(26, 115, 232, 0.15);
}

.quick-stat i {
  font-size: 1.2rem;
  width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
}

.quick-stat:nth-child(1) i {
  color: #1a73e8;
  background: #e8f0fe;
}

.quick-stat:nth-child(2) i {
  color: #34a853;
  background: #e6f4ea;
}

.quick-stat:nth-child(3) i {
  color: #f9ab00;
  background: #fef7e0;
}

.quick-stat:nth-child(4) i {
  color: #ea4335;
  background: #fce8e6;
}

.quick-stat .stat-num {
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--dark);
}

.quick-stat .stat-unit {
  font-size: 0.85rem;
  color: var(--gray-light);
  font-weight: 500;
}

/* 操作按钮 */
.settings-btn, .edit-profile-btn {
  position: absolute;
  top: 24px;
  background: white;
  color: var(--gray);
  border: 1px solid var(--border);
  border-radius: 50%;
  width: 46px;
  height: 46px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: var(--transition);
  z-index: 10;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.08);
}

.settings-btn {
  right: 24px;
}

.edit-profile-btn {
  right: 80px;
}

.settings-btn:hover, .edit-profile-btn:hover {
  background: linear-gradient(135deg, #1a73e8, #ff9800);
  color: white;
  border-color: transparent;
  transform: rotate(15deg) scale(1.1);
}

/* ===== 标签页 ===== */
.tabs {
  display: flex;
  background: white;
  border-radius: 18px;
  padding: 10px;
  margin-bottom: 30px;
  box-shadow: var(--shadow);
  border: 1px solid rgba(26, 115, 232, 0.08);
}

.tab {
  flex: 1;
  text-align: center;
  padding: 16px 20px;
  cursor: pointer;
  border-radius: 12px;
  transition: var(--transition);
  font-weight: 600;
  color: var(--gray);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.tab i {
  font-size: 1.1rem;
}

.tab:hover {
  color: #1a73e8;
  background: #e8f0fe;
}

.tab.active {
  background: linear-gradient(135deg, #1a73e8, #0d5bb9);
  color: white;
  box-shadow: 0 6px 20px rgba(26, 115, 232, 0.35);
}

/* ===== 内容区域 ===== */
.content-section {
  background: white;
  border-radius: 20px;
  padding: 32px;
  margin-bottom: 30px;
  box-shadow: var(--shadow);
  border: 1px solid rgba(255, 255, 255, 0.5);
  animation: fadeInUp 0.5s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28px;
  padding-bottom: 20px;
  border-bottom: 2px solid #f5f7fa;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--dark);
}

.section-title i {
  color: #1a73e8;
  font-size: 1.3rem;
}

.section-actions {
  display: flex;
  align-items: center;
  gap: 14px;
}

/* 按钮样式 */
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 10px;
  font-size: 0.95rem;
  cursor: pointer;
  transition: var(--transition);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-weight: 600;
}

.btn-primary {
  background: linear-gradient(135deg, #1a73e8, #0d5bb9);
  color: white;
}

.btn-primary:hover {
  background: linear-gradient(135deg, #0d5bb9, #1a73e8);
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(26, 115, 232, 0.4);
}

.btn-secondary {
  background: linear-gradient(135deg, #f8f9fa, #e9ecef);
  color: #495057;
  border: 1px solid #dee2e6;
}

.btn-secondary:hover:not(:disabled) {
  background: linear-gradient(135deg, #e9ecef, #dee2e6);
  color: #212529;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.refresh-btn {
  position: relative;
  overflow: hidden;
}

.refresh-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #34a853, #2e7d32) !important;
  color: white !important;
  border-color: #34a853 !important;
}

.refresh-btn .fa-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.more-btn {
  background: #e8f0fe;
  border: 1px solid #e8f0fe;
  color: #1a73e8;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: var(--transition);
  padding: 10px 18px;
  border-radius: 10px;
  font-weight: 600;
}

.more-btn:hover {
  background: #1a73e8;
  color: white;
  transform: translateX(3px);
  box-shadow: 0 4px 15px rgba(26, 115, 232, 0.3);
}

/* ===== 课程选择器 ===== */
.course-selector {
  display: flex;
  align-items: center;
  gap: 10px;
}

.course-selector label {
  font-size: 0.9rem;
  color: var(--gray);
  font-weight: 500;
}

.course-select {
  padding: 10px 16px;
  border: 1px solid var(--border);
  border-radius: 10px;
  font-size: 0.9rem;
  color: var(--dark);
  background: white;
  cursor: pointer;
  min-width: 200px;
  transition: var(--transition);
}

.course-select:hover {
  border-color: #1a73e8;
}

.course-select:focus {
  outline: none;
  border-color: #1a73e8;
  box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
}

/* ===== 加载状态 ===== */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 40px;
  color: #1a73e8;
  gap: 16px;
}

.loading-state i {
  font-size: 2.5rem;
}

.loading-state span {
  font-size: 1rem;
  color: var(--gray);
}

/* ===== 课程卡片 ===== */
.courses-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 24px;
}

.course-card {
  background: #ffffff;
  border-radius: 18px;
  overflow: hidden;
  transition: var(--transition);
  border: 1px solid rgba(26, 115, 232, 0.08);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
}

.course-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 15px 40px rgba(26, 115, 232, 0.15);
  border-color: rgba(26, 115, 232, 0.2);
}

/* 课程封面 */
.course-cover {
  position: relative;
  width: 100%;
  height: 160px;
  overflow: hidden;
  background: linear-gradient(135deg, #e8f0fe 0%, #d4e4fc 100%);
}

.course-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.course-card:hover .course-cover img {
  transform: scale(1.05);
}

.cover-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #e8f0fe 0%, #d4e4fc 100%);
  color: #1a73e8;
  font-size: 3rem;
  opacity: 0.5;
}

/* 难度标签 */
.difficulty-tag {
  position: absolute;
  top: 12px;
  left: 12px;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  backdrop-filter: blur(4px);
}

/* 发布状态标签 */
.status-tag {
  position: absolute;
  top: 12px;
  right: 12px;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  backdrop-filter: blur(4px);
}

.status-tag.published {
  background: rgba(52, 168, 83, 0.9);
  color: white;
}

.status-tag.draft {
  background: rgba(249, 171, 0, 0.9);
  color: white;
}

.course-card-body {
  padding: 0;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.course-card-header {
  padding: 20px 20px 12px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

/* 难度标签样式 */
.course-difficulty {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
}

.difficulty-beginner {
  background: #e6f4ea;
  color: #1e8e3e;
}

.difficulty-elementary {
  background: #e8f0fe;
  color: #1a73e8;
}

.difficulty-intermediate {
  background: #fef7e0;
  color: #f9ab00;
}

.difficulty-advanced {
  background: #fce8e6;
  color: #d93025;
}

.difficulty-expert {
  background: #f3e8fd;
  color: #9334e6;
}

.course-info {
  flex: 1;
  min-width: 0;
}

.course-title {
  font-size: 1.2rem;
  font-weight: 700;
  color: var(--dark);
  margin-bottom: 10px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.course-category {
  display: inline-block;
  background: linear-gradient(135deg, #e8f0fe, #d4e4fc);
  color: #1a73e8;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 700;
  white-space: nowrap;
}

.status-active {
  background: linear-gradient(135deg, #34a853, #2e7d32);
  color: white;
}

.status-draft {
  background: linear-gradient(135deg, #f9ab00, #f57c00);
  color: white;
}

.status-warning {
  background: linear-gradient(135deg, #f9ab00, #f57c00);
  color: white;
}

.course-stats-row {
  display: flex;
  justify-content: space-around;
  padding: 16px 20px;
  background: #fafbfc;
  border-top: 1px solid #f0f0f0;
  border-bottom: 1px solid #f0f0f0;
}

.course-stat {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px;
  border-radius: 12px;
  transition: var(--transition);
}

.course-stat:hover {
  background: #f8faff;
}

.course-stat-icon {
  width: 42px;
  height: 42px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e8f0fe;
  color: #1a73e8;
  font-size: 1rem;
}

.course-stat-icon.star {
  background: #fef7e0;
  color: #f9ab00;
}

.course-stat-icon.comment {
  background: #e6f4ea;
  color: #34a853;
}

.course-stat-info {
  text-align: left;
}

.course-stat-value {
  font-size: 1.3rem;
  font-weight: 800;
  color: var(--dark);
}

.course-stat-label {
  font-size: 0.8rem;
  color: var(--gray-light);
  font-weight: 500;
}

.course-card-actions {
  display: flex;
  gap: 10px;
  padding: 18px 20px;
  background: #f8faff;
}

.action-btn {
  flex: 1;
  padding: 10px 14px;
  border: none;
  border-radius: 10px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: var(--transition);
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

.action-btn.outline {
  background: white;
  color: var(--gray);
  border: 1px solid var(--border);
}

.action-btn.outline:hover {
  background: #1a73e8;
  color: white;
  border-color: #1a73e8;
  transform: translateY(-2px);
}

.action-btn.outline.danger {
  color: #ea4335;
  border-color: #fce8e6;
}

.action-btn.outline.danger:hover {
  background: #ea4335;
  color: white;
  border-color: #ea4335;
}

.action-btn.primary {
  background: linear-gradient(135deg, #1a73e8, #0d5bb9);
  color: white;
}

.action-btn.primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(26, 115, 232, 0.35);
}

.action-btn.small {
  padding: 8px 14px;
  font-size: 0.8rem;
}

/* ===== 空状态 ===== */
.empty-state {
  text-align: center;
  padding: 60px 40px;
  background: linear-gradient(135deg, #f8faff 0%, #eef2ff 100%);
  border-radius: 18px;
  border: 2px dashed rgba(26, 115, 232, 0.2);
}

.empty-icon {
  width: 90px;
  height: 90px;
  background: linear-gradient(135deg, #e8f0fe, #d4e4fc);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 24px;
}

.empty-icon i {
  font-size: 2.5rem;
  color: #1a73e8;
}

.empty-state p {
  font-size: 1.2rem;
  color: var(--dark);
  margin-bottom: 10px;
  font-weight: 600;
}

.empty-hint {
  font-size: 0.95rem;
  color: var(--gray);
  margin-bottom: 28px;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
  line-height: 1.6;
}

/* ===== 学生表格 ===== */
.students-table-wrapper {
  overflow-x: auto;
  border-radius: 14px;
  border: 1px solid rgba(26, 115, 232, 0.08);
}

.students-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.students-table th {
  background: linear-gradient(135deg, #f8faff 0%, #eef2ff 100%);
  color: var(--dark);
  font-weight: 700;
  font-size: 0.85rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding: 18px 16px;
  text-align: left;
  border-bottom: 2px solid rgba(26, 115, 232, 0.1);
}

.students-table td {
  padding: 16px;
  border-bottom: 1px solid #f0f4f8;
  transition: var(--transition);
}

.students-table tr:hover td {
  background: #f8faff;
}

.students-table tr:last-child td {
  border-bottom: none;
}

.student-info {
  display: flex;
  align-items: center;
  gap: 14px;
}

.student-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: linear-gradient(135deg, #1a73e8, #6c8ef5);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.95rem;
  flex-shrink: 0;
  overflow: hidden;
}

.student-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.student-details {
  min-width: 0;
}

.student-name {
  font-weight: 600;
  color: var(--dark);
  margin-bottom: 3px;
}

.student-email {
  font-size: 0.8rem;
  color: var(--gray-light);
}

.course-tag {
  display: inline-block;
  background: #e8f0fe;
  color: #1a73e8;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 500;
}

.progress-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-bar {
  width: 100px;
  height: 8px;
  background: #e8f0fe;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #1a73e8, #34a853);
  border-radius: 4px;
  transition: width 0.6s ease;
  position: relative;
}

.progress-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.progress-text {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--dark);
  min-width: 40px;
}

.time-text {
  font-size: 0.9rem;
  color: var(--gray);
}

/* ===== 数据统计卡片 ===== */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 18px;
  position: relative;
  overflow: hidden;
  border: 1px solid rgba(26, 115, 232, 0.08);
  transition: var(--transition);
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
}

.stat-card.revenue::before { background: linear-gradient(180deg, #f9ab00, #ff8c00); }
.stat-card.students::before { background: linear-gradient(180deg, #1a73e8, #6c8ef5); }
.stat-card.rating::before { background: linear-gradient(180deg, #34a853, #66bb6a); }
.stat-card.reviews::before { background: linear-gradient(180deg, #ea4335, #ff6b6b); }

.stat-card-icon {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
}

/* 数据统计卡片样式 - 图标颜色与快捷统计保持一致 */
.stat-card.courses .stat-card-icon { 
    background: #e8f0fe; 
    color: #1a73e8; 
}
.stat-card.rating .stat-card-icon { 
    background: #e6f4ea; 
    color: #34a853; 
}
.stat-card.reviews .stat-card-icon { 
    background: #fef7e0; 
    color: #f9ab00; 
}
.stat-card.satisfaction .stat-card-icon { 
    background: #fce8e6; 
    color: #ea4335; 
}

.stat-card-content {
  flex: 1;
}

.stat-card-value {
  font-size: 1.8rem;
  font-weight: 800;
  color: var(--dark);
  margin-bottom: 4px;
}

.stat-card-label {
  font-size: 0.9rem;
  color: var(--gray);
  font-weight: 500;
}

.stat-card-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 10px;
  border-radius: 8px;
  font-size: 0.8rem;
  font-weight: 600;
}

.stat-card-trend.up {
  background: #e6f4ea;
  color: #34a853;
}

.stat-card-trend.stable {
  background: #f5f5f5;
  color: var(--gray);
}

/* ===== 分析入口卡片 ===== */
.analysis-entry {
  background: linear-gradient(135deg, #f8faff 0%, #eef2ff 100%);
  border-radius: 18px;
  padding: 28px;
  display: flex;
  align-items: center;
  gap: 24px;
  cursor: pointer;
  transition: var(--transition);
  border: 2px solid rgba(26, 115, 232, 0.1);
}

.analysis-entry:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 40px rgba(26, 115, 232, 0.15);
  border-color: #1a73e8;
}

.analysis-icon {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #1a73e8, #0d5bb9);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 8px 25px rgba(26, 115, 232, 0.3);
}

.analysis-icon i {
  font-size: 2rem;
  color: white;
}

.analysis-content {
  flex: 1;
}

.analysis-content h3 {
  font-size: 1.4rem;
  font-weight: 700;
  color: var(--dark);
  margin-bottom: 10px;
}

.analysis-content p {
  color: var(--gray);
  font-size: 0.95rem;
  line-height: 1.6;
  margin-bottom: 14px;
}

.analysis-features {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.analysis-features span {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  color: #1a73e8;
  font-weight: 500;
}

.analysis-features i {
  font-size: 0.75rem;
}

.analysis-arrow {
  width: 50px;
  height: 50px;
  background: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #1a73e8;
  font-size: 1.2rem;
  transition: var(--transition);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
}

.analysis-entry:hover .analysis-arrow {
  background: #1a73e8;
  color: white;
  transform: translateX(8px);
}

/* ===== 响应式设计 ===== */
@media (max-width: 1024px) {
  .container {
    padding: 0 20px;
  }
  
  .profile-header {
    padding: 30px;
    gap: 28px;
  }
  
  .profile-avatar {
    width: 110px;
    height: 110px;
    font-size: 2.4rem;
  }
  
  .profile-info h1 {
    font-size: 1.9rem;
  }
  
  .courses-grid {
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  }
}

@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }
  
  .profile-header {
    flex-direction: column;
    text-align: center;
    padding: 30px 20px;
    gap: 24px;
  }
  
  .profile-left {
    width: 100%;
  }
  
  .profile-avatar {
    width: 100px;
    height: 100px;
    font-size: 2rem;
  }
  
  .profile-name-row {
    justify-content: center;
    flex-direction: column;
    gap: 12px;
  }
  
  .profile-info h1 {
    font-size: 1.6rem;
  }
  
  .user-badges {
    justify-content: center;
  }
  
  .user-title {
    justify-content: center;
  }
  
  .profile-bio-wrapper {
    padding: 0 16px;
  }
  
  .quote-mark {
    font-size: 3rem;
  }
  
  .profile-quick-stats {
    justify-content: center;
    gap: 12px;
  }
  
  .quick-stat {
    padding: 10px 14px;
  }
  
  .quick-stat .stat-num {
    font-size: 1.2rem;
  }
  
  .decoration-circle {
    display: none;
  }
  
  .settings-btn, .edit-profile-btn {
    position: relative;
    top: 0;
    right: 0;
    display: inline-flex;
    margin: 5px;
  }
  
  .tabs {
    flex-wrap: wrap;
    padding: 8px;
    gap: 8px;
  }
  
  .tab {
    flex: 1 0 calc(50% - 8px);
    padding: 14px;
    font-size: 0.9rem;
  }
  
  .tab span {
    display: none;
  }
  
  .tab i {
    font-size: 1.3rem;
  }
  
  .content-section {
    padding: 24px 18px;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  
  .section-actions {
    width: 100%;
    flex-direction: column;
    gap: 10px;
  }
  
  .section-actions .btn,
  .section-actions .more-btn {
    width: 100%;
    justify-content: center;
  }
  
  .courses-grid {
    grid-template-columns: 1fr;
  }
  
  .course-stats-row {
    flex-wrap: wrap;
    gap: 10px;
  }
  
  .course-card-actions {
    flex-direction: column;
  }
  
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .stat-card {
    padding: 18px;
  }
  
  .stat-card-value {
    font-size: 1.5rem;
  }
  
  .analysis-entry {
    flex-direction: column;
    text-align: center;
    gap: 20px;
  }
  
  .analysis-features {
    justify-content: center;
  }
  
  .analysis-arrow {
    display: none;
  }
  
  .students-table th,
  .students-table td {
    padding: 12px 10px;
    font-size: 0.85rem;
  }
}

@media (max-width: 480px) {
  .profile-header {
    padding: 24px 16px;
    margin: 20px 0;
  }
  
  .profile-avatar {
    width: 90px;
    height: 90px;
    font-size: 1.8rem;
  }
  
  .profile-info h1 {
    font-size: 1.4rem;
  }
  
  .user-title {
    font-size: 1rem;
  }
  
  .profile-quick-stats {
    flex-direction: column;
    align-items: center;
  }
  
  .quick-stat {
    width: 100%;
    max-width: 200px;
    justify-content: center;
  }
  
  .tab {
    flex: 1 0 100%;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .stat-card {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }
  
  .stat-card-trend {
    position: static;
  }
  
  .footer-content {
    grid-template-columns: 1fr;
  }
}

/* ===== 滚动条美化 ===== */
.teacher-center-wrapper::-webkit-scrollbar {
  width: 8px;
}

.teacher-center-wrapper::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.teacher-center-wrapper::-webkit-scrollbar-thumb {
  background: linear-gradient(135deg, #1a73e8, #ff9800);
  border-radius: 4px;
}

.teacher-center-wrapper::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(135deg, #0d5bb9, #f57c00);
}

/* ===== 学生管理新增样式 ===== */

/* 学生总数徽章 */
.student-count-badge {
  background: linear-gradient(135deg, #1a73e8, #0d5bb9);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  margin-left: 10px;
  box-shadow: 0 2px 8px rgba(26, 115, 232, 0.3);
}

/* 排序选择器 */
.sort-selector {
  display: flex;
  align-items: center;
  gap: 8px;
}

.sort-selector label {
  font-size: 0.9rem;
  color: var(--gray);
  font-weight: 500;
}

.sort-select {
  padding: 8px 14px;
  border: 1px solid var(--border);
  border-radius: 8px;
  font-size: 0.9rem;
  color: var(--dark);
  background: white;
  cursor: pointer;
  transition: var(--transition);
  min-width: 140px;
}

.sort-select:hover {
  border-color: #1a73e8;
}

.sort-select:focus {
  outline: none;
  border-color: #1a73e8;
  box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.15);
}

/* 可排序表头 */
.sortable-th {
  cursor: pointer;
  user-select: none;
  transition: var(--transition);
}

.sortable-th:hover {
  color: #1a73e8;
  background: #f8faff;
}

.sortable-th i {
  margin-left: 6px;
  font-size: 0.75rem;
  color: var(--gray-light);
  transition: var(--transition);
}

.sortable-th:hover i {
  color: #1a73e8;
}

/* 展开更多按钮 */
.load-more-wrapper {
  display: flex;
  justify-content: center;
  padding: 20px 0;
  border-top: 1px dashed var(--border);
  margin-top: 10px;
}

.load-more-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 28px;
  background: linear-gradient(135deg, #e8f0fe, #d4e4fc);
  border: 1px solid #d4e4fc;
  border-radius: 25px;
  color: #1a73e8;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition);
}

.load-more-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #1a73e8, #0d5bb9);
  color: white;
  border-color: #1a73e8;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(26, 115, 232, 0.3);
}

.load-more-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.load-more-btn i {
  font-size: 0.85rem;
}

/* 状态样式 */
.status-success {
  background: linear-gradient(135deg, #34a853, #2e7d32);
  color: white;
}

/* ===== 课程设置弹窗 ===== */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
  animation: fadeIn 0.2s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.course-settings-modal {
  background: white;
  border-radius: 20px;
  width: 90%;
  max-width: 480px;
  max-height: 85vh;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  background: linear-gradient(135deg, #f8faff 0%, #eef2ff 100%);
  border-bottom: 1px solid rgba(26, 115, 232, 0.1);
}

.modal-header h3 {
  margin: 0;
  font-size: 1.2rem;
  color: var(--dark);
  display: flex;
  align-items: center;
  gap: 10px;
}

.modal-header h3 i {
  color: #1a73e8;
}

.close-btn {
  width: 36px;
  height: 36px;
  border: none;
  background: white;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--gray);
  transition: var(--transition);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.close-btn:hover {
  background: #ea4335;
  color: white;
  transform: rotate(90deg);
}

.modal-body {
  padding: 24px;
  overflow-y: auto;
  max-height: calc(85vh - 80px);
}

.course-info-summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  background: linear-gradient(135deg, #f8faff 0%, #eef2ff 100%);
  border-radius: 12px;
  margin-bottom: 24px;
}

.course-info-summary h4 {
  margin: 0;
  font-size: 1.1rem;
  color: var(--dark);
  font-weight: 600;
}

.settings-section {
  padding: 20px;
  background: #f8faff;
  border-radius: 14px;
  margin-bottom: 16px;
  border: 1px solid rgba(26, 115, 232, 0.08);
  transition: var(--transition);
}

.settings-section:hover {
  border-color: rgba(26, 115, 232, 0.2);
  box-shadow: 0 4px 15px rgba(26, 115, 232, 0.08);
}

.settings-section h5 {
  margin: 0 0 8px 0;
  font-size: 1rem;
  color: var(--dark);
  display: flex;
  align-items: center;
  gap: 8px;
}

.settings-section h5 i {
  color: #1a73e8;
  font-size: 0.9rem;
}

.section-desc {
  margin: 0 0 14px 0;
  font-size: 0.85rem;
  color: var(--gray);
  line-height: 1.5;
}

.settings-action-btn {
  width: 100%;
  padding: 12px 20px;
  border: none;
  border-radius: 10px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: var(--transition);
}

.settings-action-btn.btn-primary {
  background: linear-gradient(135deg, #1a73e8, #0d5bb9);
  color: white;
}

.settings-action-btn.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(26, 115, 232, 0.35);
}

.settings-action-btn.btn-success {
  background: linear-gradient(135deg, #34a853, #2e7d32);
  color: white;
}

.settings-action-btn.btn-success:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(52, 168, 83, 0.35);
}

.settings-action-btn.btn-warning {
  background: linear-gradient(135deg, #f9ab00, #f57c00);
  color: white;
}

.settings-action-btn.btn-warning:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(249, 171, 0, 0.35);
}

.settings-action-btn.btn-info {
  background: linear-gradient(135deg, #00bcd4, #0097a7);
  color: white;
}

.settings-action-btn.btn-info:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 188, 212, 0.35);
}

.settings-action-btn.btn-danger {
  background: linear-gradient(135deg, #ea4335, #c62828);
  color: white;
}

.settings-action-btn.btn-danger:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(234, 67, 53, 0.35);
}

.danger-zone {
  background: linear-gradient(135deg, #fff5f5 0%, #ffebee 100%);
  border-color: rgba(234, 67, 53, 0.2);
}

.danger-zone h5 {
  color: #c62828;
}

.danger-zone h5 i {
  color: #ea4335;
}
</style>
