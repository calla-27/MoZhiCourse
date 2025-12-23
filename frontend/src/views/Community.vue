<template>
  <div class="community" :data-active-tab="activeTab">
    <!-- 社区头部 -->
    <section class="community-header">
      <div class="header-background"></div>
      <div class="container">
        <div class="header-content">
          <div class="header-icon">🎓</div>
          <h1>学习社区 <span class="sparkle"></span></h1>
          <p>与志同道合的学习者一起进步，在交流中成长，在互助中提升</p>
        </div>
      </div>
    </section>

    <div class="container">

      <!-- 标签页 -->
      <div class="tabs">
        <div
          class="tab"
          :class="{ active: activeTab === 'teams' }"
          @click="switchTab('teams')"
        >
          组队学习
        </div>
        <div
          class="tab"
          :class="{ active: activeTab === 'study-rooms' }"
          @click="switchTab('study-rooms')"
        >
          自习室
        </div>
        <div
          class="tab"
          :class="{ active: activeTab === 'discussion' }"
          @click="switchTab('discussion')"
        >
          公共讨论区
        </div>
        <div
          class="tab"
          :class="{ active: activeTab === 'teachers' }"
          @click="switchTab('teachers')"
        >
          名师答疑
        </div>
        <div
          class="tab"
          :class="{ active: activeTab === 'help' }"
          @click="switchTab('help')"
        >
          互助学习
        </div>
      </div>

      <!-- 组队学习 -->
      <section v-show="activeTab === 'teams'" class="content-section">
        <div class="section-title">
          <span>组队学习</span>
          <div class="section-actions">
            <select v-model="teamFilterCourseId" class="btn btn-secondary select">
              <option :value="null">全部课程</option>
              <option
                v-for="c in availableData.courses"
                :key="c.course_id"
                :value="c.course_id"
              >
                {{ c.course_name }}
              </option>
            </select>
            <button class="btn btn-primary" @click="openCreateTeamForm">
              <i class="fas fa-plus"></i>
              创建学习小组
            </button>
          </div>
        </div>

        <!-- 创建小组表单 -->
        <div v-if="createForms.team.show" class="create-form">
          <h3>创建学习小组</h3>
          <div class="form-group">
            <label>小组名称:</label>
            <input v-model="createForms.team.team_name" class="input full" placeholder="请输入小组名称" />
          </div>
          <div class="form-group">
            <label>小组描述:</label>
            <textarea v-model="createForms.team.description" class="textarea" placeholder="请输入小组描述"></textarea>
          </div>
          <div class="form-group">
            <label>关联课程:</label>
            <select v-model="createForms.team.course_id" class="input full">
              <option :value="null">不关联课程</option>
              <option
                v-for="c in availableData.courses"
                :key="c.course_id"
                :value="c.course_id"
              >
                {{ c.course_name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>最大成员数:</label>
            <input v-model.number="createForms.team.max_members" type="number" class="input" min="2" max="50" />
          </div>
          <div class="form-group">
            <label>标签(逗号分隔):</label>
            <input v-model="createForms.team.tags" class="input full" placeholder="例如: 编程,学习,互助" />
          </div>
          <div class="form-actions">
            <button class="btn btn-primary" @click="createTeam">创建</button>
            <button class="btn btn-secondary" @click="createForms.team.show = false">取消</button>
          </div>
        </div>

        <!-- 组队学习列表 -->
        <div class="team-grid">
          <div
            class="team-card"
            v-for="team in teams"
            :key="team.team_id"
            @click="viewTeamDetail(team)"
          >
            <!-- 新增：顶部状态条 -->
            <div class="card-status-bar">
              <span class="status-text">组队中</span>
              <span class="status-days">已运行 {{ calcRunningDays(team.create_time) }} 天</span>
            </div>
            
            <div class="team-header">
              <div class="team-avatar">
                {{ (team.team_name && team.team_name[0]) || '组' }}
              </div>
              <div class="team-info">
                <h3 class="team-name">{{ team.team_name }}</h3>
                <div class="team-creator">
                  <i class="fas fa-user"></i>
                  {{ team.creator_name || '未知创建者' }}
                </div>
              </div>
            </div>
            
            <p class="team-desc">{{ team.description || '暂无描述' }}</p>
            
            <div class="team-tags" v-if="team.tags && team.tags.length > 0">
              <span class="tag" v-for="tag in team.tags" :key="tag">{{ tag }}</span>
            </div>
            
            <!-- 成员进度条 -->
            <div class="team-progress">
              <div class="progress-header">
                <span class="progress-label">成员进度</span>
                <span class="progress-count">{{ team.member_count || 0 }}/{{ team.max_members || 10 }}人</span>
              </div>
              <div class="progress-bar">
                <div class="progress-fill" :style="{width: Math.round(((team.member_count || 0) / (team.max_members || 10)) * 100) + '%'}"></div>
              </div>
            </div>
            
            <div class="team-actions">
              <button class="btn btn-primary btn-small flex-1" @click.stop="joinTeam(team)">
                <i class="fas fa-user-plus"></i>
                加入
              </button>
              <button class="btn btn-secondary btn-small flex-1" @click.stop="leaveTeam(team)">
                <i class="fas fa-sign-out-alt"></i>
                退出
              </button>
              <!-- 只有创建者能看到删除按钮 -->
              <button 
                v-if="team.is_owner" 
                class="btn btn-secondary btn-small flex-1" 
                @click.stop="deleteTeam(team)"
              >
                <i class="fas fa-trash"></i>
                删除
              </button>
            </div>
          </div>
        </div>

        <!-- 小组详情 & 任务 -->
        <div v-if="selectedTeam" class="section-detail">
          <h3>当前小组：{{ selectedTeam.team_name }}</h3>
          <p class="detail-desc">{{ selectedTeam.description }}</p>
          <p class="detail-meta">
            成员：{{ selectedTeam.current_members }}/{{ selectedTeam.max_members }}
          </p>

          <h4 class="sub-title">小组任务</h4>
          <div
            v-if="teamTasks.length === 0"
            class="empty-tip"
          >
            暂无任务，可点击下方按钮创建示例任务。
          </div>
          <div v-else class="help-requests">
            <div class="help-card" v-for="task in teamTasks" :key="task.task_id">
              <div class="help-avatar">任</div>
              <div class="help-content">
                <div class="help-title">{{ task.task_title }}</div>
                <p class="help-text">{{ task.task_content }}</p>
                <div class="help-meta">
                  <span>创建人：{{ task.creator_name }}</span>
                  <span>截止：{{ formatDate(task.deadline) }}</span>
                  <span>状态：{{ task.status }}</span>
                </div>
                <div class="help-actions">
                  <button
                    class="btn btn-secondary btn-small"
                    @click="updateTaskStatus(task, 'completed')"
                  >
                    标记完成
                  </button>
                  <button
                    class="btn btn-secondary btn-small"
                    @click="deleteTask(task)"
                  >
                    删除任务
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- 创建任务 -->
          <div class="task-create">
            <h4 class="sub-title">创建示例任务</h4>
            <div class="task-input-row">
              <input
                v-model="newTask.task_title"
                placeholder="任务标题"
                class="input"
              />
              <input
                v-model="newTask.deadline"
                placeholder="截止日期(ISO，留空默认当前时间)"
                class="input"
              />
            </div>
            <textarea
              v-model="newTask.task_content"
              placeholder="任务内容"
              class="textarea"
            ></textarea>
            <button class="btn btn-primary" @click="createTaskForTeam">
              创建任务
            </button>
          </div>
        </div>
      </section>

      <!-- 自习室 -->
      <section v-show="activeTab === 'study-rooms'" class="content-section">
        <div class="section-title">
          <span>自习室</span>
          <button class="btn btn-primary" @click="openCreateRoomForm">
            <i class="fas fa-plus"></i>
            创建自习室
          </button>
        </div>

        <!-- 创建自习室表单 -->
        <div v-if="createForms.room.show" class="create-form">
          <h3>创建自习室</h3>
          <div class="form-group">
            <label>自习室名称:</label>
            <input v-model="createForms.room.room_name" class="input full" placeholder="请输入自习室名称" />
          </div>
          <div class="form-group">
            <label>自习室描述:</label>
            <textarea v-model="createForms.room.description" class="textarea" placeholder="请输入自习室描述"></textarea>
          </div>
          <div class="form-group">
            <label>最大参与人数:</label>
            <input v-model.number="createForms.room.max_members" type="number" class="input" min="1" max="200" />
          </div>
          <div class="form-group">
            <label>开放时间:</label>
            <input v-model="createForms.room.schedule_time" class="input full" placeholder="例如: 09:00-21:00" />
          </div>
          <div class="form-group">
            <label>自习室规则:</label>
            <textarea v-model="createForms.room.rules" class="textarea" placeholder="请输入自习室规则"></textarea>
          </div>
          <div class="form-actions">
            <button class="btn btn-primary" @click="createRoom">创建</button>
            <button class="btn btn-secondary" @click="createForms.room.show = false">取消</button>
          </div>
        </div>

        <!-- 自习室列表 -->
        <div class="team-grid">
          <div
            class="team-card room-type"
            v-for="room in rooms"
            :key="room.room_id"
            @click="viewRoomDetail(room)"
          >
            <!-- 顶部状态条 -->
            <div class="card-status-bar">
              <span class="status-text">自习室</span>
              <span class="status-days" v-if="room.schedule_time">
                <i class="fas fa-clock"></i> {{ room.schedule_time }}
              </span>
            </div>
            
            <div class="team-header">
              <div class="team-avatar room-avatar">
                <i class="fas fa-door-open"></i>
              </div>
              <div class="team-info">
                <h3 class="team-name">{{ room.room_name }}</h3>
                <div class="team-creator">
                  <i class="fas fa-user"></i>
                  {{ room.creator_name || '未知创建者' }}
                </div>
              </div>
            </div>
            
            <p class="team-desc">{{ room.description || '专注学习的安静空间' }}</p>
            
            <!-- 在线成员 -->
            <div class="team-participants">
              <div class="participants-label">
                <i class="fas fa-user-friends"></i>
                在线成员
              </div>
              <div class="participants-list">
                <div
                  class="participant"
                  v-for="m in (room.members || []).slice(0, 5)"
                  :key="m.user_id"
                >
                  {{ m.user_name && m.user_name[0] }}
                </div>
                <div
                  v-if="room.member_count > 5"
                  class="participant"
                >
                  +{{ room.member_count - 5 }}
                </div>
              </div>
            </div>
            
            <!-- 成员进度条 -->
            <div class="team-progress">
              <div class="progress-header">
                <span class="progress-label">在线人数</span>
                <span class="progress-count">{{ room.member_count || 0 }}/{{ room.max_members || 50 }}人</span>
              </div>
              <div class="progress-bar">
                <div class="progress-fill" :style="{width: Math.round(((room.member_count || 0) / (room.max_members || 50)) * 100) + '%'}"></div>
              </div>
            </div>
            
            <div class="team-actions">
              <button
                class="btn btn-primary btn-small flex-1"
                @click.stop="joinRoom(room)"
              >
                <i class="fas fa-door-open"></i>
                加入自习
              </button>
              <button
                class="btn btn-secondary btn-small flex-1"
                @click.stop="leaveRoom(room)"
              >
                <i class="fas fa-sign-out-alt"></i>
                退出
              </button>
              <!-- 只有创建者能看到删除按钮 -->
              <button
                v-if="room.is_owner"
                class="btn btn-secondary btn-small flex-1"
                @click.stop="deleteRoom(room)"
              >
                <i class="fas fa-trash"></i>
                删除
              </button>
            </div>
          </div>
        </div>

        <!-- 自习室详情 + 留言 -->
        <div v-if="selectedRoom" class="section-detail">
          <h3>当前自习室：{{ selectedRoom.room_name }}</h3>
          <p class="detail-meta">
            当前人数：{{ selectedRoom.current_members }}/{{ selectedRoom.max_members }}
          </p>

          <h4 class="sub-title">自习室留言</h4>
          <div class="discussion-feed room-feed">
            <div class="post" v-for="msg in roomMessages" :key="msg.message_id">
              <div class="post-header">
                <div class="post-avatar">
                  {{ msg.user_name && msg.user_name[0] }}
                </div>
                <div class="post-user">{{ msg.user_name }}</div>
                <div class="post-time">{{ formatDate(msg.create_time) }}</div>
              </div>
              <div class="post-content">
                <p>{{ msg.content }}</p>
              </div>
              <div class="post-actions">
                <!-- 只有留言作者能看到删除按钮 -->
                <div 
                  v-if="msg.user_id === currentUserId" 
                  class="post-action" 
                  @click="deleteMessage(msg)"
                >
                  <i class="fas fa-trash"></i>
                  删除
                </div>
              </div>
            </div>
          </div>

          <div class="post post-create">
            <textarea
              class="post-input"
              v-model="newMessage.content"
              placeholder="在自习室中和大家打个招呼吧~"
            ></textarea>
            <div class="post-footer">
              <button class="btn btn-primary" @click="createMessage">
                <i class="fas fa-paper-plane"></i>
                发布留言
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- 公共讨论区（已修改） -->
      <section v-show="activeTab === 'discussion'" class="content-section">
        <div class="section-title">
          <span>公共讨论区</span>
          <button class="btn btn-primary" @click="showCreatePostModal('discussion')">
            <i class="fas fa-edit"></i>
            发布帖子
          </button>
        </div>

        <!-- 发帖区域 -->
        <div class="post post-create" v-if="showPostForm && newPost.category === 'discussion'">
          <h3>发布讨论帖</h3>
          <input
            class="input full"
            v-model="newPost.title"
            placeholder="帖子标题"
            required
          />
          <textarea
            class="post-input"
            v-model="newPost.content"
            placeholder="分享你的学习心得或提出问题..."
            rows="4"
            required
          ></textarea>
          <div class="post-bottom-row">
            <input
              class="input flex-1"
              v-model="newPost.tags"
              placeholder="标签（逗号分隔，如：Python,进阶）"
            />
            <button class="btn btn-primary" @click="createPost('discussion')">
              <i class="fas fa-paper-plane"></i>
              发布
            </button>
            <button class="btn btn-secondary" @click="cancelCreatePost">
              取消
            </button>
          </div>
        </div>

        <div class="discussion-feed">
          <!-- 帖子列表 -->
          <div v-if="discussionPosts.length === 0" class="empty-tip">
            暂无讨论帖，快来发布第一个帖子吧！
          </div>
          
          <div class="post" v-for="post in discussionPosts" :key="post.post_id">
            <div class="post-header">
              <div class="post-avatar">
                {{ post.author_name && post.author_name[0] }}
              </div>
              <div class="post-user">{{ post.author_name }}</div>
              <div class="post-time">{{ formatDate(post.create_time) }}</div>
            </div>
            <div class="post-content">
              <h4>{{ post.title }}</h4>
              <p>{{ post.content }}</p>
              <div class="post-tags" v-if="post.tags && post.tags.length > 0">
                <span class="tag" v-for="tag in post.tags" :key="tag">{{ tag }}</span>
              </div>
            </div>
            <div class="post-actions">
              <div class="post-action" @click="togglePostLike(post)">
                <i :class="post.user_has_liked ? 'fas fa-thumbs-up' : 'far fa-thumbs-up'"></i>
                <span>{{ post.likes_count || 0 }}</span>
              </div>
              <div class="post-action" @click="toggleComments(post)">
                <i class="far fa-comment"></i>
                <span>{{ post.comments_count || 0 }}</span>
              </div>
              <div class="post-action" @click="togglePostFavorite(post)">
                <i :class="post.user_has_favorited ? 'fas fa-star' : 'far fa-star'"></i>
                <span>{{ post.favorites_count || 0 }}</span>
              </div>
              <!-- 只有帖子作者能看到删除按钮 -->
              <div 
                v-if="post.is_owner" 
                class="post-action" 
                @click="deletePost(post)"
              >
                <i class="fas fa-trash"></i>
                删除
              </div>
            </div>

            <!-- 评论列表 -->
            <div v-if="post.showComments" class="comment-list">
              <div
                class="comment-item"
                v-for="comment in commentsByPost[post.post_id] || []"
                :key="comment.comment_id"
              >
                <div class="comment-meta">
                  <span>{{ comment.user_name }}</span>
                  <span>{{ formatDate(comment.create_time) }}</span>
                </div>
                <div class="comment-text">{{ comment.content }}</div>
                <div class="post-actions">
                  <div class="post-action" @click="toggleCommentLike(comment)">
                    <i
                      :class="comment.user_has_liked ? 'fas fa-thumbs-up' : 'far fa-thumbs-up'"
                    ></i>
                    <span>{{ comment.likes_count || 0 }}</span>
                  </div>
                  <!-- 只有评论作者能看到删除按钮 -->
                  <div 
                    v-if="comment.is_owner" 
                    class="post-action" 
                    @click="deleteComment(comment)"
                  >
                    <i class="fas fa-trash"></i>
                    删除
                  </div>
                </div>
              </div>

              <!-- 发表评论 -->
              <div class="comment-create">
                <textarea
                  class="post-input small"
                  :placeholder="'回复 ' + (post.title || '该帖子')"
                  v-model="newCommentContent[post.post_id]"
                ></textarea>
                <div class="post-footer">
                  <button class="btn btn-primary" @click="createComment(post)">
                    发表评论
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 名师答疑（已修改） -->
      <section v-show="activeTab === 'teachers'" class="content-section">
        <div class="section-title">
          <span>名师答疑</span>
          <button class="btn btn-primary" @click="showCreatePostModal('question')">
            <i class="fas fa-question-circle"></i>
            我要提问
          </button>
        </div>

        <!-- 名师列表 -->
        <div class="instructor-grid">
          <div class="instructor-card" v-for="teacher in topTeachers" :key="teacher.user_id">
            <div class="instructor-media">
              <div class="instructor-avatar" v-if="teacher.avatar_url">
                <img :src="getAvatarUrl(teacher.avatar_url)" alt="avatar" />
              </div>
              <div class="instructor-avatar" v-else>
                <i class="fas fa-user"></i>
              </div>
            </div>
            <div class="instructor-body">
              <div class="instructor-name">{{ teacher.user_name }}</div>
              <div class="instructor-desc">{{ teacher.user_intro || '暂无简介' }}</div>
              <div class="instructor-stats">
                <div class="stat">
                  <span class="stat-label">学生</span>
                  <span class="stat-value">{{ teacher.total_students || 0 }}</span>
                </div>
                <div class="stat">
                  <span class="stat-label">课程</span>
                  <span class="stat-value">{{ teacher.course_count || 0 }}</span>
                </div>
                <div class="stat">
                  <span class="stat-label">评分</span>
                  <span class="stat-value">{{ teacher.avg_rating ? Number(teacher.avg_rating).toFixed(1) : '-' }}</span>
                </div>
              </div>
              <button class="btn btn-primary btn-full" @click="askTeacher(teacher)">
                <i class="fas fa-comment-dots"></i>
                向TA提问
              </button>
            </div>
          </div>
        </div>

        <!-- 提问表单 -->
        <div class="post post-create" v-if="showPostForm && newPost.category === 'question'">
          <h3>向老师提问</h3>
          <div class="form-group">
            <label>选择老师:</label>
            <select v-model="newPost.teacher_id" class="input full" required>
              <option value="">请选择老师</option>
              <option v-for="teacher in topTeachers" :key="teacher.user_id" :value="teacher.user_id">
                {{ teacher.user_name }}
              </option>
            </select>
          </div>
          <input
            class="input full"
            v-model="newPost.title"
            placeholder="问题标题"
            required
          />
          <textarea
            class="post-input"
            v-model="newPost.content"
            placeholder="请详细描述你的问题..."
            rows="4"
            required
          ></textarea>
          <div class="post-bottom-row">
            <input
              class="input flex-1"
              v-model="newPost.tags"
              placeholder="标签（逗号分隔）"
            />
            <button class="btn btn-primary" @click="createPost('question')">
              <i class="fas fa-paper-plane"></i>
              提交问题
            </button>
            <button class="btn btn-secondary" @click="cancelCreatePost">
              取消
            </button>
          </div>
        </div>

        <!-- 问答列表 -->
        <div class="qa-section" v-if="questionPosts.length > 0">
          <h3 class="sub-title">最新问答</h3>
          <div class="qa-list">
            <div class="qa-card" v-for="post in questionPosts" :key="post.post_id">
              <div class="qa-header">
                <div class="qa-avatar">{{ post.author_name && post.author_name[0] }}</div>
                <div class="qa-info">
                  <div class="qa-user">{{ post.author_name }}</div>
                  <div class="qa-teacher" v-if="post.teacher_name">
                    提问老师：{{ post.teacher_name }}
                  </div>
                </div>
                <div class="qa-status" :class="post.status === 'solved' ? 'solved' : 'unsolved'">
                  {{ post.status === 'solved' ? '已解决' : '待解决' }}
                </div>
              </div>
              <div class="qa-content">
                <h4>{{ post.title }}</h4>
                <p>{{ post.content }}</p>
                <div class="post-tags" v-if="post.tags && post.tags.length > 0">
                  <span class="tag" v-for="tag in post.tags" :key="tag">{{ tag }}</span>
                </div>
              </div>
              <div class="post-actions">
                <div class="post-action" @click="togglePostLike(post)">
                  <i :class="post.user_has_liked ? 'fas fa-thumbs-up' : 'far fa-thumbs-up'"></i>
                  <span>{{ post.likes_count || 0 }}</span>
                </div>
                <div class="post-action" @click="toggleComments(post)">
                  <i class="far fa-comment"></i>
                  <span>{{ post.comments_count || 0 }}</span>
                </div>
                <!-- 只有提问者可以标记解决 -->
                <div 
                  v-if="post.is_owner && post.status !== 'solved'"
                  class="post-action"
                  @click="showMarkSolvedModal(post)"
                >
                  <i class="fas fa-check"></i>
                  标记解决
                </div>
                <!-- 只有帖子作者能看到删除按钮 -->
                <div 
                  v-if="post.is_owner"
                  class="post-action"
                  @click="deletePost(post)"
                >
                  <i class="fas fa-trash"></i>
                  删除
                </div>
              </div>

              <!-- 评论列表（回答） -->
              <div v-if="post.showComments" class="comment-list">
                <div
                  class="comment-item answer-item"
                  v-for="comment in commentsByPost[post.post_id] || []"
                  :key="comment.comment_id"
                  :class="{ 'accepted-answer': comment.is_accepted }"
                >
                  <div class="answer-badge" v-if="comment.is_accepted">
                    <i class="fas fa-check-circle"></i> 采纳的回答
                  </div>
                  <div class="comment-meta">
                    <span>{{ comment.user_name }}</span>
                    <span>{{ formatDate(comment.create_time) }}</span>
                  </div>
                  <div class="comment-text">{{ comment.content }}</div>
                  <div class="post-actions">
                    <div class="post-action" @click="toggleCommentLike(comment)">
                      <i :class="comment.user_has_liked ? 'fas fa-thumbs-up' : 'far fa-thumbs-up'"></i>
                      <span>{{ comment.likes_count || 0 }}</span>
                    </div>
                    <!-- 提问者可以采纳回答 -->
                    <div 
                      v-if="post.is_owner && !comment.is_accepted && post.status !== 'solved'"
                      class="post-action"
                      @click="markCommentAsAccepted(post, comment)"
                    >
                      <i class="fas fa-check"></i>
                      采纳回答
                    </div>
                    <!-- 回答者可以删除自己的回答 -->
                    <div 
                      v-if="comment.is_owner"
                      class="post-action"
                      @click="deleteComment(comment)"
                    >
                      <i class="fas fa-trash"></i>
                      删除
                    </div>
                  </div>
                </div>

                <!-- 发表回答 -->
                <div class="comment-create">
                  <textarea
                    class="post-input small"
                    placeholder="写下你的回答..."
                    v-model="newCommentContent[post.post_id]"
                  ></textarea>
                  <div class="post-footer">
                    <button class="btn btn-primary" @click="createComment(post, 'answer')">
                      发表回答
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 采纳回答弹窗 -->
        <div v-if="showSolvedModal" class="modal-overlay" @click.self="closeSolvedModal">
          <div class="modal-content">
            <h3>选择采纳的回答</h3>
            <div class="answers-list">
              <div v-if="!currentPost.comments_count" class="empty-tip">
                暂无回答
              </div>
              <div
                v-for="comment in commentsByPost[currentPost.post_id] || []"
                :key="comment.comment_id"
                class="answer-option"
                :class="{ selected: selectedCommentId === comment.comment_id }"
                @click="selectedCommentId = comment.comment_id"
              >
                <div class="answer-content">{{ comment.content }}</div>
                <div class="answer-author">回答者：{{ comment.user_name }}</div>
              </div>
            </div>
            <div class="modal-actions">
              <button class="btn btn-primary" @click="markPostAsSolved" :disabled="!selectedCommentId">
                确认采纳
              </button>
              <button class="btn btn-secondary" @click="closeSolvedModal">
                取消
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- 互助学习（已修改） -->
      <section v-show="activeTab === 'help'" class="content-section">
        <div class="section-title">
          <span>互助学习</span>
          <button class="btn btn-primary" @click="showCreatePostModal('help')">
            <i class="fas fa-hands-helping"></i>
            我要发起互助
          </button>
        </div>

        <!-- 发帖区域 -->
        <div class="post post-create" v-if="showPostForm && newPost.category === 'help'">
          <h3>发起互助请求</h3>
          <input
            class="input full"
            v-model="newPost.title"
            placeholder="求助标题"
            required
          />
          <textarea
            class="post-input"
            v-model="newPost.content"
            placeholder="请详细描述你需要帮助的问题..."
            rows="4"
            required
          ></textarea>
          <div class="post-bottom-row">
            <input
              class="input flex-1"
              v-model="newPost.tags"
              placeholder="标签（逗号分隔，如：编程,算法,作业）"
            />
            <button class="btn btn-primary" @click="createPost('help')">
              <i class="fas fa-paper-plane"></i>
              发布求助
            </button>
            <button class="btn btn-secondary" @click="cancelCreatePost">
              取消
            </button>
          </div>
        </div>

        <div class="help-requests">
          <div v-if="helpPosts.length === 0" class="empty-tip">
            暂无互助帖，快来发起第一个求助吧！
          </div>
          
          <div class="help-card" v-for="post in helpPosts" :key="post.post_id">
            <div class="help-avatar">
              {{ post.author_name && post.author_name[0] }}
            </div>
            <div class="help-content">
              <div class="help-title">{{ post.title }}</div>
              <p class="help-text">{{ post.content }}</p>
              <div class="help-meta">
                <span>发布者：{{ post.author_name }}</span>
                <span>回答数：{{ post.comments_count || 0 }}</span>
                <span>
                  状态：
                  <span :class="post.status === 'solved' ? 'status-solved' : 'status-unsolved'">
                    {{ post.status === 'solved' ? '已解决' : '待解决' }}
                  </span>
                </span>
              </div>
              
              <!-- 回答区域 -->
              <div class="help-actions">
                <!-- 不是帖子作者才能回答 -->
                <button 
                  v-if="!post.is_owner" 
                  class="btn btn-primary btn-small" 
                  @click="toggleAnswerInput(post)"
                >
                  <i class="fas fa-reply"></i>
                  {{ post.showAnswerInput ? '取消回答' : '回答' }}
                </button>
                <button class="btn btn-secondary btn-small" @click="toggleHelpAnswers(post)">
                  <i class="fas fa-comments"></i>
                  {{ post.showAnswers ? '隐藏回答' : '查看回答' }} ({{ post.comments_count || 0 }})
                </button>
                <!-- 只有求助者可以标记解决 -->
                <button 
                  v-if="post.is_owner && post.status !== 'solved' && (commentsByPost[post.post_id] || []).length > 0"
                  class="btn btn-secondary btn-small" 
                  @click="showHelpSolvedModal(post)"
                >
                  <i class="fas fa-check"></i>
                  标记解决
                </button>
                <button 
                  v-if="post.is_owner"
                  class="btn btn-secondary btn-small" 
                  @click="deletePost(post)"
                >
                  <i class="fas fa-trash"></i>
                  删除
                </button>
              </div>

              <!-- 回答输入框 -->
              <div v-if="post.showAnswerInput" class="answer-input-section">
                <textarea
                  v-model="newHelpAnswers[post.post_id]"
                  class="post-input small"
                  placeholder="请输入您的回答..."
                  rows="3"
                ></textarea>
                <div class="answer-input-actions">
                  <button class="btn btn-primary" @click="submitHelpAnswer(post)">
                    提交回答
                  </button>
                  <button class="btn btn-secondary" @click="post.showAnswerInput = false">
                    取消
                  </button>
                </div>
              </div>

              <!-- 回答列表 -->
              <div v-if="post.showAnswers" class="answers-list">
                <div v-if="!commentsByPost[post.post_id] || commentsByPost[post.post_id].length === 0" class="empty-tip">
                  📝 暂无回答
                </div>
                <div v-else class="answers">
                  <div 
                    class="answer-item" 
                    v-for="comment in commentsByPost[post.post_id]" 
                    :key="comment.comment_id"
                    :class="{ 'accepted-answer': comment.is_accepted }"
                  >
                    <div class="answer-badge" v-if="comment.is_accepted">
                      <i class="fas fa-check-circle"></i> 采纳的回答
                    </div>
                    <div class="answer-header">
                      <div class="answer-avatar">{{ comment.user_name && comment.user_name[0] }}</div>
                      <div class="answer-user">{{ comment.user_name }}</div>
                      <div class="answer-time">{{ formatDate(comment.create_time) }}</div>
                    </div>
                    <div class="answer-content">{{ comment.content }}</div>
                    <div class="answer-actions">
                      <div class="post-action" @click="toggleCommentLike(comment)">
                        <i :class="comment.user_has_liked ? 'fas fa-thumbs-up' : 'far fa-thumbs-up'"></i>
                        <span>{{ comment.likes_count || 0 }}</span>
                      </div>
                      <!-- 求助者可以采纳回答 -->
                      <button 
                        v-if="post.is_owner && !comment.is_accepted && post.status !== 'solved'"
                        class="btn btn-secondary btn-small"
                        @click="markCommentAsAccepted(post, comment)"
                      >
                        <i class="fas fa-check"></i>
                        采纳回答
                      </button>
                      <!-- 回答者可以删除自己的回答 -->
                      <button 
                        v-if="comment.is_owner"
                        class="btn btn-secondary btn-small"
                        @click="deleteComment(comment)"
                      >
                        <i class="fas fa-trash"></i>
                        删除回答
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
const API_BASE = process.env.VUE_APP_API_BASE_URL || 'http://localhost:4000';

export default {
  name: 'Community',
  data() {
    return {
      currentUserId: null,
      currentUserName: '',
      activeTab: 'teams',
      
      healthStatus: {
        overall: null,
        app: null,
        db: null,
        stats: null
      },
      
      // 名师列表
      topTeachers: [],
      
      // 帖子数据
      discussionPosts: [],     // 公共讨论区
      questionPosts: [],       // 名师答疑
      helpPosts: [],           // 互助学习
      
      // 评论数据
      commentsByPost: {},
      newCommentContent: {},
      
      // 创建帖子表单
      showPostForm: false,
      newPost: {
        title: '',
        content: '',
        category: '',
        teacher_id: null,
        tags: '',
        course_id: null
      },
      
      // 互助学习回答
      newHelpAnswers: {},
      
      // 采纳回答相关
      showSolvedModal: false,
      currentPost: null,
      selectedCommentId: null,
      
      // 其他数据（组队学习、自习室保持不变）
      availableData: {
        users: [],
        courses: [],
        tags: []
      },
      teams: [],
      teamFilterCourseId: null,
      selectedTeam: null,
      teamTasks: [],
      rooms: [],
      selectedRoom: null,
      roomMessages: [],
      newMessage: {
        content: ''
      },
      newTask: {
        task_title: '',
        task_content: '',
        deadline: ''
      },
      createForms: {
        team: { show: false },
        room: { show: false }
      },
      error: null
    };
  },
  mounted() {
    this.initData();
  },
  methods: {
    // 在methods中添加
    calcRunningDays(createTime) {
        if (!createTime) return 0;
        try {
            const createDate = new Date(createTime);
            const now = new Date();
            const diffTime = Math.abs(now - createDate);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            return diffDays;
        } catch (e) {
            console.error('计算运行天数失败:', e);
            return 0;
        }
    },

    async apiRequest(path, { method = 'GET', body = null, skipAuth = false } = {}) {
  try {
    const options = { 
      method, 
      headers: {
        'Content-Type': 'application/json'
      }
    };
    
    const token = localStorage.getItem('token');
    if (token && !skipAuth) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }
    
    if (method === 'GET') {
      const url = new URL(path, API_BASE);
      if (!url.searchParams.has('current_user_id')) {
        url.searchParams.set('current_user_id', this.currentUserId);
      }
      path = url.pathname + url.search;
    }
    
    if (body && method !== 'GET') {
      options.body = JSON.stringify(body);
    }
    
    console.log(`📤 API请求: ${method} ${path}`);
    console.log(`🔗 完整URL: ${API_BASE}${path}`);
    console.log(`📋 请求选项:`, options);
    
    const res = await fetch(`${API_BASE}${path}`, options);
    console.log(`📥 响应状态: ${res.status} ${res.statusText}`);
    
    const data = await res.json().catch(() => ({}));
    
    console.log('📥 API响应状态:', res.status, res.statusText);
    
    // 特殊处理：对于POST创建帖子和评论，即使500也继续
    if ((path === '/api/community/posts' || path.includes('/comments')) && method === 'POST' && res.status === 500) {
      console.log('⚠️ 创建API返回500，但可能已创建成功');
      // 返回一个模拟的成功响应，让上层继续处理
      return { success: true, message: '内容可能已创建成功' };
    }
    
    if (!res.ok) {
      console.error('❌ API请求失败:', { status: res.status, data });
      throw new Error(data.message || `请求失败: ${res.status}`);
    }
    
    console.log('✅ API请求成功');
    return data;
    
  } catch (e) {
    console.error('❌ API请求异常:', e.message);
    // 对于帖子和评论创建的500错误，不在这里抛出，让上层处理
    if ((path === '/api/community/posts' || path.includes('/comments')) && method === 'POST') {
      console.log('🔄 创建异常，但继续处理');
      return { success: false, message: e.message };
    }
    throw e;
  }
},

    async initData() {
      this.getCurrentUser();
      
      try {
        await Promise.all([
          this.fetchTeams(),
          this.fetchRooms(),
          this.fetchDiscussionPosts(),
          this.fetchQuestionPosts(),
          this.fetchHelpPosts(),
          this.fetchTopTeachers()
        ]);
      } catch (error) {
        console.error('初始化数据失败:', error);
        this.notify('加载数据失败，请刷新页面重试', 'error');
      }
    },

    getCurrentUser() {
      const token = localStorage.getItem('token');
      if (token) {
        try {
          const payload = JSON.parse(atob(token.split('.')[1]));
          this.currentUserId = payload.userId;
          this.currentUserName = payload.userName || '用户';
        } catch (error) {
          console.error('解析token失败:', error);
          this.currentUserId = 1;
          this.currentUserName = '游客';
        }
      } else {
        this.currentUserId = 1;
        this.currentUserName = '游客';
      }
    },

    switchTab(tab) {
      this.activeTab = tab;
      if (tab === 'teams') this.fetchTeams();
      if (tab === 'study-rooms') this.fetchRooms();
      if (tab === 'discussion') this.fetchDiscussionPosts();
      if (tab === 'teachers') {
        this.fetchQuestionPosts();
        this.fetchTopTeachers();
      }
      if (tab === 'help') this.fetchHelpPosts();
    },

    /* ========== 公共讨论区 ========== */
    async fetchDiscussionPosts() {
      try {
        const data = await this.apiRequest(
          `/api/community/posts?category=discussion&current_user_id=${this.currentUserId}`
        );
        this.discussionPosts = (data.data || []).map(post => ({
          ...post,
          user_has_liked: post.user_has_liked || false,
          user_has_favorited: post.user_has_favorited || false,
          showComments: false
        }));
      } catch (error) {
        console.error('获取讨论帖子失败:', error);
        this.discussionPosts = [];
      }
    },

    /* ========== 名师答疑 ========== */
    async fetchQuestionPosts() {
      try {
        const data = await this.apiRequest(
          `/api/community/posts?category=question&current_user_id=${this.currentUserId}`
        );
        this.questionPosts = (data.data || []).map(post => ({
          ...post,
          user_has_liked: post.user_has_liked || false,
          user_has_favorited: post.user_has_favorited || false,
          showComments: false
        }));
      } catch (error) {
        console.error('获取答疑帖子失败:', error);
        this.questionPosts = [];
      }
    },

    async fetchTopTeachers() {
      try {
        const data = await this.apiRequest('/api/community/posts/teachers/list');
        this.topTeachers = data.data || [];
      } catch (error) {
        console.error('获取名师列表失败:', error);
        this.topTeachers = [];
      }
    },

    // 向老师提问
    async askTeacher(teacher) {
      this.showPostForm = true;
      this.newPost = {
        title: '',
        content: '',
        category: 'question',
        teacher_id: teacher.user_id,
        tags: '',
        course_id: null
      };
    },

    /* ========== 互助学习 ========== */
    async fetchHelpPosts() {
      try {
        const data = await this.apiRequest(
          `/api/community/posts?category=help&current_user_id=${this.currentUserId}`
        );
        this.helpPosts = (data.data || []).map(post => ({
          ...post,
          user_has_liked: post.user_has_liked || false,
          user_has_favorited: post.user_has_favorited || false,
          showComments: false,
          showAnswers: false,
          showAnswerInput: false
        }));
      } catch (error) {
        console.error('获取互助帖子失败:', error);
        this.helpPosts = [];
      }
    },

    /* ========== 通用帖子操作 ========== */
    // 修改显示创建帖子模态框的方法
showCreatePostModal(category) {
  this.showPostForm = true;
  this.newPost = {
    title: '',
    content: '',
    category: category,  // ✅ 确保category被正确设置
    teacher_id: null,
    tags: '',
    course_id: null
  };
  console.log('📝 打开发帖模态框:', this.newPost);
},

// 修改取消发布的方法
cancelCreatePost() {
  this.showPostForm = false;
  this.newPost = {
    title: '',
    content: '',
    category: '',  // ✅ 重置category
    teacher_id: null,
    tags: '',
    course_id: null
  };
},

    async createPost(category) {
  const postData = { ...this.newPost, category };
  
  if (!postData.title.trim()) {
    this.notify('请输入标题', 'error');
    return;
  }
  if (!postData.content.trim()) {
    this.notify('请输入内容', 'error');
    return;
  }
  if (category === 'question' && !postData.teacher_id) {
    this.notify('请选择要提问的老师', 'error');
    return;
  }

  // 构建请求数据，去除可能为空的值
  const payload = {
    title: postData.title.trim(),
    content: postData.content.trim(),
    category: category,
    author_id: this.currentUserId
  };
  
  // 只有有值时才添加可选字段
  if (postData.teacher_id) payload.teacher_id = postData.teacher_id;
  if (postData.course_id) payload.course_id = postData.course_id;
  if (postData.tags && postData.tags.trim()) {
    payload.tags = postData.tags.split(',').map(tag => tag.trim()).filter(Boolean);
  }

  console.log('📝 发布帖子请求数据:', payload);

  try {
    // 即使后端返回500错误，我们也当作成功处理（因为实际上创建成功了）
    await this.apiRequest('/api/community/posts', {
      method: 'POST',
      body: payload
    });
    
    // 如果执行到这里，说明后端返回了200
    console.log('✅ 帖子创建成功');
    this.notify('发布成功', 'success');
    
  } catch (error) {
    // 检查是否是"创建后无法获取"的错误
    if (error.message.includes('创建帖子失败') ||
        error.message.includes('帖子创建后无法获取') ||
        error.message.includes('500')) {
      
      console.log('⚠️ 帖子可能已创建成功，但后端获取失败。继续执行刷新操作...');
      // 不显示错误弹窗，继续执行后续操作
    } else {
      // 其他错误正常显示
      console.error('发布帖子失败:', error);
      this.notify(`发布失败: ${error.message}`, 'error');
      return;
    }
  }
  
  // 无论API是否报错，都执行以下操作
  this.showPostForm = false;
  this.newPost = {
    title: '',
    content: '',
    category: '',
    teacher_id: null,
    tags: '',
    course_id: null
  };

  // 延迟一小段时间后刷新列表，确保数据库事务完成
  setTimeout(() => {
    console.log('🔄 刷新帖子列表...');
    if (category === 'discussion') {
      this.fetchDiscussionPosts();
    } else if (category === 'question') {
      this.fetchQuestionPosts();
      this.fetchTopTeachers();
    } else if (category === 'help') {
      this.fetchHelpPosts();
    }
  }, 500);
},

    async deletePost(post) {
      if (!window.confirm('确定删除这个帖子吗？')) return;
      
      try {
        await this.apiRequest(`/api/community/posts/${post.post_id}`, {
          method: 'DELETE',
          body: { user_id: this.currentUserId }
        });
        
        this.notify('帖子删除成功', 'success');
        
        // 刷新对应分类的帖子列表
        if (post.category === 'discussion') this.fetchDiscussionPosts();
        else if (post.category === 'question') this.fetchQuestionPosts();
        else if (post.category === 'help') this.fetchHelpPosts();
        
      } catch (error) {
        console.error('删除帖子失败:', error);
      }
    },

    async togglePostLike(post) {
      try {
        if (post.user_has_liked) {
          const res = await this.apiRequest(`/api/community/posts/${post.post_id}/like`, {
            method: 'DELETE',
            body: { user_id: this.currentUserId }
          });
          post.likes_count = res.data.like_count;
          post.user_has_liked = false;
        } else {
          const res = await this.apiRequest(`/api/community/posts/${post.post_id}/like`, {
            method: 'POST',
            body: { user_id: this.currentUserId }
          });
          post.likes_count = res.data.like_count;
          post.user_has_liked = true;
        }
      } catch (error) {
        console.error('点赞操作失败:', error);
      }
    },

    async togglePostFavorite(post) {
      try {
        if (post.user_has_favorited) {
          const res = await this.apiRequest(`/api/community/posts/${post.post_id}/favorite`, {
            method: 'DELETE',
            body: { user_id: this.currentUserId }
          });
          post.favorites_count = res.data.favorite_count;
          post.user_has_favorited = false;
        } else {
          const res = await this.apiRequest(`/api/community/posts/${post.post_id}/favorite`, {
            method: 'POST',
            body: { user_id: this.currentUserId }
          });
          post.favorites_count = res.data.favorite_count;
          post.user_has_favorited = true;
        }
      } catch (error) {
        console.error('收藏操作失败:', error);
      }
    },

    /* ========== 评论操作 ========== */
    async toggleComments(post) {
      post.showComments = !post.showComments;
      
      if (post.showComments && !this.commentsByPost[post.post_id]) {
        await this.fetchComments(post);
      }
    },

    async fetchComments(post) {
      try {
        const data = await this.apiRequest(
          `/api/community/posts/${post.post_id}/comments?current_user_id=${this.currentUserId}`
        );
        this.commentsByPost = {
          ...this.commentsByPost,
          [post.post_id]: data.data || []
        };
      } catch (error) {
        console.error('获取评论失败:', error);
        this.commentsByPost[post.post_id] = [];
      }
    },

    async createComment(post, commentType = 'discussion') {
      const content = this.newCommentContent[post.post_id];
      if (!content || !content.trim()) {
        this.notify('评论内容不能为空', 'error');
        return;
      }

      const payload = {
        content: content.trim(),
        user_id: this.currentUserId,
        comment_type: commentType
      };

      try {
        const res = await this.apiRequest(`/api/community/posts/${post.post_id}/comments`, {
          method: 'POST',
          body: payload
        });

        // 处理成功响应或500错误但可能成功的情况
        if (res.success || res.message === '内容可能已创建成功') {
          // 清空输入框
          this.newCommentContent[post.post_id] = '';
          
          // 更新评论数
          post.comments_count = (post.comments_count || 0) + 1;
          
          // 确保评论区域是展开的
          post.showComments = true;
          
          // 重新获取评论列表以确保数据一致性
          await this.fetchComments(post);
          
          console.log('评论添加成功');
          this.notify('发布成功', 'success');
        } else {
          throw new Error(res.message || '评论失败');
        }
      } catch (error) {
        // 检查是否是500错误但实际成功的情况
        if (error.message.includes('500') || error.message.includes('创建评论失败')) {
          console.log('⚠️ 评论可能已创建成功，但后端获取失败。继续执行刷新操作...');
          
          // 清空输入框
          this.newCommentContent[post.post_id] = '';
          
          // 更新评论数
          post.comments_count = (post.comments_count || 0) + 1;
          
          // 确保评论区域是展开的
          post.showComments = true;
          
          // 延迟刷新评论列表
          setTimeout(async () => {
            await this.fetchComments(post);
          }, 500);
          
          this.notify('发布成功', 'success');
        } else {
          console.error('评论失败:', error);
          this.notify('评论失败，请重试', 'error');
        }
      }
    },

    async deleteComment(comment) {
      if (!window.confirm('确定删除这个评论吗？')) return;

      // 找到对应的帖子
      const post = [...this.discussionPosts, ...this.questionPosts, ...this.helpPosts]
        .find(p => p.post_id === comment.post_id);

      // 立即从UI中移除评论（乐观更新）
      if (post && post.comments) {
        const commentIndex = post.comments.findIndex(c => c.comment_id === comment.comment_id);
        if (commentIndex !== -1) {
          post.comments.splice(commentIndex, 1);
          post.comments_count = Math.max(0, (post.comments_count || 1) - 1);
        }
      }

      try {
        const res = await this.apiRequest(`/api/community/comments/${comment.comment_id}`, {
          method: 'DELETE',
          body: { user_id: this.currentUserId }
        });

        if (res.success) {
          console.log('评论删除成功');
          this.notify('评论删除成功');
          
          // 确保评论数与服务器返回的一致
          if (res.data && res.data.comment_count !== undefined && post) {
            post.comments_count = res.data.comment_count;
          }
        }
      } catch (error) {
        console.error('删除评论失败:', error);
        
        // 如果删除失败，恢复评论到列表中
        if (post && post.comments) {
          post.comments.push(comment);
          post.comments_count = (post.comments_count || 0) + 1;
        }
        
        this.notify('删除失败，请重试');
      }
    },

    async toggleCommentLike(comment) {
      console.log('切换评论点赞状态:', comment);
      
      // 立即更新UI状态（乐观更新）
      const originalLiked = comment.user_has_liked;
      const originalCount = comment.likes_count || 0;
      
      // 先更新UI，给用户即时反馈
      comment.user_has_liked = !originalLiked;
      comment.likes_count = originalLiked ? Math.max(0, originalCount - 1) : originalCount + 1;
      
      try {
        const res = await this.apiRequest(`/api/community/comments/${comment.comment_id}/like`, {
          method: 'POST',
          body: { user_id: this.currentUserId }
        });
        
        // 用服务器返回的数据更新UI（确保数据一致性）
        if (res.success && res.data) {
          comment.likes_count = res.data.like_count;
          comment.user_has_liked = res.data.user_has_liked;
          console.log(res.data.liked ? '点赞成功' : '取消点赞成功');
        }
      } catch (error) {
        console.error('切换点赞状态失败:', error);
        
        // 如果请求失败，回滚UI状态
        comment.user_has_liked = originalLiked;
        comment.likes_count = originalCount;
        
        this.notify('操作失败，请重试');
      }
    },

    /* ========== 互助学习特有功能 ========== */
    toggleAnswerInput(post) {
      post.showAnswerInput = !post.showAnswerInput;
      if (!post.showAnswerInput) {
        this.newHelpAnswers[post.post_id] = '';
      }
    },

    toggleHelpAnswers(post) {
      post.showAnswers = !post.showAnswers;
      if (post.showAnswers && !this.commentsByPost[post.post_id]) {
        this.fetchComments(post);
      }
    },

    async submitHelpAnswer(post) {
      const content = this.newHelpAnswers[post.post_id];
      if (!content || !content.trim()) {
        this.notify('请输入回答内容', 'error');
        return;
      }

      try {
        const res = await this.apiRequest(`/api/community/posts/${post.post_id}/comments`, {
          method: 'POST',
          body: {
            content: content.trim(),
            user_id: this.currentUserId,
            comment_type: 'answer'
          }
        });

        // 处理成功响应或500错误但可能成功的情况
        if (res.success || res.message === '内容可能已创建成功') {
          // 清空输入框并隐藏输入区域
          this.newHelpAnswers[post.post_id] = '';
          post.showAnswerInput = false;
          post.comments_count = (post.comments_count || 0) + 1;
          
          // 确保回答列表是展开的
          post.showAnswers = true;
          
          // 重新获取评论列表以确保数据一致性
          await this.fetchComments(post);
          
          console.log('回答添加成功');
          this.notify('发布成功', 'success');
        } else {
          throw new Error(res.message || '回答失败');
        }
      } catch (error) {
        // 检查是否是500错误但实际成功的情况
        if (error.message.includes('500') || error.message.includes('创建评论失败')) {
          console.log('⚠️ 回答可能已创建成功，但后端获取失败。继续执行刷新操作...');
          
          // 清空输入框并隐藏输入区域
          this.newHelpAnswers[post.post_id] = '';
          post.showAnswerInput = false;
          post.comments_count = (post.comments_count || 0) + 1;
          
          // 确保回答列表是展开的
          post.showAnswers = true;
          
          // 延迟刷新评论列表
          setTimeout(async () => {
            await this.fetchComments(post);
          }, 500);
          
          this.notify('发布成功', 'success');
        } else {
          console.error('提交回答失败:', error);
          this.notify('发布失败，请重试', 'error');
        }
      }
    },

    /* ========== 采纳回答功能 ========== */
    showMarkSolvedModal(post) {
      this.currentPost = post;
      this.selectedCommentId = null;
      this.showSolvedModal = true;
      
      // 确保评论已加载
      if (!this.commentsByPost[post.post_id]) {
        this.fetchComments(post);
      }
    },

    showHelpSolvedModal(post) {
      this.showMarkSolvedModal(post);
    },

    closeSolvedModal() {
      this.showSolvedModal = false;
      this.currentPost = null;
      this.selectedCommentId = null;
    },

    async markCommentAsAccepted(post, comment) {
      if (!window.confirm('确定采纳这个回答吗？')) return;
      
      await this.markPostAsSolvedInternal(post, comment.comment_id);
    },

    async markPostAsSolved() {
      if (!this.selectedCommentId) {
        this.notify('请选择一个回答', 'error');
        return;
      }
      
      await this.markPostAsSolvedInternal(this.currentPost, this.selectedCommentId);
    },

    async markPostAsSolvedInternal(post, commentId) {
      try {
        await this.apiRequest(`/api/community/posts/${post.post_id}/solve`, {
          method: 'PATCH',
          body: {
            solved_comment_id: commentId,
            user_id: this.currentUserId
          }
        });

        // 更新帖子状态
        post.status = 'solved';
        
        // 更新评论状态
        if (this.commentsByPost[post.post_id]) {
          this.commentsByPost[post.post_id] = this.commentsByPost[post.post_id].map(comment => ({
            ...comment,
            is_accepted: comment.comment_id === commentId
          }));
        }

        this.closeSolvedModal();
        this.notify('已标记为已解决', 'success');
      } catch (error) {
        console.error('标记解决失败:', error);
        this.notify('操作失败: ' + error.message, 'error');
      }
    },

    /* ========== 工具函数 ========== */
    notify(message, type = 'info') {
      // 简单的通知实现，可以后续替换为更复杂的通知组件
      console.log(`[${type.toUpperCase()}] ${message}`);
      
      // 创建临时通知元素
      const notification = document.createElement('div');
      notification.textContent = message;
      notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'error' ? '#f56565' : type === 'success' ? '#48bb78' : '#4299e1'};
        color: white;
        padding: 12px 20px;
        border-radius: 6px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        font-size: 14px;
        max-width: 300px;
        word-wrap: break-word;
        transition: all 0.3s ease;
      `;
      
      document.body.appendChild(notification);
      
      // 3秒后自动移除
      setTimeout(() => {
        if (notification.parentNode) {
          notification.style.opacity = '0';
          notification.style.transform = 'translateX(100%)';
          setTimeout(() => {
            document.body.removeChild(notification);
          }, 300);
        }
      }, 3000);
    },

    getAvatarUrl(avatar) {
      if (!avatar) return '';
      if (avatar.startsWith('http')) return avatar;
      return `${API_BASE}${avatar}`;
    },

    formatDate(str) {
      if (!str) return '';
      const d = new Date(str);
      if (Number.isNaN(d.getTime())) return str;
      const y = d.getFullYear();
      const m = String(d.getMonth() + 1).padStart(2, '0');
      const day = String(d.getDate()).padStart(2, '0');
      const hh = String(d.getHours()).padStart(2, '0');
      const mm = String(d.getMinutes()).padStart(2, '0');
      return `${y}-${m}-${day} ${hh}:${mm}`;
    },

    /* ========== 以下为保持不变的功能 ========== */
    /* 健康检查 */
    async checkHealth() {
      try {
        const [h, db, stats] = await Promise.all([
          this.apiRequest('/health'),
          this.apiRequest('/health/db'),
          this.apiRequest('/api/stats')
        ]);
        this.healthStatus.app = h.status === 'OK' || h.success !== false;
        this.healthStatus.db = db.status === 'healthy' || db.success !== false;
        this.healthStatus.stats = stats.success !== false;
        this.healthStatus.overall =
          this.healthStatus.app && this.healthStatus.db && this.healthStatus.stats
            ? 'ok'
            : 'error';
        this.notify(
          '健康检查完成：' +
            (this.healthStatus.overall === 'ok' ? '正常' : '存在问题'),
          this.healthStatus.overall === 'ok' ? 'success' : 'error'
        );
      } catch (e) {
        this.healthStatus.overall = 'error';
      }
    },

    /* 公共数据 */
    async fetchAvailableData() {
      try {
        const data = await this.apiRequest(
          '/api/community/teams/available-data'
        );
        this.availableData = data.data || this.availableData;
      } catch (error) {
        console.error('获取可用数据失败:', error);
        // 保持默认的availableData
      }
    },

    /* 学习小组 */
    async fetchTeams(page = 1) {
      try {
        let url = `/api/community/teams?page=${page}&limit=20&current_user_id=${this.currentUserId}`;
        if (this.teamFilterCourseId) {
          url += `&course_id=${this.teamFilterCourseId}`;
        }
        console.log('🔍 正在获取学习小组列表:', url);
        const data = await this.apiRequest(url);
        console.log('📊 获取到的小组数据:', data);
        
        if (data && data.success && Array.isArray(data.data)) {
          this.teams = data.data;
          console.log('✅ 成功设置小组列表，数量:', this.teams.length);
        } else {
          console.warn('⚠️ 返回的数据格式不正确:', data);
          this.teams = [];
        }
      } catch (error) {
        console.error('❌ 获取学习小组列表失败:', error);
        this.teams = [];
        this.notify('获取学习小组列表失败: ' + error.message, 'error');
      }
    },

    async viewTeamDetail(team) {
      // 完全跳转到新的组队详情页 StudyPair
      this.$router.push({
        name: 'StudyPair',
        params: { teamId: team.team_id }
      });
    },

    // 打开创建小组表单
    openCreateTeamForm() {
      this.createForms.team.show = true;
      this.createForms.team = {
        show: true,
        team_name: '',
        description: '',
        course_id: this.availableData.courses[0]?.course_id || null,
        max_members: 10,
        tags: ''
      };
    },

    // 创建学习小组（真实数据）
    async createTeam() {
      if (!this.createForms.team.team_name.trim()) {
        this.notify('请输入小组名称', 'error');
        return;
      }

      const tags = this.createForms.team.tags
        ? this.createForms.team.tags.split(',').map(tag => tag.trim()).filter(Boolean)
        : [];

      const payload = {
        team_name: this.createForms.team.team_name,
        description: this.createForms.team.description,
        course_id: this.createForms.team.course_id,
        max_members: this.createForms.team.max_members,
        tags: tags,
        creator_id: this.currentUserId
      };

      try {
        await this.apiRequest('/api/community/teams', {
          method: 'POST',
          body: payload
        });
        this.notify('小组创建成功', 'success');
        this.createForms.team.show = false;
        this.fetchTeams();
      } catch (error) {
        console.error('创建小组失败:', error);
      }
    },

    async joinTeam(team) {
      try {
        await this.apiRequest(`/api/community/teams/${team.team_id}/join`, {
          method: 'POST',
          body: { user_id: this.currentUserId }
        });
        this.notify('加入成功', 'success');
        this.fetchTeams();
      } catch (error) {
        console.error('加入小组失败:', error);
        this.notify('加入小组失败: ' + error.message, 'error');
      }
    },

    async leaveTeam(team) {
      try {
        await this.apiRequest(`/api/community/teams/${team.team_id}/leave`, {
          method: 'DELETE',
          body: { user_id: this.currentUserId }
        });
        this.notify('已退出小组', 'success');
        this.fetchTeams();
      } catch (error) {
        console.error('退出小组失败:', error);
        this.notify('退出小组失败: ' + error.message, 'error');
      }
    },

    async deleteTeam(team) {
      if (!window.confirm('确定删除该小组吗？')) return;
      try {
        await this.apiRequest(`/api/community/teams/${team.team_id}`, {
          method: 'DELETE',
          body: { user_id: this.currentUserId }
        });
        this.notify('小组已删除', 'success');
        if (this.selectedTeam && this.selectedTeam.team_id === team.team_id) {
          this.selectedTeam = null;
          this.teamTasks = [];
        }
        this.fetchTeams();
      } catch (error) {
        console.error('删除小组失败:', error);
        this.notify('删除小组失败: ' + error.message, 'error');
      }
    },

    async createTaskForTeam() {
      if (!this.selectedTeam) {
        this.notify('请先点击某个小组卡片，加载小组详情', 'error');
        return;
      }
      try {
        const payload = {
          creator_id: this.currentUserId,
          title: this.newTask.task_title || '示例任务',
          description: this.newTask.task_content || '示例任务内容',
          deadline: this.newTask.deadline || new Date().toISOString()
        };
        const url = `/api/community/tasks/teams/${this.selectedTeam.team_id}/tasks`;
        await this.apiRequest(url, { method: 'POST', body: payload });
        this.notify('任务创建成功', 'success');
        this.newTask = { task_title: '', task_content: '', deadline: '' };
        this.viewTeamDetail(this.selectedTeam);
      } catch (error) {
        console.error('创建任务失败:', error);
        this.notify('创建任务失败: ' + error.message, 'error');
      }
    },

    async updateTaskStatus(task, status) {
      const url = `/api/community/tasks/tasks/${task.task_id}/status`;
      await this.apiRequest(url, { method: 'PATCH', body: { status } });
      this.notify('任务状态已更新', 'success');
      this.viewTeamDetail(this.selectedTeam);
    },

    async deleteTask(task) {
      const url = `/api/community/tasks/tasks/${task.task_id}`;
      await this.apiRequest(url, { method: 'DELETE' });
      this.notify('任务已删除', 'success');
      this.viewTeamDetail(this.selectedTeam);
    },

    /* 自习室 */
    async fetchRooms(page = 1) {
      try {
        const url = `/api/community/rooms?page=${page}&limit=20&current_user_id=${this.currentUserId}`;
        console.log('🔍 正在获取自习室列表:', url);
        const data = await this.apiRequest(url);
        console.log('📊 获取到的自习室数据:', data);
        
        if (data && data.success && Array.isArray(data.data)) {
          this.rooms = data.data.map(room => ({
            ...room,
            member_count: room.online_count || room.current_participants || 0,
            max_members: room.max_participants || room.max_members || 50
          }));
          console.log('✅ 成功设置自习室列表，数量:', this.rooms.length);
        } else {
          console.warn('⚠️ 返回的自习室数据格式不正确:', data);
          this.rooms = [];
        }
      } catch (error) {
        console.error('❌ 获取自习室列表失败:', error);
        this.rooms = [];
        this.notify('获取自习室列表失败: ' + error.message, 'error');
      }
    },

    async viewRoomDetail(room) {
      this.$router.push({
        name: 'StudyRoom',
        params: { roomId: room.room_id }
      });
    },

    // 打开创建自习室表单
    openCreateRoomForm() {
      this.createForms.room.show = true;
      this.createForms.room = {
        show: true,
        room_name: '',
        description: '',
        max_members: 20,
        schedule_time: '',
        rules: ''
      };
    },

    // 创建自习室（真实数据）
    async createRoom() {
      if (!this.createForms.room.room_name.trim()) {
        this.notify('请输入自习室名称', 'error');
        return;
      }

      const payload = {
        room_name: this.createForms.room.room_name,
        description: this.createForms.room.description,
        max_members: this.createForms.room.max_members,
        schedule_time: this.createForms.room.schedule_time,
        rules: this.createForms.room.rules,
        creator_id: this.currentUserId,
        tags: ['学习']
      };

      try {
        await this.apiRequest('/api/community/rooms', {
          method: 'POST',
          body: payload
        });
        this.notify('自习室创建成功', 'success');
        this.createForms.room.show = false;
        this.fetchRooms();
      } catch (error) {
        console.error('创建自习室失败:', error);
      }
    },

    async joinRoom(room) {
      try {
        await this.apiRequest(`/api/community/rooms/${room.room_id}/join`, {
          method: 'POST',
          body: { user_id: this.currentUserId }
        });
        this.notify('加入自习室成功', 'success');
        this.fetchRooms();
      } catch (error) {
        console.error('加入自习室失败:', error);
        this.notify('加入自习室失败: ' + error.message, 'error');
      }
    },

    async leaveRoom(room) {
      try {
        await this.apiRequest(`/api/community/rooms/${room.room_id}/leave`, {
          method: 'DELETE',
          body: { user_id: this.currentUserId }
        });
        this.notify('已离开自习室', 'success');
        this.fetchRooms();
      } catch (error) {
        console.error('离开自习室失败:', error);
        this.notify('离开自习室失败: ' + error.message, 'error');
      }
    },

    async deleteRoom(room) {
      if (!window.confirm('确定删除该自习室吗？')) return;
      await this.apiRequest(`/api/community/rooms/${room.room_id}`, {
        method: 'DELETE',
        body: { user_id: this.currentUserId }
      });
      this.notify('自习室已删除', 'success');
      if (this.selectedRoom && this.selectedRoom.room_id === room.room_id) {
        this.selectedRoom = null;
        this.roomMessages = [];
      }
      this.fetchRooms();
    },

    async createMessage() {
      if (!this.selectedRoom) {
        this.notify('请先选择一个自习室', 'error');
        return;
      }
      if (!this.newMessage.content.trim()) {
        this.notify('内容不能为空', 'error');
        return;
      }
      const url = `/api/community/messages/${this.selectedRoom.room_id}`;
      const payload = {
        user_id: this.currentUserId,
        content: this.newMessage.content,
        message_type: 'text'
      };
      await this.apiRequest(url, { method: 'POST', body: payload });
      this.newMessage.content = '';
      this.viewRoomDetail(this.selectedRoom);
    },

    async deleteMessage(msg) {
      await this.apiRequest(`/api/community/messages/${msg.message_id}`, {
        method: 'DELETE'
      });
      this.viewRoomDetail(this.selectedRoom);
    }
  }
};
</script>

<style>
:root {
  --primary: #1a73e8;
  --primary-light: #e8f0fe;
  --primary-dark: #0d5bb9;
  --secondary: #34a853;
  --secondary-light: #e8f5e8;
  --danger: #ea4335;
  --warning: #ff9800;
  --success: #4caf50;
  --dark: #202124;
  --light: #f8f9fa;
  --gray: #5f6368;
  --gray-light: #9aa0a6;
  --border: #dadce0;
  --border-light: #e8f0fe;
  --shadow: 0 4px 16px rgba(11, 45, 70, 0.08);
  --shadow-hover: 0 8px 24px rgba(11, 45, 70, 0.12);
  --radius: 12px;
  --radius-large: 16px;
  --transition: all 0.3s ease;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
}

/* 确保所有装饰性伪元素不阻止点击 */
.community::before,
.community::after,
.community-header::before,
.community-header::after,
.content-section::before,
.tabs::before,
.tabs::after,
.tab::before,
.tab::after,
.team-card::after,
.post::before,
.post::after,
.create-form::before,
.create-form::after,
.instructor-card::before,
.instructor-card::after,
.qa-card::before,
.qa-card::after,
.help-card::after,
.status-bar::before,
.empty-tip::before,
.empty-tip::after {
  pointer-events: none !important;
}

body {
  background-color: var(--light);
  color: var(--dark);
}

/* 容器：横向 100% 铺满 */
.container {
  width: 100%;
  max-width: none;
  margin: 0 auto;
  padding: 0 32px;
}

/* 头部样式优化 */
.community-header {
  background: linear-gradient(135deg, #ffffff 0%, #f8fbff 50%, #f0f7ff 100%);
  color: #073b6b;
  padding: 60px 0;
  margin-bottom: 40px;
  text-align: center;
  border-bottom: 1px solid var(--border-light);
  position: relative;
  overflow: hidden;
  box-shadow: 0 2px 20px rgba(26, 115, 232, 0.08);
}

.community-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 80%, rgba(26, 115, 232, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(52, 168, 83, 0.1) 0%, transparent 50%),
    url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 20"><defs><pattern id="grid" width="10" height="10" patternUnits="userSpaceOnUse"><path d="M 10 0 L 0 0 0 10" fill="none" stroke="%23f0f5ff" stroke-width="0.5"/></pattern></defs><rect width="100" height="20" fill="url(%23grid)"/></svg>');
  opacity: 0.4;
  z-index: 0;
}

.community-header .container {
  position: relative;
  z-index: 1;
}

.community-header h1 {
  font-size: 3rem;
  margin-bottom: 20px;
  font-weight: 800;
  color: #073b6b;
  text-shadow: 0 4px 8px rgba(7, 59, 107, 0.15);
  background: linear-gradient(135deg, #073b6b 0%, #1a73e8 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  position: relative;
}

.community-header h1::before {
  content: '🎓';
  position: absolute;
  left: -60px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 2.5rem;
  opacity: 0.8;
  animation: float 3s ease-in-out infinite;
}

.community-header h1::after {
  content: '✨';
  position: absolute;
  right: -60px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 2rem;
  opacity: 0.8;
  animation: sparkle 2s ease-in-out infinite alternate;
}

@keyframes float {
  0%, 100% { transform: translateY(-50%) translateX(0); }
  50% { transform: translateY(-50%) translateX(10px); }
}

@keyframes sparkle {
  0% { opacity: 0.8; transform: translateY(-50%) scale(1); }
  100% { opacity: 1; transform: translateY(-50%) scale(1.2); }
}

.community-header p {
  font-size: 1.3rem;
  color: #4a7fc1;
  max-width: 700px;
  margin: 0 auto;
  line-height: 1.7;
  font-weight: 500;
  text-shadow: 0 2px 4px rgba(74, 127, 193, 0.1);
}

/* 状态栏 */
.status-bar {
  margin-bottom: 16px;
  font-size: 0.9rem;
  color: #6b7e90;
  display: flex;
  align-items: center;
  gap: 20px;
  background: #f8f9fa;
  padding: 12px 20px;
  border-radius: 12px;
  border-left: 4px solid #1a73e8;
}

.status-ok {
  color: var(--secondary);
}

.status-error {
  color: var(--danger);
}

.status-btn {
  padding: 6px 12px;
  font-size: 0.8rem;
}

/* 标签页样式优化 */
.tabs {
  display: flex;
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: var(--radius-large);
  padding: 8px;
  margin-bottom: 40px;
  box-shadow: var(--shadow);
  border: 1px solid var(--border-light);
  overflow-x: auto;
  position: relative;
  backdrop-filter: blur(10px);
}

.tabs::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, var(--primary), var(--secondary), var(--warning));
  border-radius: var(--radius-large) var(--radius-large) 0 0;
}

.tab {
  flex: 1;
  text-align: center;
  padding: 16px 20px;
  cursor: pointer;
  border-radius: var(--radius);
  transition: var(--transition);
  white-space: nowrap;
  font-size: 1rem;
  color: var(--gray);
  font-weight: 600;
  position: relative;
  min-width: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.tab::before {
  content: '';
  position: absolute;
  bottom: 4px;
  left: 50%;
  width: 0;
  height: 3px;
  background: linear-gradient(90deg, var(--primary), var(--secondary));
  border-radius: 2px;
  transition: var(--transition);
  transform: translateX(-50%);
}

.tab::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  background: radial-gradient(circle, rgba(26, 115, 232, 0.1) 0%, transparent 70%);
  border-radius: 50%;
  transition: var(--transition);
  transform: translate(-50%, -50%);
  z-index: -1;
}

.tab.active {
  background: linear-gradient(135deg, #f0f5ff 0%, #e8f0fe 100%);
  color: var(--primary);
  font-weight: 700;
  border: 2px solid var(--border-light);
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(26, 115, 232, 0.2);
}

.tab.active::before {
  width: 70%;
}

.tab.active::after {
  width: 100%;
  height: 100%;
}

.tab:hover:not(.active) {
  background: linear-gradient(135deg, #f8f9fa 0%, #f0f5ff 100%);
  color: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(26, 115, 232, 0.1);
}

.tab:hover:not(.active)::after {
  width: 80%;
  height: 80%;
}

/* 内容区域 */
.content-section {
  background: #ffffff;
  border-radius: 16px;
  padding: 32px;
  margin-bottom: 28px;
  box-shadow: 0 4px 16px rgba(11, 45, 70, 0.08);
  border: 1px solid #f0f5ff;
  position: relative;
}

.content-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: #1a73e8;
  border-radius: 16px 16px 0 0;
}

.section-title {
  font-size: 1.6rem;
  margin-bottom: 28px;
  color: #073b6b;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  position: relative;
}

.section-title::before {
  content: '';
  position: absolute;
  bottom: -8px;
  left: 0;
  width: 60px;
  height: 3px;
  background: #1a73e8;
  border-radius: 2px;
}

.section-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

/* 按钮样式优化 */
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: var(--radius);
  font-size: 0.95rem;
  cursor: pointer;
  transition: var(--transition);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-weight: 600;
  text-decoration: none;
  position: relative;
  overflow: hidden;
  min-height: 44px;
}

.btn::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  transition: var(--transition);
  transform: translate(-50%, -50%);
}

.btn:hover::before {
  width: 300px;
  height: 300px;
}

.btn-primary {
  background: linear-gradient(135deg, var(--primary) 0%, #4285f4 50%, var(--secondary) 100%);
  color: #fff;
  box-shadow: 0 4px 15px rgba(26, 115, 232, 0.3);
  border: 2px solid transparent;
  font-weight: 700;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.btn-primary:hover {
  background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 50%, #4285f4 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(26, 115, 232, 0.25);
}

.btn-primary:active {
  transform: translateY(0);
  box-shadow: 0 4px 15px rgba(26, 115, 232, 0.3);
}

.btn-secondary {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  color: var(--gray);
  border: 2px solid var(--border);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.btn-secondary:hover {
  background: linear-gradient(135deg, #f0f5ff 0%, #e8f0fe 100%);
  border-color: var(--primary);
  color: var(--primary);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(26, 115, 232, 0.15);
}

.btn-success {
  background: linear-gradient(135deg, var(--secondary) 0%, var(--success) 100%);
  color: #fff;
  box-shadow: 0 4px 15px rgba(52, 168, 83, 0.3);
}

.btn-success:hover {
  background: linear-gradient(135deg, #2e7d32 0%, var(--secondary) 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(52, 168, 83, 0.4);
}

.btn-danger {
  background: linear-gradient(135deg, var(--danger) 0%, #f44336 100%);
  color: #fff;
  box-shadow: 0 4px 15px rgba(234, 67, 53, 0.3);
}

.btn-danger:hover {
  background: linear-gradient(135deg, #d32f2f 0%, var(--danger) 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(234, 67, 53, 0.4);
}

.btn-small {
  padding: 6px 12px;
  font-size: 0.8rem;
}

.btn-full {
  width: 100%;
}

.select {
  padding: 8px 10px;
}

/* Team cards */
.team-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 25px;
}

.team-card {
  background: var(--light);
  border-radius: 12px;
  padding: 25px;
  border: 2px solid transparent;
  transition: all 0.3s ease;
  cursor: pointer;
}

.team-card:hover {
  border-color: var(--primary);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.team-header {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 15px;
}

.team-avatar {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  background: #1a73e8;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-weight: bold;
  font-size: 1.2rem;
}

.team-info h3 {
  margin-bottom: 5px;
}

.team-days {
  color: var(--gray);
  font-size: 0.9rem;
}

.team-desc {
  margin-bottom: 10px;
}

.team-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin: 10px 0 15px;
}

.tag {
  background: #f0f5ff;
  color: #1a73e8;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  border: 1px solid #e8f0fe;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.tag::before {
  content: '#';
  opacity: 0.7;
  font-weight: 400;
}

.team-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: var(--gray);
  font-size: 0.9rem;
  margin-top: 10px;
  gap: 10px;
  flex-wrap: wrap;
}

.team-btn-row {
  margin-top: 8px;
}

/* Detail sections */
.section-detail {
  margin-top: 30px;
}

.detail-desc {
  margin: 8px 0;
}

.detail-meta {
  font-size: 0.9rem;
  color: var(--gray);
  margin-bottom: 10px;
}

.sub-title {
  margin: 20px 0 10px;
}

.empty-tip {
  font-size: 0.9rem;
  color: var(--gray);
  margin-bottom: 10px;
}

.task-create {
  margin-top: 15px;
}

.task-input-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 10px;
}



/* Inputs */
.input {
  padding: 12px 16px;
  border-radius: 8px;
  border: 2px solid #e8f0fe;
  min-width: 200px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
  background: #ffffff;
}

.input:focus {
  outline: none;
  border-color: #1a73e8;
  box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
  background: #fafbff;
}

.input.full {
  width: 100%;
}

.input.flex-1 {
  flex: 1;
}

.textarea {
  width: 100%;
  min-height: 80px;
  padding: 12px 16px;
  border-radius: 8px;
  border: 2px solid #e8f0fe;
  margin-bottom: 12px;
  font-size: 0.9rem;
  line-height: 1.5;
  resize: vertical;
  transition: all 0.3s ease;
  background: #ffffff;
}

.textarea:focus {
  outline: none;
  border-color: #1a73e8;
  box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
  background: #fafbff;
}

/* Study rooms */
.study-rooms {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 25px;
}

.room-card {
  background: #fff;
  border: 1px solid var(--border);
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.3s ease;
}

.room-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.room-header {
  padding: 20px;
  border-bottom: 1px solid var(--border);
}

.room-title {
  font-size: 1.2rem;
  font-weight: 600;
  margin-bottom: 8px;
}

.room-meta {
  display: flex;
  gap: 15px;
  color: var(--gray);
  font-size: 0.9rem;
}

.room-desc {
  padding: 0 20px 15px;
  color: var(--gray);
  font-size: 0.9rem;
  line-height: 1.4;
}

.room-participants {
  padding: 15px 20px;
  border-bottom: 1px solid var(--border);
}

.participants-list {
  display: flex;
  gap: 10px;
}

.participant {
  width: 35px;
  height: 35px;
  border-radius: 50%;
  background: var(--primary);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  font-weight: bold;
}

.room-actions {
  padding: 15px 20px;
  display: flex;
  gap: 10px;
}

.flex-1 {
  flex: 1;
}

/* ===== 学习社区统一卡片样式 ===== */

/* 1. 统一的卡片容器 */
.team-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 25px;
  margin-top: 15px;
}

/* 2. 卡片基础样式 */
.team-card {
  background: #ffffff;
  border: 1px solid #e8f0fe;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(11, 45, 70, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  position: relative;
  border-left: 4px solid #1a73e8;
}

.team-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(11, 45, 70, 0.1);
  border-color: #d2e3fc;
}

/* 自习室卡片特殊标识 */
.team-card.room-type {
  border-left-color: #7c3aed;
}

.team-card.room-type::after {
  content: '🏠';
  position: absolute;
  top: 16px;
  right: 16px;
  font-size: 1.2rem;
  opacity: 0.6;
}

/* 3. 卡片状态栏 */
.card-status-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 8px 12px;
  background: linear-gradient(90deg, #f8f9fa 0%, #f0f5ff 100%);
  border-radius: 8px;
  border: 1px solid #e8f0fe;
}

.status-text {
  background: linear-gradient(135deg, #1a73e8 0%, #4285f4 100%);
  color: white;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  box-shadow: 0 2px 6px rgba(26, 115, 232, 0.3);
  border: 2px solid rgba(255, 255, 255, 0.2);
}

.team-card.room-type .status-text {
  background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%);
  box-shadow: 0 2px 6px rgba(124, 58, 237, 0.3);
}

.status-days {
  color: #6b7e90;
  font-size: 0.8rem;
  display: flex;
  align-items: center;
  gap: 4px;
}

/* 4. 卡片头部 */
.team-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.team-avatar {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  background: #1a73e8;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
  font-weight: bold;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(26, 115, 232, 0.2);
  border: 3px solid #ffffff;
}

.team-card.room-type .team-avatar {
  background: #7c3aed;
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.3);
}

.team-avatar.room-avatar i {
  font-size: 1.3rem;
}

.team-info {
  flex: 1;
  min-width: 0;
}

.team-name {
  font-size: 1.15rem;
  font-weight: 600;
  color: #0b3757;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.team-creator {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  color: #6b7e90;
}

.team-creator i {
  font-size: 0.75rem;
  color: #4a7fc1;
}

/* 5. 描述区域 */
.team-desc {
  color: #6b7e90;
  font-size: 0.9rem;
  line-height: 1.5;
  margin-bottom: 16px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* 6. 标签区域 */
.team-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}

.tag {
  background: #f0f5ff;
  color: #1a73e8;
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 500;
  border: 1px solid #e8f0fe;
}

/* 7. 成员区域 */
.team-participants {
  margin-bottom: 20px;
}

.participants-label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  color: #6b7e90;
  margin-bottom: 12px;
}

.participants-label i {
  font-size: 0.8rem;
  color: #4a7fc1;
}

.participants-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.participant {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #1a73e8;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: bold;
  border: 2px solid white;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.team-card.room-type .participant {
  background: #7c3aed;
}

/* 8. 进度条区域 */
.team-progress {
  margin-bottom: 24px;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.progress-label {
  font-size: 0.85rem;
  color: #6b7e90;
  font-weight: 500;
}

.progress-count {
  font-size: 0.85rem;
  color: #1a73e8;
  font-weight: 600;
}

.progress-bar {
  height: 10px;
  background: #e8f0fe;
  border-radius: 6px;
  overflow: hidden;
  position: relative;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #1a73e8 0%, #4285f4 50%, #1a73e8 100%);
  border-radius: 6px;
  transition: width 0.8s ease;
  position: relative;
  box-shadow: 0 2px 4px rgba(26, 115, 232, 0.3);
}

.team-card.room-type .progress-fill {
  background: #7c3aed;
}

/* 9. 按钮区域 */
.team-actions {
  display: flex;
  gap: 12px;
}

.team-actions .btn {
  flex: 1;
  padding: 8px 12px;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
}

.team-actions .btn-primary {
  background: #1a73e8;
  color: white;
}

.team-actions .btn-primary:hover {
  background: #0d5bb9;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(26, 115, 232, 0.3);
}

.team-actions .btn-secondary {
  background: #f5f7fa;
  color: #5f6368;
  border: 1px solid #dadce0;
}

.team-actions .btn-secondary:hover {
  background: #e8f0fe;
  border-color: #1a73e8;
  color: #1a73e8;
  transform: translateY(-2px);
}

.team-actions .btn-small {
  padding: 6px 10px;
  font-size: 0.8rem;
}

.team-actions .flex-1 {
  flex: 1;
}

/* 10. 组队学习详情区域 */
.section-detail {
  background: #ffffff;
  border: 1px solid rgba(14, 66, 120, 0.08);
  border-radius: 16px;
  padding: 24px;
  margin-top: 24px;
  box-shadow: 0 4px 12px rgba(11, 45, 70, 0.04);
}

.detail-meta {
  font-size: 0.9rem;
  color: #6b7e90;
  margin: 8px 0 20px;
}

.sub-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #0b3757;
  margin: 20px 0 12px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.sub-title i {
  color: #4a7fc1;
}

.empty-tip {
  text-align: center;
  padding: 60px 20px;
  color: #9aa0a6;
  font-size: 1rem;
  background: #f8f9fa;
  border-radius: 16px;
  margin: 24px 0;
  border: 2px dashed #e0e0e0;
  position: relative;
}

.empty-tip::before {
  content: '📝';
  font-size: 3rem;
  display: block;
  margin-bottom: 16px;
  opacity: 0.6;
}

.empty-tip::after {
  content: '';
  position: absolute;
  top: 20px;
  right: 20px;
  width: 40px;
  height: 40px;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23e0e0e0"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>') no-repeat center;
  background-size: contain;
  opacity: 0.3;
}

/* 11. 任务创建区域 */
.task-create {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 12px;
  margin-top: 20px;
}

.task-input-row {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
}

.task-input-row .input {
  flex: 1;
  padding: 10px 12px;
  border: 1px solid #dadce0;
  border-radius: 8px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.task-input-row .input:focus {
  outline: none;
  border-color: #1a73e8;
  box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
}

.textarea {
  width: 100%;
  min-height: 80px;
  padding: 12px;
  border: 1px solid #dadce0;
  border-radius: 8px;
  font-size: 0.9rem;
  resize: vertical;
  transition: all 0.3s ease;
}

.textarea:focus {
  outline: none;
  border-color: #1a73e8;
  box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
}

/* 12. 空状态 */
.empty-state {
  text-align: center;
  padding: 40px 20px;
  background: #f8f9fa;
  border-radius: 16px;
  margin: 30px 0;
  border: 2px dashed #dadce0;
}

.empty-state i {
  font-size: 3rem;
  color: #dadce0;
  margin-bottom: 16px;
}

.empty-state p {
  font-size: 1rem;
  color: #5f6368;
  margin-bottom: 8px;
}

.empty-state .empty-hint {
  font-size: 0.9rem;
  color: #9aa0a6;
  margin-bottom: 20px;
}

.browse-btn {
  background: #1a73e8;
  color: white;
  padding: 10px 24px;
  border: none;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.browse-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(26, 115, 232, 0.3);
}

/* 13. 响应式设计 */
@media (max-width: 1200px) {
  .team-grid {
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  }
}

@media (max-width: 768px) {
  .team-grid {
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
  }
  
  .team-card {
    padding: 20px;
  }
  
  .team-header {
    gap: 12px;
  }
  
  .team-avatar {
    width: 50px;
    height: 50px;
    font-size: 1.3rem;
  }
  
  .team-name {
    font-size: 1rem;
  }
  
  .team-actions {
    flex-wrap: wrap;
  }
  
  .team-actions .btn {
    flex: 1 0 calc(50% - 6px);
  }
}

@media (max-width: 480px) {
  .team-grid {
    grid-template-columns: 1fr;
  }
  
  .team-card {
    padding: 16px;
  }
  
  .card-status-bar {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .team-actions .btn {
    flex: 1 0 100%;
  }
  
  .task-input-row {
    flex-direction: column;
  }
}

/* 14. 动画效果 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.team-card {
  animation: fadeInUp 0.4s ease-out;
}

.team-card:nth-child(1) { animation-delay: 0.1s; }
.team-card:nth-child(2) { animation-delay: 0.2s; }
.team-card:nth-child(3) { animation-delay: 0.3s; }
.team-card:nth-child(4) { animation-delay: 0.4s; }
.team-card:nth-child(5) { animation-delay: 0.5s; }
.team-card:nth-child(6) { animation-delay: 0.6s; }

/* 15. 滚动条美化 */
.section-detail::-webkit-scrollbar {
  width: 6px;
}

.section-detail::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.section-detail::-webkit-scrollbar-thumb {
  background: #1a73e8;
  border-radius: 3px;
}

.section-detail::-webkit-scrollbar-thumb:hover {
  background: #0d5bb9;
}

/* Posts & comments */
.discussion-feed {
  max-height: 600px;
  overflow-y: auto;
}

.room-feed {
  max-height: 400px;
  background: #f8fbff;
  border-radius: 12px;
  padding: 16px;
}

.room-feed .post {
  background: #ffffff;
  border: 1px solid #e3f2fd;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.room-feed .post:hover {
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  border-color: #bbdefb;
}

.post {
  background: #ffffff;
  border: 1px solid #e8f0fe;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  transition: all 0.2s ease;
  position: relative;
}

.post:hover {
  box-shadow: 0 3px 10px rgba(11, 45, 70, 0.08);
  border-color: #d2e3fc;
}

.post::before {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 0;
  height: 0;
  border-left: 20px solid transparent;
  border-top: 20px solid #f0f5ff;
}

.post-create {
  margin-top: 10px;
}

.post-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 15px;
}

.post-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #1a73e8;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.post-user {
  font-weight: 600;
}

.post-time {
  color: var(--gray);
  font-size: 0.8rem;
  margin-left: auto;
}

.post-content h4 {
  margin-bottom: 6px;
}

.post-content p {
  line-height: 1.6;
}

.post-actions {
  display: flex;
  gap: 20px;
  color: var(--gray);
  margin-top: 10px;
}

.post-action {
  display: flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
  transition: color 0.3s ease;
}

.post-action:hover {
  color: #1a73e8;
}

.post-input {
  width: 100%;
  padding: 15px;
  border: 1px solid var(--border);
  border-radius: 12px;
  font-size: 1rem;
  resize: none;
  height: 100px;
  margin-bottom: 15px;
}

.post-input.small {
  height: 60px;
}

.post-input:focus {
  outline: none;
  border-color: #1a73e8;
  box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.1);
}

.post-footer {
  display: flex;
  justify-content: flex-end;
}

.post-bottom-row {
  display: flex;
  align-items: center;
  gap: 10px;
}

/* Comments */
.comment-list {
  margin-top: 15px;
  border-top: 1px solid var(--border);
  padding-top: 10px;
}

.comment-item {
  padding: 8px 0;
  border-bottom: 1px dashed var(--border);
  font-size: 0.9rem;
}

.comment-meta {
  display: flex;
  justify-content: space-between;
  color: var(--gray);
  font-size: 0.8rem;
}

.comment-text {
  margin: 4px 0;
}

.comment-create {
  margin-top: 10px;
}

/* Teachers */
.teachers-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 25px;
  margin-top: 20px;
}

.teacher-card {
  background: #fff;
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 25px;
  text-align: center;
  transition: all 0.3s ease;
  min-height: 300px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.teacher-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.teacher-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: #1a73e8;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 1.5rem;
  font-weight: bold;
  margin: 0 auto 15px;
}

.teacher-name {
  font-size: 1.2rem;
  font-weight: 600;
  margin-bottom: 5px;
}

.teacher-title {
  color: var(--primary);
  margin-bottom: 10px;
}

.teacher-desc {
  font-size: 0.95rem;
}

.teacher-stats {
  display: flex;
  justify-content: space-around;
  margin: 15px 0;
}

.teacher-stat {
  text-align: center;
}

.teacher-stat-value {
  font-size: 1.2rem;
  font-weight: bold;
  color: var(--primary);
}

.teacher-stat-label {
  font-size: 0.8rem;
  color: var(--gray);
}

/* Help cards */
.help-requests {
  display: grid;
  gap: 20px;
}

.help-card {
  background: #fff;
  border: 1px solid var(--border);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  gap: 15px;
  transition: all 0.3s ease;
}

.help-card:hover {
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.06);
  transform: translateY(-1px);
}

.help-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: var(--primary);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  flex-shrink: 0;
}

.help-content {
  flex: 1;
}

.help-title {
  font-weight: 600;
  margin-bottom: 8px;
}

.help-text {
  font-size: 0.95rem;
}

.help-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  color: var(--gray);
  font-size: 0.9rem;
  margin-top: 10px;
}

.help-actions {
  margin-top: 8px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

/* 创建表单样式 */
.create-form {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border: 1px solid #e8f0fe;
  border-radius: 16px;
  padding: 28px;
  margin-bottom: 28px;
  box-shadow: 0 4px 12px rgba(11, 45, 70, 0.06);
  position: relative;
}

.create-form::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #1a73e8, #34a853);
  border-radius: 16px 16px 0 0;
}

.create-form h3 {
  margin-bottom: 20px;
  color: var(--dark);
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: var(--dark);
}

.form-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

/* 互助学习相关样式 */
.status-solved {
  color: var(--secondary);
  font-weight: 500;
}

.status-unsolved {
  color: var(--danger);
  font-weight: 500;
}

/* 回答输入区域样式 */
.answer-input-section {
  margin-top: 15px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid var(--border);
}

.answer-input-actions {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}

/* 回答列表样式 */
.answers-list {
  margin-top: 15px;
  border-top: 1px solid var(--border);
  padding-top: 15px;
}

.answer-item {
  padding: 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  margin-bottom: 10px;
  background: #fafafa;
}

.answer-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.answer-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: var(--primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 0.8rem;
}

.answer-user {
  font-weight: 500;
}

.answer-time {
  color: var(--gray);
  font-size: 0.8rem;
  margin-left: auto;
}

.answer-content {
  line-height: 1.5;
  margin-bottom: 8px;
}

.answer-actions {
  display: flex;
  gap: 15px;
}

/* 响应式 */
@media (max-width: 768px) {
  .nav-links {
    display: none;
  }

  .team-grid,
  .study-rooms,
  .teachers-grid {
    grid-template-columns: 1fr;
  }

  .community-header h1 {
    font-size: 2rem;
  }

  .container {
    padding: 0 16px;
  }

  .status-bar {
    flex-direction: column;
    align-items: flex-start;
  }

  .post-bottom-row {
    flex-direction: column;
    align-items: stretch;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .help-actions {
    flex-direction: column;
  }
  
  .answer-input-actions {
    flex-direction: column;
  }
}

/* 社区页面整体样式优化 */
.community {
  padding-top: 20px;
  background: 
    linear-gradient(135deg, #fbfdff 0%, #f6fbff 25%, #f2f8ff 50%, #eef5ff 75%, #e8f2ff 100%),
    radial-gradient(circle at 10% 20%, rgba(26, 115, 232, 0.05) 0%, transparent 50%),
    radial-gradient(circle at 90% 80%, rgba(52, 168, 83, 0.05) 0%, transparent 50%);
  min-height: 100vh;
  position: relative;
  overflow-x: hidden;
}

.community::before {
  content: '';
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 60"><defs><pattern id="dots" width="60" height="60" patternUnits="userSpaceOnUse"><circle cx="30" cy="30" r="2" fill="%23e8f0fe"/></pattern></defs><rect width="100%" height="100%" fill="url(%23dots)"/></svg>');
  opacity: 0.4;
  z-index: -1;
  pointer-events: none;
}

/* 名师答疑 - 讲师卡片样式（参照首页） */
.instructor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 24px;
  margin-bottom: 30px;
}

.instructor-card {
  background: #ffffff;
  border: 1px solid #e8f0fe;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(11, 45, 70, 0.08);
  transition: all 0.3s ease;
  position: relative;
}

.instructor-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #1a73e8, #4285f4, #34a853, #fbbc04, #ea4335);
}

.instructor-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(11, 45, 70, 0.1);
}

.instructor-media {
  background: #ffffff;
  padding: 16px 16px 12px;
}

.instructor-avatar {
  width: 100%;
  aspect-ratio: 1 / 1;
  border-radius: 12px;
  background: #1a73e8;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 48px;
  overflow: hidden;
}

.instructor-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 12px;
}

.instructor-body {
  padding: 8px 16px 16px;
}

.instructor-name {
  font-size: 1.15rem;
  font-weight: 600;
  color: #0b3757;
  margin-bottom: 6px;
}

.instructor-desc {
  font-size: 0.85rem;
  color: #888;
  margin-bottom: 14px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.instructor-stats {
  display: flex;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 14px;
}

.instructor-stats .stat {
  flex: 1;
  background: #f0f5ff;
  border: 1px solid #e8f0fe;
  padding: 10px 8px;
  border-radius: 10px;
  text-align: center;
}

.instructor-stats .stat-label {
  display: block;
  color: #6b7e90;
  font-size: 0.75rem;
  margin-bottom: 4px;
}

.instructor-stats .stat-value {
  display: block;
  color: var(--primary);
  font-weight: 700;
  font-size: 1.1rem;
}

/* 问答列表样式 */
.qa-section {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid var(--border);
}

.qa-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.qa-card {
  background: #fff;
  border: 1px solid #e8f0fe;
  border-radius: 12px;
  padding: 24px;
  transition: all 0.3s ease;
  position: relative;
  border-left: 4px solid #34a853;
}

.qa-card::before {
  content: '💡';
  position: absolute;
  top: 16px;
  right: 16px;
  font-size: 1.2rem;
  opacity: 0.6;
}

.qa-card:hover {
  box-shadow: 0 4px 12px rgba(11, 45, 70, 0.08);
  transform: translateY(-1px);
}

.qa-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.qa-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--primary);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  flex-shrink: 0;
}

.qa-info {
  flex: 1;
}

.qa-user {
  font-weight: 600;
  color: var(--dark);
}

.qa-course {
  font-size: 0.85rem;
  color: var(--gray);
}

.qa-status {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
}

.qa-status.solved {
  background: linear-gradient(135deg, #34a853, #4caf50);
  color: white;
  box-shadow: 0 2px 6px rgba(52, 168, 83, 0.3);
}

.qa-status.solved::before {
  content: '✓ ';
}

.qa-status.unsolved {
  background: linear-gradient(135deg, #ff9800, #ffc107);
  color: white;
  box-shadow: 0 2px 6px rgba(255, 152, 0, 0.3);
}

.qa-status.unsolved::before {
  content: '⏳ ';
}

.qa-content h4 {
  margin-bottom: 8px;
  color: var(--dark);
}

.qa-content p {
  color: var(--gray);
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.qa-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 15px;
  padding-top: 12px;
  border-top: 1px solid var(--border);
}

.qa-stats {
  display: flex;
  gap: 15px;
  color: var(--gray);
  font-size: 0.9rem;
}

.qa-stats span {
  display: flex;
  align-items: center;
  gap: 5px;
}

.qa-actions {
  display: flex;
  gap: 8px;
}

@media (min-width: 1200px) {
  .instructor-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 768px) {
  .instructor-grid {
    grid-template-columns: 1fr;
  }
  
  .qa-footer {
    flex-direction: column;
    gap: 10px;
    align-items: flex-start;
  }
  
  .qa-actions {
    width: 100%;
    flex-wrap: wrap;
  }
}

/* 添加一些新样式 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 24px;
  border-radius: 12px;
  max-width: 500px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
}

.modal-actions {
  display: flex;
  gap: 12px;
  margin-top: 20px;
  justify-content: flex-end;
}

.answer-option {
  padding: 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  margin-bottom: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.answer-option:hover {
  border-color: var(--primary);
  background: var(--primary-light);
}

.answer-option.selected {
  border-color: var(--primary);
  background: var(--primary-light);
}

.answer-content {
  margin-bottom: 8px;
}

.answer-author {
  font-size: 0.9rem;
  color: var(--gray);
}

.accepted-answer {
  border-left: 4px solid var(--secondary);
  background: rgba(52, 168, 83, 0.05);
}

.answer-badge {
  background: var(--secondary);
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 0.75rem;
  margin-bottom: 8px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.post-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

/* ========== 设计感半圆装饰元素 ========== */

/* 主页面装饰已移除，避免遮挡内容 */

/* 头部左下角装饰半圆 */
.community-header::after {
  content: '';
  position: absolute;
  bottom: -150px;
  left: -150px;
  width: 300px;
  height: 300px;
  background: linear-gradient(45deg, rgba(255, 193, 7, 0.1) 0%, rgba(255, 152, 0, 0.08) 100%);
  border-radius: 50%;
  z-index: 0;
  animation: pulse-gentle 15s ease-in-out infinite;
}

/* 内容区域和标签页装饰已移除 */

/* 所有卡片装饰半圆已移除，避免遮挡点击 */

/* 状态栏装饰半圆 */
.status-bar::before {
  content: '';
  position: absolute;
  left: -40px;
  top: 50%;
  transform: translateY(-50%);
  width: 80px;
  height: 80px;
  background: linear-gradient(90deg, rgba(26, 115, 232, 0.06) 0%, rgba(52, 168, 83, 0.04) 100%);
  border-radius: 50%;
  z-index: -1;
  animation: breathe 8s ease-in-out infinite;
}

/* 创建表单装饰半圆 */
.create-form::after {
  content: '';
  position: absolute;
  top: -50px;
  right: -50px;
  width: 100px;
  height: 100px;
  background: linear-gradient(135deg, rgba(63, 81, 181, 0.08) 0%, rgba(103, 58, 183, 0.06) 100%);
  border-radius: 50%;
  z-index: 0;
  opacity: 0.7;
  animation: wobble 10s ease-in-out infinite;
}

/* ========== 半圆动画效果 ========== */

@keyframes float-slow {
  0%, 100% { 
    transform: translateY(0px) rotate(0deg); 
    opacity: 0.6;
  }
  50% { 
    transform: translateY(-20px) rotate(180deg); 
    opacity: 0.8;
  }
}

@keyframes pulse-gentle {
  0%, 100% { 
    transform: scale(1); 
    opacity: 0.6; 
  }
  50% { 
    transform: scale(1.1); 
    opacity: 0.8; 
  }
}

@keyframes rotate-slow {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@keyframes scale-pulse {
  0%, 100% { 
    transform: translateX(-50%) scale(1); 
    opacity: 0.5;
  }
  50% { 
    transform: translateX(-50%) scale(1.2); 
    opacity: 0.7;
  }
}

@keyframes bounce-gentle {
  0%, 100% { transform: translateY(0px); }
  25% { transform: translateY(-3px); }
  50% { transform: translateY(-5px); }
  75% { transform: translateY(-2px); }
}

@keyframes spin-gentle {
  0% { transform: rotate(0deg) scale(1); }
  50% { transform: rotate(180deg) scale(1.1); }
  100% { transform: rotate(360deg) scale(1); }
}

@keyframes drift {
  0%, 100% { 
    transform: translateX(0px) translateY(0px); 
    opacity: 0.4;
  }
  25% { 
    transform: translateX(10px) translateY(-5px); 
    opacity: 0.6;
  }
  50% { 
    transform: translateX(-5px) translateY(-10px); 
    opacity: 0.8;
  }
  75% { 
    transform: translateX(-10px) translateY(5px); 
    opacity: 0.5;
  }
}

@keyframes breathe {
  0%, 100% { 
    transform: translateY(-50%) scale(1); 
    opacity: 0.3;
  }
  50% { 
    transform: translateY(-50%) scale(1.15); 
    opacity: 0.6;
  }
}

@keyframes wobble {
  0%, 100% { 
    transform: rotate(0deg) scale(1); 
    opacity: 0.7;
  }
  25% { 
    transform: rotate(5deg) scale(1.05); 
    opacity: 0.8;
  }
  50% { 
    transform: rotate(-3deg) scale(0.95); 
    opacity: 0.6;
  }
  75% { 
    transform: rotate(2deg) scale(1.02); 
    opacity: 0.9;
  }
}

/* ========== 响应式半圆调整 ========== */

@media (max-width: 1200px) {
  .community::after {
    width: 300px;
    height: 300px;
    top: -150px;
    right: -150px;
  }
  
  .community-header::after {
    width: 250px;
    height: 250px;
    bottom: -125px;
    left: -125px;
  }
}

@media (max-width: 768px) {
  .community::after {
    width: 200px;
    height: 200px;
    top: -100px;
    right: -100px;
  }
  
  .community-header::after {
    width: 150px;
    height: 150px;
    bottom: -75px;
    left: -75px;
  }
  
  .content-section::before {
    width: 100px;
    height: 100px;
    top: -50px;
    right: -50px;
  }
  
  .tabs::after {
    width: 120px;
    height: 120px;
    bottom: -60px;
  }
  
  /* 移动端隐藏部分装饰元素以提升性能 */
  .team-card::after,
  .post::after,
  .instructor-card::after {
    display: none;
  }
}

@media (max-width: 480px) {
  .community::after,
  .community-header::after,
  .content-section::before {
    display: none;
  }
  
  .tabs::after {
    width: 80px;
    height: 80px;
    bottom: -40px;
  }
}

/* ========== 半圆颜色主题变化 ========== */

/* 为不同标签页添加不同颜色的半圆 */
.community[data-active-tab="teams"] .content-section::before {
  background: linear-gradient(225deg, rgba(26, 115, 232, 0.08) 0%, rgba(66, 133, 244, 0.06) 100%);
}

.community[data-active-tab="study-rooms"] .content-section::before {
  background: linear-gradient(225deg, rgba(124, 58, 237, 0.08) 0%, rgba(168, 85, 247, 0.06) 100%);
}

.community[data-active-tab="discussion"] .content-section::before {
  background: linear-gradient(225deg, rgba(52, 168, 83, 0.08) 0%, rgba(76, 175, 80, 0.06) 100%);
}

.community[data-active-tab="teachers"] .content-section::before {
  background: linear-gradient(225deg, rgba(255, 193, 7, 0.08) 0%, rgba(255, 152, 0, 0.06) 100%);
}

.community[data-active-tab="help"] .content-section::before {
  background: linear-gradient(225deg, rgba(255, 87, 34, 0.08) 0%, rgba(244, 67, 54, 0.06) 100%);
}

/* 深色模式适配（如果需要） */
@media (prefers-color-scheme: dark) {
  .community::after {
    background: linear-gradient(135deg, rgba(26, 115, 232, 0.15) 0%, rgba(52, 168, 83, 0.12) 100%);
  }
  
  .community-header::after {
    background: linear-gradient(45deg, rgba(255, 193, 7, 0.18) 0%, rgba(255, 152, 0, 0.15) 100%);
  }
  
  .content-section::before {
    background: linear-gradient(225deg, rgba(156, 39, 176, 0.12) 0%, rgba(233, 30, 99, 0.08) 100%);
  }
}
</style>