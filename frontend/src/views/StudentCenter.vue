<template>
  <div class="student-center">
    <!-- 个人头部 -->
    <div class="container">
      <div class="profile-header">
        <button class="settings-btn" title="账户设置" @click="showSettings=true">
          <i class="fas fa-cog"></i>
        </button>
        <div class="profile-avatar" @click="showAvatar=true">
          <img v-if="user.avatarUrl" :src="user.avatarUrl" :alt="user.userName"/>
          <span v-else>{{ user.userName?.charAt(0) || '学' }}</span>
          <div class="avatar-edit-overlay"><i class="fas fa-camera"></i></div>
        </div>
        <div class="profile-info">
          <h1>
            {{ user.userName || '未设置用户名' }}
            <i class="fas fa-edit edit-icon" @click="editName"></i>
          </h1>
          <p>{{ user.occupation || '持续学习者' }}</p>
          <div class="profile-bio" @click="startEditBio">
            <template v-if="!editingBio">{{ user.userIntro || '这个人很懒，什么都没有写～' }}</template>
            <textarea 
              v-else 
              v-model="draftBio" 
              @blur="saveBio" 
              @keydown.enter.prevent="saveBio"
              :placeholder="user.userIntro"
              ref="bioTextarea"
            ></textarea>
          </div>
          <div class="profile-stats">
            <div class="stat-item">
              <div class="stat-value">{{ user.learningStats?.total_learning_hours || 0 }}h</div>
              <div class="stat-label">学习时长</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ user.learningStats?.courses_completed || 0 }}</div>
              <div class="stat-label">已学课程</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ user.learningStats?.achievements_earned || 0 }}</div>
              <div class="stat-label">获得成就</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ user.learningStats?.continuous_days || 0 }}</div>
              <div class="stat-label">连续学习</div>
            </div>
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
          <div class="stat-card"><div class="value">{{ user.learningStats?.total_learning_hours || 0 }}h</div><div class="label">总学习时长</div></div>
          <div class="stat-card"><div class="value">{{ user.learningStats?.courses_completed || 0 }}</div><div class="label">已学课程</div></div>
          <div class="stat-card"><div class="value">{{ user.learningStats?.continuous_days || 0 }}</div><div class="label">连续学习天数</div></div>
          <div class="stat-card"><div class="value">{{ user.learningStats?.achievement_rate || 0 }}%</div><div class="label">成就达成率</div></div>
        </div>
      </section>

      <!-- 2. 正在学习 -->
      <section v-if="activeTab === 'learning'" class="content-section">
        <h2 class="section-title">正在学习的课程 <button class="more-btn">查看全部 <i class="fas fa-chevron-right"></i></button></h2>
        <div class="courses-grid">
          <div v-for="course in learningList" :key="course.id" class="course-card">
            <div class="course-image" :style="{background: course.bg || 'linear-gradient(135deg,#667eea,#764ba2)'}"></div>
            <div class="course-content">
              <h3 class="course-title">{{ course.title || course.name }}</h3>
              <p>{{ course.desc || course.description }}</p>
              <div class="course-progress">
                <div class="progress-bar"><div class="progress-fill" :style="{width: (course.progress || 0)+'%'}"></div></div>
                <div class="progress-text">{{ course.progress || 0 }}% 已完成</div>
              </div>
            </div>
          </div>
          <div v-if="learningList.length === 0" class="empty-state">
            <i class="fas fa-book-open"></i>
            <p>还没有开始学习任何课程</p>
            <button class="browse-btn" @click="$router.push('/search')">浏览课程</button>
          </div>
        </div>
      </section>

      <!-- 3. 我的收藏 -->
      <section v-if="activeTab === 'collect'" class="content-section">
        <h2 class="section-title">收藏的课程 <button class="more-btn">查看全部 <i class="fas fa-chevron-right"></i></button></h2>
        <div class="courses-grid">
          <div v-for="course in collectList" :key="course.id" class="course-card">
            <div class="course-image" :style="{background: course.bg || 'linear-gradient(135deg,#ffecd2,#fcb69f)'}"></div>
            <div class="course-content">
              <h3 class="course-title">{{ course.title || course.name }}</h3>
              <p>{{ course.desc || course.description }}</p>
              <div class="course-meta">收藏于 {{ course.collect_time || course.date }}</div>
            </div>
          </div>
          <div v-if="collectList.length === 0" class="empty-state">
            <i class="fas fa-heart"></i>
            <p>还没有收藏任何课程</p>
            <button class="browse-btn" @click="$router.push('/search')">发现课程</button>
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
          </div>
        </div>
      </section>

      <!-- 5. 我的成就 -->
      <section v-if="activeTab === 'achievement'" class="content-section">
        <h2 class="section-title">已获得成就 <button class="more-btn">查看全部 <i class="fas fa-chevron-right"></i></button></h2>
        <div class="achievements-grid">
          <div v-for="achievement in achievements" :key="achievement.id" class="achievement-card">
            <div class="achievement-icon"><i :class="achievement.icon || 'fas fa-trophy'"></i></div>
            <h3 class="achievement-title">{{ achievement.title || achievement.name }}</h3>
            <p class="achievement-desc">{{ achievement.description || achievement.desc }}</p>
          </div>
          <div v-if="achievements.length === 0" class="empty-state">
            <i class="fas fa-trophy"></i>
            <p>还没有获得任何成就</p>
            <p class="empty-hint">继续学习，解锁更多成就吧！</p>
          </div>
        </div>
      </section>
    </div>
  </div>
  <EditProfileModal
    v-model="showEditProfile"
    :user-name="user.userName"
    :email="user.email"
    :user-intro="user.userIntro"
    @save="handleSaveProfile"
  />
</template>

<script setup>
import { onMounted, ref, nextTick } from 'vue'
import { useUserStore } from '../stores/user.js'
import EditProfileModal from '../components/EditProfileModal.vue'

/* 用户状态 */
const user = useUserStore()
const editingBio = ref(false)
const draftBio = ref('')
const showAvatar = ref(false)
const showName = ref(false)
const showSettings = ref(false)
const bioTextarea = ref()

/* 标签数据 */
const activeTab = ref('analysis')
const tabs = [
  { key: 'analysis', label: '学情分析' },
  { key: 'learning', label: '正在学习' },
  { key: 'collect', label: '我的收藏' },
  { key: 'community', label: '我的社区' },
  { key: 'achievement', label: '我的成就' }
]

/* 动态数据 */
const stats = ref({})
const learningList = ref([])
const collectList = ref([])
const communityData = ref({})
const achievements = ref([])

/* 方法 */
function startEditBio() {
  draftBio.value = user.userIntro
  editingBio.value = true
  nextTick(() => {
    bioTextarea.value && bioTextarea.value.focus()
  })
}

async function saveBio() {
  if (draftBio.value.trim() && draftBio.value !== user.userIntro) {
    try {
      await user.updateBio(draftBio.value)
    } catch (error) {
      console.error('更新个性签名失败:', error)
    }

  async function editName() {
    const current = user.userName || ''
    const newName = window.prompt('请输入新的昵称', current)
    if (!newName || newName === current) return
    try {
      await user.updateName(newName)
    } catch (e) {
      console.error('更新昵称失败:', e)
      window.alert(e.message || '更新昵称失败，请重试')
    }
  }
  }
  editingBio.value = false
}

onMounted(async () => {
  console.log('🎓 学生个人中心加载中...')
  
  // 检查用户认证状态
  if (!user.checkAuth()) {
    console.log('用户未登录，请先登录')
    return
  }

  try {
    // 获取用户信息
    if (!user.userId) {
      console.log('📝 获取用户信息...')
      await user.fetchUserProfile()
      console.log('✅ 用户信息获取完成:', user.userName)
    }
    
    // 加载学习统计
    console.log('📊 获取学习统计...')
    await user.fetchLearningStats()
    console.log('✅ 学习统计获取完成:', user.learningStats)
    
    // 模拟加载其他数据
    learningList.value = [
      {
        id: 1,
        title: 'Vue.js 3.0 完整教程',
        description: '从零开始学习Vue.js 3.0的核心概念和实战应用',
        progress: 65,
        bg: 'linear-gradient(135deg,#667eea,#764ba2)'
      },
      {
        id: 2,
        title: 'JavaScript ES6+ 高级特性',
        description: '深入理解现代JavaScript的高级特性和最佳实践',
        progress: 40,
        bg: 'linear-gradient(135deg,#f093fb,#f5576c)'
      }
    ]
    
    collectList.value = [
      {
        id: 1,
        title: 'React Hooks 深度解析',
        description: '全面掌握React Hooks的使用技巧',
        collect_time: '2024-01-15'
      }
    ]
    
    achievements.value = [
      {
        id: 1,
        title: '初学者',
        description: '完成第一门课程学习',
        icon: 'fas fa-star'
      },
      {
        id: 2,
        title: '坚持者',
        description: '连续学习7天',
        icon: 'fas fa-fire'
      }
    ]
    
    console.log('✅ 学生数据加载完成')
  } catch (error) {
    console.error('❌ 加载学生数据失败:', error)
    // 设置默认数据避免页面空白
    learningList.value = []
    collectList.value = []
    achievements.value = []
  }
})
</script>

<style src="../assets/student.css"></style>
