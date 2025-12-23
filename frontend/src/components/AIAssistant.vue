<template>
  <div class="ai-section">
    <div class="ai-header">
      <div class="ai-avatar">
        <i class="fas fa-robot"></i>
      </div>
      <div>
        <h3 style="font-size: 1.1rem;">AI学习助手</h3>
        <p style="font-size: 0.75rem; color: var(--gray);">实时分析课程内容，智能辅助学习</p>
      </div>
      <div class="ai-header-actions">
        <button class="btn btn-secondary btn-icon" @click="refreshTab" title="刷新当前内容">
          <i class="fas fa-sync-alt"></i>
        </button>
      </div>
    </div>
    
    <div class="ai-content">
      <!-- AI对话历史 -->
      <div class="chat-history" ref="chatHistory">
        <div v-if="chatMessages.length === 0" class="empty-chat">
          <i class="fas fa-robot"></i>
          <p>你好！我是AI学习助手</p>
          <p class="hint">你可以问我关于课程内容的任何问题</p>
        </div>
        
        <div v-for="(msg, index) in chatMessages" :key="index" class="chat-message" :class="msg.role">
          <div class="message-avatar">
            <i :class="msg.role === 'user' ? 'fas fa-user' : 'fas fa-robot'"></i>
          </div>
          <div class="message-content">
            <div class="message-text">{{ msg.content }}</div>
            <div class="message-time">{{ msg.time }}</div>
          </div>
        </div>
        
        <div v-if="isLoading" class="chat-message assistant">
          <div class="message-avatar">
            <i class="fas fa-robot"></i>
          </div>
          <div class="message-content">
            <div class="message-text loading">
              <span class="dot"></span>
              <span class="dot"></span>
              <span class="dot"></span>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="ai-input-area">
      <textarea 
        v-model="questionInput" 
        class="ai-input" 
        placeholder="向AI助手提问关于课程内容的问题..."
        @keypress.enter.prevent="handleQuestionSubmit"
      ></textarea>
      <div class="ai-send">
        <button class="btn btn-primary" @click="handleQuestionSubmit" :disabled="!questionInput.trim()">
          <i class="fas fa-paper-plane"></i>
          发送
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch, nextTick } from 'vue'
import request from '@/utils/request'

export default {
  name: 'AIAssistant',
  props: {
    videoId: {
      type: Number,
      required: true
    },
    courseId: {
      type: Number,
      required: true
    }
  },
  emits: ['ask-question'],
  setup(props) {
    const questionInput = ref('')
    const chatMessages = ref([])
    const isLoading = ref(false)
    const chatHistory = ref(null)

    // 刷新对话
    const refreshTab = () => {
      chatMessages.value = []
    }

    // 滚动到底部
    const scrollToBottom = () => {
      nextTick(() => {
        if (chatHistory.value) {
          chatHistory.value.scrollTop = chatHistory.value.scrollHeight
        }
      })
    }

    // AI问答
    const handleQuestionSubmit = async () => {
      if (!questionInput.value.trim() || isLoading.value) return
      
      const userQuestion = questionInput.value.trim()
      
      // 添加用户消息
      chatMessages.value.push({
        role: 'user',
        content: userQuestion,
        time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
      })
      
      questionInput.value = ''
      scrollToBottom()
      
      isLoading.value = true
      
      try {
        // 调用DeepSeek API
        const response = await request.post('/deepseek/chat', {
          message: `作为一个课程学习助手，请回答以下关于课程的问题：${userQuestion}`
        })
        
        // 添加AI回复
        chatMessages.value.push({
          role: 'assistant',
          content: response.data.answer || '抱歉，我暂时无法回答这个问题。',
          time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
        })
        
        scrollToBottom()
      } catch (error) {
        console.error('AI回答失败:', error)
        chatMessages.value.push({
          role: 'assistant',
          content: '抱歉，服务暂时不可用，请稍后再试。',
          time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
        })
      } finally {
        isLoading.value = false
      }
    }

    // 监听视频ID变化
    watch(() => props.videoId, () => {
      chatMessages.value = []
    })

    return {
      questionInput,
      chatMessages,
      isLoading,
      chatHistory,
      refreshTab,
      handleQuestionSubmit
    }
  }
}
</script>

<style scoped>
.ai-section {
  background: white;
  border-top: 1px solid var(--border);
  display: flex;
  flex-direction: column;
  height: 800px;
}

.ai-header {
  padding: 15px 20px;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  gap: 10px;
}

.ai-header-actions {
  margin-left: auto;
}

.btn-icon {
  padding: 8px;
  width: 34px;
  height: 34px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.ai-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--primary), #6c8ef5);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1rem;
}

.ai-content {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.chat-history {
  flex: 1;
  overflow-y: auto;
  padding: 15px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.empty-chat {
  text-align: center;
  padding: 60px 20px;
  color: var(--gray);
}

.empty-chat i {
  font-size: 3rem;
  margin-bottom: 15px;
  color: var(--primary);
  opacity: 0.6;
}

.empty-chat p {
  font-size: 1rem;
  margin: 5px 0;
}

.empty-chat .hint {
  font-size: 0.85rem;
  color: var(--text-secondary);
}

.chat-message {
  display: flex;
  gap: 10px;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.chat-message.user {
  flex-direction: row-reverse;
}

.message-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: var(--primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.chat-message.user .message-avatar {
  background: var(--secondary);
}

.message-content {
  flex: 1;
  max-width: 70%;
}

.chat-message.user .message-content {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.message-text {
  background: var(--light);
  padding: 10px 14px;
  border-radius: 12px;
  font-size: 0.9rem;
  line-height: 1.5;
  word-wrap: break-word;
}

.chat-message.user .message-text {
  background: var(--primary);
  color: white;
}

.message-text.loading {
  display: flex;
  gap: 5px;
  padding: 15px 20px;
}

.message-text.loading .dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--gray);
  animation: bounce 1.4s infinite ease-in-out both;
}

.message-text.loading .dot:nth-child(1) {
  animation-delay: -0.32s;
}

.message-text.loading .dot:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

.message-time {
  font-size: 0.7rem;
  color: var(--gray);
  margin-top: 4px;
  padding: 0 4px;
}

.ai-input-area {
  padding: 12px 15px;
  border-top: 1px solid var(--border);
  display: flex;
  gap: 10px;
  align-items: center;
}

.ai-input {
  flex: 1;
  padding: 10px 12px;
  border: 1px solid var(--border);
  border-radius: 10px;
  font-size: 0.9rem;
  resize: none;
  height: 50px;
  font-family: inherit;
}

.ai-input:focus {
  outline: none;
  border-color: var(--primary);
}

.btn {
  padding: 8px 14px;
  border: none;
  border-radius: 6px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 5px;
}
.ai-send {
  display: flex;
  align-items: center;
}

.ai-send .btn {
  height: 40px;
  border-radius: 10px;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background: var(--primary);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #0d5bb9;
}

.btn-secondary {
  background: var(--light);
  color: var(--dark);
  border: 1px solid var(--border);
}

.btn-secondary:hover:not(:disabled) {
  background: var(--primary-light);
}
</style>