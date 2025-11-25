// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import CourseVideo from '../views/CourseVideo.vue'
import CourseDetail from '../views/CourseDetail.vue'
import Login from '../views/Login.vue'
import SearchResults from '../views/SearchResults.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/register',
    name: 'Register',
    component: Login
  },
  {
    path: '/search',
    name: 'SearchResults',
    component: SearchResults
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
    path: '/',
    redirect: '/search'
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

  const protectedPaths = ['/course', '/search']
  const needsAuth = protectedPaths.some(path => to.path.startsWith(path))
  
  if (!isPublic && needsAuth && !token) {
    return next({
      path: '/login',
      query: { redirect: to.fullPath },
    })
  }

  next()
})

export default router