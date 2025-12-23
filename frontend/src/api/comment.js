import request from '../utils/request';

export const commentApi = {
  // 获取帖子评论
  getComments(postId, params) {
    return request.get(`/community/posts/${postId}/comments`, { params });
  },
  
  // 获取视频评论
  getVideoComments(videoId, params) {
    return request.get(`/courses/videos/${videoId}/comments`, { params });
  },
  
  // 添加评论
  addComment(postId, data) {
    return request.post(`/community/posts/${postId}/comments`, data);
  },
  
  // 添加视频评论
  addVideoComment(videoId, data) {
    return request.post(`/courses/videos/${videoId}/comments`, data);
  },
  
  // 删除视频评论
  deleteVideoComment(commentId) {
    return request.delete(`/courses/comments/${commentId}`);
  },
  
  // 删除评论
  deleteComment(commentId, data) {
    return request.delete(`/community/comments/${commentId}`, { data });
  },
  
  // 点赞/取消点赞视频评论
  toggleCommentLike(commentId, data) {
    return request.post(`/courses/comments/${commentId}/like`, data);
  },

  // 更新评论
  updateComment(commentId, data) {
    return request.put(`/community/comments/${commentId}`, data);
  },

  // 获取评论点赞状态
  getCommentLikeStatus(commentId, userId) {
    return request.get(`/community/comments/${commentId}/like/status`, {
      params: { user_id: userId }
    });
  }
};

// 兼容旧的导出方式
export const postComment = commentApi.addComment;
export const likeComment = commentApi.toggleCommentLike;
export const getComments = commentApi.getVideoComments; // 视频页面使用视频评论API
export const getVideoComments = commentApi.getVideoComments;
export const addVideoComment = commentApi.addVideoComment;
export const deleteVideoComment = commentApi.deleteVideoComment;

// 默认导出
export default commentApi;