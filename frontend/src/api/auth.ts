import http from './http'

export const apiLogin = (phone: string, pwd: string) =>
  http.post('/auth/login', { phone, password: pwd })

export const apiRegister = (user_name: string, phone: string, email: string, password: string, role: 'learner' | 'instructor') =>
  http.post('/auth/register', { user_name, phone, email, password, role })