<template>
  <div class="discussion-sidebar">
    <div class="discussion-stats">
      <div class="discussion-stat-item">
        <i class="fas fa-signal"></i>
        <span class="label">在线</span>
        <span class="value">{{ onlineCount }}人</span>
      </div>
      <div class="discussion-stat-item">
        <i class="fas fa-comment-dots"></i>
        <span class="label">讨论</span>
        <span class="value">{{ totalDiscussions }}条</span>
      </div>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="discussion-controls">
      <div class="search-box">
        <i class="fas fa-search search-icon"></i>
        <input
          v-model="searchKeyword"
          type="text"
          class="search-input"
          placeholder="搜索讨论内容..."
          @input="handleSearch"
        />
      </div>
      <div class="filter-dropdown">
        <select
          v-model="sortBy"
          class="filter-select"
          @change="handleSortChange"
        >
          <option value="latest">最新</option>
          <option value="popular">最热</option>
        </select>
      </div>
    </div>

    <!-- 可滚动的讨论内容区域 -->
    <div class="discussion-content-wrapper">
      <div class="discussion-content" ref="discussionContent">
        <div
          v-for="discussion in filteredDiscussions"
          :key="discussion.comment_id"
          class="message"
          :class="{ 'current-user': discussion.user_id === currentUserId }"
        >
          <div class="message-header">
            <div class="message-avatar">{{ getAvatarText(discussion.user_name) }}</div>
            <div class="message-user">{{ discussion.user_name }}</div>
            <div class="message-time">
              {{ formatTime(discussion.create_time) }}
            </div>
          </div>
          <div class="message-text">{{ discussion.comment_content }}</div>
          <div class="message-actions">
            <span
              class="message-action"
              :class="{ liked: discussion.liked }"
              @click="handleLike(discussion.comment_id)"
            >
              <i class="fas fa-thumbs-up"></i> {{ discussion.like_count || 0 }}
            </span>
            <span class="message-action" @click="handleReply(discussion)">
              <i class="fas fa-reply"></i> 回复
            </span>
            <span 
              v-if="discussion.user_id === currentUserId" 
              class="message-action delete-action" 
              @click="handleDelete(discussion.comment_id)"
            >
              <i class="fas fa-trash-alt"></i> 删除
            </span>
          </div>

          <!-- 回复列表 -->
          <div
            v-if="discussion.replies && discussion.replies.length > 0"
            class="replies"
          >
            <div
              v-for="reply in discussion.replies"
              :key="reply.reply_id"
              class="reply"
              :class="{ 'current-user': reply.user_id === currentUserId }"
            >
              <div class="message-header">
                <div class="message-avatar">{{ getAvatarText(reply.user_name) }}</div>
                <div class="message-user">{{ reply.user_name }}</div>
                <div class="message-time">
                  {{ formatTime(reply.create_time) }}
                </div>
              </div>
              <div class="message-text">{{ reply.comment_content }}</div>
              <div class="message-actions">
                <span
                  class="message-action"
                  :class="{ liked: reply.liked }"
                  @click="handleLike(reply.comment_id)"
                >
                  <i class="fas fa-thumbs-up"></i> {{ reply.like_count || 0 }}
                </span>
                <span 
                  v-if="reply.user_id === currentUserId" 
                  class="message-action delete-action" 
                  @click="handleDelete(reply.comment_id)"
                >
                  <i class="fas fa-trash-alt"></i> 删除
                </span>
              </div>
            </div>
          </div>

          <!-- 回复输入框 -->
          <div v-if="replyingTo === discussion.comment_id" class="reply-input">
            <textarea
              v-model="replyContent"
              class="reply-textarea"
              placeholder="输入回复内容..."
              rows="2"
            ></textarea>
            <div class="reply-actions">
              <button
                class="btn btn-primary btn-sm"
                @click="submitReply(discussion.comment_id)"
                :disabled="!replyContent.trim()"
              >
                发送
              </button>
              <button class="btn btn-secondary btn-sm" @click="cancelReply">
                取消
              </button>
            </div>
          </div>
        </div>

        <div v-if="filteredDiscussions.length === 0" class="no-discussions">
          <i class="fas fa-comment-slash"></i>
          <p>暂无讨论内容</p>
        </div>
      </div>
    </div>

    <!-- 固定的发送区域 -->
    <div class="discussion-input-fixed">
      <div class="discussion-input-area">
        <input
          v-model="newMessage"
          type="text"
          class="discussion-input"
          placeholder="输入消息..."
          @keypress.enter="handleSendMessage"
        />
        <div class="input-actions">
          <button
            class="btn btn-primary"
            @click="handleSendMessage"
            :disabled="!newMessage.trim()"
          >
            <i class="fas fa-paper-plane"></i>
            发送
          </button>
          <button class="btn btn-secondary" type="button" title="常用表情">
            <i class="fas fa-smile"></i>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch, nextTick } from "vue";
import { commentApi } from "@/api/comment";

const debounce = (fn, delay = 300) => {
  let timer = null;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
};

export default {
  name: "DiscussionPanel",
  props: {
    videoId: {
      type: Number,
      required: true,
    },
    discussions: {
      type: Array,
      default: () => [],
    },
    userInfo: {
      type: Object,
      default: () => ({})
    }
  },
  emits: ["send-message", "discussion-search", "like-discussion", "reply-discussion"],
  setup(props, { emit }) {
    const discussionContent = ref(null);
    const newMessage = ref("");
    const searchKeyword = ref("");
    const sortBy = ref("latest");
    const debouncedSearch = ref(null);

    const replyingTo = ref(null);
    const replyContent = ref("");
    const onlineCount = ref(128);

    // 计算当前用户ID
    const currentUserId = computed(() => {
      return props.userInfo.user_id || 1;
    });

    // 计算属性
    const totalDiscussions = computed(() => {
      return props.discussions.length;
    });

    const filteredDiscussions = computed(() => {
      const keyword = searchKeyword.value.trim().toLowerCase();
      const normalizedDiscussions = props.discussions.map((discussion) => ({
        ...discussion,
        replies: Array.isArray(discussion.replies) ? discussion.replies : [],
      }));

      let discussions = normalizedDiscussions;

      if (keyword) {
        discussions = normalizedDiscussions.reduce((acc, discussion) => {
          const replies = discussion.replies || [];
          const parentMatch =
            (discussion.comment_content || "").toLowerCase().includes(keyword) ||
            (discussion.user_name || "").toLowerCase().includes(keyword);

          const matchedReplies = replies.filter(
            (reply) =>
              (reply.comment_content || "").toLowerCase().includes(keyword) ||
              (reply.user_name || "").toLowerCase().includes(keyword)
          );

          if (parentMatch) {
            acc.push({ ...discussion });
          } else if (matchedReplies.length > 0) {
            acc.push({ ...discussion, replies: matchedReplies });
          }

          return acc;
        }, []);
      }

      if (sortBy.value === "latest") {
        discussions.sort(
          (a, b) => new Date(b.create_time) - new Date(a.create_time)
        );
      } else if (sortBy.value === "popular") {
        discussions.sort((a, b) => (b.like_count || 0) - (a.like_count || 0));
      }

      return discussions;
    });

    // 处理方法
    const handleSendMessage = async () => {
      if (!newMessage.value.trim()) return;

      try {
        // 调用发送视频评论API
        await commentApi.addVideoComment(props.videoId, {
          content: newMessage.value.trim()
        });

        newMessage.value = "";
        
        // 触发事件通知父组件重新获取数据
        emit("send-message");
        
        scrollToBottom();
      } catch (error) {
        console.error("发送消息失败:", error);
        alert("发送失败，请重试");
      }
    };

    const emitSearch = () => {
      if (!props.videoId) return;
      emit("discussion-search", {
        keyword: searchKeyword.value,
        sort: sortBy.value,
      });
    };

    const initDebounce = () => {
      if (!debouncedSearch.value) {
        debouncedSearch.value = debounce(emitSearch, 300);
      }
    };

    const handleSearch = () => {
      if (!props.videoId) return;
      initDebounce();
      debouncedSearch.value();
    };

    const handleSortChange = () => {
      if (!props.videoId) return;
      emitSearch();
    };

    // 点赞状态管理（防止重复点击）
    const likingComments = ref(new Set());

    const handleLike = async (commentId) => {
      // 防止重复点击
      if (likingComments.value.has(commentId)) {
        console.log('⏳ 点赞请求进行中，请稍候...');
        return;
      }

      try {
        likingComments.value.add(commentId);
        await commentApi.toggleCommentLike(commentId);
        // 立即刷新评论列表
        emit("send-message");
      } catch (error) {
        console.error("点赞失败:", error);
      } finally {
        // 1秒后允许再次点击
        setTimeout(() => {
          likingComments.value.delete(commentId);
        }, 1000);
      }
    };

    const handleReply = (discussion) => {
      replyingTo.value = discussion.comment_id;
      replyContent.value = "";
    };

    const submitReply = async (parentCommentId) => {
      if (!replyContent.value.trim()) return;
      try {
        await commentApi.addVideoComment(props.videoId, {
          content: replyContent.value.trim(),
          parentId: parentCommentId
        });
        
        replyContent.value = "";
        replyingTo.value = null;
        
        // 立即刷新评论列表
        emit("send-message");
      } catch (error) {
        console.error("回复失败:", error);
        alert("回复失败，请重试");
      }
    };

    const cancelReply = () => {
      replyingTo.value = null;
      replyContent.value = "";
    };

    // 删除评论
    const handleDelete = async (commentId) => {
      if (!confirm('确定要删除这条评论吗？')) return;
      
      try {
        await commentApi.deleteVideoComment(commentId);
        // 触发事件通知父组件重新获取数据
        emit("send-message");
      } catch (error) {
        console.error("删除评论失败:", error);
        alert("删除失败，请重试");
      }
    };

    // 工具函数
    const formatTime = (timeString) => {
      if (!timeString) return "";
      
      const time = new Date(timeString);
      const now = new Date();
      const diff = now - time;

      if (diff < 60000) {
        // 1分钟内
        return "刚刚";
      } else if (diff < 3600000) {
        // 1小时内
        return `${Math.floor(diff / 60000)}分钟前`;
      } else if (diff < 86400000) {
        // 1天内
        return `${Math.floor(diff / 3600000)}小时前`;
      } else {
        return time.toLocaleDateString();
      }
    };

    // 获取头像文本
    const getAvatarText = (userName) => {
      if (!userName) return "用";
      return userName.charAt(0);
    };

    // 滚动到底部
    const scrollToBottom = () => {
      nextTick(() => {
        if (discussionContent.value) {
          discussionContent.value.scrollTop =
            discussionContent.value.scrollHeight;
        }
      });
    };

    // 监听讨论数据变化
    watch(
      () => props.discussions,
      () => {
        scrollToBottom();
      },
      { deep: true }
    );

    onMounted(() => {
      scrollToBottom();
    });

    return {
      discussionContent,
      newMessage,
      searchKeyword,
      sortBy,
      replyingTo,
      replyContent,
      onlineCount,
      currentUserId,
      totalDiscussions,
      filteredDiscussions,
      handleSendMessage,
      handleSearch,
      handleSortChange,
      handleLike,
      handleReply,
      submitReply,
      cancelReply,
      handleDelete,
      formatTime,
      getAvatarText
    };
  },
};
</script>

<style scoped>
.discussion-sidebar {
  background: white;
  border-left: 1px solid var(--border);
  display: flex;
  flex-direction: column;
  height: 100%;
  position: relative;
}

.discussion-stats {
  display: flex;
  gap: 15px;
  padding: 10px 20px;
  background: var(--light);
  border-bottom: 1px solid var(--border);
  font-size: 0.8rem;
  color: var(--gray);
  flex-shrink: 0;
}

.discussion-stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
}

.discussion-stat-item .label {
  color: var(--text-secondary);
}

.discussion-stat-item .value {
  font-weight: 600;
  color: var(--primary);
}

.discussion-controls {
  padding: 10px 15px;
  border-bottom: 1px solid var(--border);
  display: flex;
  gap: 10px;
  align-items: center;
  flex-shrink: 0;
}

.search-box {
  flex: 1;
  position: relative;
}

.search-input {
  width: 100%;
  padding: 8px 12px 8px 35px;
  border: 1px solid var(--border);
  border-radius: 18px;
  font-size: 0.85rem;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(26, 115, 232, 0.2);
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--gray);
  font-size: 0.9rem;
}

.filter-dropdown {
  position: relative;
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid var(--border);
  border-radius: 6px;
  background: white;
  font-size: 0.85rem;
  cursor: pointer;
  min-width: 100px;
  transition: all 0.3s ease;
}

.filter-select:focus {
  outline: none;
  border-color: var(--primary);
}

/* 可滚动的讨论内容区域 */
.discussion-content-wrapper {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  min-height: 0; /* 重要：允许内容区域收缩 */
}

.discussion-content {
  flex: 1;
  overflow-y: auto;
  padding: 15px;
  min-height: 0; /* 重要：允许内容区域滚动 */
}

.message {
  margin-bottom: 15px;
  transition: all 0.3s ease;
}

.message.current-user .message-text {
  background: var(--primary-light);
  border-color: var(--primary);
}

.message-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.message-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: var(--primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: bold;
}

.message-user {
  font-weight: 600;
  font-size: 0.8rem;
}

.message-time {
  color: var(--gray);
  font-size: 0.75rem;
  margin-left: auto;
}

.message-text {
  background: var(--light);
  padding: 10px 12px;
  border-radius: 10px;
  font-size: 0.8rem;
  line-height: 1.4;
  border: 1px solid transparent;
  word-wrap: break-word;
}

.message-actions {
  display: flex;
  gap: 12px;
  margin-top: 6px;
  font-size: 0.75rem;
  color: var(--gray);
}

.message-action {
  cursor: pointer;
  transition: color 0.3s ease;
  user-select: none;
}

.message-action:hover {
  color: var(--primary);
}

.message-action.liked {
  color: var(--primary);
  font-weight: 500;
}

.message-action.delete-action {
  color: #dc3545;
}

.message-action.delete-action:hover {
  color: #c82333;
}

.message-action i {
  margin-right: 4px;
  font-size: 0.85em;
}

.replies {
  margin-top: 10px;
  margin-left: 20px;
  border-left: 2px solid var(--border);
  padding-left: 15px;
}

.reply {
  margin-bottom: 10px;
}

.reply-input {
  margin-top: 10px;
  padding: 10px;
  background: var(--light);
  border-radius: 8px;
  border: 1px solid var(--border);
}

.reply-textarea {
  width: 100%;
  padding: 8px;
  border: 1px solid var(--border);
  border-radius: 4px;
  font-size: 0.8rem;
  resize: vertical;
  font-family: inherit;
}

.reply-textarea:focus {
  outline: none;
  border-color: var(--primary);
}

.reply-actions {
  display: flex;
  gap: 8px;
  margin-top: 8px;
  justify-content: flex-end;
}

/* 固定的发送区域 */
.discussion-input-fixed {
  flex-shrink: 0;
  border-top: 1px solid var(--border);
  background: white;
  padding: 15px;
  position: sticky;
  bottom: 0;
  z-index: 10;
}

.discussion-input-area {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.discussion-input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--border);
  border-radius: 18px;
  font-size: 0.85rem;
  transition: all 0.3s ease;
}

.discussion-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(26, 115, 232, 0.1);
}

.input-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 6px;
}

.btn-primary {
  background: var(--primary);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #1557b0;
}

.btn-primary:disabled {
  background: var(--border);
  cursor: not-allowed;
  opacity: 0.6;
}

.btn-secondary {
  background: var(--light);
  color: var(--text-secondary);
  border: 1px solid var(--border);
}

.btn-secondary:hover {
  background: var(--border);
}

.btn-sm {
  padding: 4px 8px;
  font-size: 0.75rem;
}

.no-discussions {
  text-align: center;
  padding: 40px 20px;
  color: var(--gray);
}

.no-discussions i {
  font-size: 2rem;
  margin-bottom: 10px;
  opacity: 0.5;
}

.no-discussions p {
  font-size: 0.9rem;
}

/* 滚动条样式 */
.discussion-content::-webkit-scrollbar {
  width: 6px;
}

.discussion-content::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.discussion-content::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.discussion-content::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

/* CSS 变量定义 */
.discussion-sidebar {
  --primary: #1a73e8;
  --primary-light: #e8f0fe;
  --secondary: #f8f9fa;
  --light: #f8f9fa;
  --border: #dadce0;
  --gray: #5f6368;
  --text-primary: #202124;
  --text-secondary: #5f6368;
}
</style>