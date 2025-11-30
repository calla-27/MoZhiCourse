<template>
  <div class="course-video-container">
<<<<<<< HEAD
    <!-- 顶部标题栏 -->
=======
    <!-- 顶部导航栏 -->
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
    <nav class="top-navbar">
      <div class="nav-left">
        <button class="back-btn" @click="goBack">
          <i class="fas fa-arrow-left"></i>
          <span>返回</span>
        </button>
<<<<<<< HEAD
=======
        <div class="logo">
          <i class="fas fa-graduation-cap"></i>
          <span>墨知课堂</span>
        </div>
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
      </div>
      
      <div class="nav-center" v-if="currentCourse.course_name">
        <h2 class="course-title">{{ currentCourse.course_name }}</h2>
        <div class="video-title" v-if="currentVideo.video_title">
          {{ currentVideo.video_title }}
<<<<<<< HEAD
=======
        </div>
      </div>
      
      <div class="nav-right" v-if="userInfo.user_name">
        <div class="user-info">
          <span>{{ userInfo.user_name }}</span>
          <div class="avatar">
            {{ userInfo.avatar || userInfo.user_name?.charAt(0) }}
          </div>
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
        </div>
      </div>
    </nav>

<<<<<<< HEAD
=======
    <!-- 主要内容区域 -->
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
    <main class="main-layout">
      <!-- 左侧章节目录 -->
      <aside class="chapter-sidebar" :class="{ collapsed: chapterCollapsed }">
        <div class="sidebar-header">
          <h3>课程目录</h3>
          <button class="collapse-btn" @click="toggleChapterSidebar">
            <i class="fas" :class="chapterCollapsed ? 'fa-chevron-right' : 'fa-chevron-left'"></i>
          </button>
        </div>
        <div class="sidebar-content" v-show="!chapterCollapsed">
          <ChapterList
            :chapters="chapters"
            :current-video-id="currentVideo.video_id"
            @video-change="handleVideoChange"
          />
        </div>
      </aside>

      <!-- 中间视频和AI区域 -->
      <section class="center-content">
        <!-- 视频播放器区域 -->
        <div class="video-section">
          <div class="video-player-container">
            <template v-if="currentVideo.video_id">
              <CourseVideoPlayer
                :video-url="getVideoUrl(currentVideo)"
                :initial-progress="learningProgress"
                @progress-update="handleProgressUpdate"
                @behavior-record="handleBehaviorRecord"
              />
            </template>
            
            <div v-else class="empty-video-player">
              <i class="fas fa-video"></i>
              <p>请选择左侧章节开始学习</p>
            </div>
          </div>

          <!-- 视频信息和操作栏 -->
          <div class="video-actions" v-if="currentVideo.video_id">
            <div class="video-info-section">
              <div class="episode-info">
                <span class="current-episode">第{{ getCurrentEpisodeNumber() }}集</span>
                <span class="video-title">{{ currentVideo.video_title }}</span>
              </div>
              <div class="video-stats">
                <span class="duration">时长: {{ formatDuration(currentVideo.duration_seconds) }}</span>
              </div>
            </div>
            
            <div class="action-buttons">
              <button class="action-btn" @click="toggleLike" :class="{ active: isLiked }">
                <i class="fas fa-thumbs-up"></i>
                <span>{{ isLiked ? '已点赞' : '点赞' }}</span>
              </button>
              <button class="action-btn" @click="toggleCollect" :class="{ active: isCollected }">
                <i class="fas fa-star"></i>
                <span>{{ isCollected ? '已收藏' : '收藏' }}</span>
              </button>
              <button class="action-btn" @click="shareVideo">
                <i class="fas fa-share"></i>
                <span>分享</span>
              </button>
              <button class="action-btn" @click="showEpisodeList = !showEpisodeList">
                <i class="fas fa-list"></i>
                <span>选集</span>
              </button>
              <button class="action-btn" @click="playNext" :disabled="!hasNextVideo">
                <i class="fas fa-step-forward"></i>
                <span>下一集</span>
              </button>
            </div>
          </div>
        </div>

        <!-- 课程描述区域 -->
        <div class="course-description" v-if="currentCourse.course_desc">
          <div class="description-header">
            <h3>课程介绍</h3>
          </div>
          <div class="description-content">
            <p>{{ currentCourse.course_desc }}</p>
            
            <!-- 课程详细信息 -->
            <div class="course-details">
              <div class="detail-item">
                <span class="detail-label">难度等级：</span>
                <span class="detail-value">{{ currentCourse.difficulty_level || '初级' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">课程时长：</span>
                <span class="detail-value">{{ currentCourse.course_duration || '待更新' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">学习人数：</span>
                <span class="detail-value">{{ currentCourse.student_count || 0 }}人</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">课程评分：</span>
                <span class="detail-value">{{ currentCourse.rating || '暂无评分' }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 右侧面板：笔记和资料 -->
      <aside class="right-panel" :class="{ collapsed: rightPanelCollapsed }">
        <div class="panel-header">
          <div class="panel-tabs">
            <button class="tab-btn" 
                    :class="{ active: activeRightTab === 'comments' }"
                    @click="activeRightTab = 'comments'">
              <i class="fas fa-comments"></i>
              <span>评论</span>
            </button>
            <button class="tab-btn" 
                    :class="{ active: activeRightTab === 'notes' }"
                    @click="activeRightTab = 'notes'">
              <i class="fas fa-sticky-note"></i>
              <span>笔记</span>
            </button>
            <button class="tab-btn" 
                    :class="{ active: activeRightTab === 'materials' }"
                    @click="activeRightTab = 'materials'">
              <i class="fas fa-folder"></i>
              <span>资料</span>
            </button>
            <button class="tab-btn" 
                    :class="{ active: activeRightTab === 'ai' }"
                    @click="activeRightTab = 'ai'">
              <i class="fas fa-robot"></i>
              <span>小墨</span>
            </button>
<<<<<<< HEAD
=======
            <button class="tab-btn" 
                    :class="{ active: activeRightTab === 'tools' }"
                    @click="activeRightTab = 'tools'">
              <i class="fas fa-tools"></i>
              <span>工具</span>
            </button>
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
          </div>
          <button class="panel-toggle" @click="rightPanelCollapsed = !rightPanelCollapsed">
            <i class="fas" :class="rightPanelCollapsed ? 'fa-chevron-left' : 'fa-chevron-right'"></i>
          </button>
        </div>

        <div class="panel-content" v-show="!rightPanelCollapsed">
          <!-- 评论区 -->
          <div v-if="activeRightTab === 'comments'" class="tab-pane comments-pane">
            <template v-if="currentVideo.video_id">
              <!-- 评论列表区域 -->
              <div class="comments-list-area">
                <DiscussionPanel
                  :video-id="currentVideo.video_id"
                  :discussions="discussions"
<<<<<<< HEAD
                  :user-info="userInfo"
=======
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
                  @send-message="handleSendMessage"
                  @discussion-search="handleDiscussionSearch"
                  @like-discussion="handleLikeDiscussion"
                  @reply-discussion="handleReplyDiscussion"
                />
              </div>
<<<<<<< HEAD
=======
              
              <!-- 固定的发表评论区域 -->
              <div class="comment-input-fixed">
                <div class="comment-input-header">
                  <h4>发表讨论</h4>
                </div>
                <div class="comment-input-form">
                  <textarea 
                    v-model="newComment" 
                    placeholder="说说你的想法..."
                    class="comment-textarea"
                    rows="3"
                  ></textarea>
                  <div class="comment-actions">
                    <button class="send-comment-btn" @click="sendComment" :disabled="!newComment.trim()">
                      <i class="fas fa-paper-plane"></i>
                      <span>发送</span>
                    </button>
                  </div>
                </div>
              </div>
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
            </template>
            <div v-else class="empty-state">
              <i class="fas fa-comments"></i>
              <p>请选择视频查看评论</p>
            </div>
          </div>

          <!-- 笔记面板 -->
          <div v-if="activeRightTab === 'notes'" class="tab-pane">
            <div class="notes-section">
              <div class="notes-header">
                <h4>我的笔记</h4>
                <button class="add-note-btn" @click="addNote">
                  <i class="fas fa-plus"></i>
                  <span>添加笔记</span>
                </button>
              </div>
              <div class="notes-list">
                <div v-for="note in notes" :key="note.id" class="note-item">
                  <div class="note-time">{{ formatTime(note.timestamp) }}</div>
                  <div class="note-content">{{ note.content }}</div>
                  <div class="note-actions">
                    <button @click="editNote(note)">
                      <i class="fas fa-edit"></i>
                    </button>
                    <button @click="deleteNote(note.id)">
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </div>
                <div v-if="notes.length === 0" class="empty-state">
                  <i class="fas fa-sticky-note"></i>
                  <p>还没有笔记，开始记录学习心得吧</p>
                </div>
              </div>
            </div>
          </div>

          <!-- 课程资料 -->
          <div v-if="activeRightTab === 'materials'" class="tab-pane">
            <div class="materials-section">
              <h4>课程资料</h4>
              <div class="materials-list">
                <div v-for="material in courseMaterials" :key="material.id" class="material-item">
                  <div class="material-icon">
                    <i class="fas" :class="getMaterialIcon(material.type)"></i>
                  </div>
                  <div class="material-info">
                    <div class="material-name">{{ material.name }}</div>
                    <div class="material-size">{{ material.size }}</div>
                  </div>
                  <button class="download-btn" @click="downloadMaterial(material)">
                    <i class="fas fa-download"></i>
                  </button>
                </div>
                <div v-if="courseMaterials.length === 0" class="empty-state">
                  <i class="fas fa-folder-open"></i>
                  <p>暂无课程资料</p>
                </div>
              </div>
            </div>
          </div>

          <!-- AI助手面板 -->
          <div v-if="activeRightTab === 'ai'" class="tab-pane">
            <div class="ai-section-panel">
              <template v-if="currentVideo.video_id && currentCourse.course_id">
                <AIAssistant 
                  @question-submit="handleAIQuestion" 
                  :video-id="currentVideo.video_id"
                  :course-id="currentCourse.course_id"
                />
              </template>
              <div v-else class="empty-state">
                <i class="fas fa-robot"></i>
                <p>请选择视频以启用小墨助手</p>
              </div>
            </div>
          </div>
<<<<<<< HEAD
=======

          <!-- 学习工具面板 -->
          <div v-if="activeRightTab === 'tools'" class="tab-pane">
            <div class="tools-section-panel">
              <!-- 学习进度 -->
              <div class="tool-item">
                <div class="tool-icon">
                  <i class="fas fa-chart-line"></i>
                </div>
                <div class="tool-info">
                  <h4>学习进度</h4>
                  <div class="progress-bar">
                    <div class="progress-fill" :style="{ width: '65%' }"></div>
                  </div>
                  <span class="progress-text">65% 完成</span>
                </div>
              </div>

              <!-- 学习统计 -->
              <div class="tool-item">
                <div class="tool-icon">
                  <i class="fas fa-clock"></i>
                </div>
                <div class="tool-info">
                  <h4>学习时长</h4>
                  <p class="stat-value">2小时30分钟</p>
                </div>
              </div>

              <!-- 知识点 -->
              <div class="tool-item">
                <div class="tool-icon">
                  <i class="fas fa-lightbulb"></i>
                </div>
                <div class="tool-info">
                  <h4>重点知识</h4>
                  <div class="knowledge-tags">
                    <span class="tag">变量定义</span>
                    <span class="tag">数据类型</span>
                    <span class="tag">循环结构</span>
                  </div>
                </div>
              </div>

              <!-- 快捷操作 -->
              <div class="tool-item">
                <div class="tool-icon">
                  <i class="fas fa-bookmark"></i>
                </div>
                <div class="tool-info">
                  <h4>快捷操作</h4>
                  <div class="quick-actions">
                    <button class="quick-btn">
                      <i class="fas fa-download"></i>
                      <span>下载课件</span>
                    </button>
                    <button class="quick-btn">
                      <i class="fas fa-print"></i>
                      <span>打印笔记</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
        </div>
      </aside>

      <!-- 右侧面板隐藏时的打开按钮 -->
      <div v-if="rightPanelCollapsed" class="right-panel-toggle-btn" @click="rightPanelCollapsed = false">
        <i class="fas fa-chevron-left"></i>
      </div>
    </main>

    <!-- 推荐课程区域 -->
    <section class="recommended-courses">
      <div class="container">
        <h2>推荐课程</h2>
        <p>这里可以添加推荐课程内容...</p>
        <!-- 为了演示滚动效果，添加一些占位内容 -->
        <div class="placeholder-content">
          <div class="placeholder-item" v-for="i in 6" :key="i">
            <div class="placeholder-image"></div>
            <div class="placeholder-text">
              <div class="placeholder-title"></div>
              <div class="placeholder-desc"></div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 选集弹窗 -->
    <div v-if="showEpisodeList" class="episode-modal" @click="showEpisodeList = false">
      <div class="episode-content" @click.stop>
        <div class="episode-header">
          <h3>选择集数</h3>
          <button @click="showEpisodeList = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="episode-list">
          <div v-for="(video, index) in getAllVideos()" 
               :key="video.video_id"
               class="episode-item"
               :class="{ active: video.video_id === currentVideo.video_id }"
               @click="selectEpisode(video)">
            <div class="episode-number">第{{ index + 1 }}集</div>
            <div class="episode-title">{{ video.video_title }}</div>
            <div class="episode-duration">{{ formatDuration(video.duration_seconds) }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import ChapterList from "@/components/ChapterList.vue";
import CourseVideoPlayer from "@/components/CourseVideoPlayer.vue";
import AIAssistant from "@/components/AIAssistant.vue";
import DiscussionPanel from "@/components/DiscussionPanel.vue";

import {
  getCourseDetail,
  getCourseChapters,
  getVideoDetail,
  getVideoProgress,
  updateVideoProgress,
  recordLearningBehavior,
} from "@/api/courseVideo";
import { getComments } from "@/api/comment";

export default {
  name: "CourseVideo",
  components: {
    ChapterList,
    CourseVideoPlayer,
    AIAssistant,
    DiscussionPanel,
  },
  setup() {
    const route = useRoute();
    const courseId = route.params.courseId || 7;
    const videoId = route.params.videoId || 1;

    const currentCourse = ref({});
    const currentVideo = ref({});
    const chapters = ref([]);
    const discussions = ref([]);
    const discussionFilters = reactive({
      keyword: "",
      sort: "latest",
    });
    const userInfo = ref({});
    const learningProgress = ref(0);
    const newComment = ref('');

    const fetchUserInfo = async () => {
      try {
        // 从 localStorage 获取用户信息
        const storedUser = localStorage.getItem('user')
        if (storedUser) {
          const user = JSON.parse(storedUser)
          userInfo.value = {
            user_id: user.user_id || user.userId,
            user_name: user.user_name || user.userName,
            avatar: user.avatar_url || (user.user_name ? user.user_name.charAt(0) : '用'),
          }
        }
      } catch (error) {
        console.error("获取用户信息失败:", error);
      }
    };

    // 获取视频URL
    const getVideoUrl = (video) => {
      if (!video || !video.video_url) return "";
      // 如果是相对路径，转换为绝对路径
      if (video.video_url.startsWith("/")) {
        if (video.video_url.includes("demo")) {
          return "/videos/demo.mp4";
        }
        return `http://localhost:4000${video.video_url}`;
      }
      return video.video_url;
    };

    // 获取课程数据
    const fetchCourseData = async () => {
      try {
        console.log("开始获取课程数据...");
        const initialVideoId = route.params.videoId || 1;

        const [courseRes, chaptersRes, videoRes] = await Promise.all([
          getCourseDetail(courseId),
          getCourseChapters(courseId),
          getVideoDetail(initialVideoId),
        ]);

        currentCourse.value = courseRes.data || {};
        chapters.value = chaptersRes.data || [];
        currentVideo.value = videoRes.data || {};

        if (currentVideo.value.video_id) {
          await Promise.all([fetchLearningProgress(), fetchDiscussions()]);
        } else if (chapters.value.length > 0) {
          const firstVideo = chapters.value
            .flatMap((chapter) => chapter.videos)
            .find((video) => video);
          if (firstVideo) {
            console.log("初始视频无数据，尝试加载第一个视频:", firstVideo);
            await handleVideoChange(firstVideo);
          }
        }
      } catch (error) {
        console.error("获取课程数据失败:", error);
      }
    };

    // 获取学习进度 (使用 currentVideo.value.video_id)
    const fetchLearningProgress = async () => {
      if (!currentVideo.value.video_id) {
        learningProgress.value = 0; 
        return;
      }
      try {
        const res = await getVideoProgress(currentVideo.value.video_id);
        learningProgress.value = res.data?.progress || 0;
      } catch (error) {
        console.error("获取学习进度失败:", error);
      }
    };

    // 获取讨论数据
    const fetchDiscussions = async () => {
      if (!currentVideo.value.video_id) {
        discussions.value = []; 
        return;
      }
      try {
        const res = await getComments(currentVideo.value.video_id, {
          keyword: discussionFilters.keyword,
          sort: discussionFilters.sort,
        });
        discussions.value = res.data || [];
      } catch (error) {
        console.error("获取讨论数据失败:", error);
      }
    };

    // 切换视频
    const handleVideoChange = async (video) => {
      currentVideo.value = video;
      await Promise.all([fetchLearningProgress(), fetchDiscussions()]);
    };

    // 更新学习进度
    const handleProgressUpdate = async (progress) => {
      try {
        if (!currentVideo.value.video_id) return;
        
        if (Math.abs(progress - learningProgress.value) > 1 || progress === 100) {
            learningProgress.value = progress; 
            await updateVideoProgress({
              videoId: currentVideo.value.video_id,
              progress: progress,
              currentTime:
                (progress / 100) * (currentVideo.value.duration_seconds || 0),
              duration: currentVideo.value.duration_seconds || 0,
            });
        }
      } catch (error) {
        console.error("更新学习进度失败:", error);
      }
    };

    // 记录学习行为
    const handleBehaviorRecord = async (behaviorData) => {
      console.log("记录学习行为:", behaviorData);
    };

    // AI问答
    const handleAIQuestion = async (question) => {
      console.log("AI 问答触发:", question);
    };

    // 发送讨论消息
    const handleSendMessage = async () => {
      await fetchDiscussions();
    };

    // 搜索讨论
    const handleDiscussionSearch = (payload) => {
      if (typeof payload === "string") {
        discussionFilters.keyword = payload;
      } else if (payload && typeof payload === "object") {
        if (Object.prototype.hasOwnProperty.call(payload, "keyword")) {
          discussionFilters.keyword = payload.keyword || "";
        }
        if (Object.prototype.hasOwnProperty.call(payload, "sort")) {
          discussionFilters.sort = payload.sort || "latest";
        }
      }

      fetchDiscussions();
    };

    // 点赞讨论
    const handleLikeDiscussion = (commentId) => {
      console.log("点赞讨论 ID:", commentId);
      fetchDiscussions();
    };

    // 回复讨论
    const handleReplyDiscussion = (replyData) => {
      console.log("回复讨论数据:", replyData);
      fetchDiscussions();
    };

    // 新增UI状态管理
    const chapterCollapsed = ref(false);
    const rightPanelCollapsed = ref(false);
    const activeRightTab = ref('comments'); // 默认显示评论
<<<<<<< HEAD
=======
    const aiMinimized = ref(false);
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
    
    // 播放器控制状态
    const isLiked = ref(false);
    const isCollected = ref(false);
<<<<<<< HEAD
    const showEpisodeList = ref(false);
    
=======
    const danmakuEnabled = ref(true);
    const subtitleEnabled = ref(false);
    const showSubtitleMenu = ref(false);
    const showSpeedMenu = ref(false);
    const showQualityMenu = ref(false);
    const showEpisodeList = ref(false);
    
    // 播放器设置
    const playbackSpeed = ref(1.0);
    const currentQuality = ref('高清');
    const speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    const qualityOptions = [
      { label: '超清', value: '1080p' },
      { label: '高清', value: '720p' },
      { label: '标清', value: '480p' },
      { label: '流畅', value: '360p' }
    ];
    
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
    // 笔记和资料
    const notes = ref([]);
    const courseMaterials = ref([
      { id: 1, name: '课程PPT.pdf', type: 'pdf', size: '2.5MB' },
      { id: 2, name: '源代码.zip', type: 'zip', size: '1.2MB' },
      { id: 3, name: '练习题.docx', type: 'doc', size: '856KB' }
    ]);

    // UI交互方法
    const goBack = () => {
      window.history.back();
    };

    const toggleChapterSidebar = () => {
      chapterCollapsed.value = !chapterCollapsed.value;
    };

    const toggleLike = () => {
      isLiked.value = !isLiked.value;
<<<<<<< HEAD
=======
      // TODO: 调用点赞API
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
    };

    const toggleCollect = () => {
      isCollected.value = !isCollected.value;
<<<<<<< HEAD
    };

    const shareVideo = () => {
      console.log('分享视频');
    };

=======
      // TODO: 调用收藏API
    };

    const shareVideo = () => {
      // TODO: 实现分享功能
      console.log('分享视频');
    };

    const toggleDanmaku = () => {
      danmakuEnabled.value = !danmakuEnabled.value;
      // TODO: 控制弹幕显示
    };

    const toggleSubtitle = () => {
      showSubtitleMenu.value = !showSubtitleMenu.value;
    };

    const setSubtitle = (type) => {
      subtitleEnabled.value = type !== 'off';
      showSubtitleMenu.value = false;
      // TODO: 设置字幕
    };

    const setPlaybackSpeed = (speed) => {
      playbackSpeed.value = speed;
      showSpeedMenu.value = false;
      // TODO: 设置播放速度
    };

    const setQuality = (quality) => {
      currentQuality.value = quality.label;
      showQualityMenu.value = false;
      // TODO: 设置视频清晰度
    };

>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
    const getCurrentEpisodeNumber = () => {
      const allVideos = getAllVideos();
      const currentIndex = allVideos.findIndex(v => v.video_id === currentVideo.value.video_id);
      return currentIndex + 1;
    };

    const getAllVideos = () => {
      return chapters.value.flatMap(chapter => chapter.videos || []);
    };

    const hasNextVideo = computed(() => {
      const allVideos = getAllVideos();
      const currentIndex = allVideos.findIndex(v => v.video_id === currentVideo.value.video_id);
      return currentIndex < allVideos.length - 1;
    });

    const playNext = () => {
      const allVideos = getAllVideos();
      const currentIndex = allVideos.findIndex(v => v.video_id === currentVideo.value.video_id);
      if (currentIndex < allVideos.length - 1) {
        handleVideoChange(allVideos[currentIndex + 1]);
      }
    };

    const selectEpisode = (video) => {
      handleVideoChange(video);
      showEpisodeList.value = false;
    };

    // 笔记功能
    const addNote = () => {
      const content = prompt('请输入笔记内容:');
      if (content) {
        notes.value.push({
          id: Date.now(),
          content,
          timestamp: Date.now(),
          videoTime: learningProgress.value
        });
      }
    };

    const editNote = (note) => {
      const newContent = prompt('编辑笔记:', note.content);
      if (newContent !== null) {
        note.content = newContent;
      }
    };

    const deleteNote = (noteId) => {
      if (confirm('确定要删除这条笔记吗？')) {
        notes.value = notes.value.filter(note => note.id !== noteId);
      }
    };

    // 资料功能
    const getMaterialIcon = (type) => {
      const icons = {
        pdf: 'fa-file-pdf',
        zip: 'fa-file-archive',
        doc: 'fa-file-word',
        ppt: 'fa-file-powerpoint',
        video: 'fa-file-video'
      };
      return icons[type] || 'fa-file';
    };

    const downloadMaterial = (material) => {
<<<<<<< HEAD
      console.log('下载资料:', material.name);
    };

    // 工具函数
    const formatDuration = (seconds) => {
      if (!seconds || isNaN(seconds)) return "00:00";
      
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      const secs = Math.floor(seconds % 60);
      
      if (hours > 0) {
        return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
      } else {
        return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
      }
    };

    const formatTime = (timestamp) => {
      if (!timestamp) return "";
      
      const date = new Date(timestamp);
      const now = new Date();
      const diffInSeconds = Math.floor((now - date) / 1000);
      
      if (date.toDateString() === now.toDateString()) {
        if (diffInSeconds < 60) {
          return '刚刚';
        } else if (diffInSeconds < 3600) {
          return `${Math.floor(diffInSeconds / 60)}分钟前`;
        } else {
          return `${Math.floor(diffInSeconds / 3600)}小时前`;
        }
      }
      
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      if (date.toDateString() === yesterday.toDateString()) {
        return `昨天 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
      }
      
      return `${date.getMonth() + 1}-${date.getDate()} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
=======
      // TODO: 实现资料下载
      console.log('下载资料:', material.name);
    };

    // 工具方法
    const formatDuration = (seconds) => {
      if (!seconds) return '00:00';
      const mins = Math.floor(seconds / 60);
      const secs = seconds % 60;
      return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    };

    const formatTime = (timestamp) => {
      return new Date(timestamp).toLocaleString('zh-CN');
    };

    // 发送评论
    const sendComment = async () => {
      if (!newComment.value.trim()) return;
      
      try {
        // TODO: 调用发送评论API
        console.log('发送评论:', newComment.value);
        
        // 模拟添加评论到列表
        const comment = {
          id: Date.now(),
          content: newComment.value,
          user_name: userInfo.value.user_name,
          created_time: new Date().toISOString(),
          likes: 0
        };
        
        discussions.value.unshift(comment);
        newComment.value = '';
        
        // 实际应用中应该调用API然后重新获取评论列表
        // await handleSendMessage();
      } catch (error) {
        console.error('发送评论失败:', error);
      }
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
    };

    onMounted(() => {
      fetchCourseData();
      fetchUserInfo();
    });

    return {
      // 原有数据
      currentCourse,
      currentVideo,
      chapters,
      discussions,
      userInfo,
      learningProgress,
      
      // UI状态
      chapterCollapsed,
      rightPanelCollapsed,
      activeRightTab,
<<<<<<< HEAD
      isLiked,
      isCollected,
      showEpisodeList,
      notes,
      courseMaterials,
      hasNextVideo,
=======
      aiMinimized,
      isLiked,
      isCollected,
      danmakuEnabled,
      subtitleEnabled,
      showSubtitleMenu,
      showSpeedMenu,
      showQualityMenu,
      showEpisodeList,
      playbackSpeed,
      currentQuality,
      speedOptions,
      qualityOptions,
      notes,
      courseMaterials,
      hasNextVideo,
      newComment,
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
      
      // 原有方法
      getVideoUrl,
      handleVideoChange,
      handleProgressUpdate,
      handleBehaviorRecord,
      handleAIQuestion,
      handleSendMessage,
      handleDiscussionSearch,
      handleLikeDiscussion,
      handleReplyDiscussion,
      
      // 新增方法
      goBack,
      toggleChapterSidebar,
      toggleLike,
      toggleCollect,
      shareVideo,
<<<<<<< HEAD
=======
      toggleDanmaku,
      toggleSubtitle,
      setSubtitle,
      setPlaybackSpeed,
      setQuality,
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
      getCurrentEpisodeNumber,
      getAllVideos,
      playNext,
      selectEpisode,
      addNote,
      editNote,
      deleteNote,
      getMaterialIcon,
      downloadMaterial,
      formatDuration,
<<<<<<< HEAD
      formatTime
=======
      formatTime,
      sendComment
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
    };
  },
};
</script>

<!-- 样式部分保持不变，与之前相同 -->
<style scoped>
/* 组件变量 */
.course-video-container {
  --primary-color: #1a73e8;
  --secondary-color: #f8f9fa;
  --text-primary: #202124;
  --text-secondary: #5f6368;
  --border-color: #dadce0;
  --success-color: #34a853;
  --warning-color: #fbbc04;
  --error-color: #ea4335;
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.1);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 25px rgba(0,0,0,0.1);
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
}

/* 主容器 */
.course-video-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f5f5f5;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

<<<<<<< HEAD
/* 顶部标题栏 */
=======
/* 顶部导航栏 */
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
.top-navbar {
  background: white;
  border-bottom: 1px solid var(--border-color);
  padding: 0 20px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: var(--shadow-sm);
  position: sticky;
  top: 0;
  z-index: 100;
<<<<<<< HEAD
}

.nav-left {
  display: flex;
  align-items: center;
  gap: 16px;
  position: absolute; /* 添加这行 */
  left: 20px; /* 添加这行 */
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: none;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  cursor: pointer;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.back-btn:hover {
  background: var(--secondary-color);
  color: var(--primary-color);
}

=======
}

.nav-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: none;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  cursor: pointer;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.back-btn:hover {
  background: var(--secondary-color);
  color: var(--primary-color);
}

.logo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 600;
  color: var(--primary-color);
}

>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
.nav-center {
  flex: 1;
  text-align: center;
  max-width: 600px;
<<<<<<< HEAD
  margin: 0 auto; 
=======
  margin: 0 20px;
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
}

.course-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0 0 4px 0;
}

.video-title {
  font-size: 14px;
  color: var(--text-secondary);
}

<<<<<<< HEAD
/* 移除了用户信息相关样式 */
=======
.nav-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: var(--primary-color);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 14px;
}
>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba

/* 主布局 */
.main-layout {
  display: flex;
  gap: 0;
  position: relative;
  min-height: calc(100vh - 60px);
}

/* 章节侧边栏 */
.chapter-sidebar {
  width: 280px;
  background: white;
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  transition: all 0.3s ease;
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.chapter-sidebar.collapsed {
  width: 60px;
}

.sidebar-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--secondary-color);
}

.sidebar-header h3 {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.collapse-btn {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.collapse-btn:hover {
  background: var(--border-color);
}

.center-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
  background: #f5f5f5;
  padding: 20px;
  gap: 20px;
}

/* 视频区域 */
.video-section {
  background: white;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.video-player-container {
  position: relative;
  background: #000;
  aspect-ratio: 16/9;
  width: 100%;
  overflow: hidden;
}

.video-player-container video,
.video-player-container > * {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

/* 如果需要保持视频完整性，使用这个样式 */
.video-player-container.fit-contain video,
.video-player-container.fit-contain > * {
  object-fit: contain;
}

.empty-video-player {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.empty-video-player i {
  font-size: 4rem;
  margin-bottom: 16px;
  opacity: 0.8;
}

.empty-video-player p {
  font-size: 16px;
  opacity: 0.9;
<<<<<<< HEAD
}

/* 视频信息和操作栏 */
.video-actions {
  padding: 16px 20px;
  background: white;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  border-top: 1px solid var(--border-color);
}

.video-info-section {
  flex: 1;
}

.episode-info {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 4px;
}

.current-episode {
  background: var(--primary-color);
  color: white;
  padding: 4px 8px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
}

.video-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
}

=======
}

/* 视频信息和操作栏 */
.video-actions {
  padding: 16px 20px;
  background: white;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  border-top: 1px solid var(--border-color);
}

.video-info-section {
  flex: 1;
}

.episode-info {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 4px;
}

.current-episode {
  background: var(--primary-color);
  color: white;
  padding: 4px 8px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
}

.video-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
}

>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
.video-stats {
  font-size: 14px;
  color: var(--text-secondary);
}

.action-buttons {
  display: flex;
  align-items: center;
  gap: 12px;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: none;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 14px;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: var(--secondary-color);
  color: var(--primary-color);
  border-color: var(--primary-color);
<<<<<<< HEAD
}

.action-btn.active {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 底部区域 */
.bottom-section {
  display: flex;
  gap: 20px;
  align-items: flex-start;
}

/* AI助手区域 */
.ai-section {
  flex: 2;
  background: white;
  display: flex;
  flex-direction: column;
  min-height: 300px;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

=======
}

.action-btn.active {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 底部区域 */
.bottom-section {
  display: flex;
  gap: 20px;
  align-items: flex-start;
}

/* AI助手区域 */
.ai-section {
  flex: 2;
  background: white;
  display: flex;
  flex-direction: column;
  min-height: 300px;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
.ai-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--secondary-color);
}

.ai-header h3 {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
<<<<<<< HEAD
}

.minimize-btn {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

=======
}

.minimize-btn {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
.minimize-btn:hover {
  background: var(--border-color);
}

.ai-content {
  flex: 1;
  overflow: hidden;
}

.ai-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 200px;
  color: var(--text-secondary);
<<<<<<< HEAD
}

.ai-placeholder i {
  font-size: 3rem;
  margin-bottom: 12px;
  opacity: 0.5;
}

/* 学习工具区域 */
.learning-tools {
  flex: 1;
  background: white;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  min-width: 300px;
}

.tools-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  background: var(--secondary-color);
}

=======
}

.ai-placeholder i {
  font-size: 3rem;
  margin-bottom: 12px;
  opacity: 0.5;
}

/* 学习工具区域 */
.learning-tools {
  flex: 1;
  background: white;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  min-width: 300px;
}

.tools-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  background: var(--secondary-color);
}

>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
.tools-header h3 {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.tools-content {
  padding: 20px;
}

.tool-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--border-color);
}

.tool-item:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.tool-icon {
  width: 40px;
  height: 40px;
  background: var(--primary-color);
<<<<<<< HEAD
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.tool-info {
  flex: 1;
}

.tool-info h4 {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0 0 8px 0;
}

.progress-bar {
  width: 100%;
  height: 6px;
  background: var(--border-color);
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 4px;
}

.progress-fill {
  height: 100%;
  background: var(--success-color);
  border-radius: 3px;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 12px;
  color: var(--text-secondary);
}

.stat-value {
  font-size: 16px;
  font-weight: 600;
  color: var(--primary-color);
  margin: 0;
}

.knowledge-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tag {
  background: var(--secondary-color);
  color: var(--text-primary);
  padding: 4px 8px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  border: 1px solid var(--border-color);
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.quick-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: none;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 12px;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.quick-btn:hover {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

/* 右侧面板 */
.right-panel {
  width: 420px;
}

.right-panel.collapsed {
  width: 60px;
}

.panel-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--secondary-color);
}

.panel-tabs {
  display: flex;
  gap: 8px;
}

.tab-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: none;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 14px;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.tab-btn:hover {
  background: var(--border-color);
}

.tab-btn.active {
  background: var(--primary-color);
  color: white;
}

.panel-toggle {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.panel-toggle:hover {
  background: var(--border-color);
}

.panel-content {
  flex: 1;
  overflow: hidden;
  max-height: 500px;
}

.tab-pane {
  height: 100%;
  overflow-y: auto;
  max-height: 500px;
}

/* 笔记区域 */
.notes-section {
  padding: 20px;
}

.notes-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.notes-header h4 {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.add-note-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: var(--primary-color);
  color: white;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s ease;
}

.add-note-btn:hover {
  background: #1557b0;
}

.note-item {
  padding: 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  margin-bottom: 12px;
  background: white;
}

.note-time {
  font-size: 12px;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.note-content {
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 8px;
}

.note-actions {
  display: flex;
  gap: 8px;
}

.note-actions button {
  background: none;
  border: none;
  padding: 4px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.note-actions button:hover {
  background: var(--secondary-color);
  color: var(--primary-color);
}

/* 资料区域 */
.materials-section {
  padding: 20px;
}

.materials-section h4 {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 16px;
}

.material-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  margin-bottom: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.material-item:hover {
  box-shadow: var(--shadow-sm);
}

.material-icon {
  color: var(--error-color);
  font-size: 20px;
}

.material-info {
  flex: 1;
}

.material-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-primary);
  margin-bottom: 4px;
}

.material-size {
  font-size: 12px;
  color: var(--text-secondary);
}

.download-btn {
  background: none;
  border: 1px solid var(--border-color);
  padding: 8px;
  border-radius: var(--radius-sm);
  cursor: pointer;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.download-btn:hover {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 200px;
  color: var(--text-secondary);
}

.empty-state i {
  font-size: 3rem;
  margin-bottom: 12px;
  opacity: 0.5;
}

/* 选集弹窗 */
.episode-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.episode-content {
  background: white;
  border-radius: var(--radius-md);
  max-width: 600px;
  max-height: 80vh;
  width: 90%;
  display: flex;
  flex-direction: column;
  box-shadow: var(--shadow-lg);
}

.episode-header {
  padding: 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.episode-header h3 {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.episode-header button {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.episode-header button:hover {
  background: var(--secondary-color);
}

.episode-sidebar-content {
  flex: 1;
  overflow-y: auto;
  max-height: 400px;
  padding: 20px;
}

.episode-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  margin-bottom: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.episode-item:hover {
  background: var(--secondary-color);
}

.episode-item.active {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.episode-number {
  font-weight: 600;
  min-width: 60px;
}

.episode-title {
  flex: 1;
  font-size: 14px;
}

.episode-duration {
  font-size: 12px;
  color: var(--text-secondary);
}

.episode-item.active .episode-duration {
  color: rgba(255, 255, 255, 0.8);
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .main-layout {
    grid-template-columns: auto 1fr 300px;
  }
  
  .chapter-sidebar {
    width: 240px;
  }
  
  .right-panel {
    width: 300px;
  }
}

=======
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.tool-info {
  flex: 1;
}

.tool-info h4 {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0 0 8px 0;
}

.progress-bar {
  width: 100%;
  height: 6px;
  background: var(--border-color);
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 4px;
}

.progress-fill {
  height: 100%;
  background: var(--success-color);
  border-radius: 3px;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 12px;
  color: var(--text-secondary);
}

.stat-value {
  font-size: 16px;
  font-weight: 600;
  color: var(--primary-color);
  margin: 0;
}

.knowledge-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tag {
  background: var(--secondary-color);
  color: var(--text-primary);
  padding: 4px 8px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  border: 1px solid var(--border-color);
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.quick-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: none;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 12px;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.quick-btn:hover {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

/* 右侧面板 */
.right-panel {
  width: 420px;
}

.right-panel.collapsed {
  width: 60px;
}

.panel-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--secondary-color);
}

.panel-tabs {
  display: flex;
  gap: 8px;
}

.tab-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: none;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 14px;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.tab-btn:hover {
  background: var(--border-color);
}

.tab-btn.active {
  background: var(--primary-color);
  color: white;
}

.panel-toggle {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.panel-toggle:hover {
  background: var(--border-color);
}

.panel-content {
  flex: 1;
  overflow: hidden;
  max-height: 500px;
}

.tab-pane {
  height: 100%;
  overflow-y: auto;
  max-height: 500px;
}

/* 笔记区域 */
.notes-section {
  padding: 20px;
}

.notes-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.notes-header h4 {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.add-note-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: var(--primary-color);
  color: white;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s ease;
}

.add-note-btn:hover {
  background: #1557b0;
}

.note-item {
  padding: 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  margin-bottom: 12px;
  background: white;
}

.note-time {
  font-size: 12px;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.note-content {
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 8px;
}

.note-actions {
  display: flex;
  gap: 8px;
}

.note-actions button {
  background: none;
  border: none;
  padding: 4px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.note-actions button:hover {
  background: var(--secondary-color);
  color: var(--primary-color);
}

/* 资料区域 */
.materials-section {
  padding: 20px;
}

.materials-section h4 {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 16px;
}

.material-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  margin-bottom: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.material-item:hover {
  box-shadow: var(--shadow-sm);
}

.material-icon {
  color: var(--error-color);
  font-size: 20px;
}

.material-info {
  flex: 1;
}

.material-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-primary);
  margin-bottom: 4px;
}

.material-size {
  font-size: 12px;
  color: var(--text-secondary);
}

.download-btn {
  background: none;
  border: 1px solid var(--border-color);
  padding: 8px;
  border-radius: var(--radius-sm);
  cursor: pointer;
  color: var(--text-secondary);
  transition: all 0.2s ease;
}

.download-btn:hover {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 200px;
  color: var(--text-secondary);
}

.empty-state i {
  font-size: 3rem;
  margin-bottom: 12px;
  opacity: 0.5;
}

/* 选集弹窗 */
.episode-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.episode-content {
  background: white;
  border-radius: var(--radius-md);
  max-width: 600px;
  max-height: 80vh;
  width: 90%;
  display: flex;
  flex-direction: column;
  box-shadow: var(--shadow-lg);
}

.episode-header {
  padding: 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.episode-header h3 {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.episode-header button {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.episode-header button:hover {
  background: var(--secondary-color);
}

.episode-sidebar-content {
  flex: 1;
  overflow-y: auto;
  max-height: 400px;
  padding: 20px;
}

.episode-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  margin-bottom: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.episode-item:hover {
  background: var(--secondary-color);
}

.episode-item.active {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.episode-number {
  font-weight: 600;
  min-width: 60px;
}

.episode-title {
  flex: 1;
  font-size: 14px;
}

.episode-duration {
  font-size: 12px;
  color: var(--text-secondary);
}

.episode-item.active .episode-duration {
  color: rgba(255, 255, 255, 0.8);
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .main-layout {
    grid-template-columns: auto 1fr 300px;
  }
  
  .chapter-sidebar {
    width: 240px;
  }
  
  .right-panel {
    width: 300px;
  }
}

>>>>>>> e148202daefea14e2752f4b8e24e17b05c9485ba
@media (max-width: 768px) {
  .main-layout {
    grid-template-columns: 1fr;
    grid-template-rows: auto 1fr auto;
  }
  
  .chapter-sidebar,
  .right-panel {
    position: fixed;
    top: 60px;
    height: calc(100vh - 60px);
    z-index: 200;
    transform: translateX(-100%);
  }
  
  .chapter-sidebar.show,
  .right-panel.show {
    transform: translateX(0);
  }
  
  .nav-center {
    display: none;
  }
}

/* 推荐课程区域 */
.recommended-courses {
  background: white;
  padding: 40px 0;
  margin-top: 20px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.recommended-courses h2 {
  font-size: 24px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 20px;
}

.placeholder-content {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.placeholder-item {
  display: flex;
  gap: 16px;
  padding: 16px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  background: white;
  transition: all 0.2s ease;
}

.placeholder-item:hover {
  box-shadow: var(--shadow-md);
}

.placeholder-image {
  width: 120px;
  height: 80px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: var(--radius-sm);
  flex-shrink: 0;
}

.placeholder-text {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.placeholder-title {
  height: 20px;
  background: var(--border-color);
  border-radius: 4px;
  width: 80%;
}

.placeholder-desc {
  height: 16px;
  background: var(--border-color);
  border-radius: 4px;
  width: 60%;
}

/* 右侧面板隐藏时的打开按钮 */
.right-panel-toggle-btn {
  position: fixed;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
  background: var(--primary-color);
  color: white;
  border: none;
  padding: 12px 8px;
  border-radius: var(--radius-sm) 0 0 var(--radius-sm);
  cursor: pointer;
  box-shadow: var(--shadow-md);
  z-index: 150;
  transition: all 0.2s ease;
}

.right-panel-toggle-btn:hover {
  background: #1557b0;
  transform: translateY(-50%) translateX(-2px);
}

.right-panel-toggle-btn i {
  font-size: 16px;
}

/* AI助手面板样式 */
.ai-section-panel {
  height: 100%;
  display: flex;
  flex-direction: column;
}

/* 学习工具面板样式 */
.tools-section-panel {
  padding: 20px;
  height: 100%;
  overflow-y: auto;
}

/* 课程描述区域 */
.course-description {
  background: white;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  height: calc(100vh - 60px - 40px - 400px); /* 与章节目录高度对应 */
  min-height: 300px;
}

.description-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  background: var(--secondary-color);
  flex-shrink: 0;
}

.description-header h3 {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.description-content {
  padding: 20px;
  flex: 1;
  overflow-y: auto;
  max-height: 400px;
}

.description-content p {
  font-size: 14px;
  line-height: 1.6;
  color: var(--text-primary);
  margin: 0 0 16px 0;
}

.course-details {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--border-color);
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-label {
  font-size: 14px;
  color: var(--text-secondary);
  font-weight: 500;
}

.detail-value {
  font-size: 14px;
  color: var(--text-primary);
  font-weight: 600;
}

/* 评论区域样式 */
.comments-pane {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.comments-list-area {
  flex: 1;
  overflow-y: auto;
  padding-bottom: 10px;
}

.comment-input-fixed {
  flex-shrink: 0;
  border-top: 1px solid var(--border-color);
  background: white;
  padding: 16px;
}

.comment-input-header {
  margin-bottom: 12px;
}

.comment-input-header h4 {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.comment-input-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.comment-textarea {
  width: 100%;
  min-height: 80px;
  padding: 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-family: inherit;
  resize: vertical;
  outline: none;
  transition: border-color 0.2s ease;
}

.comment-textarea:focus {
  border-color: var(--primary-color);
}

.comment-textarea::placeholder {
  color: var(--text-secondary);
}

.comment-actions {
  display: flex;
  justify-content: flex-end;
}

.send-comment-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: var(--primary-color);
  color: white;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.send-comment-btn:hover:not(:disabled) {
  background: #1557b0;
}

.send-comment-btn:disabled {
  background: var(--border-color);
  color: var(--text-secondary);
  cursor: not-allowed;
}
</style>