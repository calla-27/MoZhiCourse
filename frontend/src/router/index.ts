import { createRouter, createWebHistory } from 'vue-router'
import StudentIndex from '../views/StudentIndex.vue'
import TeacherIndex from '../views/TeacherIndex.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: () => {
        const role = localStorage.getItem('role')
        return role === 'instructor' ? TeacherIndex : StudentIndex
      }
    },
    { path: '/login', component: () => import('../views/Login.vue') }
  ]
})

/* 全局前置守卫 */
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (!token && to.path !== '/login') return next('/login')
  next()
})

export default router