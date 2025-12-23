//frontend\src\views\StudyRoom.vue：
<template>
  <div class="study-room">
    <!-- 自习室头部 -->
    <section class="team-header">
      <div class="container">
        <div class="team-info">
          <div class="team-avatar" @click="uploadTeamAvatar">
            <img v-if="roomData.avatarUrl" :src="roomData.avatarUrl" alt="自习室头像" />
            <div v-else class="default-avatar">
              <div class="avatar-member member-1">📚</div>
            </div>
            <div class="upload-overlay" v-if="isAdmin">
              <span class="icon">📷</span>
              <span>上传头像</span>
            </div>
          </div>
          <input type="file" ref="avatarInput" @change="handleAvatarUpload" accept="image/*" style="display: none;" />
          <div class="team-details">
            <h1>
              <span class="icon">📚</span>
              {{ roomData.name || '加载中...' }}
              <span v-if="!isJoined" class="not-joined-badge">
                <span class="icon">👀</span>
                浏览中
              </span>
            </h1>
            <p class="team-description">{{ roomData.description || '正在加载自习室信息...' }}</p>
            <div class="team-tags">
              <span v-for="tag in roomData.tags" :key="tag" class="tag">{{ tag }}</span>
            </div>
            <!-- 自习室统计数据部分 -->
            <div class="team-stats">
              <div class="team-stat">
                <div class="stat-value">{{ roomData.totalMembers || 0 }}</div>
                <div class="stat-label">成员人数</div>
              </div>
              <div class="team-stat">
                <div class="stat-value">{{ roomStats.averageCompletionRate || 0 }}%</div>
                <div class="stat-label">任务完成率</div>
              </div>
              <div class="team-stat">
                <div class="stat-value">{{ roomStats.totalCompletedTasks || 0 }}</div>
                <div class="stat-label">任务完成量</div>
              </div>
            </div>
          </div>
          <div class="team-actions" v-if="isJoined">
            <button class="btn btn-danger" @click="joinRoom">
              <span class="icon">👤➖</span>
              离开自习室
            </button>
          </div>
          <div class="team-actions" v-else>
            <button class="btn btn-primary" @click="joinRoom">
              <span class="icon">👤➕</span>
              加入自习室
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- 主要内容 -->
    <div class="container">
      <div class="content-grid">
        <!-- 左侧内容 -->
        <div class="main-content">
          <!-- 成员列表 -->
          <div class="content-section">
            <h2 class="section-title">
              <span class="icon">👥</span>
              成员列表 ({{ roomMembers.length }})
            </h2>
            <div class="members-avatar-list" v-if="roomMembers.length">
              <div 
                v-for="member in roomMembers" 
                :key="member.id" 
                class="member-avatar-item"
                :class="{ 'current-user': member.user_id === currentUserId }"
              >
                <div class="member-avatar-circle">
                  {{ member.name.charAt(0) }}
                  <div v-if="member.user_id === roomData.creatorId" class="admin-tag">
                    👑 管理员
                  </div>
                </div>
                <div class="member-name">{{ member.name }}</div>
              </div>
            </div>
            <div v-else class="empty-placeholder">
              <span class="icon">👤❌</span>
              暂无成员
            </div>
          </div>

          <!-- 修改学习记录 -->
          <div class="content-section learning-record" :class="{ 'has-modal': showEditTaskModal }">
            <h2 class="section-title">
              <span class="icon">📊</span>
              学习记录
              <span v-if="!isJoined" class="not-joined-badge">
                <span class="icon">🔒</span>
                未加入
              </span>
            </h2>

            <!-- 任务统计卡片 -->
            <div class="task-summary-cards" v-if="taskStatistics">
              <div class="summary-card">
                <div class="summary-icon completed">
                  <span class="icon">✅</span>
                </div>
                <div class="summary-content">
                  <div class="summary-value">{{ taskStatistics.completed_tasks || 0 }}</div>
                  <div class="summary-label">已完成</div>
                </div>
              </div>
              <div class="summary-card">
                <div class="summary-icon pending">
                  <span class="icon">⏳</span>
                </div>
                <div class="summary-content">
                  <div class="summary-value">{{ taskStatistics.pending_tasks || 0 }}</div>
                  <div class="summary-label">待完成</div>
                </div>
              </div>
              <div class="summary-card">
                <div class="summary-icon total">
                  <span class="icon">📋</span>
                </div>
                <div class="summary-content">
                  <div class="summary-value">{{ taskStatistics.total_tasks || 0 }}</div>
                  <div class="summary-label">总任务</div>
                </div>
              </div>
              <div class="summary-card">
                <div class="summary-icon rate">
                  <span class="icon">📈</span>
                </div>
                <div class="summary-content">
                  <div class="summary-value">{{ taskStatistics.completion_rate || 0 }}%</div>
                  <div class="summary-label">完成率</div>
                </div>
              </div>
            </div>
            
            <!-- 如果用户已加入，显示学习和任务模块 -->
            <div v-if="isJoined">
              <!-- 添加左右并排布局容器 -->
              <div class="learning-record-grid">
                <!-- 修改任务清单 -->
                <div class="task-section">
                  <div class="task-section-header">
                    <h3><span class="icon">📝</span> 任务清单</h3>
                    <button class="add-task-btn" @click="openEditTaskModal">
                      <span class="icon">✏️</span>
                      编辑任务
                    </button>
                  </div>
                  <!-- 任务列表 -->
                  <div class="task-list">
                    <div v-for="task in displayedTasks" :key="task.id" 
     :class="['task-item', { 'task-completed': task.is_completed === 1 }]">
                      <div class="task-checkbox" 
                          v-if="isJoined"
                          @click="toggleTaskCompletion(task)"
                          :class="{ 'checked': task.is_completed === 1 }">
                        <span v-if="task.is_completed === 1">✓</span>
                      </div>
                      <div class="task-info">
                        <div class="task-title" :class="{ 'completed': task.is_completed === 1 }">
                          {{ task.title || '未命名任务' }}
                          <span v-if="task.priority === 'high'" class="priority-badge high">高</span>
                          <span v-else-if="task.priority === 'medium'" class="priority-badge medium">中</span>
                          <span v-else-if="task.priority === 'low'" class="priority-badge low">低</span>
                        </div>
                        <div v-if="task.description" class="task-description">
                          {{ task.description }}
                        </div>
                        <div v-if="task.completion_time" class="completion-time-simple">
                          <span class="icon">⏰</span>
                          {{ task.completion_time }}分钟
                        </div>
                      </div>
                      <button v-if="isJoined && task.is_completed !== 1" 
                              class="quick-complete-btn" @click="quickCompleteTask(task.id)">
                        <span class="icon">⚡</span>
                        快速完成
                      </button>
                    </div>
                    <div v-if="!filteredTasks.length" class="no-tasks">
                      <span class="icon">📭</span>
                      <p>暂无任务</p>
                    </div>
                  </div>
                  
                  <!-- 查看所有任务按钮 -->
                  <div v-if="filteredTasks.length > 3 && !showAllTasks" class="view-more-tasks">
                    <button class="view-all-btn" @click="showAllTasks = true">
                      <i class="fas fa-chevron-down"></i>
                      查看所有任务 (共{{ filteredTasks.length }}个)
                    </button>
                  </div>
                  
                  <div v-if="showAllTasks && filteredTasks.length > 3" class="collapse-tasks">
                    <button class="collapse-btn" @click="showAllTasks = false">
                      <i class="fas fa-chevron-up"></i>
                      收起任务
                    </button>
                  </div>
                </div>

                <!-- 学习进度图表 -->
                <div class="learning-progress">
                  <h3><span class="icon">📊</span> 学习进度统计</h3>
                  <div class="progress-chart-container" style="height: 250px; margin-bottom: 15px;">
                    <div ref="pieChart" style="width: 100%; height: 100%;"></div>
                  </div>
                  
                  <!-- 任务进度条 -->
                  <div class="task-progress-section">
                    <div class="progress-header">
                      <span class="progress-title">
                        <span class="icon">📊</span>
                        任务完成进度
                      </span>
                      <span class="progress-percentage">{{ taskProgressPercentage }}%</span>
                    </div>
                    <div class="progress-bar-container">
                      <div class="progress-bar" :style="{ 
                          width: `${taskProgressPercentage}%`,
                          background: 'linear-gradient(90deg, #1a73e8, #34a853)'
                      }"></div>
                    </div>
                    <div class="progress-stats">
                      <span class="progress-stat">
                        <span class="icon">✅</span>
                        已完成: {{ completedTaskCount }}
                      </span>
                      <span class="progress-stat">
                        <span class="icon">⏳</span>
                        待完成: {{ pendingTaskCount }}
                      </span>
                      <span class="progress-stat">
                        <span class="icon">📋</span>
                        总计: {{ totalTaskCount }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 如果用户未加入，显示未加入信息 -->
            <div v-else class="not-joined-message">
              <div class="not-joined-icon">
                <i class="fas fa-lock"></i>
              </div>
              <p class="not-joined-text">未加入该自习室，无法查看任务和学习数据</p>
              <button class="btn btn-primary" @click="joinRoom">
                <i class="fas fa-sign-in-alt"></i>
                立即加入
              </button>
            </div>
          </div>
        </div>

        <!-- 右侧边栏 -->
        <div class="sidebar">
          <!-- 自习室规则 -->
          <div class="content-section">
            <div class="rules-header">
              <h3 class="section-title">
                <span class="icon">📜</span>
                自习室规则
              </h3>
              <button
                v-if="isAdmin"
                class="edit-rules-btn"
                @click="openRuleModal"
              >
                <span class="icon">✏️</span>
                编辑规则
              </button>
            </div>
            <div class="rules-list" v-if="roomData.rules && roomData.rules.length">
              <div class="rule-item" v-for="(rule, index) in roomData.rules" :key="index">
                <span class="icon">✅</span>
                {{ rule }}
              </div>
            </div>
            <div v-else class="empty-placeholder">
              <span class="icon">📄</span>
              暂无规则说明
            </div>
          </div>

          <!-- 学习排行 -->
          <div class="content-section">
            <h3 class="section-title">
              <span class="icon">🏆</span>
              学习排行
            </h3>
            <div class="leaderboard" v-if="leaderboard.length">
              <div v-for="(user, index) in leaderboard" :key="user.id" 
                  :class="['leaderboard-item', `rank-${index + 1}`]">
                <div class="rank">{{ index + 1 }}</div>
                <div class="user-info">
                  <div :class="['user-avatar', { 'top-3': index < 3 }]">
                    {{ user.name.charAt(0) }}
                    <div v-if="index < 3" class="rank-crown">
                      {{ index === 0 ? '👑' : index === 1 ? '🥈' : '🥉' }}
                    </div>
                  </div>
                  <div class="user-details">
                    <div class="user-name">{{ user.name }}</div>
                    <div class="user-score">
                      <span class="icon">⭐</span>
                      {{ user.completionRate || 0 }}%
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="empty-placeholder">
            <span class="icon">🏆</span>
            暂无学习数据
          </div>
          </div>
        </div>
      </div>
      
    <!-- 留言区 -->
    <div class="board-wrapper">
      <div class="board-card">
        <div class="board-header">
          <div class="board-title">
            <span class="icon">💬</span>
            <span>留言区</span>
            <span v-if="!isJoined" class="view-only-badge-small">
              <span class="icon">👀</span>
              仅查看
            </span>
          </div>
        </div>

        <div class="board-form" v-if="isJoined">
          <textarea class="board-input" v-model="newComment" placeholder="分享你的想法或学习心得..." rows="3" @keyup.enter.ctrl="submitComment"></textarea>
          <div class="board-form-footer">
            <span class="board-tip">
              <span class="icon">⌨️</span>
              Ctrl + Enter 快速发送
            </span>
            <button class="board-submit" @click="submitComment" :disabled="!newComment.trim()">
              <span class="icon">✉️</span>
              发表
            </button>
          </div>
        </div>
        <div class="board-not-joined" v-else>
          <span class="icon">🔒</span>
          <p>加入自习室后即可参与留言讨论</p>
        </div>

        <div class="board-list" v-if="comments.length > 0">
          <div class="board-item">
            <div v-for="comment in displayedComments" :key="comment.id" class="board-entry">
              <div class="board-item-header">
                <div :class="['board-avatar', { partner: comment.userId !== currentUserId }]">
                  {{ (comment.userName || '?').charAt(0) }}
                </div>
                <div class="board-meta">
                  <div class="board-name-line">
                    <span class="board-name">{{ comment.userName || '未知用户' }}</span>
                    <span class="board-badge" v-if="comment.userId === currentUserId">
                      <span class="icon">👤</span>
                      我
                    </span>
                  </div>
                  <span class="board-time">{{ formatTime(comment.createdTime) }}</span>
                </div>
              </div>
              <p class="board-content">{{ comment.content }}</p>
            </div>
          </div>

          <button class="board-more" v-if="comments.length > commentLimit" @click="expandComments">
            <span class="icon">⬇️</span>
            展开更多留言
          </button>
        </div>

        <div class="board-empty" v-else>
          <span class="icon">💬</span>
          <p>还没有留言，{{ isJoined ? '快来发表第一条吧！' : '加入自习室后即可参与讨论' }}</p>
        </div>
      </div>
    </div>
    </div>

    <!-- 编辑规则模态框 -->
    <div class="modal" v-if="showRuleModal" @click.self="closeRuleModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">编辑自习室规则</h3>
          <button class="close-btn" @click="closeRuleModal">&times;</button>
        </div>
        <div class="task-form">
          <div class="form-group">
            <label class="form-label">规则列表（每行一条）</label>
            <textarea
              class="form-input"
              rows="6"
              v-model="editRulesText"
              placeholder="例如：\n1. 保持安静，专心学习\n2. 互相尊重，友善交流"
            ></textarea>
          </div>
          <div class="form-actions">
            <button class="submit-btn" @click="saveRules">保存</button>
            <button class="cancel-btn" @click="closeRuleModal">取消</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 编辑任务模态框 -->
    <div class="modal" v-if="showEditTaskModal" @click.self="closeEditTaskModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">
            <i class="fas fa-edit"></i>
            编辑任务
          </h3>
          <button class="close-btn" @click="closeEditTaskModal">&times;</button>
        </div>
        
        <!-- 上半部分：添加任务 -->
        <div class="modal-section">
          <h4 class="section-subtitle">
            <i class="fas fa-plus"></i>
            添加新任务
          </h4>
          <div class="add-task-form">
            <div class="form-group">
              <label class="form-label">
                <i class="fas fa-pen"></i>
                任务标题
              </label>
              <input class="form-input" v-model="newTask.title" placeholder="请输入任务标题" />
            </div>
            <div class="form-group">
              <label class="form-label">
                <i class="fas fa-file-alt"></i>
                任务描述
              </label>
              <textarea class="form-textarea" v-model="newTask.description" placeholder="补充任务说明"></textarea>
            </div>
            <!-- 监督对象固定为"我自己"，不可修改 -->
            <div class="form-group">
              <label class="form-label">
                <i class="fas fa-user"></i>
                监督对象
              </label>
              <input 
                class="form-input" 
                :value="'我自己'" 
                disabled 
                style="background-color: #f5f5f5; color: #666;"
              />
            </div>
            <button class="submit-btn" @click="submitNewTask">
              <i class="fas fa-save"></i>
              保存任务
            </button>
          </div>
        </div>
        
        <!-- 分割线 -->
        <div class="modal-divider"></div>
        
        <!-- 下半部分：当前用户的所有任务 -->
        <div class="modal-section">
          <h4 class="section-subtitle">
            <i class="fas fa-tasks"></i>
            我的任务管理 ({{ myTasks.length }}个)
          </h4>
          <div class="task-management-list">
            <div v-for="task in myTasks" :key="task.id" class="task-management-item">
              <div class="task-management-info">
                <div class="task-management-title">{{ task.title || '未命名任务' }}</div>
                <div v-if="task.description" class="task-management-description">
                  {{ task.description }}
                </div>
                <div class="task-management-status">
                  <span class="status-badge" :class="{ 'completed': task.status === 'completed' || task.completed_time }">
                    {{ (task.status === 'completed' || task.completed_time) ? '已完成' : '未完成' }}
                  </span>
                  <span v-if="task.completion_time" class="task-time">
                    <i class="fas fa-clock"></i>
                    {{ task.completion_time }}分钟
                  </span>
                </div>
              </div>
              <div class="task-management-actions">
                <!-- 重置按钮 -->
                <button 
                  v-if="task.status === 'completed' || task.completed_time" 
                  class="action-btn reset-btn"
                  @click="resetTask(task.id)"
                  title="重置任务状态"
                >
                  <i class="fas fa-redo"></i>
                  重置
                </button>
                <!-- 删除按钮 -->
                <button 
                  class="action-btn delete-btn"
                  @click="deleteTask(task.id)"
                  title="删除任务"
                >
                  <i class="fas fa-trash"></i>
                  删除
                </button>
              </div>
            </div>
            <div v-if="!myTasks.length" class="no-tasks-management">
              <i class="fas fa-inbox"></i>
              <p>暂无任务</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast 通知 -->
    <div v-if="showToast" :class="['toast', `toast-${toastType}`]">
      <i :class="getToastIcon(toastType)"></i>
      {{ toastMessage }}
    </div>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import {
  getRoomDetail,
  getRoomMembers,
  getRoomStats,
  getRoomTasks,
  getRoomLeaderboard,
  joinRoom as joinRoomApi,
  leaveRoom as leaveRoomApi,
  getRoomMessages,
  createRoomMessage,
  getUserStudyTasks,
  updateStudyTaskStatus,
  getStudyStats,
  getTaskHistory,
  createStudyTask,
  setRoomAdmin,
  updateRoomRules,
  uploadRoomAvatar,
  getRoomTaskStatistics,
  updateTaskCompletionTime,
  quickCompleteTask,
  updateTaskCompletionStatus,
  deleteStudyTask
} from '@/api/rooms'
import { useUserStore } from '@/stores/user'

export default {
  name: 'StudyRoom',
  setup() {
    const userStore = useUserStore()
    return { userStore }
  },
  data() {
    return {
      isJoined: false,
      roomData: {
        name: '',
        description: '',
        tags: [],
        onlineCount: 0,
        totalMembers: 0,
        totalStudyHours: 0,
        completedTasks: 0,
        rules: [],
        scheduleTime: '',
        avatarUrl: '',
        creatorId: null,
        isAdmin: false
      },
      roomStats: {
      averageCompletionRate: 0,  // 平均完成率
      totalCompletedTasks: 0      // 总完成任务量
    },
      roomMembers: [],
      todayTasks: [],
      filteredTasks: [],
      todayStudyTime: 0,
      weekStudyTime: 0,
      leaderboard: [],
      comments: [],
      commentLimit: 2,
      newComment: '',
      showEditTaskModal: false,
      newTask: {
        title: '',
        description: ''
      },
      myTasks: [],
      showRuleModal: false,
      editRulesText: '',
      toastMessage: '',
      toastType: '',
      showToast: false,
      taskStatistics: null,
      pieChart: null,
      showAllTasks: false
    }
  },
  async mounted() {
    await this.loadRoomData()
    if (this.isJoined) {
      await this.loadTaskStatistics()
    }
  },
  computed: {
    currentUserId() {
        return this.userStore.userId || this.getStoredUserId()
    },
    currentUserName() {
        return this.userStore.userName || this.getStoredUserName()
    },
    isOwner() {
        return this.currentUserId && this.roomData.creatorId === this.currentUserId
    },
    isAdmin() {
        // 房主天然是管理员
        if (this.isOwner) return true
        return !!this.roomData.isAdmin
    },
    filteredLeaderboard() {
        return (this.leaderboard || []).filter(u => Number(u.totalStudyTime || 0) > 0)
    },
    displayedComments() {
        if (this.comments.length <= this.commentLimit) return this.comments
        return this.comments.slice(0, this.commentLimit)
    },
    displayedTasks() {
        if (this.showAllTasks) {
            return this.filteredTasks
        } else {
            return this.filteredTasks.slice(0, 3)
        }
    },
    // 任务进度相关计算 - 统一使用roomData.completedTasks
    completedTaskCount() {
        // 优先使用roomData.completedTasks，如果没有则使用当前用户的任务完成数
        if (this.roomData.completedTasks !== undefined) {
            return this.roomData.completedTasks;
        }
        return this.filteredTasks.filter(task => task.status === 'completed' || task.completed_time).length;
    },
    totalTaskCount() {
        // 如果有任务统计数据，使用统计数据的总任务数
        if (this.taskStatistics && this.taskStatistics.total_tasks) {
            return this.taskStatistics.total_tasks;
        }
        return this.filteredTasks.length;
    },
    pendingTaskCount() {
        return this.totalTaskCount - this.completedTaskCount;
    },
    taskProgressPercentage() {
        // 如果有任务统计数据，使用统计数据的完成率
        if (this.taskStatistics && this.taskStatistics.completion_rate !== undefined) {
            return this.taskStatistics.completion_rate;
        }
        return this.totalTaskCount > 0 ? Math.round((this.completedTaskCount / this.totalTaskCount) * 100) : 0;
    },
    // 添加自习室总任务完成率计算
    roomCompletionRate() {
        return this.taskProgressPercentage;
    }
},
  methods: {
    parseTags(rawTags) {
      if (!rawTags) return []
      if (Array.isArray(rawTags)) return rawTags
      if (typeof rawTags === 'string') {
        try {
          const parsed = JSON.parse(rawTags)
          return Array.isArray(parsed) ? parsed : rawTags.split(/[，,]/).map(tag => tag.trim()).filter(Boolean)
        } catch (error) {
          return rawTags.split(/[，,]/).map(tag => tag.trim()).filter(Boolean)
        }
      }
      return []
    },

    // 获取所有成员的任务统计数据
async loadAllMembersTaskStats() {
  try {
    const roomId = this.$route.params.roomId
    
    // 首先获取所有成员
    const membersResponse = await getRoomMembers(roomId)
    if (!membersResponse.success) return
    
    const members = membersResponse.data
    if (!members || members.length === 0) {
      this.roomStats = {
        averageCompletionRate: 0,
        totalCompletedTasks: 0
      }
      return
    }
    
    // 获取每个成员的任务统计
    let totalCompletionRate = 0
    let totalCompletedTasks = 0
    let validMembersCount = 0
    
    // 为每个成员获取任务统计
    for (const member of members) {
      if (member.user_id) {
        try {
          const statsResponse = await getRoomTaskStatistics(roomId, member.user_id)
          if (statsResponse && statsResponse.success) {
            const stats = statsResponse.data
            // 累加完成率
            if (stats.completion_rate !== undefined) {
              totalCompletionRate += stats.completion_rate
              validMembersCount++
            }
            // 累加已完成任务数
            if (stats.completed_tasks !== undefined) {
              totalCompletedTasks += stats.completed_tasks
            }
          }
        } catch (error) {
          console.warn(`获取成员 ${member.user_name} 的任务统计失败:`, error)
        }
      }
    }
    
    // 计算平均值
    const averageCompletionRate = validMembersCount > 0 
      ? Math.round(totalCompletionRate / validMembersCount) 
      : 0
    
    this.roomStats = {
      averageCompletionRate,
      totalCompletedTasks
    }
    
  } catch (error) {
    console.error('加载所有成员任务统计失败:', error)
    this.roomStats = {
      averageCompletionRate: 0,
      totalCompletedTasks: 0
    }
  }
},

    async loadRoomData() {
  try {
    const roomId = this.$route.params.roomId
    const userId = this.currentUserId
    
    // 加载自习室基本信息
    const roomResponse = await getRoomDetail(roomId, userId)
    if (roomResponse.success) {
      const data = roomResponse.data
      this.roomData = {
        name: data.room_name,
        description: data.description,
        tags: this.parseTags(data.tags),
        onlineCount: data.online_count || 0,
        maxMembers: data.max_participants,
        creatorName: data.creator_name,
        totalMembers: data.current_participants || data.current_members || 0,
        totalStudyHours: data.total_study_hours || 0,
        completedTasks: data.completed_tasks || 0,
        rules: this.parseRules(data.rules),
        scheduleTime: data.schedule_time || '',
        avatarUrl: data.avatar_url || '',
        creatorId: data.creator_id || null,
        isAdmin: data.is_admin || false
      }
      // 检查用户是否已加入自习室
      this.checkUserJoinStatus()
    }

    // 加载所有成员
    const membersResponse = await getRoomMembers(roomId)
    if (membersResponse.success) {
      this.roomMembers = membersResponse.data.map(member => ({
        id: member.member_id,
        name: member.user_name,
        avatar: member.avatar_url,
        user_id: member.user_id
      }))
      // 重新检查用户加入状态
      this.checkUserJoinStatus()
      
      // 加载所有成员的任务统计数据
      await this.loadAllMembersTaskStats()
    }

    // 如果用户已加入，加载今日任务
    if (this.isJoined && userId) {
      const tasksResponse = await getUserStudyTasks(roomId, userId, 'all')
      if (tasksResponse.success) {
        this.todayTasks = tasksResponse.data.map(task => ({
          id: task.task_id,
          title: task.title,
          is_completed: task.is_completed || 0,
          category: task.category || '学习任务',
          estimated_hours: task.estimated_hours || 1,
          completed_time: task.completed_time,
          completion_time: task.completion_time,
          description: task.description || ''
        }))
        this.filteredTasks = [...this.todayTasks]
      }
    } else if (!this.isJoined) {
      console.log('用户未加入自习室，不加载个人任务')
    }

    // 加载学习时长统计
    if (userId) {
      const statsResponse = await getStudyStats(roomId, userId)
      if (statsResponse.success) {
        this.todayStudyTime = statsResponse.data.todayStudyTime || 0
        this.weekStudyTime = statsResponse.data.weekStudyTime || 0
        // 更新自习室的任务完成数（个人）
        this.roomData.completedTasks = statsResponse.data.completedTasks || 0
        this.roomData.totalStudyHours = statsResponse.data.totalStudyTime || 0
      }
    }

    // 加载学习排行榜（所有成员）
    const leaderboardResponse = await getRoomLeaderboard(roomId)
    if (leaderboardResponse.success) {
      this.leaderboard = leaderboardResponse.data.map(item => ({
        id: item.userId,
        name: item.name,
        totalStudyTime: item.totalStudyHours,
        completionRate: item.completion_rate || 0
      }))
    }

    // 加载留言（所有留言）
    const messagesResponse = await getRoomMessages(roomId)
    if (messagesResponse.success) {
      this.comments = messagesResponse.data.map(message => ({
        id: message.message_id,
        userId: message.user_id || message.sender_id,
        userName: message.user_name || '匿名同学',
        content: message.content,
        createdTime: message.create_time
      }))
    }
    
    // 加载任务统计数据（个人）
    if (this.isJoined && userId) {
      await this.loadTaskStatistics()
    }
    
  } catch (error) {
    console.error('加载自习室数据失败:', error)
    this.notify('error', '加载数据失败，请稍后重试')
  }
},

handleAvatarUpload(event) {
  this.onAvatarChange(event)
},

    // 加载任务统计数据（用于饼状图）
    async loadTaskStatistics() {
    try {
        const roomId = this.$route.params.roomId
        const userId = this.currentUserId
        
        if (!userId) return
        
        const response = await getRoomTaskStatistics(roomId, userId)
        if (response && response.success) {
            this.taskStatistics = response.data
            
            // 确保数据格式正确
            if (this.taskStatistics.total_completion_hours && typeof this.taskStatistics.total_completion_hours === 'string') {
                this.taskStatistics.total_completion_hours = parseFloat(this.taskStatistics.total_completion_hours)
            }
            
            // 更新自习室的任务完成数和完成率
            if (this.taskStatistics.completed_tasks !== undefined) {
                this.roomData.completedTasks = this.taskStatistics.completed_tasks;
            }
            
            // 初始化饼状图
            if (this.taskStatistics.pie_chart && this.taskStatistics.pie_chart.labels && this.taskStatistics.pie_chart.labels.length > 0) {
                this.$nextTick(() => {
                    this.initPieChart()
                })
            }
        } else {
            console.warn('获取任务统计数据失败:', response?.message)
            // 如果获取失败，使用默认值
            this.taskStatistics = {
                total_tasks: this.filteredTasks.length,
                completed_tasks: this.filteredTasks.filter(task => task.is_completed === 1 || task.completed_time).length,
                pending_tasks: this.filteredTasks.filter(task => !(task.is_completed === 1 || task.completed_time)).length,
                completion_rate: this.taskProgressPercentage || 0,
                total_completion_hours: 0,
                average_completion_minutes: 0,
                pie_chart: {
                    labels: [],
                    datasets: [{ data: [], backgroundColor: [] }]
                }
            }
        }
    } catch (error) {
        console.error('加载任务统计数据失败:', error)
        // 设置默认值以避免前端错误
        this.taskStatistics = {
            total_tasks: this.filteredTasks.length,
            completed_tasks: this.filteredTasks.filter(task => task.is_completed === 1 || task.completed_time).length,
            pending_tasks: this.filteredTasks.filter(task => !(task.is_completed === 1 || task.completed_time)).length,
            completion_rate: this.taskProgressPercentage || 0,
            total_completion_hours: 0,
            average_completion_minutes: 0,
            pie_chart: {
                labels: [],
                datasets: [{ data: [], backgroundColor: [] }]
            }
        }
    }
},



    // 初始化饼状图
    initPieChart() {
      if (!this.taskStatistics || !this.taskStatistics.pie_chart) return
      
      const chartDom = this.$refs.pieChart
      if (!chartDom) return
      
      // 销毁旧图表
      if (this.pieChart) {
        this.pieChart.dispose()
      }
      
      try {
        this.pieChart = echarts.init(chartDom)
        
        const pieData = this.taskStatistics.pie_chart.labels.map((label, index) => ({
          name: label,
          value: this.taskStatistics.pie_chart.datasets[0].data[index] || 0,
          itemStyle: {
            color: this.taskStatistics.pie_chart.datasets[0].backgroundColor[index] || this.getChartColor(index)
          }
        }))
        
        const option = {
          tooltip: {
            trigger: 'item',
            formatter: (params) => {
              const hours = (params.value / 60).toFixed(1)
              const percentage = params.percent
              return `${params.name}<br/>完成时间: ${params.value}分钟 (${hours}小时)<br/>占比: ${percentage}%`
            }
          },
          legend: {
            type: 'scroll',
            orient: 'horizontal',
            bottom: 10,
            left: 'center',
            textStyle: {
              fontSize: 10
            },
            itemWidth: 12,
            itemHeight: 12,
            pageTextStyle: {
              fontSize: 10
            },
            pageIconSize: 10
          },
          series: [
            {
              name: '任务完成时间',
              type: 'pie',
              radius: ['40%', '65%'],
              center: ['50%', '45%'],
              avoidLabelOverlap: false,
              itemStyle: {
                borderRadius: 8,
                borderColor: '#fff',
                borderWidth: 1
              },
              label: {
                show: false,
                position: 'center'
              },
              emphasis: {
                label: {
                  show: true,
                  fontSize: '14',
                  fontWeight: 'bold',
                  formatter: `{b}\n{c}分钟\n({d}%)`
                }
              },
              labelLine: {
                show: false
              },
              data: pieData
            }
          ]
        }
        
        this.pieChart.setOption(option)
        
        // 响应式调整
        window.addEventListener('resize', () => {
          if (this.pieChart) {
            this.pieChart.resize()
          }
        })
        
      } catch (error) {
        console.error('初始化饼状图失败:', error)
      }
    },

    // 获取图表颜色
    getChartColor(index) {
      const colors = [
        '#1a73e8', '#34a853', '#f9ab00', '#ea4335',
        '#8e44ad', '#1abc9c', '#e74c3c', '#2ecc71'
      ]
      return colors[index % colors.length]
    },

    checkUserJoinStatus() {
      // 检查当前用户是否在成员列表中
      this.isJoined = this.roomMembers.some(member => 
        member.id === this.currentUserId || member.user_id === this.currentUserId
      )
    },

    async loadStudyStats() {
      try {
        const roomId = this.$route.params.roomId
        const statsResponse = await getStudyStats(roomId, this.currentUserId)
        if (statsResponse.success) {
          this.todayStudyTime = statsResponse.data.todayStudyTime || 0
          this.weekStudyTime = statsResponse.data.weekStudyTime || 0
          this.roomData.completedTasks = statsResponse.data.completedTasks || 0
          this.roomData.totalStudyHours = statsResponse.data.totalStudyTime || 0
        }
      } catch (error) {
        console.error('加载学习统计失败:', error)
      }
    },

    // 切换任务完成状态（包含时间输入）
async toggleTaskCompletion(task) {
  if (!this.isJoined) {
    this.notify('warning', '请先加入自习室以操作任务')
    return
  }
  
  const newStatus = task.is_completed === 1 ? 0 : 1;
  
  // 如果是标记为已完成
  if (newStatus === 1) {
    if (task.completion_time && task.completion_time > 0) {
      await this.updateTaskStatusDirect(task.id, newStatus, task.completion_time);
    } else {
      const completionTime = prompt('请输入任务完成时间（分钟）:', '30');
      if (!completionTime || isNaN(completionTime) || completionTime <= 0) {
        this.notify('error', '请输入有效的完成时间');
        return;
      }
      await this.updateTaskStatusDirect(task.id, newStatus, parseInt(completionTime));
    }
  } else {
    await this.updateTaskStatusDirect(task.id, newStatus, null);
  }
},

// 直接更新任务状态
async updateTaskStatusDirect(taskId, isCompleted, completionTime) {
  try {
    const response = await updateTaskCompletionStatus(taskId, {
      user_id: this.currentUserId,
      is_completed: isCompleted,
      completion_time: completionTime
    });
    
    if (response && response.success) {
      // 更新本地任务状态
      const taskToUpdate = this.filteredTasks.find(t => t.id === taskId)
      
      if (taskToUpdate) {
        taskToUpdate.is_completed = isCompleted;
        if (isCompleted === 1 && completionTime) {
          taskToUpdate.completion_time = completionTime;
          taskToUpdate.completed_at = new Date().toISOString();
        } else if (isCompleted === 0) {
          taskToUpdate.completion_time = null;
          taskToUpdate.completed_at = null;
        }
      }
      
      this.notify('success', isCompleted ? '任务已完成' : '任务已标记为未完成');
      
      // 重新计算统计
      await this.loadTaskStatistics();
    } else {
      this.notify('error', response?.message || '操作失败');
    }
  } catch (error) {
    console.error('更新任务状态失败:', error);
    this.notify('error', error?.response?.data?.message || '操作失败');
  }
},

// 快速完成任务（默认30分钟）
async quickCompleteTask(taskId) {
  if (!this.isJoined) {
    this.notify('warning', '请先加入自习室以操作任务')
    return
  }
  
  try {
    const response = await quickCompleteTask(taskId, {
      user_id: this.currentUserId
    })
    
    if (response && response.success) {
      // 更新本地任务状态
      const task = this.filteredTasks.find(t => t.id === taskId)
      if (task) {
        task.is_completed = 1
        task.completion_time = 30
        task.completed_at = new Date().toISOString()
      }
      
      this.notify('success', '任务已完成（默认30分钟）')
      
      // 重新计算统计
      await this.loadTaskStatistics()
    }
  } catch (error) {
    console.error('快速完成任务失败:', error)
    this.notify('error', error?.response?.data?.message || '操作失败')
  }
},
    
    // 在 toggleTask 方法中添加
async toggleTask(taskId) {
  if (!this.isJoined) {
    this.notify('warning', '请先加入自习室以操作任务')
    return
  }
  
  const target = this.filteredTasks.find(task => task.id === taskId)
  if (!target) return
  
  const isCompleted = target.is_completed === 1 ? 0 : 1
  
  try {
    const response = await updateTaskCompletionStatus(taskId, {
      user_id: this.currentUserId,
      is_completed: isCompleted
    })
    
    if (response && response.success) {
      target.is_completed = isCompleted
      if (isCompleted === 1) {
        target.completed_time = new Date().toISOString()
      } else {
        target.completed_time = null
        target.completion_time = null
      }
      
      this.notify('success', isCompleted === 1 ? '任务已完成' : '任务已重置')
      
      // 重新加载统计数据
      await this.loadTaskStatistics()
      await this.loadStudyStats()
      
      // 刷新所有成员的统计数据
      await this.loadAllMembersTaskStats()
      
      // 刷新排行榜数据
      await this.loadLeaderboard()
    } else {
      this.notify('error', response?.message || '更新任务状态失败')
    }
  } catch (error) {
    console.error('更新任务状态失败:', error)
    this.notify('error', '更新任务状态失败')
  }
},

// 新增加载排行榜方法
async loadLeaderboard() {
    try {
        const roomId = this.$route.params.roomId
        const leaderboardResponse = await getRoomLeaderboard(roomId)
        if (leaderboardResponse.success) {
            this.leaderboard = leaderboardResponse.data.map(item => ({
                id: item.userId,
                name: item.name,
                totalStudyTime: item.totalStudyHours,
                completionRate: item.completion_rate || 0
            }))
        }
    } catch (error) {
        console.error('加载排行榜失败:', error)
    }
},

    // 快速完成任务
    async quickCompleteTask(taskId) {
  if (!this.isJoined) {
    this.notify('warning', '请先加入自习室以操作任务')
    return
  }
  
  try {
    const response = await quickCompleteTask(taskId, {
      user_id: this.currentUserId
    })
    
    if (response && response.success) {
      // 更新本地任务状态
      const task = this.filteredTasks.find(t => t.id === taskId)
      if (task) {
        task.is_completed = 1 // 修改这里
        task.completed_time = new Date().toISOString()
        task.completion_time = 30
      }
      
      this.notify('success', '任务已完成（默认30分钟）')
      
      // 重新加载统计数据
      await this.loadTaskStatistics()
      await this.loadStudyStats()
    }
  } catch (error) {
    console.error('快速完成任务失败:', error)
    this.notify('error', error?.response?.data?.message || '操作失败')
  }
},

    openRuleModal() {
      this.editRulesText = (this.roomData.rules || []).join('\n')
      this.showRuleModal = true
    },

    closeRuleModal() {
      this.showRuleModal = false
    },

    async saveRules() {
      if (!this.isAdmin) {
        this.notify('error', '只有管理员可以编辑规则')
        return
      }

      const roomId = this.$route.params.roomId
      const rawText = (this.editRulesText || '').trim()
      const rulesArray = rawText
        .split(/\r?\n/)
        .map(line => line.replace(/^\d+[\.、]\s*/, '').trim())
        .filter(Boolean)

      try {
        const response = await updateRoomRules(roomId, {
          user_id: this.currentUserId,
          rules: rulesArray
        })

        if (response && response.success) {
          this.notify('success', '规则更新成功')
          this.showRuleModal = false
          await this.loadRoomData()
        } else {
          this.notify('error', response?.message || '规则更新失败')
        }
      } catch (error) {
        console.error('更新自习室规则失败:', error)
        this.notify('error', error?.response?.data?.message || '规则更新失败，请稍后重试')
      }
    },

    async submitComment() {
      const content = this.newComment.trim()
      if (!content) return
      if (!this.isJoined) {
        this.notify('error', '请先加入自习室再留言')
        return
      }
      try {
        const roomId = this.$route.params.roomId
        const response = await createRoomMessage(roomId, {
          user_id: this.currentUserId,
          content
        })
        if (response && response.success) {
          const saved = response.data || {}
          this.comments.unshift({
            id: saved.message_id || Date.now(),
            userId: this.currentUserId,
            userName: saved.user_name || this.currentUserName || '我',
            content,
            createdTime: saved.create_time || new Date().toISOString()
          })
          this.newComment = ''
          this.notify('success', '留言已发送')
        } else {
          this.notify('error', response?.message || '发送失败，请稍后重试')
        }
      } catch (error) {
        console.error('发送留言失败:', error)
        this.notify('error', error?.response?.data?.message || '发送失败，请稍后重试')
      }
    },

    expandComments() {
      this.commentLimit = Math.min(this.commentLimit + 5, this.comments.length)
    },

    formatTime(timestamp) {
      if (!timestamp) return ''
      const now = new Date()
      const time = new Date(timestamp)
      const diff = now - time
      const minutes = Math.floor(diff / 60000)
      const hours = Math.floor(diff / 3600000)
      const days = Math.floor(diff / 86400000)
      if (minutes < 60) return `${minutes}分钟前`
      if (hours < 24) return `${hours}小时前`
      if (days === 1) return '昨天'
      return time.toLocaleDateString()
    },

    async onAvatarChange(event) {
      const files = event.target.files
      if (!files || !files.length) return
      const file = files[0]
      const roomId = this.$route.params.roomId

      try {
        const response = await uploadRoomAvatar(roomId, file, this.currentUserId)
        if (response && response.success) {
          this.notify('success', '自习室头像更新成功')
          await this.loadRoomData()
        } else {
          this.notify('error', response?.message || '头像更新失败')
        }
      } catch (error) {
        console.error('更新自习室头像失败:', error)
        this.notify('error', error?.response?.data?.message || '头像更新失败，请稍后重试')
      } finally {
        event.target.value = ''
      }
    },

    getStoredUserInfo() {
      try {
        const userInfoStr = localStorage.getItem('userInfo')
        if (userInfoStr) {
          const info = JSON.parse(userInfoStr)
          return {
            userId: info.user_id || info.userId || info.id || null,
            userName: info.user_name || info.userName || info.name || null
          }
        }
      } catch (error) {
        console.warn('解析本地用户信息失败:', error)
      }

      const token = localStorage.getItem('token')
      if (token) {
        try {
          const base64Url = token.split('.')[1]
          const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
          const payload = JSON.parse(window.atob(base64))
          return {
            userId: payload.userId || payload.id || null,
            userName: payload.userName || payload.username || null
          }
        } catch (error) {
          console.warn('解析token失败:', error)
        }
      }

      return { userId: null, userName: null }
    },

    getStoredUserId() {
      const info = this.getStoredUserInfo()
      return info.userId
    },

    getStoredUserName() {
      const info = this.getStoredUserInfo()
      return info.userName
    },

    notify(type, message) {
      this.toastType = type
      this.toastMessage = message
      this.showToast = true

      // 3秒后自动隐藏
      setTimeout(() => {
        this.showToast = false
      }, 3000)
      
      // 控制台输出
      if (type === 'success') {
        console.log('✅', message)
      } else if (type === 'error') {
        console.error('❌', message)
      } else {
        console.log('ℹ️', message)
      }
    },

    parseRules(rawRules) {
      if (!rawRules) return []
      if (Array.isArray(rawRules)) return rawRules
      if (typeof rawRules === 'string') {
        try {
          const parsed = JSON.parse(rawRules)
          if (Array.isArray(parsed)) {
            return parsed.filter(Boolean)
          }
        } catch (error) {
          // ignore json parse error
        }
        return rawRules
          .split(/[\n\r]+/)
          .map(item => item.replace(/^\d+[\.、]\s*/, '').trim())
          .filter(Boolean)
      }
      return []
    },

    getToastIcon(type) {
      const iconMap = {
        success: 'fas fa-check-circle',
        error: 'fas fa-exclamation-circle',
        info: 'fas fa-info-circle'
      }
      return iconMap[type] || 'fas fa-info-circle'
    },

    // 编辑任务相关方法
    async openEditTaskModal() {
      if (!this.isJoined) {
        this.notify('warning', '请先加入自习室以编辑任务')
        return
      }
      // 加载当前用户的任务
      this.loadMyTasks()
      this.showEditTaskModal = true
    },
    
    closeEditTaskModal() {
      this.showEditTaskModal = false
      this.resetNewTask()
    },
    
    loadMyTasks() {
      this.myTasks = this.filteredTasks
    },
    
    async resetTask(taskId) {
      try {
        const response = await updateTaskCompletionStatus(taskId, {
          user_id: this.currentUserId,
          is_completed: 0,
          completion_time: null
        })
        
        if (response && response.success) {
          // 更新本地任务状态
          const task = this.myTasks.find(t => t.id === taskId)
          if (task) {
            task.status = 'pending'
            task.completed_time = null
            task.completion_time = null
          }
          this.notify('success', '任务已重置为未完成')
          await this.loadTaskStatistics()
        }
      } catch (error) {
        console.error('重置任务失败:', error)
        this.notify('error', '操作失败')
      }
    },
    
    async deleteTask(taskId) {
      if (!confirm('确定要删除这个任务吗？此操作不可撤销。')) {
        return
      }
      
      try {
        const response = await deleteStudyTask(taskId, {
          user_id: this.currentUserId
        })
        
        if (response && response.success) {
          // 从本地列表中移除任务
          this.filteredTasks = this.filteredTasks.filter(task => task.id !== taskId)
          this.myTasks = this.myTasks.filter(task => task.id !== taskId)
          
          this.notify('success', '任务已删除')
          
          // 重新加载统计数据
          await this.loadTaskStatistics()
        } else {
          this.notify('error', response?.message || '删除失败')
        }
      } catch (error) {
        console.error('删除任务失败:', error)
        this.notify('error', error?.response?.data?.message || '删除失败')
      }
    },
    
    async submitNewTask() {
      if (!this.isJoined) {
        this.notify('warning', '请先加入自习室以创建任务')
        return
      }
      
      if (!this.newTask.title.trim()) {
        this.notify('error', '请填写任务标题')
        return
      }
      
      try {
        const roomId = this.$route.params.roomId
        const payload = {
          user_id: this.currentUserId,
          title: this.newTask.title.trim(),
          description: this.newTask.description.trim(),
          category: '学习任务',
          estimated_hours: 1
        }
        
        const response = await createStudyTask(roomId, payload)
        if (response && response.success) {
          this.notify('success', '任务创建成功')
          
          // 刷新任务列表
          await this.loadRoomData()
          
          // 加载当前用户的任务
          this.loadMyTasks()
          
          // 清空表单
          this.resetNewTask()
          
          // 重新加载统计数据
          await this.loadTaskStatistics()
        } else {
          this.notify('error', response?.message || '创建任务失败')
        }
      } catch (error) {
        console.error('创建任务失败:', error)
        this.notify('error', error?.response?.data?.message || '创建任务失败，请稍后重试')
      }
    },
    
    resetNewTask() {
      this.newTask = {
        title: '',
        description: ''
      }
    },

    async joinRoom() {
      try {
        const roomId = this.$route.params.roomId
        const action = this.isJoined ? leaveRoomApi : joinRoomApi
        const userId = this.currentUserId

        if (!userId) {
          this.notify('error', '请先登录后再操作自习室')
          return
        }

        const response = await action(roomId, userId)
        
        if (response && response.success) {
          this.isJoined = !this.isJoined
          this.notify('success', this.isJoined ? '成功加入自习室' : '已离开自习室')
          
          if (this.isJoined) {
            await this.loadRoomData()
            await this.loadTaskStatistics()
          } else {
            await this.loadRoomData()
            this.taskStatistics = null
            if (this.pieChart) {
              this.pieChart.dispose()
              this.pieChart = null
            }
          }
        } else {
          const errorMsg = response?.message || '操作失败'
          this.notify('error', errorMsg)
          console.error('自习室操作失败:', response)
        }
      } catch (error) {
        console.error('加入/离开自习室失败:', error)
        this.notify('error', error?.response?.data?.message || '操作失败，请稍后重试')
      }
    }
  },
  
  // 组件销毁时清理图表
  beforeDestroy() {
    if (this.pieChart) {
      this.pieChart.dispose()
    }
  }
}
</script>

<style scoped>
:root {
  --primary: #1a73e8;
  --primary-light: #e8f0fe;
  --secondary: #34a853;
  --warning: #f9ab00;
  --danger: #ea4335;
  --dark: #202124;
  --light: #f8f9fa;
  --gray: #5f6368;
  --border: #dadce0;
  --my-task-bg: #e8f0fe;
  --partner-task-bg: #e6f4ea;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
}

body {
  background-color: var(--light);
  color: var(--dark);
}

.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 20px;
}

/* 自习室头部 */
.room-header {
  background: linear-gradient(135deg, var(--primary), #6c8ef5);
  color: white;
  padding: 30px 0;
  margin-bottom: 30px;
}

.room-info {
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 40px;
  align-items: center;
}

.room-avatar {
  width: 100px;
  height: 100px;
  border-radius: 20px;
  background: rgba(255,255,255,0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
  backdrop-filter: blur(10px);
  box-shadow: 0 4px 20px rgba(0,0,0,0.1);
  position: relative;
  overflow: hidden;
}

.room-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 20px;
}

.avatar-upload-btn {
  position: absolute;
  right: 6px;
  bottom: 6px;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: rgba(0,0,0,0.4);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 0.8rem;
}

.room-details h1 {
  font-size: 1.8rem;
  margin-bottom: 8px;
}

.room-description {
  font-size: 1rem;
  opacity: 0.9;
  margin-bottom: 15px;
  line-height: 1.5;
}

.room-tags {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.room-tag {
  background: rgba(255,255,255,0.2);
  padding: 6px 12px;
  border-radius: 15px;
  font-size: 0.85rem;
}

/* 图标样式 */
.icon {
  display: inline-block;
  margin-right: 8px;
  font-size: 1.1em;
  vertical-align: middle;
}

/* 组队头部样式 */
.team-header {
  background: linear-gradient(135deg, var(--primary), var(--secondary));
  color: white;
  padding: 40px 0;
  margin-bottom: 30px;
}

.team-info {
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 40px;
  align-items: center;
}

.team-avatar {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  background: rgba(255,255,255,0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 30px;
  position: relative;
  cursor: pointer;
  overflow: hidden;
  transition: all 0.3s ease;
}

.team-avatar:hover {
  transform: scale(1.05);
}

.team-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.default-avatar {
  display: flex;
  width: 100%;
  height: 100%;
  position: relative;
  align-items: center;
  justify-content: center;
}

.avatar-member {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: var(--primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 2.5rem;
  position: absolute;
  border: 3px solid white;
}

.avatar-member.member-1 {
  background: var(--primary);
}

.upload-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.7);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
  border-radius: 50%;
}

.team-avatar:hover .upload-overlay {
  opacity: 1;
}

.upload-overlay .icon {
  font-size: 1.5rem;
  margin-bottom: 5px;
}

.upload-overlay span {
  font-size: 0.8rem;
}

.team-details h1 {
  font-size: 1.8rem;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.team-description {
  font-size: 1rem;
  opacity: 0.9;
  margin-bottom: 15px;
  line-height: 1.5;
}

.team-tags {
  display: flex;
  gap: 8px;
  margin-bottom: 20px;
}

.tag {
  background: rgba(255,255,255,0.2);
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 0.8rem;
  backdrop-filter: blur(10px);
}

.team-stats {
  display: flex;
  gap: 30px;
  margin-top: 30px;
}

.team-stat {
  flex: 1;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 15px 10px;
}

.stat-value {
  font-size: 2.5rem;
  font-weight: 700;
  color: white;
  margin-bottom: 5px;
  line-height: 1;
}

.stat-label {
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.3;
  font-weight: 400;
}

.team-stat:not(:last-child) {
  border-right: 1px solid rgba(255, 255, 255, 0.3);
  padding-right: 30px;
}

/* 按钮样式 */
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  white-space: nowrap;
}

.btn-primary {
  background: white;
  color: var(--secondary);
}

.btn-primary:hover {
  background: rgba(255,255,255,0.9);
}

.btn-danger {
  background: rgba(255,255,255,0.2);
  color: white;
  backdrop-filter: blur(10px);
}

.btn-danger:hover {
  background: rgba(255,255,255,0.3);
}

/* 徽章样式 */
.not-joined-badge {
  background: rgba(255, 193, 7, 0.2);
  color: #856404;
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 0.85rem;
  margin-left: 10px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .team-info {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .team-avatar {
    margin: 0 auto;
  }
  
  .team-stats {
    flex-wrap: wrap;
  }
  
  .team-stat:not(:last-child) {
    border-right: none;
    padding-right: 0;
  }
}

@media (max-width: 480px) {
  .team-stats {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* 表单样式 */
.task-form {
  padding: 20px 0;
}

.form-group {
  margin-bottom: 20px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: var(--dark);
  font-size: 0.9rem;
}

.form-input {
  width: 100%;
  padding: 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  font-size: 0.9rem;
  transition: border-color 0.3s ease;
  box-sizing: border-box;
}

.form-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
}

.form-input[type="number"] {
  appearance: textfield;
  -moz-appearance: textfield;
}

.form-input[type="number"]::-webkit-outer-spin-button,
.form-input[type="number"]::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 25px;
}

.cancel-btn {
  padding: 10px 20px;
  background: var(--light);
  color: var(--gray);
  border: 1px solid var(--border);
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.cancel-btn:hover {
  background: var(--border);
}

.submit-btn:disabled {
  background: var(--border);
  color: var(--gray);
  cursor: not-allowed;
}

/* 留言区样式 - 与StudyPair.vue保持一致 */
.board-wrapper {
  width: 100%;
  margin: 30px 0 40px;
  padding: 0 20px;
}

.board-card {
  background: #fff;
  border-radius: 18px;
  box-shadow: 0 12px 35px rgba(15, 23, 42, 0.12);
  padding: 26px 28px;
  border: 1px solid rgba(15, 23, 42, 0.06);
}

.board-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.board-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.2rem;
  font-weight: 700;
  color: #1e3a8a;
}

.board-title .icon {
  color: #2563eb;
  font-size: 1.3rem;
}

.board-form {
  background: #f8fafc;
  border-radius: 14px;
  border: 1px solid rgba(15, 23, 42, 0.05);
  padding: 20px;
  margin-bottom: 22px;
}

.board-input {
  width: 100%;
  border: 1px solid rgba(37,99,235,0.25);
  border-radius: 10px;
  padding: 12px 14px;
  resize: vertical;
  font-size: 0.95rem;
  font-family: inherit;
  transition: all 0.2s ease;
  background: #fff;
}

.board-input:focus {
  outline: none;
  border-color: rgba(37,99,235,0.65);
  box-shadow: 0 0 0 3px rgba(37,99,235,0.18);
}

.board-form-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
}

.board-tip {
  font-size: 0.8rem;
  color: #64748b;
  display: flex;
  align-items: center;
  gap: 4px;
}

.board-submit {
  padding: 9px 22px;
  border-radius: 999px;
  border: none;
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
  color: #fff;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 6px;
}

.board-submit:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 8px 18px rgba(37,99,235,0.25);
}

.board-submit:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.board-not-joined {
  text-align: center;
  padding: 25px;
  background: #f8f9fa;
  border-radius: 10px;
  margin-bottom: 20px;
  color: #6c757d;
}

.board-not-joined .icon {
  font-size: 2rem;
  margin-bottom: 10px;
  display: block;
}

.board-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.board-item {
  border: 1px solid rgba(15, 23, 42, 0.08);
  border-radius: 12px;
  padding: 16px 18px;
  background: #fff;
  display: flex;
  flex-direction: column;
  gap: 10px;
  box-shadow: 0 6px 14px rgba(15, 23, 42, 0.06);
}

.board-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 14px;
}

.board-avatar {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1rem;
}

.board-avatar.partner {
  background: linear-gradient(135deg, #22c55e, #16a34a);
}

.board-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
}

.board-name-line {
  display: flex;
  align-items: center;
  gap: 8px;
}

.board-name {
  font-weight: 600;
  color: #1e293b;
}

.board-badge {
  background: #1d4ed8;
  color: #fff;
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 0.75rem;
  display: flex;
  align-items: center;
  gap: 4px;
}

.board-time {
  font-size: 0.8rem;
  color: #64748b;
}

.board-content {
  margin: 0;
  color: #1f2937;
  line-height: 1.6;
  font-size: 0.95rem;
  word-break: break-word;
}

.board-more {
  margin: 6px auto 0;
  border: 1px solid rgba(37,99,235,0.3);
  background: transparent;
  color: #1d4ed8;
  border-radius: 999px;
  padding: 8px 22px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 6px;
  justify-content: center;
}

.board-more:hover {
  background: #dbeafe;
}

.board-empty {
  text-align: center;
  color: #94a3b8;
  padding: 50px 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  align-items: center;
}

.board-empty .icon {
  font-size: 2.3rem;
}

/* 徽章样式 */
.view-only-badge-small {
  background: rgba(108, 117, 125, 0.15);
  color: #495057;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 0.75rem;
  margin-left: 8px;
  display: inline-flex;
  align-items: center;
  gap: 3px;
}

/* 图标样式 */
.icon {
  display: inline-block;
  margin-right: 8px;
  font-size: 1.1em;
  vertical-align: middle;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .board-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .board-history-btn {
    align-self: flex-start;
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .content-grid {
    grid-template-columns: 1fr;
  }
  
  .room-info {
    grid-template-columns: 1fr;
    text-align: center;
    gap: 20px;
  }
  
  .room-stats {
    grid-template-columns: repeat(2, 1fr);
  }

  .task-section-header {
    flex-direction: column;
    align-items: stretch;
    gap: 10px;
  }

  .add-task-btn {
    align-self: flex-end;
  }

  .form-actions {
    flex-direction: column;
  }
}

.stat-value {
  font-size: 1.5rem;
  font-weight: bold;
  margin: 8px 0;
}

.stat-label {
  font-size: 0.85rem;
  opacity: 0.8;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-primary {
  background: white;
  color: var(--primary);
}

.btn-primary:hover {
  background: var(--primary-light);
}

.btn-secondary {
  background: var(--light);
  color: var(--dark);
  border: 1px solid var(--border);
}

.btn-secondary:hover {
  background: var(--primary-light);
}

/* 主要内容 */
.content-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 30px;
  margin-bottom: 30px;
}

.content-section {
  background: white;
  border-radius: 15px;
  padding: 25px;
  margin-bottom: 25px;
  box-shadow: 0 3px 15px rgba(0,0,0,0.08);
}

.section-title {
  font-size: 1.3rem;
  margin-bottom: 20px;
  color: var(--dark);
  display: flex;
  align-items: center;
  gap: 10px;
}

.rules-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.edit-rules-btn {
  padding: 6px 12px;
  font-size: 0.8rem;
  border-radius: 6px;
  border: 1px solid var(--border);
  background: var(--light);
  cursor: pointer;
}

.edit-rules-btn:hover {
  background: var(--primary-light);
  color: var(--primary);
}

/* 成员头像列表样式 */
.members-avatar-list {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  padding: 10px 0;
  min-height: 80px;
}

.member-avatar-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  width: 60px;
  text-align: center;
}

.member-avatar-circle {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 1.2rem;
  position: relative;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.member-avatar-circle:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}

/* 管理员标签样式 */
.admin-tag {
  position: absolute;
  bottom: -6px;
  right: -6px;
  background: linear-gradient(135deg, #FFD700, #FFC107);
  color: white;
  font-size: 0.6rem;
  padding: 2px 6px;
  border-radius: 10px;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  font-weight: bold;
  z-index: 1;
  white-space: nowrap;
}

/* 成员名字样式 */
.member-name {
  font-size: 0.8rem;
  color: #4b5563;
  font-weight: 500;
  line-height: 1.2;
  max-width: 100%;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* 当前用户特殊效果 */
.member-avatar-item.current-user .member-avatar-circle {
  border: 2px solid #1a73e8;
  box-shadow: 0 4px 12px rgba(26, 115, 232, 0.3);
}

.member-avatar-item.current-user .member-name {
  color: #1a73e8;
  font-weight: 600;
}

.empty-placeholder {
  text-align: center;
  color: #9ca3af;
  padding: 30px 20px;
  font-size: 0.95rem;
  background: #f9fafb;
  border-radius: 8px;
  border: 1px dashed #d1d5db;
  width: 100%;
  margin: 10px 0;
}


/* 学习记录 */
.task-section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.add-task-btn {
  padding: 6px 12px;
  background: var(--primary);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  display: flex;
  align-items: center;
  gap: 5px;
  transition: all 0.3s ease;
}

.add-task-btn:hover {
  background: var(--primary-dark, #1557b0);
  transform: translateY(-1px);
}

.task-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 任务复选框样式 */
.task-checkbox {
  width: 24px;
  height: 24px;
  border: 2px solid #ddd;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.3s ease;
  background: white;
}

.task-checkbox:hover {
  border-color: #1a73e8;
  background: #e8f0fe;
}

.task-checkbox.checked {
  background: #34a853;
  border-color: #34a853;
  color: white;
}

/* 任务项样式 */
.task-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 10px;
  margin-bottom: 10px;
  transition: all 0.3s ease;
  border-left: 4px solid #1a73e8;
}

.task-item.task-completed {
  background: #e8f5e8;
  border-left-color: #4caf50;
}

.task-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.task-info {
  flex: 1;
  min-width: 0;
}

.task-title {
  font-weight: 600;
  margin-bottom: 4px;
  word-break: break-word;
}

.task-title.completed {
  text-decoration: line-through;
  color: #666;
}

/* 优先级徽章 */
.priority-badge {
  font-size: 0.7rem;
  padding: 2px 6px;
  border-radius: 4px;
  margin-left: 8px;
  font-weight: 500;
}

.priority-badge.high {
  background: #ffebee;
  color: #d32f2f;
}

.priority-badge.medium {
  background: #fff3e0;
  color: #ff9800;
}

.priority-badge.low {
  background: #e8f5e8;
  color: #388e3c;
}

.task-description {
  font-size: 0.85rem;
  color: #666;
  margin: 5px 0;
  line-height: 1.4;
}

.completion-time-simple {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 8px;
  font-size: 0.85rem;
  color: #2e7d32;
}

.quick-complete-btn {
  padding: 6px 12px;
  background: linear-gradient(135deg, #ff9800, #ff5722);
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 4px;
  white-space: nowrap;
  margin-left: auto;
}

.quick-complete-btn:hover {
  background: linear-gradient(135deg, #f57c00, #e64a19);
  transform: translateY(-1px);
}

.no-tasks {
  text-align: center;
  padding: 40px 20px;
  color: #94a3b8;
  background: #f8fafc;
  border-radius: 8px;
  border: 1px dashed #cbd5e1;
}

.no-tasks .icon {
  font-size: 2rem;
  margin-bottom: 10px;
  display: block;
}

/* 学习记录左右并排布局 */
.learning-record-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-top: 20px;
}

/* 任务清单样式调整 */
.task-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
}

/* 学习进度样式调整 */
.learning-progress {
  background: var(--light);
  border-radius: 12px;
  padding: 20px;
  text-align: center;
}

.learning-record {
  position: relative;
}


/* 任务进度条样式 */
.task-progress-section {
  margin-top: 15px;
  padding: 15px;
  background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.08);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.task-progress-section:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transform: translateY(-1px);
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.progress-title {
  font-size: 0.9rem;
  font-weight: 600;
  color: #343a40;
  display: flex;
  align-items: center;
  gap: 6px;
}

.progress-percentage {
  font-size: 1rem;
  font-weight: bold;
  color: white;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 4px 12px;
  border-radius: 20px;
  min-width: 50px;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.progress-bar-container {
  height: 12px;
  background: #edf2f7;
  border-radius: 6px;
  overflow: hidden;
  margin-bottom: 10px;
  box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.1);
}

.progress-bar {
  height: 100%;
  border-radius: 6px;
  transition: width 0.8s cubic-bezier(0.34, 1.56, 0.64, 1);
  position: relative;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.progress-bar::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(
    90deg,
    rgba(255, 255, 255, 0) 0%,
    rgba(255, 255, 255, 0.4) 50%,
    rgba(255, 255, 255, 0) 100%
  );
  animation: shimmer 1.5s infinite linear;
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.progress-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  font-size: 0.8rem;
  color: #6c757d;
}

.progress-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  padding: 6px;
  background: rgba(248, 249, 250, 0.7);
  border-radius: 6px;
  transition: all 0.3s ease;
}

.progress-stat:hover {
  background: rgba(233, 236, 239, 0.9);
  transform: translateY(-1px);
}

.progress-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.progress-label {
  font-size: 0.8rem;
  color: var(--gray);
}

.progress-value {
  font-weight: bold;
  color: var(--primary);
}

/* 侧边栏 */
.rules-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.rule-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  background: var(--light);
  border-radius: 8px;
  font-size: 0.9rem;
}

.rule-item i {
  color: var(--secondary);
}

/* 学习排行样式 */
.leaderboard {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.leaderboard-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  background: white;
  border-radius: 12px;
  border: 2px solid #e5e7eb;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.leaderboard-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* 前三名特殊样式 */
.leaderboard-item.rank-1 {
  border: 3px solid #FFD700; /* 金色 */
  background: linear-gradient(135deg, #fff9e6 0%, #fff5d9 100%);
}

.leaderboard-item.rank-2 {
  border: 3px solid #C0C0C0; /* 银色 */
  background: linear-gradient(135deg, #f9f9f9 0%, #f5f5f5 100%);
}

.leaderboard-item.rank-3 {
  border: 3px solid #CD7F32; /* 铜色 */
  background: linear-gradient(135deg, #fdf6e8 0%, #fbf2e1 100%);
}

/* 其他名次统一样式 */
.leaderboard-item.rank-4,
.leaderboard-item.rank-5,
.leaderboard-item.rank-6,
.leaderboard-item.rank-7,
.leaderboard-item.rank-8,
.leaderboard-item.rank-9,
.leaderboard-item.rank-10 {
  border: 2px solid #10b981; /* 绿色边框 */
  background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 100%);
}

.rank {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #64748b;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 0.9rem;
  flex-shrink: 0;
}

/* 前三名排名样式 */
.leaderboard-item.rank-1 .rank {
  background: linear-gradient(135deg, #FFD700, #FFC107);
  box-shadow: 0 2px 8px rgba(255, 215, 0, 0.3);
}

.leaderboard-item.rank-2 .rank {
  background: linear-gradient(135deg, #C0C0C0, #9CA3AF);
  box-shadow: 0 2px 8px rgba(192, 192, 192, 0.3);
}

.leaderboard-item.rank-3 .rank {
  background: linear-gradient(135deg, #CD7F32, #B45309);
  box-shadow: 0 2px 8px rgba(205, 127, 50, 0.3);
}

/* 其他名次排名样式 */
.leaderboard-item.rank-4 .rank,
.leaderboard-item.rank-5 .rank,
.leaderboard-item.rank-6 .rank,
.leaderboard-item.rank-7 .rank,
.leaderboard-item.rank-8 .rank,
.leaderboard-item.rank-9 .rank,
.leaderboard-item.rank-10 .rank {
  background: linear-gradient(135deg, #10b981, #059669);
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.2);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.user-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #64748b;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 1.2rem;
  position: relative;
  flex-shrink: 0;
}

.user-avatar.top-3 {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* 前三名头像特殊样式 */
.leaderboard-item.rank-1 .user-avatar {
  background: linear-gradient(135deg, #FFD700, #FFC107);
}

.leaderboard-item.rank-2 .user-avatar {
  background: linear-gradient(135deg, #C0C0C0, #9CA3AF);
}

.leaderboard-item.rank-3 .user-avatar {
  background: linear-gradient(135deg, #CD7F32, #B45309);
}

/* 其他名次头像样式 */
.leaderboard-item.rank-4 .user-avatar,
.leaderboard-item.rank-5 .user-avatar,
.leaderboard-item.rank-6 .user-avatar,
.leaderboard-item.rank-7 .user-avatar,
.leaderboard-item.rank-8 .user-avatar,
.leaderboard-item.rank-9 .user-avatar,
.leaderboard-item.rank-10 .user-avatar {
  background: linear-gradient(135deg, #10b981, #059669);
}

/* 皇冠图标 */
.rank-crown {
  position: absolute;
  top: -8px;
  right: -8px;
  font-size: 1.2rem;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border-radius: 50%;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.leaderboard-item.rank-1 .rank-crown {
  background: linear-gradient(135deg, #FFD700, #FFC107);
  color: white;
}

.leaderboard-item.rank-2 .rank-crown {
  background: linear-gradient(135deg, #C0C0C0, #9CA3AF);
  color: white;
}

.leaderboard-item.rank-3 .rank-crown {
  background: linear-gradient(135deg, #CD7F32, #B45309);
  color: white;
}

.user-details {
  flex: 1;
  min-width: 0;
}

.user-name {
  font-weight: 600;
  margin-bottom: 4px;
  color: #1f2937;
  font-size: 1rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-score {
  font-size: 0.9rem;
  color: #6b7280;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 4px;
}

.user-score::before {
  content: '🏆';
  font-size: 0.8rem;
}

.empty-placeholder {
  text-align: center;
  color: #9ca3af;
  padding: 30px 20px;
  font-size: 0.95rem;
  background: #f9fafb;
  border-radius: 8px;
  border: 1px dashed #d1d5db;
}

/* 留言区 */
.comments-full-width {
  margin-top: 20px;
}

.comments-section {
  margin-top: 20px;
}

.comment-form {
  background: var(--light);
  padding: 15px;
  border-radius: 10px;
  margin-bottom: 20px;
  display: flex;
  gap: 10px;
}

.comment-input {
  flex: 1;
  min-height: 60px;
  padding: 10px 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  resize: vertical;
}

.comment-input:focus {
  outline: none;
  border-color: var(--primary);
}

.comment-submit {
  display: flex;
  align-items: flex-end;
}

.submit-btn {
  padding: 8px 20px;
  background: var(--primary);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.comment-item {
  display: flex;
  gap: 15px;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--border);
}

.comment-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.comment-content {
  flex: 1;
}

.comment-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.comment-author {
  font-weight: 600;
}

.comment-time {
  font-size: 0.8rem;
  color: var(--gray);
}

.expand-today-btn {
  width: 100%;
  padding: 10px;
  background: var(--light);
  color: var(--primary);
  border: 1px solid var(--primary);
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  margin-top: 10px;
}

/* 模态框 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
}

.modal-content {
  background: white;
  padding: 25px;
  border-radius: 12px;
  width: 90%;
  max-width: 500px;
  max-height: 80vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
}

/* 模态框内部样式 */
.modal-section {
  margin-bottom: 25px;
}

.modal-section:last-child {
  margin-bottom: 0;
}

.section-subtitle {
  font-size: 1.1rem;
  margin-bottom: 15px;
  color: var(--dark);
  display: flex;
  align-items: center;
  gap: 8px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--border);
}

.modal-divider {
  height: 1px;
  background: var(--border);
  margin: 20px 0;
}

/* 任务管理列表样式 */
.task-management-list {
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid var(--border);
  border-radius: 8px;
}

.task-management-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid var(--border);
  transition: background-color 0.2s ease;
}

.task-management-item:hover {
  background-color: var(--light);
}

.task-management-item:last-child {
  border-bottom: none;
}

.task-management-info {
  flex: 1;
  min-width: 0;
  margin-right: 15px;
}

.task-management-title {
  font-weight: 600;
  margin-bottom: 5px;
  word-break: break-word;
}

.task-management-description {
  font-size: 0.85rem;
  color: #666;
  margin-bottom: 8px;
  line-height: 1.4;
}

.task-management-status {
  display: flex;
  align-items: center;
  gap: 10px;
}

.status-badge {
  font-size: 0.75rem;
  padding: 2px 8px;
  border-radius: 4px;
  background: #e0e0e0;
  color: #666;
}

.status-badge.completed {
  background: #e8f5e8;
  color: #388e3c;
}

.task-time {
  font-size: 0.8rem;
  color: #666;
  display: flex;
  align-items: center;
  gap: 4px;
}

.task-management-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 4px;
  white-space: nowrap;
}

.reset-btn {
  background: #fff3e0;
  color: #ff9800;
}

.reset-btn:hover {
  background: #ffe0b2;
}

.delete-btn {
  background: #ffebee;
  color: #f44336;
}

.delete-btn:hover {
  background: #ffcdd2;
}

.no-tasks-management {
  text-align: center;
  padding: 40px 20px;
  color: #94a3b8;
}

.no-tasks-management i {
  font-size: 2rem;
  margin-bottom: 10px;
  display: block;
}

/* 查看全部任务按钮样式 */
.view-more-tasks {
  text-align: center;
  margin-top: 20px;
  padding-top: 15px;
  border-top: 1px solid rgba(15, 23, 42, 0.1);
}

.view-all-btn {
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 10px 20px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
}

.view-all-btn:hover {
  background: linear-gradient(135deg, #1d4ed8, #1e40af);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(37,99,235,0.2);
}

/* 收起按钮样式 */
.collapse-tasks {
  text-align: center;
  margin-top: 20px;
  padding-top: 15px;
  border-top: 1px solid rgba(15, 23, 42, 0.1);
}

.collapse-btn {
  background: #f1f5f9;
  color: #475569;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  padding: 10px 20px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
}

.collapse-btn:hover {
  background: #e2e8f0;
  border-color: #94a3b8;
  transform: translateY(-2px);
}

/* Toast 通知样式 */
.toast {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 12px 20px;
  border-radius: 8px;
  color: white;
  font-weight: 500;
  z-index: 9999;
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 200px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  animation: slideIn 0.3s ease-out;
}

.toast-success {
  background: var(--secondary);
}

.toast-error {
  background: var(--danger);
}

.toast-info {
  background: var(--primary);
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

/* 新增样式 */

.not-joined-badge {
  background: rgba(255, 193, 7, 0.2);
  color: #856404;
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 0.85rem;
  margin-left: 10px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.not-joined-message {
  text-align: center;
  padding: 40px 20px;
  color: var(--gray);
  background: var(--light);
  border-radius: 10px;
  border: 1px dashed var(--border);
  margin: 20px 0;
}

.not-joined-icon {
  font-size: 3rem;
  margin-bottom: 15px;
  color: #ccc;
}

.not-joined-text {
  margin-bottom: 20px;
  font-size: 1rem;
}

.comment-form-not-joined {
  background: var(--light);
  padding: 15px;
  border-radius: 10px;
  margin-bottom: 20px;
  text-align: center;
}

.not-joined-message-small {
  color: var(--gray);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 10px;
}

.task-actions {
  margin-left: auto;
}

.quick-complete-btn {
  padding: 4px 12px;
  background: linear-gradient(135deg, #ff9800, #ff5722);
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 4px;
  white-space: nowrap;
}

.quick-complete-btn:hover {
  background: linear-gradient(135deg, #f57c00, #e64a19);
  transform: translateY(-1px);
}

.task-completion-time {
  font-size: 0.8rem;
  color: var(--secondary);
  margin-top: 5px;
  display: flex;
  align-items: center;
  gap: 5px;
}

/* 任务统计卡片样式 */
.task-summary-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 15px;
  margin-top: 20px;
}

.summary-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  border: 1px solid var(--border);
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.summary-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.summary-icon.completed {
  background: #e8f5e8;
  color: var(--secondary);
}

.summary-icon.pending {
  background: #fff3e0;
  color: var(--warning);
}

.summary-icon.total {
  background: #e3f2fd;
  color: var(--primary);
}

.summary-icon.rate {
  background: #f3e5f5;
  color: #9c27b0;
}

.summary-content {
  flex: 1;
}

.summary-value {
  font-size: 1.5rem;
  font-weight: bold;
  color: var(--dark);
  margin-bottom: 5px;
}

.summary-label {
  font-size: 0.85rem;
  color: var(--gray);
}

.progress-chart-container {
  position: relative;
  height: 250px;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .task-summary-cards {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .task-actions {
    margin-left: 0;
    margin-top: 10px;
    width: 100%;
  }
  
  .quick-complete-btn {
    width: 100%;
    justify-content: center;
  }
  
  .progress-stats {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .room-stats {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .task-summary-cards {
    grid-template-columns: 1fr;
  }
}
</style>