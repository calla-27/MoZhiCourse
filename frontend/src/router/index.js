// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import CourseVideo from '../views/CourseVideo.vue'

const routes = [
  {
    path: '/course/:courseId/video/:videoId',
    name: 'CourseVideo',
    component: CourseVideo
  },
  {
    path: '/',
    redirect: '/course/7/video/3'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router