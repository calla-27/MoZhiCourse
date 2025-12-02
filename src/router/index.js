import { createRouter, createWebHistory } from 'vue-router'
import Home from '@/views/Home.vue'
import CourseDetail from '@/views/CourseDetail.vue'
import SearchResults from '@/views/SearchResults.vue'
import Login from '@/views/Login.vue'
import Register from '@/views/Register.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/course/:id',
    name: 'CourseDetail',
    component: CourseDetail
  },
  {
    path: '/search',
    name: 'SearchResults',
    component: SearchResults
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/register',
    name: 'Register',
    component: Register
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router