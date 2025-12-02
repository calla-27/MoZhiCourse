import axios from 'axios'
import { ElMessage } from 'element-plus'

// 创建axios实例
const service = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api',
  timeout: 10000
})

// 请求拦截器
service.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  (response) => {
    const res = response.data
    
    console.log('API响应:', res) // 添加日志查看实际响应结构
    
    // 根据你的后端API格式调整
    if (res.success) {
      return res // 直接返回完整响应
    } else {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message || 'Error'))
    }
  },
  (error) => {
    console.error('API错误:', error)
    // 处理HTTP错误
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      ElMessage.error('登录已过期，请重新登录')
      window.location.href = '/login'
    } else if (error.response?.status === 404) {
      ElMessage.error('接口不存在: ' + error.config.url)
    } else if (error.response?.data?.message) {
      ElMessage.error(error.response.data.message)
    } else {
      ElMessage.error(error.message || '网络错误')
    }
    return Promise.reject(error)
  }
)
// 关键：正确导出
export const api = service
export default service