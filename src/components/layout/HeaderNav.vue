<template>
  <nav class="navbar">
    <div class="nav-content">
      <div class="logo">
        <i class="fas fa-graduation-cap"></i>
        <router-link to="/" style="text-decoration: none; color: inherit;">
          iCoursera
        </router-link>
      </div>
      <div class="nav-links">
        <router-link to="/" class="nav-link">课程中心</router-link>
        <a href="#" class="nav-link">学习社区</a>
      </div>
      <div class="user-actions">
        <!-- 登录状态显示 -->
        <template v-if="authStore.isLoggedIn">
          <el-dropdown>
            <span class="user-info">
              <div class="avatar">{{ userInitial }}</div>
              <span class="user-name">{{ authStore.user?.user_name }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="goToDashboard">
                  <i class="fas fa-user"></i> 个人中心
                </el-dropdown-item>
                <el-dropdown-item @click="handleLogout" divided>
                  <i class="fas fa-sign-out-alt"></i> 退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
        <template v-else>
          <router-link to="/login" class="login-btn">登录/注册</router-link>
        </template>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'
import { ElMessage, ElDropdown, ElDropdownMenu, ElDropdownItem } from 'element-plus'

const authStore = useAuthStore()
const router = useRouter()

// 计算用户名字的首字母
const userInitial = computed(() => {
  return authStore.user?.user_name?.charAt(0) || '用'
})

const handleLogout = () => {
  authStore.logout()
  ElMessage.success('已退出登录')
  router.push('/')
}

const goToDashboard = () => {
  const role = authStore.user?.role
  if (role === 'instructor') {
    // 跳转到教师中心（新窗口打开）
    window.open('/teacher-dashboard.html', '_blank')
  } else {
    // 跳转到学生中心（新窗口打开）
    window.open('/student-dashboard.html', '_blank')
  }
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
}

.nav-links {
  display: flex;
  gap: 30px;
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

/* 登录按钮样式 */
.login-btn {
  background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
  color: white;
  padding: 8px 20px;
  border-radius: 20px;
  text-decoration: none;
  font-weight: 500;
  transition: transform 0.3s ease;
}

.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(37, 117, 252, 0.3);
}

/* 用户信息样式 */
.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 5px 10px;
  border-radius: 20px;
  transition: background 0.3s ease;
}

.user-info:hover {
  background: #f5f5f5;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 16px;
}

.user-name {
  font-weight: 500;
  color: #202124;
}

@media (max-width: 768px) {
  .nav-links {
    display: none;
  }
  
  .user-name {
    display: none;
  }
}
</style>