import axios from 'axios'

// 创建axios实例 - 修改端口为4000
const request = axios.create({
  baseURL: 'http://localhost:4000/api', // 改为4000端口
  timeout: 10000
})

// 请求拦截器
request.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers = config.headers || {}
      config.headers.Authorization = `Bearer ${token}`
    }
    console.log(`🚀 发送请求: ${config.method?.toUpperCase()} ${config.url}`)
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    console.log(`✅ 请求成功: ${response.config.url}`)
    return response.data
  },
  error => {
    console.error('❌ API请求错误:', error.message)
    console.error('   请求URL:', error.config?.url)
    
    if (error.code === 'ERR_NETWORK') {
      console.error('   💡 建议: 请确保后端服务已启动在端口4000')
    }
    
    return Promise.reject(error)
  }
)

export default request
