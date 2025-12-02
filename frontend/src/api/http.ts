// 统一baseURL与token拦截器
// src/api/http.ts
import axios from 'axios'
import { ElMessage } from 'element-plus'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE as string,
  timeout: 8000
})

/* 请求拦截：自动挂 token */
http.interceptors.request.use(config => {
  const tk = localStorage.getItem('token')
  if (tk) config.headers.Authorization = `Bearer ${tk}`
  return config
})

/* 响应拦截：统一弹错 */
http.interceptors.response.use(
  res => res.data,
  err => {
    ElMessage.error(err.response?.data?.message || '网络异常')
    return Promise.reject(err)
  }
)

export default http