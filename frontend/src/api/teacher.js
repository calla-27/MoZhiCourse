// 教师API接口
const API_BASE = 'http://localhost:4000';

// 获取教师统计数据
export const apiTeacherStats = async () => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher-center/stats`, {
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
    const url = status ? `${API_BASE}/api/teacher-center/courses?status=${status}` : `${API_BASE}/api/teacher-center/courses`;
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
export const apiTeacherStudents = async (courseId, options = {}) => {
  try {
    const token = localStorage.getItem('token');
    const { page = 1, limit = 10, sort = 'progress', order = 'desc' } = options;
    const params = new URLSearchParams({ page, limit, sort, order });
    const res = await fetch(`${API_BASE}/api/teacher-center/courses/${courseId}/students?${params}`, {
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
    const res = await fetch(`${API_BASE}/api/teacher-center/courses`, {
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
    const res = await fetch(`${API_BASE}/api/teacher-center/courses/${courseId}`, {
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
    const res = await fetch(`${API_BASE}/api/teacher-center/courses/${courseId}`, {
      method: 'DELETE',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('删除课程失败:', error);
    return { success: false, message: '删除失败' };
  }
};

// 获取学生知识掌握分布数据（环状图）
export const apiMasteryDistribution = async () => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher-center/analytics/mastery-distribution`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取知识掌握分布失败:', error);
    return { success: false, data: [] };
  }
};

// 获取知识点词云数据
export const apiKnowledgeWordCloud = async () => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher-center/analytics/knowledge-wordcloud`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取词云数据失败:', error);
    return { success: false, data: [] };
  }
};

// 获取学习趋势数据
export const apiLearningTrend = async (type = 'overall', courseId = null) => {
  try {
    const token = localStorage.getItem('token');
    
    // 构建查询参数
    let url = `${API_BASE}/api/teacher-center/analytics/learning-trend?type=${type}`;
    if (courseId) {
      url += `&course_id=${courseId}`;
    }
    
    const res = await fetch(url, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取学习趋势数据失败:', error);
    return { success: false, data: {} };
  }
};

// 获取趋势概览
export const apiTrendOverview = async () => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher-center/analytics/trend-overview`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const data = await res.json();
    console.log('📈 趋势概览响应:', data);
    
    return data;
  } catch (error) {
    console.error('获取趋势概览失败:', error);
    return { success: false, data: {} };
  }
};

// 获取课程分类列表
export const apiGetCategories = async () => {
  try {
    const res = await fetch(`${API_BASE}/api/categories`);
    return await res.json();
  } catch (error) {
    console.error('获取分类失败:', error);
    return { success: false, data: [] };
  }
};

// 创建章节
export const apiCreateChapter = async (courseId, chapterData) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher/courses/${courseId}/chapters`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(chapterData)
    });
    return await res.json();
  } catch (error) {
    console.error('创建章节失败:', error);
    return { success: false, message: '创建章节失败' };
  }
};

// 上传视频文件
export const apiUploadVideo = async (file, onProgress) => {
  try {
    const token = localStorage.getItem('token');
    const formData = new FormData();
    formData.append('video', file);

    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      
      xhr.upload.addEventListener('progress', (e) => {
        if (e.lengthComputable && onProgress) {
          const progress = Math.round((e.loaded / e.total) * 100);
          onProgress(progress);
        }
      });

      xhr.addEventListener('load', () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          resolve(JSON.parse(xhr.responseText));
        } else {
          reject(new Error('上传失败'));
        }
      });

      xhr.addEventListener('error', () => reject(new Error('网络错误')));
      
      xhr.open('POST', `${API_BASE}/api/teacher/upload/video`);
      xhr.setRequestHeader('Authorization', `Bearer ${token}`);
      xhr.send(formData);
    });
  } catch (error) {
    console.error('上传视频失败:', error);
    return { success: false, message: '上传失败' };
  }
};

// 创建视频记录
export const apiCreateVideo = async (chapterId, videoData) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/teacher/chapters/${chapterId}/videos`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(videoData)
    });
    return await res.json();
  } catch (error) {
    console.error('创建视频记录失败:', error);
    return { success: false, message: '创建视频记录失败' };
  }
};

// 获取课程详情（用于编辑）
export const apiGetCourseDetail = async (courseId) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/courses/${courseId}`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取课程详情失败:', error);
    return { success: false, data: null };
  }
};

// 获取课程章节和视频
export const apiGetCourseChapters = async (courseId) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/courses/${courseId}/chapters`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取课程章节失败:', error);
    return { success: false, data: [] };
  }
};
