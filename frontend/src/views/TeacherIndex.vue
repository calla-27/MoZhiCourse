<template>
  <!-- 顶部导航 -->
  <nav class="navbar">
    <div class="container nav-content">
      <div class="logo"><i class="fas fa-graduation-cap"></i> iCoursera</div>
      <div class="nav-links"><a href="#">课程中心</a><a href="#">学习社区</a></div>
      <div class="user-actions">
        <button @click="$router.push('/login')" class="login-btn">登录</button>
        <div class="teacher-badge">教师</div><div class="avatar">张</div>
      </div>
    </div>
  </nav>

  <!-- 教师头部 -->
  <div class="container">
    <div class="teacher-header">
      <!-- 1. 头像可点击 -->
      <!-- 教师头像 -->
      <div class="avatar-wrapper">
        <div class="teacher-avatar" @click="showAvatar = true">
          <img v-if="user.avatar" :src="user.avatar" alt="教师头像" />
          <span v-else>张</span>
          <div class="avatar-edit-overlay">
            <i class="fas fa-camera"></i>
          </div>
        </div>
        <!-- 角标移出来，同级定位 -->
        <div class="teacher-badge-large">教师</div>
      </div>
      <div class="teacher-info">
        <h1>张老师</h1>
        <div class="teacher-title">Python高级工程师 · 全栈开发专家</div>
        <p>专注于编程教育和软件开发，拥有8年教学经验，培养超过2万名学员</p>
        <div class="teacher-stats">
          <div class="stat-item"><div class="stat-value">15</div><div class="stat-label">开设课程</div></div>
          <div class="stat-item"><div class="stat-value">24,589</div><div class="stat-label">学生总数</div></div>
          <div class="stat-item"><div class="stat-value">4.8</div><div class="stat-label">平均评分</div></div>
          <div class="stat-item"><div class="stat-value">98%</div><div class="stat-label">完课率</div></div>
        </div>
      </div>
      <div class="edit-icon" @click="showSettings=true"><i class="fas fa-cog"></i></div>
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
        <div v-for="c in teacherCourses" :key="c.title" class="course-card">
          <div class="course-header">
            <div><h3 class="course-title">{{ c.title }}</h3><span class="course-category">{{ c.category }}</span></div>
            <span class="status-badge" :class="c.status==='已发布'?'status-active':'status-warning'">{{ c.status }}</span>
          </div>
          <div class="course-stats">
            <div class="course-stat"><div class="course-stat-value">{{ c.students }}</div><div class="course-stat-label">学生</div></div>
            <div class="course-stat"><div class="course-stat-value">{{ c.rate }}</div><div class="course-stat-label">评分</div></div>
            <div class="course-stat"><div class="course-stat-value">{{ c.finish }}%</div><div class="course-stat-label">完课率</div></div>
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
        <div class="stat-card"><div class="value">156,842</div><div class="label">总学习时长(小时)</div></div>
        <div class="stat-card"><div class="value">24,589</div><div class="label">活跃学生数</div></div>
        <div class="stat-card"><div class="value">4.8</div><div class="label">平均课程评分</div></div>
        <div class="stat-card"><div class="value">82%</div><div class="label">平均完课率</div></div>
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

  <!-- 头像弹窗（与学生端同一套） -->
  <AvatarModal v-model="showAvatar" />
  <!-- 其他弹窗 -->
  <SettingsModal v-model="showSettings" />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AvatarModal from '../components/AvatarModal.vue'
import SettingsModal from '../components/SettingsModal.vue'
import {
  apiTeacherStats,
  apiTeacherCourses,
  apiTeacherStudents
} from '../api/teacher'

/* ---------- 基础 UI 状态 ---------- */
const router        = useRouter()
const activeTab     = ref<'courses' | 'students' | 'analytics'>('courses')
const showAvatar    = ref(false)
const showSettings  = ref(false)

/* 顶部导航标签 */
const tabs = [
  { key: 'courses'   as const, label: '课程管理' },
  { key: 'students'  as const, label: '学生管理' },
  { key: 'analytics' as const, label: '数据统计' }
]

/* 教师个人信息（头像/名字） */
const user = ref({ avatar: '', name: '张老师' })

/* ---------- 业务数据 ---------- */
const teacherStats   = ref<any>({})       // 4 张卡片
const teacherCourses = ref<any[]>([])     // 课程列表
const students       = ref<any[]>([])     // 学生列表

/* ---------- 初始化 ---------- */
onMounted(async () => {
  // 1. 教学统计
  const statRes   = await apiTeacherStats()
  teacherStats.value = statRes.data ?? {}

  // 2. 课程列表
  const courseRes = await apiTeacherCourses()
  console.log('courseRes =', courseRes)        // ← 先看控制台到底返回啥
  teacherCourses.value = Array.isArray(courseRes.data)
      ? courseRes.data                         // 直接数组
      : courseRes.data?.list ?? []             // 有 list 就拿 list，否则空数组

  // 3. 学生列表
  if (teacherCourses.value.length) {
    const firstId = teacherCourses.value[0].course_id
    const stuRes  = await apiTeacherStudents(firstId)
    students.value = stuRes.data?.list ?? stuRes.data ?? []
  }
})

/* ---------- 事件 ---------- */
function createNewCourse() {
  router.push('/teacher/course-create')
}

/* 切换课程时刷新学生列表（模板里按需调用） */
async function loadStudents(courseId: string) {
  students.value = (await apiTeacherStudents(courseId)).data.list
}
</script>

<style src="../assets/teacher.css"></style>