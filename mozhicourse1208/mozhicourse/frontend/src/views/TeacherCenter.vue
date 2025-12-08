<template>
  <div class="teacher-center">
    <!-- 教师头部 -->
    <div class="container">
      <div class="teacher-header">
        <!-- 教师头像 -->
        <div class="avatar-wrapper">
          <div class="teacher-avatar" @click="showAvatar = true">
            <img v-if="user.avatarUrl" :src="user.avatarUrl" alt="教师头像" />
            <span v-else>{{ user.userName?.charAt(0) || '教' }}</span>
            <div class="avatar-edit-overlay">
              <i class="fas fa-camera"></i>
            </div>
          </div>
          <!-- 角标移出来，同级定位 -->
          <div class="teacher-badge-large">教师</div>
        </div>
        <div class="teacher-info">
          <h1>{{ user.userName || '教师' }}</h1>
          <div class="teacher-title">{{ teacherStats.title || 'Python高级工程师 · 全栈开发专家' }}</div>
          <p>{{ teacherStats.description || '专注于编程教育和软件开发，拥有丰富的教学经验' }}</p>
          <div class="teacher-stats">
            <div class="stat-item"><div class="stat-value">{{ teacherStats.courses?.total || 0 }}</div><div class="stat-label">开设课程</div></div>
            <div class="stat-item"><div class="stat-value">{{ teacherStats.students?.total || 0 }}</div><div class="stat-label">学生总数</div></div>
            <div class="stat-item"><div class="stat-value">{{ teacherStats.rating?.average || '0.0' }}</div><div class="stat-label">平均评分</div></div>
            <div class="stat-item"><div class="stat-value">{{ Math.round((teacherStats.rating?.average || 0) * 20) || '0' }}%</div><div class="stat-label">满意度</div></div>
          </div>
        </div>
        <div class="edit-icons">
          <div class="edit-icon" @click="showEditProfile=true" title="编辑个人资料"><i class="fas fa-user-edit"></i></div>
          <div class="edit-icon" @click="showSettings=true" title="账户设置"><i class="fas fa-cog"></i></div>
        </div>
      </div>
    </div>

    <!-- 快速操作 -->
    <div class="quick-actions">
      <div class="quick-action-btn" @click="activeTab='courses'"><i class="fas fa-book"></i><span>课程管理</span></div>
      <div class="quick-action-btn" @click="activeTab='students'"><i class="fas fa-users"></i><span>学生管理</span></div>
      <div class="quick-action-btn" @click="activeTab='analytics'"><i class="fas fa-chart-line"></i><span>数据统计</span></div>
      <div class="quick-action-btn" @click="createNewCourse"><i class="fas fa-plus-circle"></i><span>新建课程</span></div>
    </div>

    <!-- 可点击标签 -->
    <div class="tabs">
      <div v-for="t in tabs" :key="t.key" class="tab" :class="{active:activeTab===t.key}" @click="activeTab=t.key">{{ t.label }}</div>
    </div>

    <!-- 下方内容：点谁显谁 -->
    <!-- 1. 课程管理 -->
    <section v-if="activeTab==='courses'" class="content-section">
      <div class="section-title">
        <span>我的课程</span>
        <div>
          <button class="detail-btn">查看全部 <i class="fas fa-chevron-right"></i></button>
          <button class="btn btn-primary" @click="createNewCourse"><i class="fas fa-plus"></i> 创建新课程</button>
        </div>
      </div>
      <div class="courses-grid">
        <div v-for="c in teacherCourses" :key="c.course_id" class="course-card">
          <div class="course-header">
            <div><h3 class="course-title">{{ c.course_name }}</h3><span class="course-category">{{ c.difficulty }}</span></div>
            <span class="status-badge" :class="c.status==='published'?'status-active':'status-warning'">{{ c.status === 'published' ? '已发布' : '草稿' }}</span>
          </div>
          <div class="course-stats">
            <div class="course-stat"><div class="course-stat-value">{{ c.student_count || 0 }}</div><div class="course-stat-label">学生</div></div>
            <div class="course-stat"><div class="course-stat-value">{{ c.avg_rating || '0.0' }}</div><div class="course-stat-label">评分</div></div>
            <div class="course-stat"><div class="course-stat-value">{{ c.review_count || 0 }}</div><div class="course-stat-label">评价数</div></div>
          </div>
          <div class="course-actions">
            <button class="btn btn-secondary btn-small"><i class="fas fa-edit"></i> 编辑</button>
            <button class="btn btn-secondary btn-small"><i class="fas fa-chart-bar"></i> 数据</button>
            <button class="btn btn-secondary btn-small"><i class="fas fa-cog"></i> 设置</button>
          </div>
        </div>
      </div>
    </section>

    <!-- 2. 学生管理 -->
    <section v-if="activeTab==='students'" class="content-section">
      <div class="section-title">
        <span>学生管理</span>
        <button class="detail-btn">查看全部 <i class="fas fa-chevron-right"></i></button>
      </div>
      <table class="students-table">
        <thead><tr><th>学生</th><th>课程</th><th>学习进度</th><th>最后学习</th><th>状态</th><th>操作</th></tr></thead>
        <tbody>
          <tr v-for="s in students" :key="s.name">
            <td>
              <div style="display:flex;align-items:center;gap:10px">
                <div class="student-avatar">{{ s.ab }}</div>
                <div><div style="font-weight:500">{{ s.name }}</div><div style="font-size:.8rem;color:var(--gray)">{{ s.email }}</div></div>
              </div>
            </td>
            <td>{{ s.course }}</td>
            <td>
              <div style="display:flex;align-items:center;gap:10px">
                <div class="progress-bar"><div class="progress-fill" :style="{width:s.progress+'%'}"></div></div>
                <span>{{ s.progress }}%</span>
              </div>
            </td>
            <td>{{ s.last }}</td>
            <td><span class="status-badge" :class="s.status==='活跃'?'status-active':'status-warning'">{{ s.status }}</span></td>
            <td><button class="btn btn-secondary btn-small">联系</button></td>
          </tr>
        </tbody>
      </table>
    </section>

    <!-- 3. 数据统计 -->
    <section v-if="activeTab==='analytics'" class="content-section">
      <div class="section-title">
        <span>教学数据概览</span>
        <button class="detail-btn">查看详情 <i class="fas fa-chevron-right"></i></button>
      </div>
      <div class="stats-overview">
        <div class="stat-card"><div class="value">{{ teacherStats.revenue?.total || 0 }}</div><div class="label">总收入(元)</div></div>
        <div class="stat-card"><div class="value">{{ teacherStats.students?.total || 0 }}</div><div class="label">活跃学生数</div></div>
        <div class="stat-card"><div class="value">{{ teacherStats.rating?.average || '0.0' }}</div><div class="label">平均课程评分</div></div>
        <div class="stat-card"><div class="value">{{ teacherStats.rating?.total_reviews || 0 }}</div><div class="label">评价总数</div></div>
      </div>
      <div class="chart-container">
        <div style="text-align:center;color:var(--gray);padding:50px"><i class="fas fa-chart-line" style="font-size:3rem;margin-bottom:15px"></i><p>学生学习趋势图表</p></div>
      </div>
      <div class="chart-container">
        <div style="text-align:center;color:var(--gray);padding:50px"><i class="fas fa-chart-bar" style="font-size:3rem;margin-bottom:15px"></i><p>课程表现分析图表</p></div>
      </div>
    </section>

    <!-- 页脚 -->
    <footer class="footer">
      <div class="container">
        <div class="footer-content">
          <div class="footer-section"><h3>关于iCoursera</h3><p>AI赋能的个性化在线教育平台，致力于让每个人都能享受优质教育资源。</p></div>
          <div class="footer-section"><h3>教师资源</h3><ul class="footer-links"><li><a href="#">教学指南</a></li><li><a href="#">课程制作</a></li><li><a href="#">数据分析</a></li><li><a href="#">教师社区</a></li></ul></div>
          <div class="footer-section"><h3>联系我们</h3><ul class="footer-links"><li><a href="#">教师支持</a></li><li><a href="#">合作咨询</a></li><li><a href="#">意见反馈</a></li></ul></div>
        </div>
        <div class="footer-bottom"><p>&copy; 2024 iCoursera AI+在线教育平台. 保留所有权利.</p></div>
      </div>
    </footer>
  </div>

  <!-- 头像弹窗 -->
  <AvatarModal v-model="showAvatar" @avatar-updated="handleAvatarUpdate" />
  <!-- 设置弹窗 -->
  <SettingsModal v-model="showSettings" />
  <!-- 个人资料编辑弹窗 -->
  <EditProfileModal 
    v-model="showEditProfile"
    :user-name="user.userName"
    :email="user.email"
    :user-intro="user.userIntro"
    @save="handleProfileUpdate"
  />
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
  apiTeacherStudents
} from '../api/teacher.js'

/* ... */
/* ---------- 基础 UI 状态 ---------- */
const router        = useRouter()
const activeTab     = ref('courses')
const showAvatar    = ref(false)
const showSettings  = ref(false)
const showEditProfile = ref(false)

/* 顶部导航标签 */
const tabs = [
  { key: 'courses', label: '课程管理' },
  { key: 'students', label: '学生管理' },
  { key: 'analytics', label: '数据统计' }
]

/* 教师个人信息（头像/名字） */
const user = useUserStore()

/* ---------- 业务数据 ---------- */
const teacherStats   = ref({})       // 4 张卡片
const teacherCourses = ref([])     // 课程列表
const students       = ref([])     // 学生列表

/* ---------- 初始化 ---------- */
onMounted(async () => {
  console.log('🎓 教师中心加载中...')
  
  try {
    // 0. 获取教师基本信息
    if (!user.userId) {
      console.log('📝 获取用户信息...')
      await user.fetchUserProfile()
      console.log('✅ 用户信息获取完成:', user.userName)
    }

    // 1. 教学统计
    console.log('📊 获取教学统计数据...')
    const statRes = await apiTeacherStats()
    teacherStats.value = statRes.data ?? {}
    console.log('✅ 教学统计:', teacherStats.value)
    console.log('📊 统计数据详情:', JSON.stringify(teacherStats.value, null, 2))

    // 2. 课程列表
    console.log('📚 获取课程列表...')
    const courseRes = await apiTeacherCourses()
    console.log('📋 课程数据:', courseRes)
    console.log('📋 课程数据详情:', JSON.stringify(courseRes, null, 2))
    teacherCourses.value = Array.isArray(courseRes.data)
        ? courseRes.data
        : (courseRes.data && courseRes.data.list) || []
    console.log('✅ 课程列表:', teacherCourses.value)
    console.log('📚 课程列表详情:', JSON.stringify(teacherCourses.value, null, 2))

    // 3. 学生列表
    if (teacherCourses.value.length) {
      console.log('👥 获取学生列表...')
      const firstId = teacherCourses.value[0].course_id
      const stuRes = await apiTeacherStudents(firstId)
      students.value = (stuRes.data && stuRes.data.list) || stuRes.data || []
      console.log('✅ 学生列表:', students.value)
    }
    
    console.log('🎉 教师中心数据加载完成！')
  } catch (error) {
    console.error('❌ 教师中心数据加载失败:', error)
    // 设置默认数据避免页面空白
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

/* ---------- 事件 ---------- */
function createNewCourse() {
  router.push('/teacher/course-create')
}

/* 切换课程时刷新学生列表（模板里按需调用） */
async function loadStudents(courseId) {
  students.value = (await apiTeacherStudents(courseId)).data.list
}

// 头像更新处理
const handleAvatarUpdate = (avatarUrl) => {
  user.updateAvatar(avatarUrl)
}

// 个人资料更新处理
const handleProfileUpdate = async (profileData) => {
  try {
    await user.updateProfile(profileData)
    alert('个人资料更新成功')
  } catch (error) {
    alert('更新个人资料失败：' + error.message)
  }
}
</script>

<style src="../assets/teacher.css"></style>