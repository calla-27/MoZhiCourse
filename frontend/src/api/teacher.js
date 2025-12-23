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
export const apiMasteryDistribution = async (courseId = null) => {
  try {
    const token = localStorage.getItem('token');
    let url = `${API_BASE}/api/teacher-center/analytics/mastery-distribution`;
    if (courseId) {
      url += `?course_id=${courseId}`;
    }
    const res = await fetch(url, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取知识掌握分布失败:', error);
    return { success: false, data: [] };
  }
};

// 获取知识点词云数据（基于学习行为分析）
export const apiKnowledgeWordCloud = async (courseId = null) => {
  try {
    const token = localStorage.getItem('token');
    let url = `${API_BASE}/api/learning-behavior/wordcloud`;
    if (courseId) {
      url += `?course_id=${courseId}`;
    }
    const res = await fetch(url, {
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
    const res = await fetch(`${API_BASE}/api/teacher-center/courses/${courseId}/chapters`, {
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
      
      xhr.open('POST', `${API_BASE}/api/teacher-center/upload/video`);
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
    const res = await fetch(`${API_BASE}/api/teacher-center/chapters/${chapterId}/videos`, {
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

// 获取课程详情（用于编辑）- 暂时使用通用API
export const apiGetCourseDetail = async (courseId) => {
  try {
    const token = localStorage.getItem('token');
    console.log('🔍 调用课程详情API，课程ID:', courseId);
    
    // 暂时使用通用的课程详情API
    const url = `${API_BASE}/api/courses/${courseId}`;
    console.log('🔍 API URL:', url);
    console.log('🔍 Token存在:', !!token);
    
    const res = await fetch(url, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    console.log('🔍 API响应状态:', res.status);
    
    if (!res.ok) {
      console.error('🔍 API请求失败，状态码:', res.status);
      const errorText = await res.text();
      console.error('🔍 错误响应:', errorText);
      return { success: false, data: null, message: `HTTP ${res.status}: ${errorText}` };
    }
    
    const data = await res.json();
    console.log('🔍 API响应数据:', data);
    
    return data;
  } catch (error) {
    console.error('获取课程详情失败:', error);
    return { success: false, data: null, message: error.message };
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

// ==================== 学习行为埋点相关API ====================

// 记录单个学习行为
export const apiRecordBehavior = async (behaviorData) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/learning-behavior/record`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(behaviorData)
    });
    return await res.json();
  } catch (error) {
    console.error('记录学习行为失败:', error);
    return { success: false, message: '记录失败' };
  }
};

// 批量记录学习行为
export const apiRecordBehaviors = async (behaviors) => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/learning-behavior/record-batch`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ behaviors })
    });
    return await res.json();
  } catch (error) {
    console.error('批量记录学习行为失败:', error);
    return { success: false, message: '记录失败' };
  }
};

// 获取学习行为统计
export const apiBehaviorStatistics = async (courseId = null) => {
  try {
    const token = localStorage.getItem('token');
    let url = `${API_BASE}/api/learning-behavior/statistics`;
    if (courseId) {
      url += `?course_id=${courseId}`;
    }
    const res = await fetch(url, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取行为统计失败:', error);
    return { success: false, data: [] };
  }
};

// 获取学习行为趋势
export const apiBehaviorTrend = async (courseId = null, days = 30) => {
  try {
    const token = localStorage.getItem('token');
    let url = `${API_BASE}/api/learning-behavior/trend?days=${days}`;
    if (courseId) {
      url += `&course_id=${courseId}`;
    }
    const res = await fetch(url, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取行为趋势失败:', error);
    return { success: false, data: [] };
  }
};

// 更新行为统计
export const apiUpdateBehaviorStatistics = async () => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/learning-behavior/update-statistics`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('更新行为统计失败:', error);
    return { success: false, message: '更新失败' };
  }
};
