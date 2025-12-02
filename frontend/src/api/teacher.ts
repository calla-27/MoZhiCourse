import http from './http'

export const apiTeacherStats   = () => http.get('/teacher/stats')
export const apiTeacherCourses = () => http.get('/teacher/courses')
export const apiTeacherStudents= (courseId:string) => http.get(`/teacher/courses/${courseId}/students`)