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
    
    <div class="ai-tabs">
      <div 
        class="ai-tab" 
        :class="{ active: activeTab === 'summary' }" 
        @click="switchTab('summary')"
      >
        智能总结
      </div>
      <div 
        class="ai-tab" 
        :class="{ active: activeTab === 'highlights' }" 
        @click="switchTab('highlights')"
      >
        重点标记
      </div>
      <div 
        class="ai-tab" 
        :class="{ active: activeTab === 'quiz' }" 
        @click="switchTab('quiz')"
      >
        即时测验
      </div>
    </div>
    
    <div class="ai-content">
      <!-- 智能总结 -->
      <div v-if="activeTab === 'summary'" class="ai-tab-content active">
        <div class="ai-column">
          <div class="ai-card">
            <h4>📝 内容摘要</h4>
            <p>{{ aiSummary.content_summary || '加载中...' }}</p>
          </div>
          <div class="ai-card">
            <h4>🎯 学习目标</h4>
            <p v-html="formatLearningObjectives(aiSummary.learning_objectives)"></p>
          </div>
        </div>
        <div class="ai-column">
          <div class="ai-card">
            <h4>💡 难点解析</h4>
            <p>{{ aiSummary.key_takeaways || '加载中...' }}</p>
          </div>
          <div class="ai-card">
            <h4>⚠️ 注意事项</h4>
            <p>函数可以返回多个值，实际上是返回一个元组。如果没有return语句，函数默认返回None。</p>
          </div>
        </div>
      </div>
      
      <!-- 重点标记 -->
      <div v-if="activeTab === 'highlights'" class="ai-tab-content">
        <div class="ai-column">
          <div class="ai-card">
            <h4>⏰ 关键时间点</h4>
            <ul class="highlight-list">
              <li v-for="highlight in aiHighlights" :key="highlight.highlight_id">
                <span class="highlight-time">{{ formatTime(highlight.timestamp_seconds) }}</span>
                <span>{{ highlight.description }}</span>
              </li>
            </ul>
          </div>
        </div>
        <div class="ai-column">
          <div class="ai-card">
            <h4>💻 代码示例</h4>
            <pre><code>def calculate_area(radius):
    pi = 3.14159
    area = pi * radius ** 2
    return area

result = calculate_area(5)
print(f"圆的面积: {result}")</code></pre>
          </div>
        </div>
      </div>
      
      <!-- 即时测验 -->
      <div v-if="activeTab === 'quiz'" class="ai-tab-content">
        <div class="ai-column">
          <div 
            v-for="quiz in aiQuizzes" 
            :key="quiz.quiz_id" 
            class="quiz-item"
            :class="{ answered: getQuizAnswer(quiz.quiz_id) }"
          >
            <div class="quiz-question">{{ quiz.question_text }}</div>
            <div class="quiz-options">
              <div 
                v-for="option in quiz.options" 
                :key="option.option_id"
                class="quiz-option"
                :class="{
                  selected: getSelectedOption(quiz.quiz_id) === option.option_id,
                  correct: showAnswers && option.is_correct,
                  incorrect: showAnswers && getSelectedOption(quiz.quiz_id) === option.option_id && !option.is_correct
                }"
                @click="selectOption(quiz.quiz_id, option.option_id, option.is_correct)"
              >
                {{ option.option_text }}
              </div>
            </div>
            <div v-if="showAnswers && getQuizAnswer(quiz.quiz_id)" class="quiz-feedback">
              {{ getQuizAnswer(quiz.quiz_id).isCorrect ? '✅ 回答正确！' : '❌ 回答错误，请再想想' }}
            </div>
          </div>
        </div>
        <div class="ai-column">
          <div class="ai-card">
            <h4>📊 测验统计</h4>
            <p>已完成: {{ completedQuizzes }}/{{ aiQuizzes.length }}</p>
            <p>正确率: {{ correctRate }}%</p>
            <button class="btn btn-primary" @click="checkAnswers" :disabled="completedQuizzes === 0">
              检查答案
            </button>
            <button class="btn btn-secondary" @click="resetQuiz">
              重新开始
            </button>
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
import { ref, onMounted, computed, watch } from 'vue'
import { getAISummary, getAIHighlights, getAIQuiz, submitAIQuestion } from '@/api/courseVideo'

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
    const activeTab = ref('summary')
    const aiSummary = ref({})
    const aiHighlights = ref([])
    const aiQuizzes = ref([])
    const questionInput = ref('')
    const quizAnswers = ref({})
    const showAnswers = ref(false)
    // 刷新当前标签内容
    const refreshTab = async () => {
      try {
        if (activeTab.value === 'summary') {
          aiSummary.value = {}
        } else if (activeTab.value === 'highlights') {
          aiHighlights.value = []
        } else if (activeTab.value === 'quiz') {
          aiQuizzes.value = []
          quizAnswers.value = {}
          showAnswers.value = false
        }
        await loadTabData(activeTab.value)
      } catch (error) {
        console.error('刷新内容失败:', error)
      }
    }

    // 计算属性
    const completedQuizzes = computed(() => {
      return Object.keys(quizAnswers.value).length
    })

    const correctRate = computed(() => {
      if (completedQuizzes.value === 0) return 0
      const correctCount = Object.values(quizAnswers.value).filter(answer => answer.isCorrect).length
      return Math.round((correctCount / completedQuizzes.value) * 100)
    })

    // 切换标签页
    const switchTab = (tabName) => {
      activeTab.value = tabName
      loadTabData(tabName)
    }

    // 加载标签页数据
    const loadTabData = async (tabName) => {
      try {
        switch (tabName) {
          case 'summary':
            if (Object.keys(aiSummary.value).length === 0) {
              const summaryRes = await getAISummary(props.videoId)
              aiSummary.value = summaryRes.data
            }
            break
          case 'highlights':
            if (aiHighlights.value.length === 0) {
              const highlightsRes = await getAIHighlights(props.videoId)
              aiHighlights.value = highlightsRes.data
            }
            break
          case 'quiz':
            if (aiQuizzes.value.length === 0) {
              const quizRes = await getAIQuiz(props.videoId)
              aiQuizzes.value = quizRes.data
            }
            break
        }
      } catch (error) {
        console.error(`加载${tabName}数据失败:`, error)
      }
    }

    // 格式化学习目标
    const formatLearningObjectives = (objectives) => {
      if (!objectives) return '加载中...'
      return objectives.split('\n').map(obj => `• ${obj}`).join('<br>')
    }

    // 格式化时间
    const formatTime = (seconds) => {
      const mins = Math.floor(seconds / 60)
      const secs = Math.floor(seconds % 60)
      return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
    }

    // 测验相关方法
    const selectOption = (quizId, optionId, isCorrect) => {
      if (showAnswers.value) return
      
      quizAnswers.value[quizId] = {
        selectedOption: optionId,
        isCorrect: isCorrect
      }
    }

    const getSelectedOption = (quizId) => {
      return quizAnswers.value[quizId]?.selectedOption
    }

    const getQuizAnswer = (quizId) => {
      return quizAnswers.value[quizId]
    }

    const checkAnswers = () => {
      showAnswers.value = true
    }

    const resetQuiz = () => {
      quizAnswers.value = {}
      showAnswers.value = false
    }

    // AI问答
    const handleQuestionSubmit = async () => {
      if (!questionInput.value.trim()) return
      
      try {
        const response = await submitAIQuestion({
          videoId: props.videoId,
          question: questionInput.value.trim()
        })
        
        // 显示AI回答
        alert(`AI助手回答：\n\n${response.data.answer}`)
        questionInput.value = ''
      } catch (error) {
        console.error('提交问题失败:', error)
        alert('提问失败，请稍后重试')
      }
    }

    const clearQuestion = () => {
      questionInput.value = ''
    }

    const handleKeyPress = (event) => {
      if (event.key === 'Enter' && event.ctrlKey) {
        handleQuestionSubmit()
      }
    }

    // 监听视频ID变化
    watch(() => props.videoId, (newVideoId) => {
      // 重置数据
      aiSummary.value = {}
      aiHighlights.value = []
      aiQuizzes.value = []
      quizAnswers.value = {}
      showAnswers.value = false
      questionInput.value = ''
      
      // 重新加载当前标签页数据
      loadTabData(activeTab.value)
    })

    onMounted(() => {
      loadTabData(activeTab.value)
    })

    return {
      activeTab,
      aiSummary,
      aiHighlights,
      aiQuizzes,
      questionInput,
      showAnswers,
      completedQuizzes,
      correctRate,
      switchTab,
      formatLearningObjectives,
      formatTime,
      selectOption,
      getSelectedOption,
      getQuizAnswer,
      checkAnswers,
      resetQuiz,
      handleQuestionSubmit,
      clearQuestion,
      refreshTab,
      handleKeyPress
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

.ai-tabs {
  display: flex;
  border-bottom: 1px solid var(--border);
}

.ai-tab {
  flex: 1;
  text-align: center;
  padding: 12px;
  cursor: pointer;
  border-bottom: 3px solid transparent;
  transition: all 0.3s ease;
  font-weight: 500;
  font-size: 0.9rem;
}

.ai-tab.active {
  border-bottom-color: var(--primary);
  color: var(--primary);
}

.ai-content {
  flex: 1;
  overflow-y: auto;
  padding: 15px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.ai-column {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.ai-card {
  background: var(--light);
  border-radius: 8px;
  padding: 15px;
  border-left: 3px solid var(--primary);
}

.ai-card h4 {
  margin-bottom: 8px;
  color: var(--primary);
  font-size: 0.95rem;
}

.ai-card p {
  line-height: 1.5;
  color: var(--dark);
  font-size: 0.85rem;
}

.highlight-list {
  list-style: none;
}

.highlight-list li {
  padding: 6px 0;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
}

.highlight-list li:last-child {
  border-bottom: none;
}

.highlight-time {
  background: var(--primary-light);
  color: var(--primary);
  padding: 3px 6px;
  border-radius: 10px;
  font-size: 0.75rem;
  font-weight: 500;
  min-width: 45px;
  text-align: center;
}

pre {
  background: #f6f8fa;
  padding: 10px;
  border-radius: 6px;
  font-size: 0.75rem;
  overflow-x: auto;
  margin: 0;
  line-height: 1.4;
}

code {
  font-family: 'Courier New', monospace;
  color: #24292e;
}

.quiz-item {
  background: white;
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.quiz-item:hover {
  border-color: var(--primary);
  box-shadow: 0 2px 6px rgba(26, 115, 232, 0.1);
}

.quiz-item.answered {
  border-color: var(--primary);
  background: var(--primary-light);
}

.quiz-question {
  font-weight: 500;
  margin-bottom: 8px;
  font-size: 0.9rem;
}

.quiz-options {
  display: grid;
  gap: 6px;
}

.quiz-option {
  padding: 6px 10px;
  border: 1px solid var(--border);
  border-radius: 4px;
  font-size: 0.8rem;
  transition: all 0.3s ease;
  cursor: pointer;
}

.quiz-option:hover {
  background: var(--primary-light);
  border-color: var(--primary);
}

.quiz-option.selected {
  background: var(--primary-light);
  border-color: var(--primary);
  color: var(--primary);
}

.quiz-option.correct {
  background: #e6f4ea;
  border-color: var(--secondary);
  color: var(--secondary);
}

.quiz-option.incorrect {
  background: #fce8e6;
  border-color: var(--danger);
  color: var(--danger);
}

.quiz-feedback {
  margin-top: 8px;
  padding: 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
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