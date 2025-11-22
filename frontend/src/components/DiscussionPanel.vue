<template>
  <div class="discussion-sidebar">
    <div class="discussion-header">
      <div class="discussion-avatar">
        <i class="fas fa-comments"></i>
      </div>
      <div>
        <h3 style="font-size: 1.1rem">实时讨论区</h3>
        <p style="font-size: 0.75rem; color: var(--gray)">与同学交流学习心得</p>
      </div>
    </div>

    <div class="discussion-stats">
      <span>在线: {{ onlineCount }}人</span>
      <span>讨论: {{ totalDiscussions }}条</span>
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

    <div class="discussion-content" ref="discussionContent">
      <div
        v-for="discussion in filteredDiscussions"
        :key="discussion.comment_id"
        class="message"
        :class="{ 'current-user': discussion.user_id === currentUserId }"
      >
        <div class="message-header">
          <div class="message-avatar">{{ discussion.avatar }}</div>
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
            👍 {{ discussion.like_count }}
          </span>
          <span class="message-action" @click="handleReply(discussion)">
            💬 回复
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
              <div class="message-avatar">{{ reply.avatar }}</div>
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
                👍 {{ reply.like_count }}
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

    <div class="discussion-input-area">
      <input
        v-model="newMessage"
        type="text"
        class="discussion-input"
        placeholder="输入消息..."
        @keypress.enter="handleSendMessage"
      />
      <div style="display: flex; gap: 8px">
        <button
          class="btn btn-primary"
          @click="handleSendMessage"
          :disabled="!newMessage.trim()"
        >
          <i class="fas fa-paper-plane"></i>
          发送
        </button>
        <button class="btn btn-secondary">
          <i class="fas fa-smile"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch, nextTick } from "vue";
import { postComment, likeComment } from "@/api/comment";
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
  },
  emits: ["send-message", "search", "like", "reply"],
  setup(props, { emit }) {
    const discussionContent = ref(null);
    const newMessage = ref("");
    const searchKeyword = ref("");
    const sortBy = ref("latest");
    const replyingTo = ref(null);
    const replyContent = ref("");
    const onlineCount = ref(128);
    const currentUserId = ref(1); // 模拟当前用户ID

    // 计算属性
    const totalDiscussions = computed(() => {
      return props.discussions.length;
    });

    const filteredDiscussions = computed(() => {
      let discussions = [...props.discussions];

      // 搜索过滤
      if (searchKeyword.value.trim()) {
        const keyword = searchKeyword.value.toLowerCase();
        discussions = discussions.filter(
          (discussion) =>
            discussion.comment_content.toLowerCase().includes(keyword) ||
            discussion.user_name.toLowerCase().includes(keyword)
        );
      }

      // 排序
      if (sortBy.value === "latest") {
        discussions.sort(
          (a, b) => new Date(b.create_time) - new Date(a.create_time)
        );
      } else if (sortBy.value === "popular") {
        discussions.sort((a, b) => b.like_count - a.like_count);
      }

      return discussions;
    });

    // 处理方法
    const handleSendMessage = async () => {
      if (!newMessage.value.trim()) return;

      try {
        // ✅ 使用正确的参数结构
        await postComment({
          videoId: props.videoId,
          userId: currentUserId.value,
          content: newMessage.value.trim(),
          // parentId 不传表示主评论
        });

        newMessage.value = "";
        emit("send-message", newMessage.value);

        // 可以添加成功提示
        console.log("评论发送成功");

        scrollToBottom();
      } catch (error) {
        console.error("发送消息失败:", error);
        alert("发送失败，请稍后重试");
      }
    };

    const handleSearch = () => {
      emit("search", searchKeyword.value);
    };

    const handleSortChange = () => {
      // 排序变化时自动处理
    };

    const handleLike = async (commentId) => {
      try {
        await likeComment(commentId); // 使用正确的函数名
        emit("like", commentId);
      } catch (error) {
        console.error("点赞失败:", error);
      }
    };

    const handleReply = (discussion) => {
      replyingTo.value = discussion.comment_id;
      replyContent.value = "";
    };

    const submitReply = async (parentCommentId) => {
      if (!replyContent.value.trim()) return;
      try {
        await postComment({
          videoId: props.videoId,
          content: replyContent.value.trim(),
          userId: currentUserId.value,
          parentId: parentCommentId, // 关键：传递 parentId 表示这是回复
        });
        replyContent.value = "";
        replyingTo.value = null;
        emit("reply", { parentCommentId, content: replyContent.value });

        // 可以在这里触发重新获取评论列表
      } catch (error) {
        console.error("回复失败:", error);
        alert("回复失败，请稍后重试");
      }
    };

    const cancelReply = () => {
      replyingTo.value = null;
      replyContent.value = "";
    };

    // 格式化时间
    const formatTime = (timeString) => {
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
      formatTime,
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
}

.discussion-header {
  padding: 20px;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  gap: 10px;
}

.discussion-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--secondary), #4caf50);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1rem;
}

.discussion-stats {
  display: flex;
  gap: 15px;
  padding: 10px 20px;
  background: var(--light);
  border-bottom: 1px solid var(--border);
  font-size: 0.8rem;
  color: var(--gray);
}

.discussion-controls {
  padding: 10px 15px;
  border-bottom: 1px solid var(--border);
  display: flex;
  gap: 10px;
  align-items: center;
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

.discussion-content {
  flex: 1;
  overflow-y: auto;
  padding: 15px;
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

.discussion-input-area {
  padding: 15px;
  border-top: 1px solid var(--border);
}

.discussion-input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--border);
  border-radius: 18px;
  font-size: 0.85rem;
  margin-bottom: 8px;
  transition: all 0.3s ease;
}

.discussion-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(26, 115, 232, 0.1);
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
</style>