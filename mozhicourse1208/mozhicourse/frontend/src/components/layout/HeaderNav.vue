<template>
  <nav class="navbar">
    <div class="nav-content">
      <div class="logo" @click="goHome">
        <i class="fas fa-graduation-cap"></i>
        墨知课堂
      </div>

      <div class="nav-links">
        <router-link to="/" class="nav-link">课程中心</router-link>
        <router-link to="/community" class="nav-link">学习社区</router-link>
      </div>

      <div class="nav-search">
        <input
          v-model="keyword"
          type="text"
          class="nav-search-input"
          placeholder="搜索课程、技能或知识点..."
          @keyup.enter="handleSearch"
        />
        <button class="nav-search-btn" @click="handleSearch">
          <i class="fas fa-search"></i>
        </button>
      </div>

      <div class="user-actions">
        <div v-if="userName" class="avatar" @click="goToPersonalCenter" title="点击进入个人中心">{{ avatar }}</div>
        <button class="logout-btn" @click="handleLogout">退出</button>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const keyword = ref('')

const userName = computed(() => {
  try {
    const storedUser = localStorage.getItem('user')
    if (!storedUser) return ''
    const user = JSON.parse(storedUser)
    return user.user_name || user.userName || ''
  } catch (e) {
    return ''
  }
})

const avatar = computed(() => {
  return userName.value ? userName.value.charAt(0) : '用'
})

const handleSearch = () => {
  const q = keyword.value.trim()
  if (!q) return
  // 跳转到首页并传递搜索参数
  router.push({
    path: '/',
    query: { q }
  })
}

const handleLogout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  router.push('/login')
}

const goHome = () => {
  router.push('/')
}

const goToPersonalCenter = () => {
  router.push('/personal')
}
</script>

<style scoped>
.navbar {
  background: white;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  position: sticky;
  top: 0;
  z-index: 100;
  padding: 0 20px;
}

.nav-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 70px;
  max-width: 1200px;
  margin: 0 auto;
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 24px;
  font-weight: bold;
  color: #1a73e8;
  cursor: pointer;
}

.nav-links {
  display: flex;
  gap: 30px;
}

.nav-search {
  flex: 1;
  max-width: 460px;
  margin: 0 20px;
  display: flex;
  align-items: center;
  position: relative;
}

.nav-search-input {
  width: 100%;
  padding: 8px 40px 8px 16px;
  border-radius: 20px;
  border: 1px solid #dadce0;
  font-size: 0.9rem;
}

.nav-search-btn {
  position: absolute;
  right: 8px;
  background: transparent;
  border: none;
  cursor: pointer;
  color: #5f6368;
}

.nav-link {
  text-decoration: none;
  color: #202124;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 20px;
  transition: all 0.3s ease;
}

.nav-link.router-link-active,
.nav-link:hover {
  background: #e8f0fe;
  color: #1a73e8;
}

.user-actions {
  display: flex;
  align-items: center;
  gap: 15px;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #1a73e8;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
}

.avatar:hover {
  background: #1557b0;
  transform: scale(1.05);
}

.logout-btn {
  border: 1px solid #dadce0;
  background: #fff;
  border-radius: 20px;
  padding: 6px 14px;
  font-size: 0.85rem;
  cursor: pointer;
}

@media (max-width: 768px) {
  .nav-links {
    display: none;
  }
}
</style>