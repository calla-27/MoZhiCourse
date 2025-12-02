<template>
  <div class="auth-page">
    <!-- 导航栏 -->
    <nav class="navbar">
      <div class="nav-content">
        <div class="logo">
          <i class="fas fa-graduation-cap"></i>
          <router-link to="/" style="text-decoration: none; color: inherit;">
            iCoursera
          </router-link>
        </div>
        <div class="nav-links">
          <router-link to="/" class="nav-link">返回首页</router-link>
        </div>
      </div>
    </nav>

    <!-- 注册表单 -->
    <div class="auth-container">
      <div class="auth-card">
        <div class="auth-header">
          <h2>创建账户</h2>
          <p>选择您的身份，开启iCoursera学习之旅</p>
        </div>

        <!-- 用户类型选择 -->
        <div class="user-type-selector">
          <div 
            class="user-type-card"
            :class="{ active: form.user_type === 'student' }"
            @click="form.user_type = 'student'"
          >
            <div class="type-icon">
              <i class="fas fa-user-graduate"></i>
            </div>
            <h3>学生</h3>
            <p>学习课程，提升技能</p>
            <ul>
              <li>报名学习各类课程</li>
              <li>跟踪学习进度</li>
              <li>参与课程评价</li>
            </ul>
          </div>
          
          <div 
            class="user-type-card"
            :class="{ active: form.user_type === 'instructor' }"
            @click="form.user_type = 'instructor'"
          >
            <div class="type-icon">
              <i class="fas fa-chalkboard-teacher"></i>
            </div>
            <h3>教师</h3>
            <p>创建课程，分享知识</p>
            <ul>
              <li>发布和管理课程</li>
              <li>查看学生数据</li>
              <li>建立个人品牌</li>
            </ul>
          </div>
        </div>

        <form @submit.prevent="handleRegister" class="auth-form" v-if="form.user_type">
          <div class="form-row">
            <div class="form-group">
              <label for="username">姓名</label>
              <input
                type="text"
                id="username"
                v-model="form.username"
                placeholder="请输入真实姓名"
                required
              >
            </div>
            
            <div class="form-group">
              <label for="phone">手机号</label>
              <input
                type="tel"
                id="phone"
                v-model="form.phone"
                placeholder="请输入手机号"
                pattern="[0-9]{11}"
                required
              >
            </div>
          </div>

          <div class="form-group">
            <label for="password">密码</label>
            <input
              type="password"
              id="password"
              v-model="form.password"
              placeholder="请输入密码（至少6位）"
              minlength="6"
              required
            >
          </div>

          <div class="form-group">
            <label for="confirmPassword">确认密码</label>
            <input
              type="password"
              id="confirmPassword"
              v-model="form.confirmPassword"
              placeholder="请再次输入密码"
              required
            >
          </div>

          <!-- 教师专属字段 -->
          <div v-if="form.user_type === 'instructor'" class="teacher-fields">
            <div class="form-group">
              <label for="occupation">职业/职称</label>
              <input
                type="text"
                id="occupation"
                v-model="form.occupation"
                placeholder="例如：高级软件工程师、数据科学家"
              >
            </div>
            
            <div class="form-group">
              <label for="user_intro">个人简介</label>
              <textarea
                id="user_intro"
                v-model="form.user_intro"
                placeholder="请简要介绍您的专业背景和教学经验"
                rows="3"
              ></textarea>
            </div>
          </div>

          <div class="form-options">
            <label class="checkbox-label">
              <input type="checkbox" v-model="form.agreeTerms" required>
              <span>我已阅读并同意<a href="#">服务条款</a>和<a href="#">隐私政策</a></span>
            </label>
          </div>

          <button type="submit" class="auth-btn" :disabled="loading">
            <span v-if="loading">
              <i class="fas fa-spinner fa-spin"></i> 注册中...
            </span>
            <span v-else>
              {{ form.user_type === 'instructor' ? '成为教师' : '成为学生' }}
            </span>
          </button>
        </form>

        <div class="auth-footer">
          <p>已有账户？ <router-link to="/login" class="auth-link">立即登录</router-link></p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

export default {
  name: 'Register',
  setup() {
    const router = useRouter()
    const loading = ref(false)
    
    const form = ref({
      user_type: '', // 'student' 或 'instructor'
      username: '',
      phone: '',
      password: '',
      confirmPassword: '',
      occupation: '',
      user_intro: '',
      agreeTerms: false
    })

    const handleRegister = async () => {
      // 前端验证
      if (!form.value.user_type) {
        ElMessage.warning('请选择用户类型')
        return
      }

      if (form.value.password !== form.value.confirmPassword) {
        ElMessage.error('两次输入的密码不一致')
        return
      }

      if (form.value.password.length < 6) {
        ElMessage.error('密码长度至少6位')
        return
      }

      if (!form.value.agreeTerms) {
        ElMessage.warning('请同意服务条款和隐私政策')
        return
      }

      loading.value = true

      try {
        // 使用正确的字段名（英文）
        const registerData = {
          username: form.value.username,
          phone: form.value.phone,
          password: form.value.password,
          user_type: form.value.user_type
        }

        // 如果是教师，添加额外字段
        if (form.value.user_type === 'instructor') {
          if (form.value.occupation) {
            registerData.occupation = form.value.occupation
          }
          if (form.value.user_intro) {
            registerData.user_intro = form.value.user_intro
          }
        }

        console.log('📤 发送注册请求:', registerData)

        // 使用代理URL（现在应该能正常工作了）
        const response = await fetch('/api/auth/register', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(registerData)
        })

        console.log('📥 响应状态:', response.status)
        
        if (!response.ok) {
          const errorText = await response.text()
          console.log('📥 错误响应:', errorText)
          throw new Error(`HTTP错误! 状态: ${response.status}`)
        }

        const result = await response.json()
        console.log('📥 响应数据:', result)

        if (result.success) {
          const userTypeText = form.value.user_type === 'instructor' ? '教师' : '学生'
          ElMessage.success(`${userTypeText}注册成功！`)
          router.push('/login')
        } else {
          ElMessage.error(result.message || '注册失败')
        }
      } catch (error) {
        console.error('❌ 注册错误:', error)
        ElMessage.error(`注册失败: ${error.message}`)
      } finally {
        loading.value = false
      }
    }

    // 这里缺少了 return 语句！
    return {
      form,
      loading,
      handleRegister
    }
  }
}
</script>

<style scoped>
/* 样式代码保持不变 */
.auth-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.navbar {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 0 20px;
}

.nav-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
  height: 70px;
}

.logo {
  display: flex;
  align-items: center;
  font-size: 24px;
  font-weight: bold;
  color: #4a6cf7;
}

.logo i {
  margin-right: 10px;
}

.auth-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 70px);
  padding: 40px 20px;
}

.auth-card {
  background: white;
  padding: 40px;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 500px;
}

.auth-header {
  text-align: center;
  margin-bottom: 30px;
}

.auth-header h2 {
  color: #333;
  margin-bottom: 8px;
  font-size: 28px;
}

.auth-header p {
  color: #666;
  font-size: 14px;
}

/* 用户类型选择器 */
.user-type-selector {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 30px;
}

.user-type-card {
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  background: #f8f9fa;
}

.user-type-card:hover {
  border-color: #4a6cf7;
  transform: translateY(-2px);
}

.user-type-card.active {
  border-color: #4a6cf7;
  background: #f0f4ff;
  box-shadow: 0 4px 12px rgba(74, 108, 247, 0.15);
}

.type-icon {
  font-size: 32px;
  color: #4a6cf7;
  margin-bottom: 10px;
}

.user-type-card h3 {
  margin-bottom: 8px;
  color: #333;
}

.user-type-card p {
  color: #666;
  font-size: 12px;
  margin-bottom: 10px;
}

.user-type-card ul {
  text-align: left;
  font-size: 11px;
  color: #888;
  padding-left: 15px;
}

.user-type-card li {
  margin-bottom: 4px;
}

/* 表单样式 */
.auth-form {
  margin-top: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 6px;
  color: #333;
  font-weight: 500;
  font-size: 14px;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  transition: border-color 0.3s;
  font-family: inherit;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #4a6cf7;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.teacher-fields {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 6px;
  margin-bottom: 20px;
  border-left: 3px solid #4a6cf7;
}

.form-options {
  margin-bottom: 25px;
}

.checkbox-label {
  display: flex;
  align-items: flex-start;
  font-size: 12px;
  color: #666;
  line-height: 1.4;
}

.checkbox-label input {
  margin-right: 8px;
  margin-top: 2px;
}

.checkbox-label a {
  color: #4a6cf7;
  text-decoration: none;
}

.checkbox-label a:hover {
  text-decoration: underline;
}

.auth-btn {
  width: 100%;
  padding: 12px;
  background: #4a6cf7;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.3s;
}

.auth-btn:hover:not(:disabled) {
  background: #3a5bd9;
}

.auth-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.auth-footer {
  text-align: center;
  margin-top: 25px;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

.auth-footer p {
  color: #666;
  font-size: 14px;
}

.auth-link {
  color: #4a6cf7;
  text-decoration: none;
  font-weight: 500;
}

.auth-link:hover {
  text-decoration: underline;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .user-type-selector {
    grid-template-columns: 1fr;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .auth-card {
    padding: 30px 20px;
    margin: 20px;
  }
}
</style>