// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// 等待DOM加载完成
document.addEventListener('DOMContentLoaded', () => {
  const app = createApp(App)
  app.use(router)
  app.mount('#app')
  console.log('✅ Vue应用挂载成功')
})