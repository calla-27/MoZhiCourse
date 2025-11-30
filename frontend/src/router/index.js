// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import CourseVideo from '../views/CourseVideo.vue'
import CourseDetail from '../views/CourseDetail.vue'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import Home from '@/views/Home.vue' 
import Community from '../views/Community.vue'
import StudentCenter from '../views/StudentCenter.vue'
import TeacherCenter from '../views/TeacherCenter.vue'
import PersonalCenterRouter from '../views/PersonalCenterRouter.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/register',
    name: 'Register',
    component: Register
  },
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/course/:courseId',
    name: 'CourseDetail',
    component: CourseDetail
  },
  {
    path: '/course/:courseId/video/:videoId',
    name: 'CourseVideo',
    component: CourseVideo
  },
  {
    path: '/community',
    name: 'Community',
    component: Community
  },
  {
    path: '/personal',
    name: 'PersonalCenterRouter',
    component: PersonalCenterRouter
  },
  {
    path: '/personal/student',
    name: 'StudentCenter',
    component: StudentCenter
  },
  {
    path: '/personal/teacher',
    name: 'TeacherCenter',
    component: TeacherCenter
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to, from, next) => {
  const publicPaths = ['/login', '/register']
  const isPublic = publicPaths.includes(to.path)
  const token = localStorage.getItem('token')

  // 如果是公开页面，直接放行
  if (isPublic) {
    return next()
  }

  // 如果需要认证但没有 token，跳转到登录页
  if (!token) {
    return next({
      path: '/login',
      query: { redirect: to.fullPath },
    })
  }

  // 已登录，放行
  next()
})

export default router