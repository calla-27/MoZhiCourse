import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
  const name = ref('张三')
  const bio = ref('热爱编程，专注于前端技术和用户体验设计')
  const avatar = ref('') // base64
  const stats = ref({ learnHours: 156, courses: 28, followers: 128, following: 42 })
  return { name, bio, avatar, stats }
})