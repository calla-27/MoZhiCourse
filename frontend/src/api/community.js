import request from '@/utils/request'

// 获取小组详情（含成员）
export function getTeamDetail(teamId, currentUserId) {
  return request({
    url: `/community/teams/${teamId}`,
    method: 'get',
    params: { current_user_id: currentUserId }
  })
}

// 获取小组今日学习数据
export function getTeamDailyStudyData(teamId) {
  return request({
    url: `/community/teams/${teamId}/daily-study`,
    method: 'get'
  })
}

// 获取用户今日学习详情
export function getUserDailyStudyDetail(teamId, userId) {
  return request({
    url: `/community/teams/${teamId}/users/${userId}/daily-study`,
    method: 'get'
  })
}

// 获取小组成员
export function getTeamMembers(teamId) {
  return request({
    url: `/community/teams/${teamId}`,
    method: 'get'
  })
}

// 获取小组任务
export function getTeamTasks(teamId) {
  return request({
    url: `/community/teams/${teamId}/task-completion`,
    method: 'get'
  })
}

// 获取小组任务完成数据
export function getTeamTaskCompletionData(teamId) {
  return request({
    url: `/community/teams/${teamId}/task-completion`,
    method: 'get'
  })
}

// 获取团队任务统计 - 使用 taskRoutes
export function getTeamTasksStatistics(teamId) {
  return request({
    url: `/community/tasks/teams/${teamId}/tasks-statistics`,
    method: 'get'
  })
}

// ===================== 任务管理API（使用 taskRoutes） =====================

// 创建小组任务
export function createTeamTask(teamId, data) {
  return request({
    url: `/community/teams/${teamId}/tasks`,
    method: 'post',
    data
  })
}

// 删除小组任务
export function deleteTeamTask(taskId, data) {
  return request({
    url: `/community/tasks/${taskId}`,
    method: 'delete',
    data
  })
}

// 更新任务完成状态（打勾功能）
export function updateTaskCompletionStatus(taskId, data) {
  return request({
    url: `/community/tasks/${taskId}/completion-status`,
    method: 'patch',
    data
  })
}

// 快速完成任务
export function quickCompleteTask(taskId, data) {
  return request({
    url: `/community/tasks/${taskId}/quick-complete`,
    method: 'post',
    data
  })
}

// 更新小组任务信息
export function updateTeamTask(taskId, data) {
  return request({
    url: `/community/tasks/${taskId}`,
    method: 'put',
    data
  })
}

// 更新任务状态
export function updateTeamTaskStatus(taskId, status) {
  return request({
    url: `/community/tasks/${taskId}/status`,
    method: 'patch',
    data: { status }
  })
}

// ===================== 社区功能API（使用 communityRoutes） =====================

// 获取小组留言
export function getTeamComments(teamId) {
  return request({
    url: `/community/teams/${teamId}/comments`,
    method: 'get'
  })
}

// 创建小组留言
export function createTeamComment(teamId, data) {
  return request({
    url: `/community/teams/${teamId}/comments`,
    method: 'post',
    data
  })
}

// 加入小组
export function joinTeam(teamId, userId) {
  return request({
    url: `/community/teams/${teamId}/join`,
    method: 'post',
    data: { user_id: userId }
  })
}

// 退出小组
export function leaveTeam(teamId, userId) {
  return request({
    url: `/community/teams/${teamId}/leave`,
    method: 'delete',
    data: { user_id: userId }
  })
}

// 加入请求相关
export function getJoinRequests(teamId) {
  return request({
    url: `/community/teams/${teamId}/join-requests`,
    method: 'get'
  })
}

export function approveJoinRequest(requestId) {
  return request({
    url: `/community/teams/join-requests/${requestId}/approve`,
    method: 'post'
  })
}

export function rejectJoinRequest(requestId) {
  return request({
    url: `/community/teams/join-requests/${requestId}/reject`,
    method: 'post'
  })
}