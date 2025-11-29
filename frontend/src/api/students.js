// 学生API接口
const API_BASE = 'http://localhost:4000';

// 获取学习统计
export const apiStats = async () => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/personal/stats`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取学习统计失败:', error);
    return { success: false, data: {} };
  }
};

// 获取学生课程
export const apiStudentCourses = async (type = 'learning') => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/personal/courses?status=${type}`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取学生课程失败:', error);
    return { success: false, data: [] };
  }
};

// 收藏相关API
export const apiFavorites = {
  // 获取收藏课程
  getFavorites: async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_BASE}/api/personal/favorites`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      return await res.json();
    } catch (error) {
      console.error('获取收藏课程失败:', error);
      return { success: false, data: [] };
    }
  },

  // 切换收藏状态
  toggleFavorite: async (courseId) => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_BASE}/api/personal/favorites/${courseId}/toggle`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      return await res.json();
    } catch (error) {
      console.error('切换收藏失败:', error);
      return { success: false, message: '操作失败' };
    }
  }
};

// 社区相关API
export const apiCommunity = async () => {
  try {
    const token = localStorage.getItem('token');
    const res = await fetch(`${API_BASE}/api/personal/community`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return await res.json();
  } catch (error) {
    console.error('获取社区数据失败:', error);
    return { success: false, data: {} };
  }
};

// 成就相关API
export const apiAchievements = {
  // 获取成就列表
  getAchievements: async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch(`${API_BASE}/api/personal/achievements`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      return await res.json();
    } catch (error) {
      console.error('获取成就列表失败:', error);
      return { success: false, data: [] };
    }
  }
};
