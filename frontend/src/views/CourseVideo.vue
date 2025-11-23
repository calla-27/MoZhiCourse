<template>
  <div class="course-video-container">
    <nav class="navbar">
      <div class="logo">
        <i class="fas fa-graduation-cap"></i>
        <span>墨知课堂</span>
      </div>
      
      <div class="course-info" v-if="currentCourse.course_name">
        <h2 class="course-title">{{ currentCourse.course_name }}</h2>
      </div>
      
      <div class="user-actions" v-if="userInfo.user_name">
        <div class="user-info">
          <span>欢迎，{{ userInfo.user_name }}</span>
        </div>
        <div class="avatar">
          {{ userInfo.avatar || userInfo.user_name?.charAt(0) }}
        </div>
      </div>
    </nav>

    <main class="main-content">
      <ChapterList
        :chapters="chapters"
        :current-video-id="currentVideo.video_id"
        @video-change="handleVideoChange"
      />

      <section class="video-main-section">
        <template v-if="currentVideo.video_id">
          <CourseVideoPlayer
            class="video-player-fixed" 
            :video-url="getVideoUrl(currentVideo)"
            :initial-progress="learningProgress"
            @progress-update="handleProgressUpdate"
            @behavior-record="handleBehaviorRecord"
          />
        </template>
        
        <div v-else class="empty-video-player">
          <i class="fas fa-video"></i>
          <p>正在努力加载视频数据，请稍候...</p>
          <p v-if="chapters.length > 0">您也可以从左侧列表中选择章节。</p>
        </div>
        
        <template v-if="currentVideo.video_id && currentCourse.course_id">
          <AIAssistant 
            class="ai-assistant-scrollable"
            @question-submit="handleAIQuestion" 
            :video-id="currentVideo.video_id"
            :course-id="currentCourse.course_id"
          />
        </template>
        <div v-else class="ai-assistant-placeholder">
          <i class="fas fa-robot"></i>
          <p>请选择左侧章节以启用 AI 学习助手。</p>
        </div>
      </section>

      <aside class="discussion-section">
        <template v-if="currentVideo.video_id">
          <DiscussionPanel
            :video-id="currentVideo.video_id"
            :discussions="discussions"
            @send-message="handleSendMessage"
            @discussion-search="handleDiscussionSearch"
            @like-discussion="handleLikeDiscussion"
            @reply-discussion="handleReplyDiscussion"
          />
        </template>
        <div v-else class="discussion-placeholder">
          <i class="fas fa-comments"></i>
          <p>请选择一个视频以查看讨论区内容。</p>
        </div>
      </aside>
    </main>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from "vue";
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

    const fetchUserInfo = async () => {
      try {
        // 暂时模拟用户信息
        userInfo.value = {
          user_id: 1,
          user_name: "李小明",
          avatar: "李",
        };
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
        // 🚨 实际应用中，还需要获取回复，或者 DiscussionPanel 内部处理树形结构
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
      // ... (逻辑不变，已优化节流)
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
      // 实际：调用 recordLearningBehavior API
      console.log("记录学习行为:", behaviorData);
    };

    // AI问答 (🚨 需实现 API 调用)
    const handleAIQuestion = async (question) => {
      console.log("AI 问答触发:", question);
      // 实际：调用 AI API
    };

    // 发送讨论消息 (🚨 需实现 API 调用)
    const handleSendMessage = async () => {
      await fetchDiscussions();
    };

    // 搜索讨论 (🚨 需实现 API 调用)
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

    // 点赞讨论 (🚨 需实现 API 调用)
    const handleLikeDiscussion = (commentId) => {
      console.log("点赞讨论 ID:", commentId);
      fetchDiscussions();
    };

    // 回复讨论 (🚨 需实现 API 调用)
    const handleReplyDiscussion = (replyData) => {
      console.log("回复讨论数据:", replyData);
      fetchDiscussions();
    };

    onMounted(() => {
      fetchCourseData();
      fetchUserInfo();
    });

    return {
      currentCourse,
      currentVideo,
      chapters,
      discussions,
      discussionFilters,
      userInfo,
      learningProgress,
      getVideoUrl,
      handleVideoChange,
      handleProgressUpdate,
      handleBehaviorRecord,
      handleAIQuestion,
      handleSendMessage,
      handleDiscussionSearch,
      handleLikeDiscussion,
      handleReplyDiscussion,
    };
  },
};

</script>

<style scoped>
.course-video-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: var(--light, #f7f7f7);
}

.main-content {
  flex: 1;
  display: grid;
  /* 章节列表(300px) | 视频/AI区(1fr) | 讨论区(350px) */
  grid-template-columns: 300px 1fr 350px; 
  height: calc(100vh - 70px);
  /* 阻止 main-content 滚动，让子容器滚动 */
  overflow: hidden; 
}

/* 1. 章节列表：确保其可以滚动 */
/* 假设 ChapterList 内部已有滚动或在其外部容器设置 */
/* .chapter-list-container {
    overflow-y: auto; 
}
*/

/* 2. 中间视频/AI区域的 Flex 容器 */
.video-main-section {
  display: flex;
  flex-direction: column;
  /* 阻止 video-main-section 自身滚动，让 AIAssistant 内部滚动 */
  overflow-y: hidden; 
}

/* 视频播放器和空状态：限制高度，固定占据空间 */
/* 调整高度，为 AI 助手留出更多空间 */
.video-player-fixed,
.empty-video-player {
    /* 固定高度，比如屏幕高度的 50% 或固定像素值 */
    height: 450px; 
    flex-shrink: 0; /* 防止被压缩 */
}

/* 视频播放器空状态样式 */
.empty-video-player {
    background-color: #333;
    color: #ccc;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-size: 1.1rem;
    padding: 20px;
}
.empty-video-player i {
    font-size: 3rem;
    margin-bottom: 15px;
}
.empty-video-player p {
    margin: 5px 0;
}

/* AI 助手：占据剩余空间，并可滚动 */
.ai-assistant-scrollable {
    flex-grow: 1; /* 占据所有剩余空间 */
    min-height: 0; /* 确保在 flex 容器中可以正确滚动 */
    /* 假设 AIAssistant 内部已经设置了 overflow-y: auto */
    /* 如果 AIAssistant 内部没有滚动，需要在此处添加 overflow-y: auto */
}

/* 3. 讨论区：确保其可以滚动 */
.discussion-section {
    display: flex;
    flex-direction: column;
    /* 讨论区容器允许自身滚动 */
    overflow-y: auto; 
}

/* 假设 DiscussionPanel 占据剩余空间并可滚动 */
/* 如果 DiscussionPanel 内部没有滚动，需要为其添加样式: flex-grow: 1; overflow-y: auto; */

/* --- 导航栏样式 (保持不变) --- */
.navbar {
  background: white;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  height: 70px;
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 20px;
  font-weight: bold;
  color: var(--primary);
}

.course-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.course-title {
  font-weight: 600;
  font-size: 1.1rem;
}

.user-actions {
  display: flex;
  align-items: center;
  gap: 15px;
}

.avatar {
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

/* --- 响应式设计 (保持不变) --- */
@media (max-width: 1200px) {
  .main-content {
    grid-template-columns: 250px 1fr 300px;
  }
}

@media (max-width: 768px) {
  .main-content {
    grid-template-columns: 1fr;
    grid-template-rows: auto 1fr auto;
  }
}
</style>