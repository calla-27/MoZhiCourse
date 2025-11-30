// 教师API接口
const API_BASE = 'http://localhost:4000';

// 获取教师统计数据
export const apiTeacherStats = async () => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher/stats`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取教师统计失败:', error);
    return { success: false, data: {} };
  }
};

// 获取教师课程列表
export const apiTeacherCourses = async (status = '') => {
  try {
    const token = localStorage.getItem('token');
    const url = status ? `${API_BASE}/api/teacher/courses?status=${status}` : `${API_BASE}/api/teacher/courses`;
    const res = await fetch(url, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取教师课程失败:', error);
    return { success: false, data: [] };
  }
};

// 获取课程学生列表
export const apiTeacherStudents = async (courseId) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher/courses/${courseId}/students`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取课程学生失败:', error);
    return { success: false, data: [] };
  }
};

// 创建新课程
export const apiCreateCourse = async (courseData) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher/courses`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(courseData)
    });
    return await res.json();
  } catch (error) {
    console.error('创建课程失败:', error);
    return { success: false, message: '创建失败' };
  }
};

// 更新课程
export const apiUpdateCourse = async (courseId, courseData) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher/courses/${courseId}`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(courseData)
    });
    return await res.json();
  } catch (error) {
    console.error('更新课程失败:', error);
    return { success: false, message: '更新失败' };
  }
};

// 删除课程
export const apiDeleteCourse = async (courseId) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher/courses/${courseId}`, {
      method: 'DELETE',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('删除课程失败:', error);
    return { success: false, message: '删除失败' };
  }
};
