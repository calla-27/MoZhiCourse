<template>
  <div class="personal-center-router">
    <div v-if="loading" class="loading">
      <i class="fas fa-spinner fa-spin"></i>
      <p>正在加载个人中心...</p>
    </div>
    <div v-else-if="error" class="error">
      <i class="fas fa-exclamation-triangle"></i>
      <p>{{ error }}</p>
      <button @click="retry" class="retry-btn">重试</button>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user.js'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(true)
const error = ref('')

onMounted(async () => {
  await routeToCorrectCenter()
})

async function routeToCorrectCenter() {
  try {
    loading.value = true
    error.value = ''
    
    // 检查是否有token
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    // 获取用户信息
    await userStore.fetchUserProfile()
    
    // 根据用户角色跳转
    const userRole = userStore.role
    console.log('用户角色:', userRole)
    
    if (userRole === 'instructor' || userRole === 'teacher') {
      // 教师跳转到教师中心
      router.replace('/personal/teacher')
    } else {
      // 学生跳转到学生中心
      router.replace('/personal/student')
    }
    
  } catch (err) {
    console.error('路由到个人中心失败:', err)
    error.value = err.message || '加载失败，请重试'
    loading.value = false
  }
}

function retry() {
  routeToCorrectCenter()
}
</script>

<style scoped>
.personal-center-router {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f5f7fa;
}

.loading, .error {
  text-align: center;
  padding: 2rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.1);
}

.loading i {
  font-size: 2rem;
  color: #409eff;
  margin-bottom: 1rem;
}

.error i {
  font-size: 2rem;
  color: #f56c6c;
  margin-bottom: 1rem;
}

.loading p, .error p {
  margin: 0.5rem 0;
  color: #666;
}

.retry-btn {
  background: #409eff;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  margin-top: 1rem;
}

.retry-btn:hover {
  background: #66b1ff;
}
</style>
