<template>
  <div class="study-pair">

    <!-- 组队头部 -->
    <section class="team-header">
      <div class="container">
        <div class="team-info">
          <div class="team-avatar" @click="uploadTeamAvatar">
            <img v-if="teamAvatar" :src="teamAvatar" alt="小组头像" />
            <div v-else class="default-avatar">
              <div class="avatar-member" v-for="(member, index) in actualTeamMembers.slice(0, 2)" :key="getMemberKey(member, index)" :class="`member-${index + 1}`">
                {{ getMemberInitial(member) }}
              </div>
            </div>
            <div class="upload-overlay" v-if="isJoined && hasEditPermission">
              <span class="icon">📷</span>
              <span>上传头像</span>
            </div>
          </div>
          <input type="file" ref="avatarInput" @change="handleAvatarUpload" accept="image/*" style="display: none;" />
          <div class="team-details">
            <h1>
              <span class="icon">👥</span>
              {{ teamData.name || '加载中...' }}
              <span v-if="!isJoined" class="not-joined-badge">
                <span class="icon">👀</span>
                浏览中
              </span>
            </h1>
            <p class="team-description">{{ teamData.description || '正在加载团队信息...' }}</p>
            <div class="team-tags">
              <span v-for="tag in teamData.tags" :key="tag" class="tag">{{ tag }}</span>
            </div>
            <!-- 团队统计数据 -->
            <div class="team-stats">
              <div class="team-stat">
                <div class="stat-value">{{ teamData.totalMembers || 0 }}</div>
                <div class="stat-label">成员人数</div>
              </div>
              <div class="team-stat">
                <div class="stat-value">{{ teamData.completionRate || 0 }}%</div>
                <div class="stat-label">任务完成率</div>
              </div>
              <div class="team-stat">
                <div class="stat-value">{{ teamData.completedTasks || 0 }}</div>
                <div class="stat-label">任务完成量</div>
              </div>

            </div>
            <p class="pair-warning" v-if="actualTeamMembers.length > 2">
              <span class="icon">ℹ️</span>
              当前小组成员超过 2 人，已自动展示前两位成员。
            </p>
          </div>
          <div class="team-actions" v-if="isJoined">
            <button class="btn btn-danger" @click="leaveTeam">
              <span class="icon">👤➖</span>
              退出小组
            </button>
            <button class="btn btn-secondary" @click="shareTeam">
              <span class="icon">↗️</span>
              分享
            </button>
          </div>
          <div class="team-actions" v-else>
            <button class="btn btn-primary" @click="joinTeam">
              <span class="icon">👤➕</span>
              加入小组
            </button>
          </div>
        </div>
      </div>
    </section>

    <div class="container">
      <!-- 主要内容布局 -->
      <div class="main-content">
        <!-- 左侧主要内容 -->
        <div class="left-column">
          <!-- 学习进度对比 -->
          <div class="content-section">
            <h2 class="section-title">
              <span class="icon">📊</span>
              小组成员学习进度
              <span v-if="!isJoined" class="view-only-badge">
                <span class="icon">👀</span>
                仅查看
              </span>
            </h2>
            <div class="progress-comparison">
              <div v-for="member in displayedMembers" :key="getMemberKey(member)" class="member-card">
                <div class="member-avatar-wrapper">
                  <div :class="['member-avatar', { partner: member.userId !== currentUserId }]">
                    {{ getMemberInitial(member) }}
                  </div>
                  <div v-if="member.userId === currentUserId" class="current-user-badge">
                    <span>👤</span>
                  </div>
                </div>
                <h3>
                  <span class="icon">{{ member.userId === currentUserId ? '👤' : '👥' }}</span>
                  {{ member.name || '未知成员' }}
                  <span v-if="member.userId === currentUserId" class="you-badge">(我)</span>
                </h3>
                <p style="color: var(--gray); margin-bottom: 15px;">
                  <span class="icon">📋</span>
                  已完成任务: {{ member.completed_task_count || memberProgress[member.userId]?.completed || 0 }}个
                  <span v-if="member.total_completion_hours && member.total_completion_hours !== '0.0'" style="font-size: 0.8em; color: #666;">
                    (总耗时: {{ member.total_completion_hours }}小时)
                  </span>
                </p>
                
                <div v-if="member.pie_chart && member.pie_chart.labels && member.pie_chart.labels.length > 0" 
                    class="chart-container" style="height: 250px; margin-bottom: 15px;">
                  <div :ref="`memberTaskChart${member.userId}`" style="width: 100%; height: 100%;"></div>
                </div>
                <div v-else class="no-data-chart">
                  <span class="icon">📋</span>
                  <p>暂无已完成任务</p>
                </div>
                
                <div class="task-progress-section">
                  <div class="progress-header">
                    <span class="progress-title">
                      <span class="icon">📈</span>
                      {{ member.userId === currentUserId ? '我的' : (member.name || '成员') + '的' }}任务完成进度
                    </span>
                    <span class="progress-percentage">{{ memberProgress[member.userId]?.percentage || 0 }}%</span>
                  </div>
                  <div class="progress-bar-container">
                    <div class="progress-bar" :style="{ 
                      width: `${memberProgress[member.userId]?.percentage || 0}%`,
                      background: member.userId === currentUserId 
                        ? 'linear-gradient(90deg, #1a73e8, #34a853)' 
                        : 'linear-gradient(90deg, #34a853, #1a73e8)'
                    }"></div>
                  </div>
                  <div class="progress-stats">
                    <span class="progress-stat">
                      <span class="icon">{{ member.userId === currentUserId ? '✅' : '👤✅' }}</span>
                      已完成: {{ memberProgress[member.userId]?.completed || 0 }}
                    </span>
                    <span class="progress-stat">
                      <span class="icon">⏳</span>
                      待完成: {{ (memberProgress[member.userId]?.total || 0) - (memberProgress[member.userId]?.completed || 0) }}
                    </span>
                    <span class="progress-stat">
                      <span class="icon">📋</span>
                      总计: {{ memberProgress[member.userId]?.total || 0 }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 任务互相监督 -->
          <div class="content-section" style="position: relative;">
            <h2 class="section-title">
              <span class="icon">📋</span>
              任务互相监督
              <span v-if="!isJoined" class="view-only-badge">
                <span class="icon">👀</span>
                仅查看
              </span>
            </h2>
            
            <div class="task-summary-cards">
              <div class="summary-card">
                <div class="summary-icon completed">
                  <span class="icon">✅</span>
                </div>
                <div class="summary-content">
                  <div class="summary-value">{{ taskSummary.completed || 0 }}</div>
                  <div class="summary-label">已完成</div>
                </div>
              </div>
              <div class="summary-card">
                <div class="summary-icon pending">
                  <span class="icon">⏰</span>
                </div>
                <div class="summary-content">
                  <div class="summary-value">{{ taskSummary.pending || 0 }}</div>
                  <div class="summary-label">待完成</div>
                </div>
              </div>
              <div class="summary-card">
                <div class="summary-icon total">
                  <span class="icon">📋</span>
                </div>
                <div class="summary-content">
                  <div class="summary-value">{{ taskSummary.total || 0 }}</div>
                  <div class="summary-label">总任务</div>
                </div>
              </div>
              <div class="summary-card">
                <div class="summary-icon rate">
                  <span class="icon">📈</span>
                </div>
                <div class="summary-content">
                  <div class="summary-value">{{ taskSummary.completionRate || 0 }}%</div>
                  <div class="summary-label">完成率</div>
                </div>
              </div>
            </div>
            
            <div class="task-grid">
              <!-- 第一个成员的任务 -->
              <div class="task-column" v-if="displayedMembers[0]">
                <h4>
                  <span class="icon">👤</span>
                  {{ displayedMembers[0].userId === currentUserId ? '我的任务' : (displayedMembers[0].name || '成员') + '的任务' }}
                  <span class="task-count">({{ getMemberTasks(displayedMembers[0].userId).length }})</span>
                </h4>
                <div class="task-list">
                  <div v-for="task in getMemberTasks(displayedMembers[0].userId)" :key="task.id" 
                      :class="['task-item', { 'task-completed': task.is_completed === 1 }]">
                    <div class="task-checkbox" 
                         v-if="isJoined && task.assigneeId === currentUserId"
                         @click="toggleTaskCompletion(task)"
                         :class="{ 'checked': task.is_completed === 1 }">
                      <span v-if="task.is_completed === 1">✓</span>
                    </div>
                    <div class="task-checkbox readonly" v-else :class="{ 'checked': task.is_completed === 1 }">
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
                    <button v-if="isJoined && task.is_completed !== 1 && task.assigneeId === currentUserId" 
                            class="quick-complete-btn" @click="quickCompleteTask(task.id)">
                      <span class="icon">⚡</span>
                      快速完成
                    </button>
                    <button v-else-if="isJoined && task.is_completed !== 1 && task.assigneeId !== currentUserId" 
                            class="remind-btn" @click="remindPartner(task)"
                            title="提醒伙伴完成任务">
                      <span class="icon">🔔</span>
                      提醒
                    </button>
                  </div>
                  <div v-if="!getMemberTasks(displayedMembers[0].userId).length" class="no-tasks">
                    <span class="icon">📭</span>
                    <p>暂无任务</p>
                  </div>
                </div>
              </div>
              
              <!-- 第二个成员的任务 -->
              <div class="task-column" v-if="displayedMembers[1]">
                <h4>
                  <span class="icon">👤</span>
                  {{ displayedMembers[1].userId === currentUserId ? '我的任务' : (displayedMembers[1].name || '成员') + '的任务' }}
                  <span class="task-count">({{ getMemberTasks(displayedMembers[1].userId).length }})</span>
                </h4>
                <div class="task-list">
                  <div v-for="task in getMemberTasks(displayedMembers[1].userId)" :key="task.id" 
                      :class="['task-item', { 'task-completed': task.is_completed === 1 }]">
                    <div class="task-checkbox readonly" :class="{ 'checked': task.is_completed === 1 }">
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
                    <button v-if="isJoined && task.is_completed !== 1 && task.assigneeId === currentUserId" 
                            class="quick-complete-btn" @click="quickCompleteTask(task.id)">
                      <span class="icon">⚡</span>
                      快速完成
                    </button>
                    <button v-else-if="isJoined && task.is_completed !== 1 && task.assigneeId !== currentUserId" 
                            class="remind-btn" @click="remindPartner(task)"
                            title="提醒伙伴完成任务">
                      <span class="icon">🔔</span>
                      提醒
                    </button>
                  </div>
                  <div v-if="!getMemberTasks(displayedMembers[1].userId).length" class="no-tasks">
                    <span class="icon">📭</span>
                    <p>暂无任务</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 右侧内容 -->
        <div class="right-column">
          <!-- 小组成员 -->
          <div class="content-section">
            <h3 class="section-title">
              <span class="icon">👥</span>
              小组成员 ({{ actualTeamMembers.length }}人)
            </h3>
            <div v-for="member in actualTeamMembers" :key="getMemberKey(member)" class="partner-info" style="margin-bottom: 15px;">
              <div :class="['partner-avatar', { 'is-me': member.userId === currentUserId }]">
                {{ getMemberInitial(member) }}
              </div>
              <div class="partner-details">
                <h4>
                  <span class="icon">{{ member.userId === currentUserId ? '👤' : '🎓' }}</span>
                  {{ member.name || '未知成员' }}
                  <span v-if="member.userId === currentUserId" class="you-badge-small">(我)</span>
                </h4>
                <p>团队成员</p>
              </div>
            </div>
            <div v-if="!actualTeamMembers.length" class="no-members">
              <span class="icon">👥</span>
              <p>暂无成员数据</p>
            </div>
          </div>

          <!-- 任务清单 -->
          <div class="content-section tasklist-section">
            <div class="tasklist-header">
              <div class="tasklist-title">
                <span class="icon">📝</span>
                <span>任务清单</span>
                <span v-if="!isJoined" class="view-only-badge-small">
                  <span class="icon">👀</span>
                  仅查看
                </span>
              </div>
              <div class="tasklist-actions" v-if="isJoined">
                <button class="tasklist-add" @click="openEditTaskModal">
                  <span class="icon">✏️</span>
                  编辑任务
                </button>
              </div>
            </div>

            <div class="task-summary">
              <div class="task-summary-item">
                <span class="task-count">
                  <span class="icon">○</span>
                  待办
                </span>
                <span class="task-number">{{ taskSummary.pending || 0 }}</span>
              </div>
              <div class="task-summary-item">
                <span class="task-count">
                  <span class="icon">✅</span>
                  完成
                </span>
                <span class="task-number">{{ taskSummary.completed || 0 }}</span>
              </div>
            </div>

            <div class="tasklist-body" v-if="combinedTasks.length">
              <div v-for="task in displayedTasks" :key="task.id" class="task-card" :class="[`status-${task.status}`, task.assigneeType]">
                <!-- 任务内容保持不变 -->
                <div class="task-card-main">
                  <div class="task-status-icon">
                    <span v-if="task.status === 'completed'">✓</span>
                    <span v-else-if="task.status === 'in_progress'">↻</span>
                    <span v-else>○</span>
                  </div>
                  <div class="task-info-block">
                    <div class="task-card-title">{{ task.title || '未命名任务' }}</div>
                    <div class="task-card-meta">
                      <!-- 这里显示成员名称 -->
                      {{ task.assigneeLabel }} · {{ task.timeLabel }}
                    </div>
                  </div>
                </div>
                
                <!-- 修改这里：显示成员名称 -->
                <button class="task-card-action view-only" disabled>
                  {{ task.assigneeName }}
                </button>
              </div>
              
              <!-- 查看全部/收起按钮保持不变 -->
              <div v-if="hasMoreTasks && !showAllTasks" class="view-more-tasks">
                <button class="view-all-btn" @click="showAllTasks = true">
                  <span class="icon">⬇️</span>
                  查看全部任务 (共{{ combinedTasks.length }}个)
                </button>
              </div>
              
              <div v-if="showAllTasks && hasMoreTasks" class="collapse-tasks">
                <button class="collapse-btn" @click="showAllTasks = false">
                  <span class="icon">⬆️</span>
                  收起任务
                </button>
              </div>
            </div>
            <div class="tasklist-empty" v-else>
              <span class="icon">📥</span>
              <p>当前还没有任务~</p>
            </div>
          </div>

          <!-- 共同成就 -->
          <div class="content-section" v-if="isJoined">
            <h3 class="section-title">
              <span class="icon">🏆</span>
              共同成就
            </h3>
            <div class="achievements">
              <div v-for="achievement in achievements" :key="achievement.id" class="achievement-item">
                <div class="achievement-icon">{{ achievement.icon }}</div>
                <div class="achievement-info">
                  <div class="achievement-title">{{ achievement.name }}</div>
                  <div class="achievement-desc">{{ achievement.description }}</div>
                </div>
              </div>
              <div class="achievement-item" v-if="!achievements.length">
                <div class="achievement-icon">🏅</div>
                <div class="achievement-info">
                  <div class="achievement-title">暂无成就</div>
                  <div class="achievement-desc">完成更多任务来解锁成就吧！</div>
                </div>
              </div>
            </div>
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
          <button class="board-history-btn" v-if="comments.length > commentLimit" @click="viewAllComments">
            <span class="icon">🔍</span>
            查看留言记录
          </button>
        </div>

        <div class="board-form" v-if="isJoined">
          <textarea class="board-input" v-model="newComment" placeholder="分享你的学习心得、遇到的问题或给伙伴的鼓励..." rows="3" @keyup.enter.ctrl="submitComment"></textarea>
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
          <p>加入小组后即可参与留言讨论</p>
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
          <p>还没有留言，{{ isJoined ? '快来发表第一条吧！' : '加入小组后即可参与讨论' }}</p>
        </div>
      </div>
    </div>

    <!-- 编辑任务模态框 -->
    <div class="modal" v-if="showEditTaskModal" @click.self="closeEditTaskModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">
            <span class="icon">✏️</span>
            编辑任务
          </h3>
          <button class="close-btn" @click="closeEditTaskModal">&times;</button>
        </div>
        
        <!-- 上半部分：添加任务 -->
        <div class="modal-section">
          <h4 class="section-subtitle">
            <span class="icon">➕</span>
            添加新任务
          </h4>
          <div class="add-task-form">
            <div class="form-group">
              <label class="form-label">
                <span class="icon">📝</span>
                任务标题
              </label>
              <input class="form-input" v-model="newTask.title" placeholder="请输入任务标题" />
            </div>
            <div class="form-group">
              <label class="form-label">
                <span class="icon">📄</span>
                任务描述
              </label>
              <textarea class="form-textarea" v-model="newTask.description" placeholder="补充任务说明"></textarea>
            </div>
            <!-- 监督对象固定为"我自己"，不可修改 -->
            <div class="form-group">
              <label class="form-label">
                <span class="icon">👤</span>
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
              <span class="icon">💾</span>
              保存任务
            </button>
          </div>
        </div>
        
        <!-- 分割线 -->
        <div class="modal-divider"></div>
        
        <!-- 下半部分：当前用户的所有任务 -->
        <div class="modal-section">
          <h4 class="section-subtitle">
            <span class="icon">📋</span>
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
                  <span class="status-badge" :class="{ 'completed': task.is_completed === 1 }">
                    {{ task.is_completed === 1 ? '已完成' : '未完成' }}
                  </span>
                  <span v-if="task.completion_time" class="task-time">
                    <span class="icon">⏰</span>
                    {{ task.completion_time }}分钟
                  </span>
                </div>
              </div>
              <div class="task-management-actions">
                <!-- 重置按钮 -->
                <button 
                  v-if="task.is_completed === 1" 
                  class="action-btn reset-btn"
                  @click="resetTask(task.id)"
                  title="重置任务状态"
                >
                  <span class="icon">↺</span>
                  重置
                </button>
                <!-- 删除按钮 -->
                <button 
                  class="action-btn delete-btn"
                  @click="deleteTask(task.id)"
                  title="删除任务"
                >
                  <span class="icon">🗑️</span>
                  删除
                </button>
              </div>
            </div>
            <div v-if="!myTasks.length" class="no-tasks-management">
              <span class="icon">📭</span>
              <p>暂无任务</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import {
  getTeamDetail,
  getTeamMembers,
  getTeamTasks,
  getTeamAchievements,
  getTeamComments,
  createTeamComment,
  createTeamTask,
  updateTeamTask,
  deleteTeamTask,
  joinTeam as joinTeamApi,
  leaveTeam as leaveTeamApi,
  getTeamTaskCompletionData,
  updateTaskCompletionStatus,
  quickCompleteTask,
  getTeamTasksStatistics
} from '@/api/community'
import { useUserStore } from '@/stores/user'

export default {
  name: 'StudyPair',
  setup() {
    const userStore = useUserStore()
    return { userStore }
  },
  data() {
    return {
      isJoined: false,
      showAllTasks: false, // 控制是否显示全部任务
     taskDisplayLimit: 3, // 任务显示限制数量
      newComment: '',
      teamData: {
        name: '',
        description: '',
        tags: [],
        studyDays: 0,
        completionRate: 0,
        completedTasks: 0,
        onlineMembers: 0,
        totalMembers: 0
      },
      actualTeamMembers: [], // 实际小组成员
      displayedMembers: [], // 显示的成员（前2个）
      myTasks: [],
      partnerTasks: [],
      historyTasks: [],
      filteredHistoryTasks: [],
      taskSummary: {
        pending: 0,
        inProgress: 0,
        completed: 0
      },
      achievements: [],
      comments: [],
      commentLimit: 3,
      taskDateFilter: 'all',
      showCreateTaskModal: false,
      showEditTaskModal: false,
      newTask: {
        title: '',
        description: '',
        deadline: '',
        assigneeId: null
      },
      editingTask: {
        id: null,
        title: '',
        description: '',
        deadline: '',
        assigneeId: null
      },
      teamAvatar: null,
      memberTaskCharts: {},
      memberProgress: {},
      allTasksByMember: {} // 按成员分组的任务
    }
  },
  computed: {
    currentUserId() {
      return this.userStore.userId
    },
    currentUserName() {
      return this.userStore.userName
    },
    hasEditPermission() {
      return this.isJoined
    },
    // 根据是否展开显示任务
    displayedTasks() {
      if (this.showAllTasks) {
        return this.combinedTasks
      } else {
        return this.combinedTasks.slice(0, this.taskDisplayLimit)
      }
    },
    
    // 是否有更多任务可以显示,
    hasMoreTasks() {
      return this.combinedTasks.length > this.taskDisplayLimit
    },
    combinedTasks() {
  const allTasks = []
  // 收集所有成员的任务
  Object.values(this.allTasksByMember).forEach(memberTasks => {
    allTasks.push(...memberTasks)
  })
  
  return allTasks.map(task => {
    // 获取成员名称
    const memberName = this.getMemberName(task.assigneeId) || '未知成员'
    
    return {
      ...task,
      assigneeType: task.assigneeId === this.currentUserId ? 'mine' : 'partner',
      assigneeLabel: memberName, // 显示成员名称
      assigneeName: memberName,  // 新增字段用于按钮显示
      timeLabel: this.formatTime(task.updatedTime || task.createTime)
    }
  })
},
    // 改为直接返回所有任务，不进行筛选
    filteredCombinedTasks() {
      return this.combinedTasks
    },
    displayedComments() {
      if (this.comments.length <= this.commentLimit) return this.comments
      return this.comments.slice(0, this.commentLimit)
    }
  },
  async mounted() {
    if (!this.userStore.userId) {
      try {
        await this.userStore.fetchUserProfile()
      } catch (error) {
        console.error('获取用户信息失败:', error)
        this.notify('error', '请先登录')
        return
      }
    }
    await this.loadTeamData()
  },
  methods: {
    // 获取成员首字母（安全方法）
    getMemberInitial(member) {
      if (!member || !member.name) return '?'
      return member.name.charAt(0)
    },

    // 切换显示全部任务
    toggleAllTasks() {
      this.showAllTasks = !this.showAllTasks
    },

    // 获取成员唯一键（安全方法）
    getMemberKey(member, index = 0) {
      if (!member) return `member-${index}`
      return member.userId || member.id || `member-${index}`
    },
    
    // 获取成员名称
    getMemberName(userId) {
      const member = this.actualTeamMembers.find(m => m.userId === userId)
      return member ? member.name : '未知成员'
    },
    
    // 获取指定成员的任务
    getMemberTasks(userId) {
      return this.allTasksByMember[userId] || []
    },

    // 刷新图表数据
  async refreshChartData() {
    try {
      const teamId = this.$route.params.teamId
      
      // 重新加载任务完成数据
      const taskResponse = await getTeamTaskCompletionData(teamId)
      if (taskResponse && taskResponse.success && taskResponse.data) {
        const taskData = taskResponse.data
        
        // 处理成员数据
        if (taskData.users && Array.isArray(taskData.users)) {
          this.actualTeamMembers = taskData.users.map(user => ({
            userId: user.user_id,
            name: user.user_name || '未知成员',
            avatarUrl: user.avatar_url,
            completed_task_count: user.completed_task_count || 0,
            total_completion_hours: user.total_completion_hours || '0.0',
            average_completion_minutes: user.average_completion_minutes || 0,
            pie_chart: user.pie_chart,
            tasks: user.tasks || []
          }))
          
          // 按成员分组任务
          this.allTasksByMember = {}
          this.actualTeamMembers.forEach(member => {
            this.allTasksByMember[member.userId] = (member.tasks || []).map(task => ({
              id: task.task_id,
              title: task.task_title || task.title || '未命名任务',
              description: task.task_description || task.description || '',
              assigneeId: member.userId,
              assignee_id: member.userId,
              is_completed: task.is_completed || 0,
              completion_time: task.completion_time || null,
              completed_at: task.completed_at || null,
              due_date: task.due_date || null,
              priority: task.priority || 'medium',
              status: task.is_completed === 1 ? 'completed' : 'pending',
              createTime: task.created_at || task.create_time || new Date().toISOString(),
              updateTime: task.updated_at || task.update_time || new Date().toISOString(),
              estimatedTime: task.estimated_time || null
            }))
          })
          
          // 选择前2个成员显示
          this.displayedMembers = this.actualTeamMembers.slice(0, 2)
          
          // 重新计算成员进度
          this.calculateAllMemberProgress()
          
          // 重新初始化图表
          this.$nextTick(() => {
            this.initMemberTaskCharts()
          })
        }
      }
    } catch (error) {
      console.error('刷新图表数据失败:', error)
    }
  },
    
    // 加载团队数据
    async loadTeamData() {
      try {
        const teamId = this.$route.params.teamId
        
        // 1. 加载团队基本信息和成员状态
        const teamResponse = await getTeamDetail(teamId, this.currentUserId)
        if (teamResponse && teamResponse.success && teamResponse.data) {
          const data = teamResponse.data
          this.isJoined = data.is_joined !== undefined ? data.is_joined : false

          const parsedTags = this.parseTags(data.tags)
          this.teamData = {
            name: data.team_name,
            description: data.description,
            tags: parsedTags,
            studyDays: data.total_study_days || 0,
            completionRate: data.completion_rate || 0,
            completedTasks: data.completed_tasks || 0,
            onlineMembers: data.online_members || 0,
            totalMembers: data.current_members || data.max_members || 0
          }
          
          // 获取实际小组成员
          this.actualTeamMembers = data.members || []
        }

        // 2. 加载任务完成数据（包含所有成员的任务）
        const taskResponse = await getTeamTaskCompletionData(teamId)
        if (taskResponse && taskResponse.success && taskResponse.data) {
          const taskData = taskResponse.data
          
          // 处理成员数据
          if (taskData.users && Array.isArray(taskData.users)) {
            this.actualTeamMembers = taskData.users.map(user => ({
              userId: user.user_id,
              name: user.user_name || '未知成员',
              avatarUrl: user.avatar_url,
              completed_task_count: user.completed_task_count || 0,
              total_completion_hours: user.total_completion_hours || '0.0',
              average_completion_minutes: user.average_completion_minutes || 0,
              pie_chart: user.pie_chart,
              tasks: user.tasks || []
            }))
            
            // 调试日志：查看第一个成员的第一个任务的数据结构
            console.log('任务数据结构检查:', this.actualTeamMembers[0]?.tasks?.[0])
            
            // 按成员分组任务
            this.allTasksByMember = {}
            this.actualTeamMembers.forEach(member => {
              this.allTasksByMember[member.userId] = (member.tasks || []).map(task => {
                // 调试每个任务的字段
                console.log('任务字段:', {
                  task_id: task.task_id,
                  task_title: task.task_title,
                  title: task.title,
                  description: task.task_description || task.description
                })
                
                return {
                  id: task.task_id,
                  // 优先使用 task_title，如果不存在则使用 title
                  title: task.task_title || task.title || '未命名任务',
                  description: task.task_description || task.description || '',
                  assigneeId: member.userId,
                  assignee_id: member.userId,
                  is_completed: task.is_completed || 0,
                  completion_time: task.completion_time || null,
                  completed_at: task.completed_at || null,
                  due_date: task.due_date || null,
                  priority: task.priority || 'medium',
                  status: task.is_completed === 1 ? 'completed' : 'pending',
                  createTime: task.created_at || task.create_time || new Date().toISOString(),
                  updateTime: task.updated_at || task.update_time || new Date().toISOString(),
                  estimatedTime: task.estimated_time || null
                }
              })
            })
            
            // 选择前2个成员显示
            this.displayedMembers = this.actualTeamMembers.slice(0, 2)
            
            // 计算成员进度
            this.calculateAllMemberProgress()
          }
        }

        // 3. 加载留言数据
        const commentsResponse = await getTeamComments(teamId)
        if (commentsResponse && commentsResponse.success && commentsResponse.data) {
          this.comments = commentsResponse.data.map(item => ({
            id: item.message_id,
            userId: item.sender_id,
            userName: item.user_name || '同学',
            content: item.content,
            createdTime: item.create_time
          }))
        }

        // 4. 加载成就数据（只有已加入小组的用户才显示）
        if (this.isJoined) {
          this.calculateAchievements()
        }

        // 5. 设置默认值
        if (!this.newTask.assigneeId) {
          this.newTask.assigneeId = this.currentUserId
        }

        // 6. 等待DOM更新后初始化图表
        this.$nextTick(() => {
          this.initMemberTaskCharts()
        })

      } catch (error) {
        console.error('加载团队数据失败:', error)
        this.notify('error', '加载数据失败，请稍后重试')
      }
    },
    
    // 计算所有成员的任务进度
    calculateAllMemberProgress() {
      this.memberProgress = {}
      
      // 为每个成员计算进度
      this.actualTeamMembers.forEach(member => {
        const tasks = this.allTasksByMember[member.userId] || []
        const completedTasks = tasks.filter(task => 
          task.is_completed === 1 || task.is_completed === true
        ).length
        
        const totalTasks = tasks.length
        const progressData = {
          completed: completedTasks,
          total: totalTasks,
          percentage: totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0
        }
        
        this.memberProgress[member.userId] = progressData
      })
      
      // 更新整体任务统计
      this.updateTaskProgressSummary()
    },
    
    // 更新整体任务进度统计
    updateTaskProgressSummary() {
      let totalTasks = 0
      let completedTasks = 0
      
      // 遍历所有成员的任务
      Object.values(this.allTasksByMember).forEach(tasks => {
        totalTasks += tasks.length
        completedTasks += tasks.filter(task => 
          task.is_completed === 1 || task.is_completed === true
        ).length
      })
      
      const pendingTasks = totalTasks - completedTasks
      const completionRate = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0
      
      this.taskSummary = {
        total: totalTasks,
        completed: completedTasks,
        pending: pendingTasks,
        completionRate: completionRate
      }
      
      // 更新团队数据中的完成率
      if (this.teamData) {
        this.teamData.completionRate = completionRate
        this.teamData.completedTasks = completedTasks
      }
    },
    
    // 初始化成员任务饼状图
    initMemberTaskCharts() {
      this.displayedMembers.forEach(member => {
        if (member.pie_chart && member.pie_chart.labels && member.pie_chart.labels.length > 0) {
          this.initMemberTaskChart(member.userId, member.pie_chart)
        } else {
          this.initEmptyChart(member.userId)
        }
      })
    },
    
    // 初始化单个成员的任务饼状图
    initMemberTaskChart(userId, chartData) {
      const chartRef = `memberTaskChart${userId}`
      const chartDom = this.$refs[chartRef]
      if (!chartDom || !chartDom[0]) {
        console.error(`未找到成员 ${userId} 的饼状图DOM元素`)
        return
      }
      
      // 销毁旧图表
      if (this.memberTaskCharts[userId]) {
        this.memberTaskCharts[userId].dispose()
      }
      
      try {
        // 初始化图表
        const chart = echarts.init(chartDom[0])
        
        const pieData = chartData.labels.map((label, index) => ({
          name: label,
          value: chartData.datasets[0].data[index] || 0,
          itemStyle: {
            color: chartData.datasets[0].backgroundColor[index] || this.getChartColor(index)
          }
        }))
        
        if (pieData.length === 0) {
          this.initEmptyChart(userId)
          return
        }
        
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
        
        chart.setOption(option)
        this.memberTaskCharts[userId] = chart
        
        window.addEventListener('resize', () => {
          if (this.memberTaskCharts[userId]) {
            this.memberTaskCharts[userId].resize()
          }
        })
        
      } catch (error) {
        console.error(`初始化成员 ${userId} 任务饼状图失败:`, error)
      }
    },

    // 初始化空状态图表
    initEmptyChart(userId) {
      const chartRef = `memberTaskChart${userId}`
      const chartDom = this.$refs[chartRef]
      if (!chartDom || !chartDom[0]) return
      
      if (this.memberTaskCharts[userId]) {
        this.memberTaskCharts[userId].dispose()
      }
      
      const chart = echarts.init(chartDom[0])
      
      const option = {
        title: {
          text: '暂无已完成任务',
          left: 'center',
          top: 'center',
          textStyle: {
            color: '#999',
            fontSize: 14,
            fontWeight: 'normal'
          }
        },
        graphic: {
          type: 'text',
          left: 'center',
          top: '45%',
          style: {
            text: '📊',
            fontSize: 30,
            fill: '#ccc'
          }
        }
      }
      
      chart.setOption(option)
      this.memberTaskCharts[userId] = chart
    },

    // 切换任务完成状态
async toggleTaskCompletion(task) {
  if (!this.isJoined) {
    this.notify('warning', '请先加入小组以操作任务')
    return
  }
  
  // 只能操作自己的任务
  const taskAssigneeId = task.assigneeId || task.assignee_id;
  if (taskAssigneeId !== this.currentUserId) {
    this.notify('warning', '只能操作自己的任务')
    return;
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
      const allTasks = Object.values(this.allTasksByMember).flat()
      const taskToUpdate = allTasks.find(t => t.id === taskId)
      
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
      this.calculateAllMemberProgress();
      
      // 重新刷新图表数据
      await this.refreshChartData();
    } else {
      this.notify('error', response?.message || '操作失败');
    }
  } catch (error) {
    console.error('更新任务状态失败:', error);
    this.notify('error', error?.response?.data?.message || '操作失败');
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
          const allTasks = Object.values(this.allTasksByMember).flat()
          const taskToUpdate = allTasks.find(t => t.id === taskId)
          
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
          this.calculateAllMemberProgress();
          
          // 重新加载数据以更新饼图
          await this.loadTeamData();
        } else {
          this.notify('error', response?.message || '操作失败');
        }
      } catch (error) {
        console.error('更新任务状态失败:', error);
        this.notify('error', error?.response?.data?.message || '操作失败');
      }
    },

    // 快速完成任务
    async quickCompleteTask(taskId) {
      if (!this.isJoined) {
        this.notify('warning', '请先加入小组以操作任务')
        return
      }
      
      try {
        const response = await quickCompleteTask(taskId, {
          user_id: this.currentUserId
        })
        
        if (response && response.success) {
          // 更新本地任务状态
          const allTasks = Object.values(this.allTasksByMember).flat()
          const task = allTasks.find(t => t.id === taskId)
          if (task) {
            task.is_completed = 1
            task.completion_time = 30
            task.completed_at = new Date().toISOString()
          }
          
          this.notify('success', '任务已完成（默认30分钟）')
          
          // 重新计算统计
          this.calculateAllMemberProgress()
          
          // 重新加载数据以更新饼图
          await this.refreshChartData()
        }
      } catch (error) {
        console.error('快速完成任务失败:', error)
        this.notify('error', error?.response?.data?.message || '操作失败')
      }
    },
    
    // 解析标签
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

    // 加入小组
    async joinTeam() {
      try {
        const teamId = this.$route.params.teamId
        const response = await joinTeamApi(teamId, this.currentUserId)
        if (response.success) {
          this.notify('success', '已成功加入小组')
          this.isJoined = true
          await this.loadTeamData()
        } else {
          this.notify('error', response?.message || '加入失败')
        }
      } catch (error) {
        console.error('加入小组失败:', error)
        this.notify('error', '加入失败，请稍后重试')
      }
    },
    
    // 离开小组
    async leaveTeam() {
      if (!confirm('确定要退出该学习小组吗？退出后将无法查看小组详情。')) {
        return
      }
      
      try {
        const teamId = this.$route.params.teamId
        const response = await leaveTeamApi(teamId, this.currentUserId)
        if (response.success) {
          this.notify('success', '已成功退出小组')
          this.isJoined = false
          // 刷新页面或返回小组列表
          this.$router.push('/community/teams')
        } else {
          this.notify('error', response?.message || '退出失败')
        }
      } catch (error) {
        console.error('退出小组失败:', error)
        this.notify('error', '退出失败，请稍后重试')
      }
    },
    
    // 分享小组
    shareTeam() {
      const teamUrl = window.location.href
      if (navigator.share) {
        navigator.share({
          title: this.teamData.name,
          text: this.teamData.description,
          url: teamUrl
        })
      } else {
        navigator.clipboard.writeText(teamUrl)
        this.notify('success', '链接已复制到剪贴板')
      }
    },
    
    // 更新任务状态
    async updateTaskStatus(taskId, newStatus) {
      if (!this.isJoined) {
        this.notify('warning', '请先加入小组以操作任务')
        return
      }
      
      // 这里可以根据需要添加实际的状态更新逻辑
      this.notify('info', '任务状态更新功能待实现')
    },

    // 提醒伙伴
    remindPartner(task) {
      if (!this.isJoined) {
        this.notify('warning', '请先加入小组以提醒伙伴')
        return
      }
      
      const memberName = this.getMemberName(task.assigneeId)
      this.notify('success', `已提醒 ${memberName} 尽快完成：${task.title}`)
    },
    
    // 提交留言
    async submitComment() {
      if (!this.isJoined) {
        this.notify('warning', '请先加入小组以发表留言')
        return
      }
      
      if (!this.newComment.trim()) return
      
      try {
        const teamId = this.$route.params.teamId
        
        const response = await createTeamComment(teamId, {
          user_id: this.currentUserId,
          content: this.newComment
        })
        
        this.newComment = ''
        
        if (response && response.success && response.data) {
          const saved = response.data
          this.comments.unshift({
            id: saved.message_id || Date.now(),
            userId: this.currentUserId,
            userName: saved.user_name || this.currentUserName || '我',
            content: saved.content,
            createdTime: saved.create_time || new Date().toISOString()
          })
        } else {
          this.notify('error', response?.message || '发送失败')
        }
      } catch (error) {
        console.error('发送留言失败:', error)
        this.notify('error', error?.response?.data?.message || '发送失败，请稍后重试')
      }
    },
    
    // 获取任务状态文本
    getTaskStatusText(task) {
      const statusMap = {
        'completed': '已完成',
        'in_progress': '进行中',
        'pending': '待开始'
      }

      if (task.status === 'completed') {
        return `已完成 ✓ ${this.formatTime(task.updatedTime)}`
      } else if (task.status === 'in_progress') {
        return task.assigneeId === this.currentUserId ? '进行中' : '伙伴进行中'
      } else {
        return task.assigneeId === this.currentUserId ? '待开始' : '等待伙伴开始'
      }
    },
    
    // 格式化时间
    formatTime(timestamp) {
      if (!timestamp) return ''
      
      const now = new Date()
      const time = new Date(timestamp)
      const diff = now - time
      
      const minutes = Math.floor(diff / 60000)
      const hours = Math.floor(diff / 3600000)
      const days = Math.floor(diff / 86400000)
      
      if (minutes < 60) {
        return `${minutes}分钟前`
      } else if (hours < 24) {
        return `${hours}小时前`
      } else if (days === 1) {
        return '昨天'
      } else {
        return time.toLocaleDateString()
      }
    },

     // 打开编辑任务模态框
  openEditTaskModal() {
    if (!this.isJoined) {
      this.notify('warning', '请先加入小组以编辑任务')
      return
    }
    // 加载当前用户的任务
    this.loadMyTasks()
    this.showEditTaskModal = true
  },
  
  // 关闭编辑任务模态框
  closeEditTaskModal() {
    this.showEditTaskModal = false
    this.resetNewTask()
  },
  
  // 加载当前用户的任务
  loadMyTasks() {
    // 从 allTasksByMember 中获取当前用户的任务
    this.myTasks = this.allTasksByMember[this.currentUserId] || []
  },
  
  // 重置任务状态
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
          task.is_completed = 0
          task.completion_time = null
          task.completed_at = null
        }
        this.notify('success', '任务已重置为未完成')
        this.calculateAllMemberProgress()
      }
    } catch (error) {
      console.error('重置任务失败:', error)
      this.notify('error', '操作失败')
    }
  },
  
  // 删除任务
async deleteTask(taskId) {
  if (!confirm('确定要删除这个任务吗？此操作不可撤销。')) {
    return
  }
  
  try {
    const response = await deleteTeamTask(taskId, {
      user_id: this.currentUserId
    })
    
    if (response && response.success) {
      // 从本地列表中移除任务
      this.myTasks = this.myTasks.filter(task => task.id !== taskId)
      
      // 更新 allTasksByMember
      if (this.allTasksByMember[this.currentUserId]) {
        this.allTasksByMember[this.currentUserId] = 
          this.allTasksByMember[this.currentUserId].filter(task => task.id !== taskId)
      }
      
      this.notify('success', '任务已删除')
      
      // 重新计算统计
      this.calculateAllMemberProgress()
      
      // 重新刷新图表数据
      await this.refreshChartData()
    } else {
      this.notify('error', response?.message || '删除失败')
    }
  } catch (error) {
    console.error('删除任务失败:', error)
    this.notify('error', error?.response?.data?.message || '删除失败')
  }
},
  
  // 提交新任务（修改，确保监督对象为当前用户）
async submitNewTask() {
  if (!this.isJoined) {
    this.notify('warning', '请先加入小组以创建任务')
    return
  }
  
  if (!this.newTask.title.trim()) {
    this.notify('error', '请填写任务标题')
    return
  }
  
  try {
    const teamId = this.$route.params.teamId
    const payload = {
      creator_id: this.currentUserId,
      title: this.newTask.title.trim(),
      description: this.newTask.description.trim(),
      deadline: null,  // 根据需求，不需要截止日期
      assignee_id: this.currentUserId  // 固定为当前用户
    }
    
    const response = await createTeamTask(teamId, payload)
    if (response && response.success) {
      this.notify('success', '任务创建成功')
      
      // 刷新任务列表
      await this.refreshChartData()
      
      // 加载当前用户的任务
      this.loadMyTasks()
      
      // 清空表单
      this.resetNewTask()
    } else {
      this.notify('error', response?.message || '创建任务失败')
    }
  } catch (error) {
    console.error('创建任务失败:', error)
    this.notify('error', error?.response?.data?.message || '创建任务失败，请稍后重试')
  }
},
  
  // 重置新任务数据
  resetNewTask() {
    this.newTask = {
      title: '',
      description: ''
    }
  },

    // 查看所有留言
    viewAllComments() {
      this.notify('success', '查看留言记录功能待实现')
    },

    // 展开留言
    expandComments() {
      this.commentLimit = this.comments.length
    },

    // 计算个人成就
    calculateAchievements() {
      const achievements = []
      
      // 获取当前用户的任务
      const myTasks = this.allTasksByMember[this.currentUserId] || []
      const myCompletedCount = myTasks.filter(t => t.is_completed === 1).length
      const myTotalCount = myTasks.length
      const completionRate = myTotalCount > 0 ? Math.round((myCompletedCount / myTotalCount) * 100) : 0

      // 成就1: 初出茅庐 - 完成第一个任务
      if (myCompletedCount >= 1) {
        achievements.push({
          id: 'first_task',
          name: '初出茅庐',
          description: '完成了第一个学习任务',
          icon: '🎯'
        })
      }

      // 成就2: 勤奋学习 - 完成5个任务
      if (myCompletedCount >= 5) {
        achievements.push({
          id: 'five_tasks',
          name: '勤奋学习',
          description: '累计完成5个学习任务',
          icon: '📚'
        })
      }

      // 成就3: 学霸之路 - 完成10个任务
      if (myCompletedCount >= 10) {
        achievements.push({
          id: 'ten_tasks',
          name: '学霸之路',
          description: '累计完成10个学习任务',
          icon: '🏆'
        })
      }

      // 成就4: 完美主义 - 任务完成率达到100%
      if (completionRate === 100 && myTotalCount > 0) {
        achievements.push({
          id: 'perfectionist',
          name: '完美主义',
          description: '任务完成率达到100%',
          icon: '💯'
        })
      }

      // 成就5: 高效达人 - 任务完成率超过80%
      if (completionRate >= 80 && myTotalCount >= 3) {
        achievements.push({
          id: 'efficient',
          name: '高效达人',
          description: '任务完成率超过80%',
          icon: '⚡'
        })
      }

      // 成就6: 团队协作 - 有伙伴且双方都有任务
      if (this.actualTeamMembers.length > 1) {
        achievements.push({
          id: 'teamwork',
          name: '团队协作',
          description: '与伙伴共同学习进步',
          icon: '🤝'
        })
      }

      // 成就7: 坚持不懈 - 连续学习（基于团队学习天数）
      if (this.teamData.studyDays >= 7) {
        achievements.push({
          id: 'persistent',
          name: '坚持不懈',
          description: `已坚持学习${this.teamData.studyDays}天`,
          icon: '🔥'
        })
      }

      this.achievements = achievements
    },

    // 通知方法
    notify(type, message) {
      const messenger = this.$message
      if (messenger && typeof messenger[type] === 'function') {
        messenger[type](message)
      } else {
        if (type === 'error') {
          console.error(message)
        } else {
          console.log(message)
        }
      }
    },

    // 组件销毁时清理图表
    beforeDestroy() {
      Object.values(this.memberTaskCharts).forEach(chart => {
        if (chart && chart.dispose) {
          chart.dispose()
        }
      })
      
      window.removeEventListener('resize', this.handleResize)
    },

    // 获取图表颜色
    getChartColor(index) {
      const colors = [
        '#1a73e8', '#34a853', '#f9ab00', '#ea4335',
        '#8e44ad', '#1abc9c', '#e74c3c', '#2ecc71'
      ];
      return colors[index % colors.length];
    }
  }
}
</script>

<style scoped>
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

.view-only-badge {
  background: rgba(108, 117, 125, 0.2);
  color: #495057;
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 0.85rem;
  margin-left: 10px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

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

.you-badge {
  color: #1a73e8;
  font-size: 0.9rem;
  margin-left: 4px;
}

.you-badge-small {
  color: #1a73e8;
  font-size: 0.8rem;
  margin-left: 4px;
}

.partner-avatar.is-me {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

.task-checkbox.readonly {
  cursor: default;
  background: #f5f5f5;
}

.task-card-action.view-only {
  background: #e9ecef;
  color: #6c757d;
  cursor: default;
}

.task-card-action.view-only:hover {
  background: #e9ecef;
}

.no-tasks {
  text-align: center;
  padding: 20px;
  color: #94a3b8;
}

.no-tasks .icon {
  font-size: 1.5rem;
  margin-bottom: 8px;
  display: block;
}

.no-members {
  text-align: center;
  padding: 20px;
  color: #94a3b8;
  border: 1px dashed #cbd5e1;
  border-radius: 10px;
}

.no-members .icon {
  font-size: 2rem;
  margin-bottom: 10px;
  display: block;
}



/* 其他原有样式保持不变 */
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
  width: 100%;
  max-width: 100%;
  margin: 0;
  padding: 0 20px;
}

/* 图标样式 */
.icon {
  display: inline-block;
  margin-right: 8px;
  font-size: 1.1em;
  vertical-align: middle;
}

/* 组队头部 */
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
}

.avatar-member {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: var(--primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 1.2rem;
  position: absolute;
  border: 3px solid white;
}

.avatar-member.member-1 {
  top: 10px;
  left: 15px;
  background: var(--primary);
}

.avatar-member.member-2 {
  bottom: 10px;
  right: 15px;
  background: var(--secondary);
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

.upload-overlay i {
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

.team-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
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

.no-tasks-management .icon {
  font-size: 2rem;
  margin-bottom: 10px;
  display: block;
}

/* 查看全部按钮样式 */
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

.view-all-btn .icon {
  font-size: 1rem;
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

.collapse-btn .icon {
  font-size: 1rem;
}

/* 空状态消息更新 */
.tasklist-empty p {
  font-size: 0.9rem;
  color: #94a3b8;
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

.btn-secondary {
  background: rgba(255,255,255,0.2);
  color: white;
  backdrop-filter: blur(10px);
}

.btn-secondary:hover {
  background: rgba(255,255,255,0.3);
}

.btn-danger {
  background: rgba(255,255,255,0.2);
  color: white;
  backdrop-filter: blur(10px);
}

.btn-danger:hover {
  background: rgba(255,255,255,0.3);
}

/* 主要内容布局 */
.main-content {
  display: grid;
  grid-template-columns: 1fr 400px; /* 固定右侧栏宽度 */
  gap: 24px;
  width: 100%;
}

/* 左侧主要内容区 */
.left-column {
  flex: 1;
  min-width: 0; /* 防止内容溢出 */
}

/* 右侧栏 */
.right-column {
  width: 400px;
  flex-shrink: 0;
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

/* 学习进度对比 */
.progress-comparison {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
}

.member-card {
  background: white;
  border-radius: 16px;
  padding: 25px;
  text-align: center;
  border: 1px solid rgba(0, 0, 0, 0.08);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  position: relative;
}

.member-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.member-avatar-wrapper {
  position: relative;
  width: 90px;
  height: 90px;
  margin: 0 auto 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.member-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.8rem;
  font-weight: bold;
  margin: 0 auto;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
  position: relative;
  z-index: 1;
}

.member-avatar:not(.partner) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: 3px solid #667eea;
}

.member-avatar.partner {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  border: 3px solid #22c55e;
}

.current-user-badge {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  border: 3px solid white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  z-index: 2;
}

.member-card h3 {
  font-size: 1.2rem;
  margin-bottom: 10px;
  color: #1e293b;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.chart-container {
  height: 250px;
  margin-top: 15px;
  margin-bottom: 15px;
  position: relative;
}

.no-data-chart {
  height: 180px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: var(--gray);
  background: var(--light);
  border-radius: 8px;
  margin-bottom: 15px;
}

.no-data-chart i {
  font-size: 2rem;
  margin-bottom: 10px;
  opacity: 0.5;
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

/* 任务统计卡片 */
.task-summary-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 15px;
  margin-bottom: 25px;
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
  color: #34a853;
}

.summary-icon.pending {
  background: #fff3e0;
  color: #ff9800;
}

.summary-icon.total {
  background: #e3f2fd;
  color: #1a73e8;
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

/* 任务监督 */
.task-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.task-column h4 {
  margin-bottom: 15px;
  color: var(--primary);
  display: flex;
  align-items: center;
  gap: 8px;
}

.task-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 15px;
  background: var(--my-task-bg);
  border-radius: 10px;
  position: relative;
}

.task-item.task-completed {
  background: #e8f5e8;
  border-left: 4px solid #4caf50;
}

.task-info {
  flex: 1;
  min-width: 0;
}

.task-checkbox {
  width: 24px;
  height: 24px;
  border: 2px solid var(--border);
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.3s ease;
  background: white;
}

.task-checkbox:hover:not(.readonly) {
  border-color: var(--primary);
  background: var(--primary-light);
}

.task-checkbox span {
  font-size: 14px;
  font-weight: bold;
  color: white;
}

.task-checkbox i {
  font-size: 12px;
  color: white;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.task-checkbox.checked {
  background: var(--secondary);
  border-color: var(--secondary);
}

.task-checkbox.checked i {
  opacity: 1;
}

.task-checkbox.readonly {
  cursor: default;
  background: #f5f5f5;
}

.task-checkbox.readonly:hover {
  border-color: var(--border);
  background: #f5f5f5;
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

.task-description {
  font-size: 0.85rem;
  color: #666;
  margin: 5px 0;
  line-height: 1.4;
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

/* 完成时间相关样式 */
.completion-time-simple {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 8px;
  font-size: 0.85rem;
  color: #2e7d32;
}

/* 按钮样式 */
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
}

.quick-complete-btn:hover {
  background: linear-gradient(135deg, #f57c00, #e64a19);
  transform: translateY(-1px);
}

.remind-btn {
  background: #fff3cd;
  border: 1px solid #ffeaa7;
  color: #856404;
  padding: 6px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s ease;
  margin-left: auto;
}

.remind-btn:hover {
  background: #ffeaa7;
  border-color: #f39c12;
  color: #b7791f;
}

/* 右侧内容样式 */
.right-column .content-section {
  margin-bottom: 20px;
}

.partner-info {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
}

.partner-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: var(--secondary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  font-weight: bold;
}

.partner-details h4 {
  margin: 0 0 5px 0;
  font-size: 1.1rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.partner-details p {
  margin: 0;
  color: var(--gray);
  font-size: 0.9rem;
}

/* 任务清单样式 */
.tasklist-section {
  padding: 24px 28px;
  border-radius: 16px;
  background: #fff;
}

.tasklist-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tasklist-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1.15rem;
  font-weight: 700;
  color: #0f172a;
}

.tasklist-title i {
  color: #2563eb;
}

.tasklist-actions {
  display: flex;
  gap: 10px;
}

.tasklist-add {
  border: 1px solid rgba(15, 23, 42, 0.08);
  border-radius: 999px;
  padding: 8px 16px;
  background: #f8fafc;
  color: #1e40af;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.tasklist-add {
  background: linear-gradient(135deg, #22c55e, #16a34a);
  border-color: rgba(22,163,74,0.35);
  color: white;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(22,163,74,0.2);
}

.tasklist-add:hover {
  background: linear-gradient(135deg, #16a34a, #15803d);
  box-shadow: 0 4px 12px rgba(22,163,74,0.3);
  transform: translateY(-2px);
}

.tasklist-tabs {
  margin: 20px 0;
  display: flex;
  gap: 12px;
}

.tasklist-tab {
  border: none;
  padding: 10px 20px;
  border-radius: 12px;
  background: #f1f5f9;
  color: #475569;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 6px;
}

.tasklist-tab.active {
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
  color: #fff;
  box-shadow: 0 6px 16px rgba(37,99,235,0.25);
}

.task-summary {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  background: #f8fafc;
  padding: 14px 18px;
  border-radius: 12px;
  border: 1px solid rgba(15, 23, 42, 0.05);
}

.task-summary-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.task-count {
  font-size: 0.8rem;
  color: #64748b;
  display: flex;
  align-items: center;
  gap: 4px;
}

.task-number {
  font-weight: 700;
  font-size: 1.15rem;
  color: #2563eb;
}

.tasklist-body {
  margin-top: 18px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.task-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 18px;
  border-radius: 14px;
  background: #eef2ff;
  border-left: 6px solid #2563eb;
  transition: all 0.2s ease;
}

.task-card.partner {
  background: #ecfdf5;
  border-color: #16a34a;
}

.task-card.status-completed {
  background: #f1f5f9;
  border-color: #22c55e;
}

.task-card.status-pending {
  background: #fef2f2;
  border-color: #f97316;
}

.task-card-main {
  display: flex;
  align-items: center;
  gap: 14px;
  flex: 1;
}

.task-status-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: rgba(255,255,255,0.85);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.95rem;
  color: #1e3a8a;
}

.task-info-block {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.task-card-title {
  font-weight: 600;
  font-size: 1rem;
  color: #0f172a;
}

.task-card-meta {
  font-size: 0.85rem;
  color: #64748b;
}

.task-card-action {
  border: none;
  border-radius: 999px;
  padding: 8px 18px;
  background: rgba(37,99,235,0.12);
  color: #1d4ed8;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.task-card-action:hover {
  background: rgba(37,99,235,0.2);
}

.tasklist-empty {
  margin-top: 20px;
  text-align: center;
  color: #94a3b8;
  padding: 40px 20px;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px dashed rgba(148,163,184,0.4);
}

.tasklist-empty i {
  font-size: 2rem;
  margin-bottom: 10px;
}

/* 成就样式 */
.achievements {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.achievement-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: var(--light);
  border-radius: 10px;
}

.achievement-icon {
  font-size: 1.5rem;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border-radius: 50%;
}

.achievement-title {
  font-weight: 600;
  margin-bottom: 2px;
}

.achievement-desc {
  font-size: 0.8rem;
  color: var(--gray);
}

/* 留言区样式 */
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

.board-title i {
  color: #2563eb;
  font-size: 1.3rem;
}

.board-history-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  border: 1px solid rgba(37,99,235,0.3);
  color: #1d4ed8;
  padding: 6px 14px;
  border-radius: 999px;
  background: #eef2ff;
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.25s ease;
}

.board-history-btn:hover {
  background: #dbeafe;
  border-color: rgba(37,99,235,0.45);
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

.board-empty i {
  font-size: 2.3rem;
}

/* 模态框样式 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 15px;
  padding: 30px;
  max-width: 500px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 1px solid var(--border);
}

.modal-title {
  font-size: 1.3rem;
  font-weight: 600;
  color: var(--dark);
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: var(--gray);
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.close-btn:hover {
  background: var(--light);
  color: var(--dark);
}

/* 表单样式 */
.form-group {
  margin-bottom: 20px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: var(--dark);
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 6px;
}

.form-input, .form-textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  font-size: 0.9rem;
  font-family: inherit;
  transition: border-color 0.3s ease;
}

.form-input:focus, .form-textarea:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(26, 115, 232, 0.1);
}

.form-textarea {
  min-height: 80px;
  resize: vertical;
}

.search-form, .add-task-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.search-results {
  max-height: 300px;
  overflow-y: auto;
  margin-top: 20px;
}

.empty-placeholder {
  text-align: center;
  color: var(--gray);
  padding: 40px 20px;
  font-style: italic;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.search-result-item {
  padding: 15px;
  border: 1px solid var(--border);
  border-radius: 8px;
  margin-bottom: 10px;
  background: white;
  transition: all 0.3s ease;
}

.search-result-item:hover {
  background: var(--light);
  border-color: var(--primary);
}

.history-task-title {
  font-weight: 500;
  margin-bottom: 5px;
}

.history-task-meta {
  font-size: 0.8rem;
  color: var(--gray);
}

.submit-btn {
  padding: 12px 24px;
  background: var(--primary);
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.submit-btn:hover {
  background: #1557b0;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .main-content {
    grid-template-columns: 1fr;
  }
  
  .progress-comparison {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .task-grid {
    grid-template-columns: 1fr;
  }
  
  .team-info {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .team-avatar {
    margin: 0 auto;
  }
  
  .team-stats {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .task-summary-cards {
    grid-template-columns: repeat(2, 1fr);
  }
}

.pair-warning {
  margin-top: 10px;
  padding: 8px 12px;
  background: rgba(255, 193, 7, 0.1);
  border: 1px solid rgba(255, 193, 7, 0.3);
  border-radius: 6px;
  font-size: 0.85rem;
  color: #856404;
  display: flex;
  align-items: center;
  gap: 8px;
}

.task-count {
  font-size: 0.9rem;
  color: var(--gray);
  font-weight: normal;
  margin-left: 8px;
}
</style>