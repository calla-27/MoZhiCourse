// api/like.js
import request from '@/utils/request';

// 获取课程点赞状态
export const getCourseLikeStatus = (courseId) => {
  return request({
    url: `/courses/${courseId}/like-status`,
    method: 'get'
  });
};

// 切换课程点赞
export const toggleCourseLike = (courseId) => {
  return request({
    url: `/courses/${courseId}/like`,
    method: 'post'
  });
};

// 获取课程收藏状态
export const getCourseFavoriteStatus = (courseId) => {
  return request({
    url: `/courses/${courseId}/favorite-status`,
    method: 'get'
  });
};

// 切换课程收藏
export const toggleCourseFavorite = (courseId) => {
  return request({
    url: `/courses/${courseId}/favorite-toggle`,
    method: 'post'
  });
};
