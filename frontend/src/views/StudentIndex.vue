<template>
  <!-- 顶部导航 -->
  <nav class="navbar">
    <div class="container nav-content">
      <div class="logo"><i class="fas fa-graduation-cap"></i> iCoursera</div>
      <div class="nav-links">
        <a href="#">课程中心</a>
        <a href="#">学习社区</a>
      </div>
      <div class="user-actions">
        <div class="avatar">张</div>
      </div>
    </div>
  </nav>

  <!-- 个人头部 -->
  <div class="container">
    <div class="profile-header">
      <button class="settings-btn" title="账户设置" @click="showSettings=true"><i class="fas fa-cog"></i></button>
      <div class="profile-avatar" @click="showAvatar=true">
        <img v-if="user.avatar" :src="user.avatar" alt="头像"/>
        <span v-else>张</span>
        <div class="avatar-edit-overlay"><i class="fas fa-camera"></i></div>
      </div>
      <div class="profile-info">
        <h1>{{ user.name }}<i class="fas fa-edit edit-icon" @click="showName=true"></i></h1>
        <p>前端开发工程师 | 持续学习者</p>
        <div class="profile-bio" @click="startEditBio">
          <template v-if="!editingBio">{{ user.bio }}</template>
          <textarea v-else v-model="draftBio" @blur="saveBio" @keydown.enter.prevent="saveBio"></textarea>
        </div>
        <div class="profile-stats">
          <div class="stat-item"><div class="stat-value">{{ user.stats.learnHours }}h</div><div class="stat-label">学习时长</div></div>
          <div class="stat-item"><div class="stat-value">{{ user.stats.courses }}</div><div class="stat-label">已学课程</div></div>
          <div class="stat-item"><div class="stat-value">{{ user.stats.followers }}</div><div class="stat-label">收藏课程</div></div>
          <div class="stat-item"><div class="stat-value">{{ user.stats.following }}</div><div class="stat-label">我的关注</div></div>
        </div>
      </div>
    </div>

    <!-- 可点击标签 -->
    <div class="tabs-container">
      <div class="tabs">
        <div
          v-for="t in tabs"
          :key="t.key"
          class="tab"
          :class="{ active: activeTab === t.key }"
          @click="activeTab = t.key"
        >
          {{ t.label }}
        </div>
      </div>
    </div>

    <!-- 下方内容：点谁显谁 -->
    <!-- 1. 学情分析 -->
    <section v-if="activeTab === 'analysis'" class="content-section">
      <h2 class="section-title">学情分析 <button class="more-btn">更多分析 <i class="fas fa-chevron-right"></i></button></h2>
      <div class="stats-grid">
        <div class="stat-card"><div class="value">156h</div><div class="label">总学习时长</div></div>
        <div class="stat-card"><div class="value">28</div><div class="label">已学课程</div></div>
        <div class="stat-card"><div class="value">15</div><div class="label">连续学习天数</div></div>
        <div class="stat-card"><div class="value">4.8</div><div class="label">平均评分</div></div>
      </div>
    </section>

    <!-- 2. 正在学习 -->
    <section v-if="activeTab === 'learning'" class="content-section">
      <h2 class="section-title">正在学习的课程 <button class="more-btn">查看全部 <i class="fas fa-chevron-right"></i></button></h2>
      <div class="courses-grid">
        <div v-for="c in learningList" :key="c.title" class="course-card">
          <div class="course-image" :style="{background: c.bg}"></div>
          <div class="course-content">
            <h3 class="course-title">{{ c.title }}</h3>
            <p>{{ c.desc }}</p>
            <div class="course-progress">
              <div class="progress-bar"><div class="progress-fill" :style="{width: c.progress+'%'}"></div></div>
              <div class="progress-text">{{ c.progress }}% 已完成</div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 3. 我的收藏 -->
    <section v-if="activeTab === 'collect'" class="content-section">
      <h2 class="section-title">收藏的课程 <button class="more-btn">查看全部 <i class="fas fa-chevron-right"></i></button></h2>
      <div class="courses-grid">
        <div v-for="c in collectList" :key="c.title" class="course-card">
          <div class="course-image" :style="{background: c.bg}"></div>
          <div class="course-content">
            <h3 class="course-title">{{ c.title }}</h3>
            <p>{{ c.desc }}</p>
            <div class="course-meta">收藏于 {{ c.date }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 4. 我的社区 -->
    <section v-if="activeTab === 'community'" class="content-section">
      <h2 class="section-title">我的社区 <button class="more-btn">探索更多 <i class="fas fa-chevron-right"></i></button></h2>
      <!-- 社区统计 -->
      <div class="community-stats">
        <div class="stat-card"><div class="value">3</div><div class="label">活跃组队</div></div>
        <div class="stat-card"><div class="value">2</div><div class="label">自习室</div></div>
        <div class="stat-card"><div class="value">28</div><div class="label">讨论帖子</div></div>
        <div class="stat-card"><div class="value">156</div><div class="label">互动次数</div></div>
      </div>
      <!-- 我的组队 -->
      <div class="community-section">
        <h3 class="subsection-title"><i class="fas fa-users"></i> 我的组队</h3>
        <div class="teams-grid">
          <div class="team-card">
            <div class="team-header"><h4 class="team-name">React学习小组</h4><span class="team-status active">进行中</span></div>
            <p class="team-desc">共同学习React高级特性和最佳实践</p>
            <div class="team-members">
              <div class="member-avatars"><div class="member-avatar">张</div><div class="member-avatar">李</div><div class="member-avatar">王</div><div class="member-avatar">+2</div></div>
              <span class="member-count">5人</span>
            </div>
            <div class="team-progress">
              <div class="progress-bar"><div class="progress-fill" style="width:60%"></div></div>
              <span class="progress-text">60% 完成</span>
            </div>
            <div class="team-actions"><button class="action-btn primary">进入小组</button><button class="action-btn">管理</button></div>
          </div>
          <div class="team-card">
            <div class="team-header"><h4 class="team-name">算法刷题小队</h4><span class="team-status active">进行中</span></div>
            <p class="team-desc">每日一题，共同进步</p>
            <div class="team-members">
              <div class="member-avatars"><div class="member-avatar">张</div><div class="member-avatar">陈</div><div class="member-avatar">刘</div></div>
              <span class="member-count">3人</span>
            </div>
            <div class="team-progress">
              <div class="progress-bar"><div class="progress-fill" style="width:85%"></div></div>
              <span class="progress-text">85% 完成</span>
            </div>
            <div class="team-actions"><button class="action-btn primary">进入小组</button><button class="action-btn">管理</button></div>
          </div>
        </div>
      </div>
      <!-- 我的自习室 -->
      <div class="community-section">
        <h3 class="subsection-title"><i class="fas fa-door-open"></i> 我的自习室</h3>
        <div class="study-rooms-grid">
          <div class="study-room-card">
            <div class="room-header"><h4 class="room-name">前端开发自习室</h4><span class="room-status online">在线 8人</span></div>
            <p class="room-desc">专注前端技术学习与交流</p>
            <div class="room-schedule"><div class="schedule-item"><i class="far fa-clock"></i><span>每日 19:00-21:00</span></div></div>
            <div class="room-actions"><button class="action-btn primary">进入自习</button><button class="action-btn">邀请好友</button></div>
          </div>
          <div class="study-room-card">
            <div class="room-header"><h4 class="room-name">考研数学自习室</h4><span class="room-status online">在线 12人</span></div>
            <p class="room-desc">考研数学复习打卡监督</p>
            <div class="room-schedule"><div class="schedule-item"><i class="far fa-clock"></i><span>每周一三五 20:00-22:00</span></div></div>
            <div class="room-actions"><button class="action-btn primary">进入自习</button><button class="action-btn">邀请好友</button></div>
          </div>
        </div>
      </div>
      <!-- 讨论记录 -->
      <div class="community-section">
        <h3 class="subsection-title"><i class="fas fa-comments"></i> 讨论记录</h3>
        <div class="discussion-list">
          <div class="discussion-item">
            <div class="discussion-header">
              <div class="discussion-title"><h4>关于React Hooks的最佳实践讨论</h4><span class="discussion-time">2小时前</span></div>
              <span class="discussion-replies">15 回复</span>
            </div>
            <p class="discussion-preview">在useEffect中如何处理依赖数组的问题...</p>
            <div class="discussion-tags"><span class="tag">React</span><span class="tag">前端</span></div>
          </div>
          <div class="discussion-item">
            <div class="discussion-header">
              <div class="discussion-title"><h4>Node.js性能优化经验分享</h4><span class="discussion-time">1天前</span></div>
              <span class="discussion-replies">8 回复</span>
            </div>
            <p class="discussion-preview">分享一些在生产环境中优化Node.js应用性能的经验...</p>
            <div class="discussion-tags"><span class="tag">Node.js</span><span class="tag">后端</span><span class="tag">性能优化</span></div>
          </div>
          <div class="discussion-item">
            <div class="discussion-header">
              <div class="discussion-title"><h4>算法题解：二叉树层序遍历</h4><span class="discussion-time">3天前</span></div>
              <span class="discussion-replies">23 回复</span>
            </div>
            <p class="discussion-preview">分享几种不同的二叉树层序遍历实现方法...</p>
            <div class="discussion-tags"><span class="tag">算法</span><span class="tag">数据结构</span></div>
          </div>
        </div>
      </div>
    </section>

    <!-- 5. 我的成就 -->
    <section v-if="activeTab === 'achievement'" class="content-section">
      <h2 class="section-title">已获得成就 <button class="more-btn">查看全部 <i class="fas fa-chevron-right"></i></button></h2>
      <div class="achievements-grid">
        <div class="achievement-card">
          <div class="achievement-icon"><i class="fas fa-graduation-cap"></i></div>
          <h3 class="achievement-title">学习新人</h3><p class="achievement-desc">完成第一个课程学习</p>
        </div>
        <div class="achievement-card">
          <div class="achievement-icon"><i class="fas fa-fire"></i></div>
          <h3 class="achievement-title">坚持之星</h3><p class="achievement-desc">连续学习7天</p>
        </div>
        <div class="achievement-card">
          <div class="achievement-icon"><i class="fas fa-book"></i></div>
          <h3 class="achievement-title">知识探索者</h3><p class="achievement-desc">学习3个不同领域课程</p>
        </div>
        <div class="achievement-card">
          <div class="achievement-icon"><i class="fas fa-star"></i></div>
          <h3 class="achievement-title">课程达人</h3><p class="achievement-desc">完成10门课程学习</p>
        </div>
        <div class="achievement-card">
          <div class="achievement-icon"><i class="fas fa-trophy"></i></div>
          <h3 class="achievement-title">学习冠军</h3><p class="achievement-desc">连续30天坚持学习</p>
        </div>
      </div>
    </section>

    <!-- 6. 页脚 -->
    <footer class="footer">
      <div class="container">
        <div class="footer-content">
          <div class="footer-section"><h3>关于iCoursera</h3><p>AI赋能的个性化在线教育平台，致力于让每个人都能享受优质教育资源。</p></div>
          <div class="footer-section"><h3>快速链接</h3><ul class="footer-links"><li><a href="#">课程广场</a></li><li><a href="#">学习计划</a></li><li><a href="#">教师入驻</a></li><li><a href="#">企业合作</a></li></ul></div>
          <div class="footer-section"><h3>联系我们</h3><ul class="footer-links"><li><a href="#">客服中心</a></li><li><a href="#">意见反馈</a></li><li><a href="#">合作咨询</a></li></ul></div>
        </div>
        <div class="footer-bottom"><p>&copy; 2024 iCoursera AI+在线教育平台. 保留所有权利.</p></div>
      </div>
    </footer>
  </div>

  <!-- 弹窗 -->
  <AvatarModal v-model="showAvatar" />
  <NameModal  v-model="showName" />
  <SettingsModal v-model="showSettings" />
</template>

<script setup lang="ts">
// import { ref } from 'vue'
import { useUserStore } from '../stores/user'
import AvatarModal from '../components/AvatarModal.vue'
import NameModal from '../components/NameModal.vue'
import SettingsModal from '../components/SettingsModal.vue'

/* 用户状态 */
const user = useUserStore()
const editingBio = ref(false)
const draftBio = ref('')
const showAvatar = ref(false)
const showName   = ref(false)
const showSettings = ref(false)

/* 标签数据 */
const activeTab = ref('analysis')
const tabs = [
  { key: 'analysis',   label: '学情分析' },
  { key: 'learning',   label: '正在学习' },
  { key: 'collect',    label: '我的收藏' },
  { key: 'community',  label: '我的社区' },
  { key: 'achievement',label: '我的成就' }
]

// /* 假数据 = 原来 HTML 里的静态内容 */
// const learningList = [
//   { title: 'React高级实战', desc: '深入学习React生态和最佳实践', progress: 65, bg: 'linear-gradient(135deg,#667eea,#764ba2)' },
//   { title: 'Node.js后端开发', desc: '构建高性能的服务器端应用', progress: 45, bg: 'linear-gradient(135deg,#f093fb,#f5576c)' },
//   { title: 'TypeScript进阶', desc: '掌握类型系统和高级特性', progress: 30, bg: 'linear-gradient(135deg,#4facfe,#00f2fe)' },
//   { title: '数据结构与算法', desc: '掌握核心数据结构和算法思想', progress: 80, bg: 'linear-gradient(135deg,#43e97b,#38f9d7)' }
// ]

// const collectList = [
//   { title: 'UI/UX设计原理', desc: '掌握用户体验设计核心概念', date: '2024-01-10', bg: 'linear-gradient(135deg,#ffecd2,#fcb69f)' },
//   { title: 'Python数据分析', desc: '使用Python进行数据处理和分析', date: '2024-01-05', bg: 'linear-gradient(135deg,#a8edea,#fed6e3)' },
//   { title: '人工智能基础', desc: '了解AI基本原理和应用场景', date: '2023-12-28', bg: 'linear-gradient(135deg,#d299c2,#fef9d7)' },
//   { title: '云计算入门', desc: '学习云计算基础知识和应用', date: '2023-12-20', bg: 'linear-gradient(135deg,#89f7fe,#66a6ff)' }
// ]

/* 方法 */
function startEditBio () {
  draftBio.value = user.bio
  editingBio.value = true
}
function saveBio () {
  user.bio = draftBio.value || user.bio
  editingBio.value = false
}

import { onMounted, ref } from 'vue'
import { apiStudentStats, apiStudentCourses, apiFavorites, apiCommunity, apiAchievements } from '../api/students'

/* 原来写死的 ref 全部清空，换成后端返回的 */
const stats        = ref<any>({})
const learningList = ref<any[]>([])
const collectList  = ref<any[]>([])
const community    = ref<any>({})
const achievements = ref<any[]>([])

onMounted(async () => {
  stats.value        = (await apiStudentStats()).data
  learningList.value = (await apiStudentCourses()).data.list
  collectList.value  = (await apiFavorites()).data.list
  community.value    = (await apiCommunity()).data
  achievements.value = (await apiAchievements()).data.list
})
</script>

<style src="../assets/student.css"></style>