import { defineStore } from 'pinia'
import { ref } from 'vue'
import service from '@/utils/request'  // 改为导入默认导出

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token'))
  const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
  const isLoggedIn = ref(!!token.value)

  const login = async (credentials) => {
    try {
      // 使用 service 而不是 api
      const response = await service.post('/auth/login', credentials)
      
      if (response.success) {
        token.value = response.data.token
        user.value = response.data.user
        isLoggedIn.value = true
        
        localStorage.setItem('token', token.value)
        localStorage.setItem('user', JSON.stringify(user.value))
        
        return response
      } else {
        throw new Error(response.message)
      }
    } catch (error) {
      throw new Error(error.response?.data?.message || '登录失败')
    }
  }

  const logout = () => {
    token.value = null
    user.value = null
    isLoggedIn.value = false
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  const getCurrentUser = async () => {
    if (!token.value) return null
    
    try {
      const response = await service.get('/auth/me')
      if (response.success) {
        user.value = response.data
        localStorage.setItem('user', JSON.stringify(user.value))
        return user.value
      }
    } catch (error) {
      logout()
    }
    return null
  }

  return {
    token,
    user,
    isLoggedIn,
    login,
    logout,
    getCurrentUser
  }
})