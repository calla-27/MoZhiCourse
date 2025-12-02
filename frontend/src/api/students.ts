import http from './http'

export const apiStudentStats   = () => http.get('/student/stats')
export const apiStudentCourses = () => http.get('/student/courses')
export const apiFavorites      = () => http.get('/student/favorites')
export const apiCommunity      = () => http.get('/student/community')
export const apiAchievements   = () => http.get('/student/achievements')