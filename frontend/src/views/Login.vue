<template>
  <div class="auth-page">
    <div class="auth-card">
      <h1 class="auth-title">课程中心</h1>
      <p class="auth-subtitle">使用用户名和密码登录 / 注册</p>

      <div class="auth-tabs">
        <div
          class="auth-tab"
          :class="{ active: activeTab === 'login' }"
          @click="activeTab = 'login'"
        >
          登录
        </div>
        <div
          class="auth-tab"
          :class="{ active: activeTab === 'register' }"
          @click="activeTab = 'register'"
        >
          注册
        </div>
      </div>

      <!-- 登录表单 -->
      <form v-if="activeTab === 'login'" class="auth-form" @submit.prevent="handleLogin">
        <div class="form-group">
          <label>用户名</label>
          <input
            v-model="loginForm.username"
            type="text"
            placeholder="请输入用户名"
            required
          />
        </div>

        <div class="form-group">
          <label>密码</label>
          <input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            required
          />
        </div>

        <div v-if="error" class="error-msg">{{ error }}</div>

        <button class="btn-primary" type="submit" :disabled="loading">
          {{ loading ? '登录中...' : '登录' }}
        </button>
      </form>

      <!-- 注册表单 -->
      <form v-else class="auth-form" @submit.prevent="handleRegister">
        <div class="form-group">
          <label>用户名</label>
          <input
            v-model="registerForm.user_name"
            type="text"
            placeholder="请输入你的名字"
            required
          />
        </div>

        <div class="form-group">
          <label>密码</label>
          <input
            v-model="registerForm.password"
            type="password"
            placeholder="请输入登录密码"
            required
          />
        </div>

        <div class="form-group">
          <label>身份</label>
          <div class="role-group">
            <label class="role-option">
              <input type="radio" value="learner" v-model="registerForm.role" />
              <span>我是学生</span>
            </label>
            <label class="role-option">
              <input type="radio" value="instructor" v-model="registerForm.role" />
              <span>我是老师</span>
            </label>
          </div>
        </div>

        <div v-if="error" class="error-msg">{{ error }}</div>

        <button class="btn-primary" type="submit" :disabled="loading">
          {{ loading ? '注册中...' : '注册并登录' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { login, register } from '@/api/auth'

const router = useRouter()
const route = useRoute()

const activeTab = ref(route.name === 'Register' || route.query.mode === 'register' ? 'register' : 'login')

const loginForm = ref({
  username: '',
  password: '',
})

const registerForm = ref({
  user_name: '',
  password: '',
  role: 'learner',
})

const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  if (!loginForm.value.username || !loginForm.value.password) return
  loading.value = true
  error.value = ''
  try {
    const res = await login({
      username: loginForm.value.username,
      password: loginForm.value.password,
    })
    const { user, token } = res.data

    localStorage.setItem('token', token)
    localStorage.setItem('user', JSON.stringify(user))

    console.log('登录成功，收到的 token:', token)

    const redirect = route.query.redirect || '/search'
    router.push(redirect)
  } catch (e) {
    error.value = e.response?.data?.message || '登录失败，请检查账号密码'
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  if (!registerForm.value.user_name || !registerForm.value.password) return
  loading.value = true
  error.value = ''
  try {
    const res = await register({
      user_name: registerForm.value.user_name,
      password: registerForm.value.password,
      role: registerForm.value.role,
    })

    const { user, token } = res.data
    localStorage.setItem('token', token)
    localStorage.setItem('user', JSON.stringify(user))

     console.log('注册成功，收到的 token:', token)

    const redirect = route.query.redirect || '/search'
    router.push(redirect)
  } catch (e) {
    error.value = e.response?.data?.message || '注册失败，请稍后重试'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.auth-card {
  width: 380px;
  background: #fff;
  border-radius: 12px;
  padding: 30px 26px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}

.auth-title {
  font-size: 22px;
  font-weight: 600;
  margin-bottom: 6px;
}

.auth-subtitle {
  font-size: 13px;
  color: #5f6368;
  margin-bottom: 20px;
}

.auth-tabs {
  display: flex;
  background: #f1f3f4;
  border-radius: 999px;
  padding: 4px;
  margin-bottom: 18px;
}

.auth-tab {
  flex: 1;
  text-align: center;
  font-size: 13px;
  padding: 6px 0;
  border-radius: 999px;
  cursor: pointer;
  color: #5f6368;
}

.auth-tab.active {
  background: #fff;
  color: #1a73e8;
  font-weight: 600;
  box-shadow: 0 1px 3px rgba(60, 64, 67, 0.3);
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group label {
  font-size: 13px;
  color: #202124;
}

.form-group input {
  height: 36px;
  border-radius: 6px;
  border: 1px solid #dadce0;
  padding: 0 10px;
  font-size: 14px;
}

.form-group input:focus {
  outline: none;
  border-color: #1a73e8;
  box-shadow: 0 0 0 1px rgba(26, 115, 232, 0.2);
}

.role-group {
  display: flex;
  gap: 16px;
}

.role-option {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
}

.error-msg {
  color: #d93025;
  font-size: 13px;
}

.btn-primary {
  margin-top: 4px;
  width: 100%;
  height: 38px;
  border: none;
  border-radius: 6px;
  background: #1a73e8;
  color: #fff;
  font-size: 14px;
  cursor: pointer;
}

.btn-primary:disabled {
  opacity: 0.7;
  cursor: default;
}
</style>
