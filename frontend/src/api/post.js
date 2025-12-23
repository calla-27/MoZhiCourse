import request from '../utils/request';

const API_BASE = process.env.VUE_APP_API_BASE_URL || 'http://localhost:4000';

export const postApi = {
  // 获取帖子列表
  getPosts(params) {
    return request.get(`${API_BASE}/api/community/posts`, { params });
  },
  
  // 获取帖子详情
  getPostById(id, params) {
    return request.get(`${API_BASE}/api/community/posts/${id}`, { params });
  },
  
  // 创建帖子
  createPost(data) {
    return request.post(`${API_BASE}/api/community/posts`, data);
  },
  
  // 更新帖子
  updatePost(id, data) {
    return request.put(`${API_BASE}/api/community/posts/${id}`, data);
  },
  
  // 删除帖子
  deletePost(id, data) {
    return request.delete(`${API_BASE}/api/community/posts/${id}`, { data });
  },
  
  // 点赞/取消点赞帖子
  togglePostLike(id, data) {
    return request.post(`${API_BASE}/api/community/posts/${id}/like`, data);
  },
  
  // 收藏/取消收藏帖子
  togglePostFavorite(id, data) {
    return request.post(`${API_BASE}/api/community/posts/${id}/favorite`, data);
  },
  
  // 标记帖子为已解决
  markPostSolved(id, data) {
    return request.patch(`${API_BASE}/api/community/posts/${id}/solve`, data);
  },
  
  // 获取名师列表
  getTeachers(params) {
    return request.get(`${API_BASE}/api/community/teachers`, { params });
  }
};