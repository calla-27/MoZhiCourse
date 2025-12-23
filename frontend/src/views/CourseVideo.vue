<!-- 视频播放页 -->
<template>
  <div class="course-video-container">
    <!-- 顶部标题栏 -->
    <nav class="top-navbar">
      <!-- <div class="top-navbar-inner"> -->
        <div class="nav-left">
          <button class="back-btn" @click="goBack">
            <i class="fas fa-arrow-left"></i>
            <span>返回</span>
          </button>
        </div>
        <div class="nav-center" v-if="currentCourse.course_name">
          <h2 class="course-title">{{ currentCourse.course_name }}</h2>
          <div class="video-title" v-if="currentVideo.video_title">
            {{ currentVideo.video_title }}
          <!-- </div> -->
        </div>
      </div>
    </nav>
    <main class="main-layout">
      <!-- 左侧章节目录 已移除，视频区将占据左侧空间 -->

      <!-- 中间视频和AI区域 -->
      <section class="center-content">
        <!-- 视频播放器区域 -->
        <div class="video-section">
          <div class="video-player-container">
            <template v-if="currentVideo.video_id">
              <CourseVideoPlayer
                ref="videoPlayerRef"
                :video-id="currentVideo.video_id"
                :course-id="courseId"
                :video-url="getVideoUrl(currentVideo)"
                :initial-progress="learningProgress"
                @progress-update="handleProgressUpdate"
                @behavior-record="handleBehaviorRecord"
                @speed-change="handleSpeedChange"
                @video-state-change="handleVideoStateChange"
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
            </div>
            
            <div class="action-buttons">
              <button class="action-btn like-btn" :class="{ active: isLiked }" @click="handleToggleLike">
                <i class="fas fa-thumbs-up"></i>
                <span>{{ isLiked ? '已点赞' : '点赞' }} {{ likeCount > 0 ? `(${likeCount})` : '' }}</span>
              </button>
              <button class="action-btn collect-btn" :class="{ active: isFavorited }" @click="handleToggleFavorite">
                <i class="fas fa-star"></i>
                <span>{{ isFavorited ? '已收藏' : '收藏' }} {{ favoriteCount > 0 ? `(${favoriteCount})` : '' }}</span>
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
              <button class="action-btn speed-btn" @click="showSpeedPanel = !showSpeedPanel">
                <i class="fas fa-tachometer-alt"></i>
                <span>{{ currentSpeed }}x</span>
              </button>
            </div>

            <!-- 倍速选择面板 -->
            <div v-if="showSpeedPanel" class="speed-panel">
              <div class="speed-options">
                <button 
                  v-for="speed in speedOptions" 
                  :key="speed"
                  class="speed-option"
                  :class="{ active: Math.abs(currentSpeed - speed) < 0.01 }"
                  @click="changePlaybackSpeed(speed)"
                >
                  {{ speed }}x
                </button>
              </div>
              <div class="speed-history" v-if="speedHistory.length > 0">
                <span class="speed-history-label">常用: </span>
                <button 
                  v-for="history in speedHistory.slice(0, 3)" 
                  :key="history.speed"
                  class="speed-history-item"
                  @click="changePlaybackSpeed(history.speed)"
                >
                  {{ history.speed }}x
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- 课程描述区域已删除 -->
      </section>

      <!-- 右侧面板：章节和评论 -->
      <aside class="right-panel" :class="{ collapsed: rightPanelCollapsed }">
        <div class="panel-header">
          <div class="panel-tabs">
            <button class="tab-btn" 
                    :class="{ active: activeRightTab === 'chapters' }"
                    @click="activeRightTab = 'chapters'">
              <i class="fas fa-list-ul"></i>
              <span>章节</span>
            </button>
            <button class="tab-btn" 
                    :class="{ active: activeRightTab === 'comments' }"
                    @click="activeRightTab = 'comments'">
              <i class="fas fa-comments"></i>
              <span>评论</span>
            </button>
          </div>
        </div>

        <!-- 面板左侧中间的折叠/展开按钮 -->
        <button
          v-if="!rightPanelCollapsed"
          class="panel-edge-toggle"
          @click="rightPanelCollapsed = true"
          aria-label="收起面板"
        >
          <i class="fas fa-chevron-right"></i>
        </button>
        <button
          v-else
          class="panel-edge-toggle collapsed-toggle"
          @click="rightPanelCollapsed = false"
          aria-label="展开面板"
        >
          <i class="fas fa-chevron-left"></i>
        </button>

        <div class="panel-content" v-show="!rightPanelCollapsed">
          <!-- 章节目录 -->
          <div v-if="activeRightTab === 'chapters'" class="tab-pane chapters-pane">
            <ChapterList
              :chapters="chapters"
              :current-video="currentVideo"
              @video-change="handleVideoChange"
            />
          </div>

          <!-- 评论区 -->
          <div v-if="activeRightTab === 'comments'" class="tab-pane comments-pane">
            <template v-if="currentVideo.video_id">
              <div class="comments-list-area">
                <DiscussionPanel
                  :video-id="currentVideo.video_id"
                  :discussions="discussions"
                  :user-info="userInfo"
                  @send-message="handleSendMessage"
                  @discussion-search="handleDiscussionSearch"
                  @like-discussion="handleLikeDiscussion"
                  @reply-discussion="handleReplyDiscussion"
                />
              </div>
            </template>
            <div v-else class="empty-state">
              <i class="fas fa-comments"></i>
              <p>请选择视频查看评论</p>
            </div>
          </div>

          <!-- 学习行为面板 -->
          <div v-if="activeRightTab === 'behavior'" class="tab-pane behavior-pane">
            <div class="behavior-section">
              <div class="behavior-header">
                <h4>学习行为分析</h4>
                <button class="refresh-btn" @click="refreshBehaviorStats">
                  <i class="fas fa-sync-alt"></i>
                </button>
              </div>
              
              <div class="behavior-stats-cards">
                <div class="stat-card">
                  <div class="stat-icon">
                    <i class="fas fa-clock"></i>
                  </div>
                  <div class="stat-info">
                    <div class="stat-value">{{ formatDuration(totalLearningTime) }}</div>
                    <div class="stat-label">累计学习时长</div>
                  </div>
                </div>
                
                <div class="stat-card">
                  <div class="stat-icon">
                    <i class="fas fa-play-circle"></i>
                  </div>
                  <div class="stat-info">
                    <div class="stat-value">{{ behaviorStats.total }}</div>
                    <div class="stat-label">行为记录总数</div>
                  </div>
                </div>
                
                <div class="stat-card">
                  <div class="stat-icon">
                    <i class="fas fa-tachometer-alt"></i>
                  </div>
                  <div class="stat-info">
                    <div class="stat-value">{{ averageSpeed.toFixed(1) }}x</div>
                    <div class="stat-label">平均播放速度</div>
                  </div>
                </div>
              </div>
              
              <!-- 倍速使用分布 -->
              <div class="speed-distribution" v-if="speedDistribution.length > 0">
                <h5>倍速使用分布</h5>
                <div class="speed-bars">
                  <div 
                    v-for="item in speedDistribution" 
                    :key="item.speed"
                    class="speed-bar-item"
                  >
                    <div class="speed-label">{{ item.speed }}x</div>
                    <div class="speed-bar">
                      <div 
                        class="speed-fill" 
                        :style="{ width: item.percentage + '%' }"
                        :class="getSpeedBarClass(item.speed)"
                      ></div>
                    </div>
                    <div class="speed-percentage">{{ item.percentage.toFixed(1) }}%</div>
                  </div>
                </div>
              </div>
              
              <!-- 行为类型统计 -->
              <div class="behavior-types">
                <h5>行为类型统计</h5>
                <div class="behavior-type-list">
                  <div 
                    v-for="type in behaviorTypeStats" 
                    :key="type.name"
                    class="behavior-type-item"
                  >
                    <div class="type-icon">
                      <i :class="getBehaviorTypeIcon(type.name)"></i>
                    </div>
                    <div class="type-info">
                      <div class="type-name">{{ getBehaviorTypeLabel(type.name) }}</div>
                      <div class="type-count">{{ type.count }} 次</div>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- 学习建议 -->
              <div class="learning-suggestions" v-if="learningSuggestions.length > 0">
                <h5>学习建议</h5>
                <ul class="suggestions-list">
                  <li v-for="(suggestion, index) in learningSuggestions" :key="index">
                    <i class="fas fa-lightbulb"></i> {{ suggestion }}
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </aside>

      <!-- 右侧面板隐藏时的打开按钮 -->
      <div v-if="rightPanelCollapsed" class="right-panel-toggle-btn" @click="rightPanelCollapsed = false">
        <i class="fas fa-chevron-left"></i>
      </div>

      <!-- 浮动工具栏 -->
      <div 
        class="floating-toolbar" 
        :class="{ hidden: floatingToolbarHidden }"
        :style="floatingToolbarStyle"
        @mousedown="startDragToolbar"
      >
        <!-- 拖动手柄 -->
        <div class="toolbar-drag-handle" title="拖动移动位置">
          <i class="fas fa-grip-vertical"></i>
        </div>
        <button 
          class="floating-btn" 
          :class="{ active: activeFloatingPanel === 'notes' }"
          @click.stop="toggleFloatingPanel('notes')"
          title="笔记"
        >
          <i class="fas fa-sticky-note"></i>
        </button>
        <button 
          class="floating-btn" 
          :class="{ active: activeFloatingPanel === 'materials' }"
          @click.stop="toggleFloatingPanel('materials')"
          title="资料"
        >
          <i class="fas fa-folder"></i>
        </button>
        <button 
          class="floating-btn ai-btn" 
          :class="{ active: activeFloatingPanel === 'ai' }"
          @click.stop="toggleFloatingPanel('ai')"
          title="小墨AI助手"
        >
          <i class="fas fa-robot"></i>
        </button>
        <!-- 隐藏按钮 -->
        <button 
          class="floating-btn hide-btn" 
          @click.stop="floatingToolbarHidden = true"
          title="隐藏工具栏"
        >
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>

      <!-- 显示工具栏的小按钮（隐藏时显示） -->
      <div 
        v-if="floatingToolbarHidden" 
        class="floating-toolbar-show-btn"
        @click="floatingToolbarHidden = false"
        title="显示工具栏"
      >
        <i class="fas fa-chevron-left"></i>
      </div>

      <!-- 浮动面板 -->
      <transition name="slide-up">
        <div v-if="activeFloatingPanel" class="floating-panel" :class="activeFloatingPanel + '-panel'" :style="floatingPanelStyle">
          <div class="floating-panel-header">
            <h4>
              <i :class="getFloatingPanelIcon(activeFloatingPanel)"></i>
              {{ getFloatingPanelTitle(activeFloatingPanel) }}
            </h4>
            <button class="close-btn" @click="activeFloatingPanel = null">
              <i class="fas fa-times"></i>
            </button>
          </div>
          <div class="floating-panel-content">
            <!-- 笔记面板 -->
            <template v-if="activeFloatingPanel === 'notes'">
              <div class="notes-section">
                <div class="note-input-area">
                  <textarea class="note-input" v-model="newNoteContent" placeholder="在此直接输入你的学习笔记..."></textarea>
                  <div class="note-input-actions">
                    <button class="add-note-btn" :disabled="!newNoteContent.trim()" @click="addNoteInline">
                      <i class="fas fa-plus"></i>
                      <span>添加笔记</span>
                    </button>
                  </div>
                </div>
                <div class="notes-list">
                  <div v-for="note in notes" :key="note.id" class="note-item">
                    <div class="note-time">{{ formatTime(note.timestamp) }}</div>
                    <div v-if="note.editing" class="note-editing">
                      <textarea class="note-edit-input" v-model="note.editContent"></textarea>
                      <div class="note-actions">
                        <button @click="saveNoteEdit(note)">
                          <i class="fas fa-check"></i>
                        </button>
                        <button @click="cancelNoteEdit(note)">
                          <i class="fas fa-times"></i>
                        </button>
                      </div>
                    </div>
                    <div v-else>
                      <div class="note-content">{{ note.content }}</div>
                      <div class="note-actions">
                        <button @click="startNoteEdit(note)">
                          <i class="fas fa-edit"></i>
                        </button>
                        <button @click="deleteNoteInline(note.id)">
                          <i class="fas fa-trash"></i>
                        </button>
                      </div>
                    </div>
                  </div>
                  <div v-if="notes.length === 0" class="empty-state">
                    <i class="fas fa-sticky-note"></i>
                    <p>还没有笔记，开始记录学习心得吧</p>
                  </div>
                </div>
              </div>
            </template>

            <!-- 资料面板 -->
            <template v-if="activeFloatingPanel === 'materials'">
              <div class="materials-section">
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
            </template>

            <!-- AI助手面板 -->
            <template v-if="activeFloatingPanel === 'ai'">
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
            </template>
          </div>
        </div>
      </transition>
    </main>

    <!-- 推荐课程区域 -->
    <section class="recommended-courses">
      <div class="container">
        <h2>推荐课程</h2>
        <div class="recommended-grid" v-if="(recommendedCourses || []).length">
          <CourseCard 
            v-for="c in recommendedCourses.slice(0, 6)" 
            :key="c.id" 
            :course="c" 
          />
        </div>
        <div v-else class="placeholder-content">
          <div class="placeholder-item" v-for="i in 3" :key="i">
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
import { ref, reactive, computed, onMounted, onUnmounted } from "vue";
import { useRoute } from "vue-router";
import ChapterList from "@/components/ChapterList.vue";
import CourseVideoPlayer from "@/components/CourseVideoPlayer.vue";
import AIAssistant from "@/components/AIAssistant.vue";
import DiscussionPanel from "@/components/DiscussionPanel.vue";
import CourseCard from "@/components/course/CourseCard.vue";

import {
  getCourseDetail,
  getCourseChapters,
  getVideoDetail,
  getVideoProgress,
  updateVideoProgress,
  recordLearningBehavior,
  BEHAVIOR_TYPES,
  createStandardBehavior,
  BehaviorRecorder,
  DebugUtils,
  getRelatedCourses,
  getAllCourses
} from "@/api/courseVideo";
import { getComments } from "@/api/comment";
import studentBehavior from "@/api/studentBehavior";
import { 
  getCourseLikeStatus, 
  toggleCourseLike, 
  getCourseFavoriteStatus, 
  toggleCourseFavorite 
} from "@/api/like";

export default {
  name: "CourseVideo",
  components: {
    ChapterList,
    CourseVideoPlayer,
    AIAssistant,
    DiscussionPanel,
    CourseCard,
  },
  setup() {
    const route = useRoute();
    const courseId = parseInt(route.params.courseId) || 7;
    const videoId = parseInt(route.params.videoId) || 1;

    const currentCourse = ref({});
    const currentVideo = ref({});
    const recommendedCourses = ref([]);
    const chapters = ref([]);
    const discussions = ref([]);
    const discussionFilters = reactive({
      keyword: "",
      sort: "latest",
    });
    const userInfo = ref({});
    const learningProgress = ref(0);

    // 新增：视频播放器引用
    const videoPlayerRef = ref(null);
    
    // 新增：倍速相关状态
    const currentSpeed = ref(1.0);
    const showSpeedPanel = ref(false);
    const speedOptions = ref([0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]);
    const speedHistory = ref([]);
    
    // 新增：行为统计状态
    const behaviorStats = reactive({
      total: 0,
      byType: {},
      speedChanges: []
    });
    
    const totalLearningTime = ref(0);
    const averageSpeed = ref(1.0);
    const showBehaviorStats = ref(false);
    const learningSuggestions = ref([]);
    
    // 新增：点赞和收藏状态
    const isLiked = ref(false);
    const isFavorited = ref(false);
    const likeCount = ref(0);
    const favoriteCount = ref(0);
    
    // UI 状态管理
    const chapterCollapsed = ref(false);
    const rightPanelCollapsed = ref(false);
    const activeRightTab = ref('chapters');
    const activeFloatingPanel = ref(null);
    const floatingToolbarHidden = ref(false);
    const floatingToolbarPos = reactive({ x: null, y: null });
    const isDraggingToolbar = ref(false);
    const dragOffset = reactive({ x: 0, y: 0 });
    
    // 播放器控制状态
    const showEpisodeList = ref(false);
    
    // 笔记和资料
    const notes = ref([]);
    const newNoteContent = ref("");
    const courseMaterials = ref([
      { id: 1, name: '课程PPT.pdf', type: 'pdf', size: '2.5MB' },
      { id: 2, name: '源代码.zip', type: 'zip', size: '1.2MB' },
      { id: 3, name: '练习题.docx', type: 'doc', size: '856KB' }
    ]);
    
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

        // 加载相关课程推荐（优先同标签/分类，不足再补齐其他课程，最多6个）
        try {
          const cid = currentCourse.value?.course_id || courseId;
          const relatedRes = await getRelatedCourses(cid, 12);
          const relatedData = (relatedRes && relatedRes.data) || relatedRes || [];
          const courses = Array.isArray(relatedData) ? relatedData : relatedData.data || [];
          const API_BASE = 'http://localhost:4000';
          // 先就地取前若干作为候选（服务端已按同分类优先排序）
          let normalized = courses.map(rc => ({
            id: rc.course_id,
            title: rc.course_name,
            description: rc.course_desc,
            instructor: rc.teacher_name || '未知讲师',
            students: String(rc.student_count || 0),
            rating: rc.rating || 0,
            difficulty: rc.difficulty_level || '初级',
            image: rc.cover_img ? (rc.cover_img.startsWith('http') ? rc.cover_img : `${API_BASE}${rc.cover_img}`) : (rc.image || rc.cover || '')
          }));
          // 若不足6个，用全量课程补齐（去重）
          if (normalized.length < 6) {
            try {
              const allRes = await getAllCourses();
              const allData = (allRes && allRes.data) || allRes || [];
              const allNorm = (Array.isArray(allData) ? allData : allData.data || []).map(rc => ({
                id: rc.course_id,
                title: rc.course_name,
                description: rc.course_desc,
                instructor: rc.teacher_name || '未知讲师',
                students: String(rc.student_count || 0),
                rating: rc.rating || 0,
                difficulty: rc.difficulty_level || '初级',
                image: rc.cover_img ? (rc.cover_img.startsWith('http') ? rc.cover_img : `${API_BASE}${rc.cover_img}`) : (rc.image || rc.cover || '')
              }));
              const existIds = new Set(normalized.map(c => c.id));
              for (const c of allNorm) {
                if (existIds.has(c.id)) continue;
                normalized.push(c);
                if (normalized.length >= 6) break;
              }
            } catch (fillErr) {
              console.warn('补齐推荐课程失败:', fillErr);
            }
          }
          recommendedCourses.value = normalized.slice(0, 6);
        } catch (e) {
          console.warn('获取相关课程失败:', e);
          recommendedCourses.value = [];
        }

        if (currentVideo.value.video_id) {
          await Promise.all([fetchLearningProgress(), fetchDiscussions(), fetchLikeAndFavoriteStatus()]);
          await fetchBehaviorStats();
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
    
    // 获取点赞和收藏状态
    const fetchLikeAndFavoriteStatus = async () => {
      if (!currentCourse.value.course_id && !courseId) return;
      
      const cid = currentCourse.value.course_id || courseId;
      
      try {
        const [likeRes, favoriteRes] = await Promise.all([
          getCourseLikeStatus(cid),
          getCourseFavoriteStatus(cid)
        ]);
        
        if (likeRes.data) {
          isLiked.value = likeRes.data.isLiked;
          likeCount.value = likeRes.data.likeCount || 0;
        }
        
        if (favoriteRes.data) {
          isFavorited.value = favoriteRes.data.isFavorited;
          favoriteCount.value = favoriteRes.data.favoriteCount || 0;
        }
      } catch (error) {
        console.error("获取点赞收藏状态失败:", error);
      }
    };
    
    // 切换点赞
    const handleToggleLike = async () => {
      if (!currentCourse.value.course_id && !courseId) return;
      
      const cid = currentCourse.value.course_id || courseId;
      
      console.log('👍 点击点赞按钮，课程ID:', cid);
      console.log('👍 当前点赞状态:', isLiked.value);
      
      try {
        const res = await toggleCourseLike(cid);
        console.log('👍 后端响应:', res);
        
        if (res && res.data) {
          console.log('👍 更新前 - isLiked:', isLiked.value, 'likeCount:', likeCount.value);
          isLiked.value = res.data.isLiked;
          likeCount.value = res.data.likeCount || 0;
          console.log('👍 更新后 - isLiked:', isLiked.value, 'likeCount:', likeCount.value);
        } else {
          console.warn('👍 响应数据格式不正确:', res);
        }
      } catch (error) {
        console.error("❌ 点赞操作失败:", error);
      }
    };
    
    // 切换收藏
    const handleToggleFavorite = async () => {
      if (!currentCourse.value.course_id && !courseId) return;
      
      const cid = currentCourse.value.course_id || courseId;
      
      try {
        const res = await toggleCourseFavorite(cid);
        if (res.data) {
          isFavorited.value = res.data.isFavorited;
          favoriteCount.value = res.data.favoriteCount || 0;
        }
      } catch (error) {
        console.error("收藏操作失败:", error);
      }
    };
    
    // 获取行为统计数据
    const fetchBehaviorStats = async () => {
      if (!currentVideo.value.video_id) return;
      
      try {
        // 获取用户在本课程的倍速使用情况
        const speedRes = await studentBehavior.getPlaybackSpeedUsage(courseId);
        if (speedRes.data) {
          updateSpeedStats(speedRes.data);
        }
        
        // 获取学习建议
        const suggestionRes = await studentBehavior.getLearningSuggestions();
        if (suggestionRes.data) {
          learningSuggestions.value = suggestionRes.data.suggestions || [];
        }
        
        showBehaviorStats.value = true;
      } catch (error) {
        console.error("获取行为统计数据失败:", error);
      }
    };
    
    // 更新倍速统计
    const updateSpeedStats = (speedData) => {
      if (speedData.speedDistribution) {
        // 处理倍速分布数据
        const distribution = Object.entries(speedData.speedDistribution).map(([speed, stats]) => ({
          speed: parseFloat(speed),
          count: stats.count,
          percentage: stats.percentage
        }));
        speedHistory.value = distribution
          .filter(item => item.count > 0)
          .sort((a, b) => b.count - a.count);
        
        averageSpeed.value = speedData.overallStats?.averageSpeed || 1.0;
      }
    };
    
    // 刷新行为统计
    const refreshBehaviorStats = async () => {
      await fetchBehaviorStats();
    };

    // 切换视频
    const handleVideoChange = async (video) => {
      // 记录切换视频前的行为
      await recordVideoSwitch();
      
      currentVideo.value = video;
      await Promise.all([fetchLearningProgress(), fetchDiscussions()]);
      loadNotes();
      await fetchBehaviorStats();
      
      // 重置当前倍速
      currentSpeed.value = 1.0;
    };
    
    // 记录视频切换行为
    const recordVideoSwitch = async () => {
      if (!currentVideo.value.video_id) return;
      
      try {
        const behaviorData = createStandardBehavior(
          currentVideo.value.video_id,
          'video_switch',
          {
            currentTime: learningProgress.value || 0,
            duration: currentVideo.value.duration_seconds || 0,
            playSpeed: currentSpeed.value,
            progress: learningProgress.value || 0
          }
        );
        
        await recordLearningBehavior(behaviorData);
        updateBehaviorStats('video_switch');
      } catch (error) {
        console.error("记录视频切换行为失败:", error);
      }
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

    // 记录学习行为 - 主要处理函数
    const handleBehaviorRecord = async (behaviorData) => {
      console.log("记录学习行为:", behaviorData);
      
      try {
        if (!currentVideo.value.video_id) return;
        
        // 使用标准化的行为数据格式
        const standardData = createStandardBehavior(
          currentVideo.value.video_id,
          behaviorData.behaviorType,
          {
            currentTime: behaviorData.currentTime || learningProgress.value || 0,
            duration: currentVideo.value.duration_seconds || 0,
            playSpeed: behaviorData.playSpeed || currentSpeed.value,
            progress: learningProgress.value || 0
          }
        );
        
        // 添加额外数据
        if (behaviorData.extraData) {
          Object.assign(standardData, behaviorData.extraData);
        }
        
        // 调用API记录行为
        await recordLearningBehavior(standardData);
        
        // 更新本地统计
        updateBehaviorStats(behaviorData.behaviorType);
        
        // 如果是倍速变化，更新本地状态
        if (behaviorData.behaviorType === BEHAVIOR_TYPES.SPEED_CHANGE) {
          currentSpeed.value = behaviorData.playSpeed || 1.0;
          showSpeedPanel.value = false;
        }
        
        // 开发环境调试
        DebugUtils.logBehavior(standardData);
        
      } catch (error) {
        console.error("记录学习行为失败:", error);
      }
    };
    
    // 处理倍速变化
    const handleSpeedChange = async (newSpeed) => {
      console.log("倍速变化:", newSpeed);
      
      try {
        if (!currentVideo.value.video_id) return;
        
        // 记录倍速切换行为
        const videoState = {
          currentTime: learningProgress.value || 0,
          duration: currentVideo.value.duration_seconds || 0,
          playSpeed: newSpeed,
          progress: learningProgress.value || 0
        };
        
        await BehaviorRecorder.recordSpeedChange(
          currentVideo.value.video_id, 
          videoState, 
          newSpeed
        );
        
        // 更新当前倍速
        currentSpeed.value = newSpeed;
        
        // 更新倍速历史
        updateSpeedHistory(newSpeed);
        
        console.log('✅ 倍速切换埋点记录成功:', newSpeed);
        
      } catch (error) {
        console.error("倍速切换埋点记录失败:", error);
      }
    };
    
    // 处理视频状态变化
    const handleVideoStateChange = (state) => {
      console.log("视频状态变化:", state);
      // 可以在这里处理播放、暂停等状态变化的逻辑
    };
    
    // 更新行为统计
    const updateBehaviorStats = (behaviorType) => {
      behaviorStats.total++;
      
      if (!behaviorStats.byType[behaviorType]) {
        behaviorStats.byType[behaviorType] = 0;
      }
      behaviorStats.byType[behaviorType]++;
      
      // 如果是倍速变化，记录到历史
      if (behaviorType === BEHAVIOR_TYPES.SPEED_CHANGE) {
        behaviorStats.speedChanges.push({
          timestamp: new Date(),
          speed: currentSpeed.value
        });
      }
    };
    
    // 更新倍速历史
    const updateSpeedHistory = (speed) => {
      const existingIndex = speedHistory.value.findIndex(item => Math.abs(item.speed - speed) < 0.01);
      
      if (existingIndex > -1) {
        // 增加计数
        speedHistory.value[existingIndex].count++;
      } else {
        // 添加新记录
        speedHistory.value.push({
          speed,
          count: 1
        });
      }
      
      // 按使用频率排序
      speedHistory.value.sort((a, b) => b.count - a.count);
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

    // 浮动工具栏样式
    const floatingToolbarStyle = computed(() => {
      if (floatingToolbarPos.x !== null && floatingToolbarPos.y !== null) {
        return {
          right: 'auto',
          bottom: 'auto',
          transform: 'none',
          left: floatingToolbarPos.x + 'px',
          top: floatingToolbarPos.y + 'px'
        };
      }
      return {};
    });
    
    // 浮动面板样式 - 跟随工具栏位置
    const floatingPanelStyle = computed(() => {
      if (floatingToolbarPos.x !== null && floatingToolbarPos.y !== null) {
        // 判断工具栏在屏幕左半边还是右半边
        const isOnLeft = floatingToolbarPos.x < window.innerWidth / 2;
        const panelWidth = 420;
        
        let panelX;
        if (isOnLeft) {
          // 工具栏在左边，面板显示在右边
          panelX = floatingToolbarPos.x + 80;
        } else {
          // 工具栏在右边，面板显示在左边
          panelX = floatingToolbarPos.x - panelWidth - 10;
        }
        
        // 确保面板不超出屏幕
        panelX = Math.max(10, Math.min(panelX, window.innerWidth - panelWidth - 10));
        
        return {
          right: 'auto',
          left: panelX + 'px',
          top: floatingToolbarPos.y + 'px',
          transform: 'none'
        };
      }
      return {};
    });
    
    // 开始拖动工具栏
    const startDragToolbar = (e) => {
      // 如果点击的是按钮，不触发拖动
      if (e.target.closest('.floating-btn')) return;
      
      isDraggingToolbar.value = true;
      const toolbar = e.currentTarget;
      const rect = toolbar.getBoundingClientRect();
      dragOffset.x = e.clientX - rect.left;
      dragOffset.y = e.clientY - rect.top;
      
      document.addEventListener('mousemove', onDragToolbar);
      document.addEventListener('mouseup', stopDragToolbar);
    };
    
    // 拖动中
    const onDragToolbar = (e) => {
      if (!isDraggingToolbar.value) return;
      
      let newX = e.clientX - dragOffset.x;
      let newY = e.clientY - dragOffset.y;
      
      // 获取工具栏尺寸（大约宽70px，高250px）
      const toolbarWidth = 70;
      const toolbarHeight = 300;
      
      // 限制在窗口范围内，允许全屏移动
      const maxX = window.innerWidth - toolbarWidth;
      const maxY = window.innerHeight - toolbarHeight;
      newX = Math.max(0, Math.min(newX, maxX));
      newY = Math.max(0, Math.min(newY, maxY));
      
      floatingToolbarPos.x = newX;
      floatingToolbarPos.y = newY;
    };
    
    // 停止拖动
    const stopDragToolbar = () => {
      isDraggingToolbar.value = false;
      document.removeEventListener('mousemove', onDragToolbar);
      document.removeEventListener('mouseup', stopDragToolbar);
    };
    
    // 浮动面板切换
    const toggleFloatingPanel = (panel) => {
      if (activeFloatingPanel.value === panel) {
        activeFloatingPanel.value = null;
      } else {
        activeFloatingPanel.value = panel;
      }
    };
    
    // 获取浮动面板标题
    const getFloatingPanelTitle = (panel) => {
      const titles = {
        notes: '我的笔记',
        materials: '课程资料',
        ai: '小墨AI助手'
      };
      return titles[panel] || '';
    };
    
    // 获取浮动面板图标
    const getFloatingPanelIcon = (panel) => {
      const icons = {
        notes: 'fas fa-sticky-note',
        materials: 'fas fa-folder',
        ai: 'fas fa-robot'
      };
      return icons[panel] || '';
    };
    
    // UI交互方法
    const goBack = () => {
      window.history.back();
    };

    const toggleChapterSidebar = () => {
      chapterCollapsed.value = !chapterCollapsed.value;
    };

    const shareVideo = () => {
      console.log('分享视频');
    };

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
    
    // 倍速控制方法
    const changePlaybackSpeed = (speed) => {
      // 通知视频播放器组件改变倍速
      if (videoPlayerRef.value && videoPlayerRef.value.setPlaybackSpeed) {
        videoPlayerRef.value.setPlaybackSpeed(speed);
      }
      
      // 通过事件触发行为记录
      handleSpeedChange(speed);
    };
    
    // 获取倍速分布统计
    const speedDistribution = computed(() => {
      if (speedHistory.value.length === 0) return [];
      
      const total = speedHistory.value.reduce((sum, item) => sum + item.count, 0);
      return speedHistory.value.map(item => ({
        speed: item.speed,
        count: item.count,
        percentage: (item.count / total) * 100
      }));
    });
    
    // 获取行为类型统计
    const behaviorTypeStats = computed(() => {
      return Object.entries(behaviorStats.byType).map(([type, count]) => ({
        name: type,
        count
      })).sort((a, b) => b.count - a.count);
    });
    
    // 获取行为类型图标
    const getBehaviorTypeIcon = (type) => {
      const icons = {
        [BEHAVIOR_TYPES.PLAY]: 'fas fa-play',
        [BEHAVIOR_TYPES.PAUSE]: 'fas fa-pause',
        [BEHAVIOR_TYPES.SEEK]: 'fas fa-forward',
        [BEHAVIOR_TYPES.COMPLETE]: 'fas fa-check-circle',
        [BEHAVIOR_TYPES.SPEED_CHANGE]: 'fas fa-tachometer-alt',
        'video_switch': 'fas fa-exchange-alt'
      };
      return icons[type] || 'fas fa-circle';
    };
    
    // 获取行为类型标签
    const getBehaviorTypeLabel = (type) => {
      const labels = {
        [BEHAVIOR_TYPES.PLAY]: '播放',
        [BEHAVIOR_TYPES.PAUSE]: '暂停',
        [BEHAVIOR_TYPES.SEEK]: '跳转',
        [BEHAVIOR_TYPES.COMPLETE]: '完成',
        [BEHAVIOR_TYPES.SPEED_CHANGE]: '倍速切换',
        'video_switch': '视频切换'
      };
      return labels[type] || type;
    };
    
    // 获取倍速条样式类
    const getSpeedBarClass = (speed) => {
      if (speed <= 0.75) return 'slow-speed';
      if (speed >= 1.5) return 'fast-speed';
      return 'normal-speed';
    };

    // 笔记功能
    const addNoteInline = () => {
      const content = newNoteContent.value.trim();
      if (!content) return;
      notes.value.unshift({
        id: Date.now(),
        content,
        timestamp: Date.now(),
        videoTime: learningProgress.value,
        editing: false,
        editContent: ""
      });
      newNoteContent.value = "";
      saveNotes();
    };

    const startNoteEdit = (note) => {
      note.editing = true;
      note.editContent = note.content;
    };

    const saveNoteEdit = (note) => {
      const content = (note.editContent || "").trim();
      if (!content) {
        note.editing = false;
        note.editContent = "";
        return;
      }
      note.content = content;
      note.timestamp = Date.now();
      note.editing = false;
      note.editContent = "";
      saveNotes();
    };

    const cancelNoteEdit = (note) => {
      note.editing = false;
      note.editContent = "";
    };

    const deleteNoteInline = (noteId) => {
      notes.value = notes.value.filter(note => note.id !== noteId);
      saveNotes();
    };

    // 笔记持久化
    const getNotesStorageKey = () => {
      const cid = currentCourse.value?.course_id || route.params.courseId || 'unknown_course';
      const vid = currentVideo.value?.video_id || route.params.videoId || 'unknown_video';
      return `mozhi_notes_${cid}_${vid}`;
    };

    const loadNotes = () => {
      try {
        const key = getNotesStorageKey();
        const raw = localStorage.getItem(key);
        if (raw) {
          const parsed = JSON.parse(raw);
          // 规范化字段，确保编辑状态字段存在
          notes.value = Array.isArray(parsed)
            ? parsed.map(n => ({
                id: n.id,
                content: n.content,
                timestamp: n.timestamp,
                videoTime: n.videoTime ?? 0,
                editing: false,
                editContent: ""
              }))
            : [];
        } else {
          notes.value = [];
        }
      } catch (e) {
        console.error('加载笔记失败:', e);
        notes.value = [];
      }
    };

    const saveNotes = () => {
      try {
        const key = getNotesStorageKey();
        const data = notes.value.map(n => ({
          id: n.id,
          content: n.content,
          timestamp: n.timestamp,
          videoTime: n.videoTime ?? 0
        }));
        localStorage.setItem(key, JSON.stringify(data));
      } catch (e) {
        console.error('保存笔记失败:', e);
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
    };

    onMounted(() => {
      fetchCourseData();
      fetchUserInfo();
      // 初次加载尝试读取笔记（若已有视频上下文会覆盖）
      loadNotes();
    });

    return {
      // 原有数据
      courseId,
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
      activeFloatingPanel,
      showEpisodeList,
      notes,
      courseMaterials,
      hasNextVideo,
      
      // 浮动面板方法
      toggleFloatingPanel,
      getFloatingPanelTitle,
      getFloatingPanelIcon,
      floatingToolbarHidden,
      floatingToolbarStyle,
      floatingPanelStyle,
      startDragToolbar,
      
      // 新增状态
      videoPlayerRef,
      currentSpeed,
      showSpeedPanel,
      speedOptions,
      speedHistory,
      behaviorStats,
      totalLearningTime,
      averageSpeed,
      showBehaviorStats,
      learningSuggestions,
      
      // 点赞和收藏状态
      isLiked,
      isFavorited,
      likeCount,
      favoriteCount,
      
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
      shareVideo,
      getCurrentEpisodeNumber,
      getAllVideos,
      playNext,
      selectEpisode,
      
      // 笔记方法
      newNoteContent,
      addNoteInline,
      startNoteEdit,
      saveNoteEdit,
      cancelNoteEdit,
      deleteNoteInline,
      loadNotes,
      saveNotes,
      
      // 资料方法
      getMaterialIcon,
      downloadMaterial,
      
      // 倍速和行为方法
      handleSpeedChange,
      handleVideoStateChange,
      changePlaybackSpeed,
      refreshBehaviorStats,
      
      // 点赞和收藏方法
      handleToggleLike,
      handleToggleFavorite,
      
      // 计算属性
      speedDistribution,
      behaviorTypeStats,
      
      // 工具函数
      formatDuration,
      formatTime,
      getSpeedBarClass,
      getBehaviorTypeIcon,
      getBehaviorTypeLabel,
      // 推荐课程
      recommendedCourses
    };
  },
};
</script>

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

/* 顶部标题栏 */
.top-navbar {
  /* background: linear-gradient(45deg, #6376c9 0%, #75aed6 60%, #ebeff7 100%); */
  background: white;
  border-bottom: 1px solid var(--border-color);
  padding: 0 20px;
  height: auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: var(--shadow-sm);
  position: sticky;
  top: 0;
  z-index: 100;
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

.nav-center {
  flex: 1;
  text-align: center;
  max-width: 600px;
  margin: 0 auto; 
}

.course-title {
  font-size: 26px;
  font-weight: 600;
  color: var(--text-primary);
  margin-left: 30px;
  margin-top: 1rem;
}

.video-title {
  font-size: 18px;
  color: var(--text-secondary);
  margin-bottom: 0.8rem;
}

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
  align-items: center; /* center inner video section horizontally */
}

/* 视频区域 */
.video-section {
  background: white;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  width: 100%;
  max-width: 1100px; /* limit width so it stays centered with side spacing */
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
  position: relative; /* 作为倍速面板的定位参考 */
  z-index: 30; /* 确保面板可浮在视频之上 */
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
  padding: 0 12px;
  background: none;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 14px;
  color: var(--text-secondary);
  transition: all 0.2s ease;
  height: 36px;
  min-height: 36px;
  line-height: 36px;
}

.action-btn:hover {
  background: var(--secondary-color);
  color: var(--primary-color);
  border-color: var(--primary-color);
}

/* 图标在左，文字在右，文字单行省略显示 */
.action-btn i {
  font-size: 16px;
}

.action-btn span {
  display: inline-block;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 7.5em; /* 适配不同语言长度，自动省略 */
}

/* 点赞/收藏激活时的图标颜色 */
.like-btn.active i {
  color: #e74c3c; /* 红色 */
}
.collect-btn.active i {
  color: #f1c40f; /* 黄色 */
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 右侧面板 */
/* 右侧面板高度自适应内容 */
.right-panel {
  width: 420px;
  background: white;
  border-left: 1px solid var(--border-color);
  box-shadow: var(--shadow-sm);
  display: flex;
  flex-direction: column;
  position: relative;
  max-height: calc(100vh - 60px);
  overflow-y: auto;
}

.right-panel.collapsed {
  width: 0;
  border-left: none;
  box-shadow: none;
  overflow: visible;
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
  /* background: linear-gradient(180deg, #a4b2ef 0%, #b0d6f1 60%, #ebeff7 100%);
  border-bottom: 1px solid var(--border-color);
  padding: 0 20px;
  height: auto; */
  display: flex;
  align-items: center;
  /* justify-content: center;
  box-shadow: var(--shadow-sm);
  position: sticky;
  top: 0;
  z-index: 100; */
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

/* .top-navbar-inner {
  width: 100%;
  max-width: 1100px; 
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  padding: 10px 0;
} */

.tab-btn:hover {
  background: var(--border-color);
/* 

  position: absolute;
  left: 0;
  color: white; */
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

/* 折叠按钮：放置在右侧面板左侧中间（展开时））*/
.panel-edge-toggle {
  position: absolute;
  left: -22px;
  top: 40%;
  transform: translateY(-50%);
  width: 40px;
  height: 48px;
  background: white;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  box-shadow: var(--shadow-sm);
  z-index: 1200;
  transition: all 0.16s ease;
}
.panel-edge-toggle:hover { transform: translateY(-50%) translateX(-3px); }
.panel-edge-toggle i { color: var(--text-secondary); font-size: 16px; }

/* 收缩状态下的箭头样式（更紧凑） */
.panel-edge-toggle.collapsed-toggle {
  left: -18px;
  width: 32px;
  height: 40px;
  padding: 4px;
  border-radius: 6px;
}

/* 隐藏面板内容 when collapsed */
.right-panel.collapsed .panel-header,
.right-panel.collapsed .panel-content {
  display: none !important;
}

/* 隐藏页面右侧浮动打开按钮（我们使用边缘箭头替代） */
.right-panel-toggle-btn { display: none !important; }

.panel-content {
  flex: 1;
  overflow-y: auto;
  background: var(--light);
}

.tab-pane {
  height: 100%;
  overflow-y: auto;
}

/* 章节面板整体内边距与统一背景，使右侧与章节卡片更协调 */
.chapters-pane {
  padding: 12px;
}

/* 评论面板优化：与章节面板一致的留白与背景，提升可读性 */
.comments-pane {
  padding: 12px;
}

.comments-list-area {
  background: #fff;
  border: 1px solid var(--border-color);
  border-radius: 10px;
  box-shadow: var(--shadow-sm);
  padding: 12px;
}

/* 细化评论面板内元素的通用卡片化与间距（不依赖具体子组件类名） */
.comments-list-area > * + * {
  margin-top: 12px;
}

.comments-list-area :where(.comment-item, .discussion-item, .reply-item, .message-item) {
  background: #fff;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.04);
  padding: 12px;
}

.comments-list-area :where(.comment-header, .discussion-header) {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

.comments-list-area :where(.comment-meta, .discussion-meta) {
  color: var(--text-secondary);
  font-size: 12px;
}

.comments-list-area :where(.comment-content, .discussion-content) {
  font-size: 14px;
  line-height: 1.6;
}

.comments-list-area :where(.action-row, .comment-actions, .discussion-actions) {
  display: flex;
  gap: 8px;
  margin-top: 10px;
}

.comments-list-area :where(.action-row button, .comment-actions button, .discussion-actions button) {
  border: 1px solid var(--border-color);
  background: #f7f9fc;
  color: var(--text-secondary);
  border-radius: 6px;
  padding: 6px 10px;
  cursor: pointer;
  transition: all 0.16s ease;
}

.comments-list-area :where(.action-row button, .comment-actions button, .discussion-actions button):hover {
  background: #eef3fb;
  color: var(--primary-color);
  border-color: var(--primary-color);
}

.comments-list-area :where(.reply-list, .children) {
  margin-top: 10px;
  padding-left: 12px;
  border-left: 2px solid var(--border-color);
}

.empty-state {
  background: #fff;
  border: 1px dashed var(--border-color);
  border-radius: 10px;
  padding: 24px 16px;
  color: var(--text-secondary);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  gap: 8px;
}

.empty-state i {
  color: var(--primary-color);
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

/* 新增：内联笔记输入区域样式 */
.note-input-area {
  padding: 12px;
  border: 1px dashed var(--border-color);
  border-radius: var(--radius-sm);
  background: #fff;
  margin-bottom: 12px;
}

.note-input {
  width: 100%;
  min-height: 80px;
  padding: 10px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  font-size: 14px;
  resize: vertical;
}

.note-input-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 8px;
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

.note-edit-input {
  width: 100%;
  min-height: 80px;
  padding: 10px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  font-size: 14px;
  resize: vertical;
  margin-bottom: 8px;
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
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  backdrop-filter: saturate(160%) blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1400;
}

.episode-content {
  background: #fff;
  border: 1px solid var(--border-color);
  border-radius: 14px;
  max-width: 520px;
  max-height: 80vh;
  width: min(88vw, 520px);
  display: flex;
  flex-direction: column;
  box-shadow: var(--shadow-lg);
  overflow: hidden;
  animation: modalPop 0.2s ease;
}

@keyframes modalPop {
  from { transform: translateY(8px) scale(0.98); opacity: 0; }
  to { transform: translateY(0) scale(1); opacity: 1; }
}

.episode-header {
  position: sticky;
  top: 0;
  padding: 16px 18px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #fff;
  z-index: 2;
}

.episode-header h3 {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.episode-header button {
  background: #fff;
  border: 1px solid var(--border-color);
  padding: 6px 10px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: 8px;
  transition: all 0.16s ease;
}

.episode-header button:hover {
  background: #eef3fb;
  color: var(--primary-color);
  border-color: var(--primary-color);
}

/* 列表容器（兼容现有模板中的 .episode-list） */
.episode-list {
  flex: 1;
  overflow-y: auto;
  max-height: 60vh;
  padding: 12px;
  background: #fff;
}

.episode-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 12px 14px;
  border: 1px solid var(--border-color);
  border-radius: 10px;
  margin-bottom: 10px;
  cursor: pointer;
  transition: all 0.16s ease;
  background: #fff;
  box-shadow: 0 1px 2px rgba(0,0,0,0.04);
}

.episode-item:hover {
  background: #f6f9ff;
  border-color: var(--primary-color);
}

.episode-item.active {
  background: var(--primary-color);
  color: #fff;
  border-color: var(--primary-color);
}

.episode-number {
  font-weight: 700;
  min-width: 64px;
}

.episode-title {
  flex: 1;
  font-size: 14px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
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
    display: grid;
    grid-template-columns: 1fr 360px; /* 中间视频区 + 右侧面板 */
  }
  
  .right-panel {
    width: 360px;
  }
}

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

/* 在大屏上放大视频播放器高度，使观看更舒适 */
@media (min-width: 1200px) {
  .video-player-container {
    aspect-ratio: auto;
    height: 640px;
  }
  .center-content {
    padding: 28px;
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

.recommended-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 20px;
}

@media (max-width: 1024px) {
  .recommended-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}

@media (max-width: 640px) {
  .recommended-grid { grid-template-columns: 1fr; }
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
  background: linear-gradient(135deg, #5c76eb 0%, #764ba2 100%);
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
/* .course-description 已删除 */

.description-header {
  padding: 18px 24px;
  border-bottom: 1px solid var(--border-color);
  background: linear-gradient(180deg, #f9fbff 0%, #f3f6fb 100%);
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.description-header h3 {
  font-size: 18px;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
}

.description-content {
  padding: 22px 24px;
  flex: 1;
  overflow-y: auto;
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
  display: grid;
  grid-template-columns: repeat(2, minmax(220px, 1fr));
  gap: 12px 16px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  background: #fff;
}

.detail-label {
  font-size: 13px;
  color: var(--text-secondary);
  font-weight: 600;
}

.detail-value {
  font-size: 13px;
  color: var(--text-primary);
  font-weight: 700;
  background: #f6f9ff;
  border: 1px solid #e3e8f3;
  padding: 4px 8px;
  border-radius: 999px;
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

/* 新增样式部分 */
/* 倍速面板样式 */
.speed-panel {
  position: absolute;
  bottom: calc(100% + 8px); /* 悬浮于操作栏上方并留出间距 */
  right: 0;
  background: white;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-lg);
  padding: 16px;
  min-width: 200px;
  z-index: 100;
}

.speed-options {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 12px;
}

.speed-option {
  padding: 6px 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  background: none;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s ease;
}

.speed-option:hover {
  background: var(--secondary-color);
  border-color: var(--primary-color);
}

.speed-option.active {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.speed-history {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-top: 12px;
  border-top: 1px solid var(--border-color);
}

.speed-history-label {
  font-size: 12px;
  color: var(--text-secondary);
}

.speed-history-item {
  padding: 4px 8px;
  background: var(--secondary-color);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.speed-history-item:hover {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

/* 行为统计样式 */
.behavior-pane {
  padding: 16px;
}

.behavior-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.behavior-header h4 {
  margin: 0;
  font-size: 16px;
  color: var(--text-primary);
}

.refresh-btn {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.refresh-btn:hover {
  background: var(--border-color);
  color: var(--primary-color);
}

.behavior-stats-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: var(--secondary-color);
  border-radius: var(--radius-md);
  border: 1px solid var(--border-color);
}

.stat-icon {
  width: 36px;
  height: 36px;
  background: var(--primary-color);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: var(--text-secondary);
}

.speed-distribution {
  margin-bottom: 20px;
}

.speed-distribution h5 {
  font-size: 14px;
  color: var(--text-primary);
  margin: 0 0 12px 0;
}

.speed-bar-item {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.speed-label {
  width: 40px;
  font-size: 12px;
  color: var(--text-secondary);
}

.speed-bar {
  flex: 1;
  height: 8px;
  background: var(--border-color);
  border-radius: 4px;
  overflow: hidden;
}

.speed-fill {
  height: 100%;
  transition: width 0.3s ease;
}

.speed-fill.slow-speed {
  background: var(--success-color);
}

.speed-fill.normal-speed {
  background: var(--primary-color);
}

.speed-fill.fast-speed {
  background: var(--warning-color);
}

.speed-percentage {
  width: 50px;
  text-align: right;
  font-size: 12px;
  color: var(--text-secondary);
}

.behavior-types {
  margin-bottom: 20px;
}

.behavior-types h5 {
  font-size: 14px;
  color: var(--text-primary);
  margin: 0 0 12px 0;
}

.behavior-type-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.behavior-type-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px;
  background: var(--secondary-color);
  border-radius: var(--radius-sm);
}

.type-icon {
  width: 24px;
  height: 24px;
  background: var(--primary-color);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}

.type-info {
  flex: 1;
}

.type-name {
  font-size: 14px;
  color: var(--text-primary);
}

.type-count {
  font-size: 12px;
  color: var(--text-secondary);
}

.learning-suggestions h5 {
  font-size: 14px;
  color: var(--text-primary);
  margin: 0 0 12px 0;
}

.suggestions-list {
  margin: 0;
  padding-left: 20px;
}

.suggestions-list li {
  font-size: 13px;
  color: var(--text-secondary);
  margin-bottom: 8px;
  line-height: 1.4;
}

.suggestions-list li i {
  color: var(--warning-color);
  margin-right: 8px;
}

/* 倍速按钮样式 */
.speed-btn {
  position: relative;
}

.behavior-stats {
  font-size: 12px;
  color: var(--text-secondary);
  margin-left: 12px;
  padding-left: 12px;
  border-left: 1px solid var(--border-color);
}

/* 视频信息区域优化 */
.video-info-section {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.video-stats {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* 章节面板样式 */
.chapters-pane {
  height: 100%;
  overflow: hidden;
}

.chapters-pane :deep(.chapters-sidebar) {
  border-right: none;
  height: 100%;
}

/* 浮动工具栏 */
.floating-toolbar {
  position: fixed;
  right: 20px;
  bottom: 30px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  z-index: 2147483600; /* 置于页面最顶层（悬浮工具栏） */
  background: rgba(255, 255, 255, 0.95);
  padding: 12px 8px;
  border-radius: 28px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  cursor: move;
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.floating-toolbar.hidden {
  opacity: 0;
  pointer-events: none;
  transform: translateX(100px);
}

/* 拖动手柄 */
.toolbar-drag-handle {
  width: 100%;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-secondary);
  opacity: 0.5;
  cursor: grab;
  margin-bottom: 4px;
}

.toolbar-drag-handle:active {
  cursor: grabbing;
}

.toolbar-drag-handle i {
  font-size: 12px;
}

/* 显示工具栏的小按钮 */
.floating-toolbar-show-btn {
  position: fixed;
  right: 0;
  bottom: 120px;
  width: 28px;
  height: 60px;
  background: var(--primary-color);
  color: white;
  border-radius: 8px 0 0 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  box-shadow: -2px 0 10px rgba(0, 0, 0, 0.1);
  z-index: 2147483601; /* 比工具栏略高，便于召回 */
  transition: all 0.2s ease;
}

.floating-toolbar-show-btn:hover {
  width: 36px;
  background: #1557b0;
}

/* 隐藏按钮样式 */
.floating-btn.hide-btn {
  width: 36px;
  height: 36px;
  font-size: 14px;
  background: var(--secondary-color);
  margin-top: 4px;
}

.floating-btn.hide-btn:hover {
  background: var(--border-color);
}

.floating-btn {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  border: none;
  background: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  color: var(--text-secondary);
  transition: all 0.3s ease;
}

.floating-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2);
  color: var(--primary-color);
}

.floating-btn.active {
  background: var(--primary-color);
  color: white;
}

.floating-btn.ai-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.floating-btn.ai-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.floating-btn.ai-btn.active {
  background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
}

/* 浮动面板 */
.floating-panel {
  position: fixed;
  right: 90px;
  top: 50%;
  transform: translateY(-50%);
  width: 380px;
  max-height: 500px;
  background: white;
  border-radius: var(--radius-lg);
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  z-index: 2147483602; /* 悬浮窗面板层级最高，覆盖一切 */
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.floating-panel.ai-panel {
  width: 420px;
  max-height: 600px;
}

.floating-panel-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: linear-gradient(180deg, #f9fbff 0%, #f3f6fb 100%);
}

.floating-panel-header h4 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
  display: flex;
  align-items: center;
  gap: 8px;
}

.floating-panel-header h4 i {
  color: var(--primary-color);
}

.floating-panel-header .close-btn {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.floating-panel-header .close-btn:hover {
  background: var(--border-color);
  color: var(--error-color);
}

.floating-panel-content {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

/* 浮动面板内的笔记样式调整 */
.floating-panel .notes-section {
  padding: 0;
}

.floating-panel .notes-section .notes-header {
  display: none;
}

.floating-panel .materials-section {
  padding: 0;
}

.floating-panel .materials-section h4 {
  display: none;
}

.floating-panel .ai-section-panel {
  height: 100%;
  min-height: 400px;
}

/* 浮动面板动画 */
.slide-up-enter-active,
.slide-up-leave-active {
  transition: all 0.3s ease;
}

.slide-up-enter-from,
.slide-up-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .floating-toolbar {
    right: 10px;
    top: auto;
    bottom: 80px;
    transform: none;
  }
  
  .floating-btn {
    width: 44px;
    height: 44px;
    font-size: 16px;
  }
  
  .floating-panel {
    left: 10px;
    right: 10px;
    top: auto;
    bottom: 140px;
    width: auto;
    max-height: 60vh;
    transform: none;
  }
}
</style>