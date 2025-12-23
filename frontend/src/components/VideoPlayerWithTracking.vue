<!-- 带埋点功能的视频播放器组件 -->
<template>
  <div class="video-player-container">
    <div class="video-wrapper">
      <video 
        ref="videoRef"
        :src="videoSrc"
        controls
        @loadedmetadata="onVideoLoaded"
        @play="onPlay"
        @pause="onPause"
        @ended="onEnded"
        @timeupdate="onTimeUpdate"
        @seeking="onSeeking"
        @seeked="onSeeked"
        @ratechange="onRateChange"
        class="video-element"
      >
        您的浏览器不支持视频播放
      </video>
      
      <!-- 自定义控制栏 -->
      <div class="custom-controls">
        <button @click="togglePlay" class="play-btn">
          <i :class="isPlaying ? 'fas fa-pause' : 'fas fa-play'"></i>
        </button>
        
        <div class="progress-container">
          <div class="progress-bar" @click="seekTo">
            <div class="progress-filled" :style="{ width: progressPercent + '%' }"></div>
          </div>
          <span class="time-display">{{ formatTime(currentTime) }} / {{ formatTime(duration) }}</span>
        </div>
        
        <div class="speed-controls">
          <select @change="changeSpeed" v-model="playbackRate">
            <option value="0.5">0.5x</option>
            <option value="0.75">0.75x</option>
            <option value="1">1x</option>
            <option value="1.25">1.25x</option>
            <option value="1.5">1.5x</option>
            <option value="2">2x</option>
          </select>
        </div>
        
        <button @click="addBookmark" class="bookmark-btn" title="添加书签">
          <i class="fas fa-bookmark"></i>
        </button>
        
        <button @click="toggleNotes" class="notes-btn" title="记笔记">
          <i class="fas fa-sticky-note"></i>
        </button>
      </div>
    </div>
    
    <!-- 笔记面板 -->
    <div v-if="showNotes" class="notes-panel">
      <div class="notes-header">
        <h4>学习笔记</h4>
        <button @click="toggleNotes" class="close-btn">
          <i class="fas fa-times"></i>
        </button>
      </div>
      <textarea 
        v-model="noteContent"
        @input="onNoteInput"
        placeholder="在这里记录你的学习笔记..."
        class="note-textarea"
      ></textarea>
      <div class="notes-actions">
        <button @click="saveNote" class="save-note-btn">保存笔记</button>
      </div>
    </div>
    
    <!-- 书签列表 -->
    <div v-if="bookmarks.length > 0" class="bookmarks-panel">
      <h4>我的书签</h4>
      <div class="bookmark-list">
        <div 
          v-for="bookmark in bookmarks" 
          :key="bookmark.id"
          @click="jumpToBookmark(bookmark.time)"
          class="bookmark-item"
        >
          <i class="fas fa-bookmark"></i>
          <span>{{ formatTime(bookmark.time) }}</span>
          <span class="bookmark-note">{{ bookmark.note || '无备注' }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import behaviorTracker from '../utils/behaviorTracker.js'

const props = defineProps({
  videoSrc: {
    type: String,
    required: true
  },
  courseId: {
    type: Number,
    required: true
  },
  chapterId: {
    type: Number,
    required: true
  }
})

// 视频相关状态
const videoRef = ref(null)
const isPlaying = ref(false)
const currentTime = ref(0)
const duration = ref(0)
const playbackRate = ref(1)
const progressPercent = ref(0)

// 埋点相关状态
const lastSeekTime = ref(0)
const sessionStartTime = ref(Date.now())
const totalPauseTime = ref(0)
const pauseStartTime = ref(0)
const actualWatchTime = ref(0) // 实际观看时间（秒）
const lastPlayTime = ref(0) // 上次播放时的时间点
const watchTimeTracker = ref(null) // 观看时间追踪定时器

// 笔记相关状态
const showNotes = ref(false)
const noteContent = ref('')
const noteInputTimer = ref(null)

// 书签相关状态
const bookmarks = ref([])

// 组件挂载时设置埋点上下文
onMounted(() => {
  behaviorTracker.setContext(props.courseId, props.chapterId)
  
  // 设置视频自动追踪
  if (videoRef.value) {
    behaviorTracker.setupVideoTracking(videoRef.value)
  }
  
  console.log('📹 视频播放器组件已挂载，开始行为追踪')
})

// 组件卸载时记录学习时长
onUnmounted(() => {
  // 停止观看时间追踪
  stopWatchTimeTracking()
  
  const totalTime = Date.now() - sessionStartTime.value
  
  // 记录最终的学习时长数据
  behaviorTracker.trackStudyDuration(actualWatchTime.value, totalTime)
  console.log('📊 学习会话结束')
  console.log('   实际观看时长:', Math.round(actualWatchTime.value), '秒')
  console.log('   会话总时长:', Math.round(totalTime / 1000), '秒')
  console.log('   学习效率:', Math.round((actualWatchTime.value / (totalTime / 1000)) * 100), '%')
})

// 开始追踪观看时间
function startWatchTimeTracking() {
  if (watchTimeTracker.value) {
    clearInterval(watchTimeTracker.value)
  }
  
  watchTimeTracker.value = setInterval(() => {
    if (isPlaying.value && videoRef.value) {
      const currentVideoTime = videoRef.value.currentTime
      const playbackRate = videoRef.value.playbackRate || 1
      
      // 计算实际观看时间增量（考虑播放速度）
      const timeDelta = 1 / playbackRate // 1秒实际时间对应的视频时间
      actualWatchTime.value += timeDelta
      
      // 每10秒记录一次进度
      if (Math.floor(actualWatchTime.value) % 10 === 0) {
        behaviorTracker.trackVideoProgress(currentVideoTime, duration.value, playbackRate)
      }
    }
  }, 1000) // 每秒更新一次
}

// 停止追踪观看时间
function stopWatchTimeTracking() {
  if (watchTimeTracker.value) {
    clearInterval(watchTimeTracker.value)
    watchTimeTracker.value = null
  }
  
  // 记录当前的观看进度
  if (videoRef.value) {
    behaviorTracker.trackVideoProgress(
      videoRef.value.currentTime, 
      duration.value, 
      videoRef.value.playbackRate || 1
    )
  }
}

// 视频事件处理
function onVideoLoaded() {
  duration.value = videoRef.value.duration
  console.log('📹 视频加载完成，时长:', duration.value)
}

function onPlay() {
  isPlaying.value = true
  lastPlayTime.value = currentTime.value
  
  // 记录暂停时长
  if (pauseStartTime.value > 0) {
    totalPauseTime.value += Date.now() - pauseStartTime.value
    pauseStartTime.value = 0
  }
  
  // 开始追踪观看时间
  startWatchTimeTracking()
  
  behaviorTracker.trackPlayStart({
    video_duration: duration.value,
    current_position: currentTime.value
  })
}

function onPause() {
  isPlaying.value = false
  pauseStartTime.value = Date.now()
  
  // 停止追踪观看时间并记录
  stopWatchTimeTracking()
  
  behaviorTracker.trackPause('user')
}

function onEnded() {
  isPlaying.value = false
  
  // 停止追踪观看时间并记录最终数据
  stopWatchTimeTracking()
  
  // 记录章节完成，包含实际观看时间
  behaviorTracker.trackChapterComplete(100)
  behaviorTracker.trackStudyDuration(actualWatchTime.value)
  
  console.log('🎉 视频播放完成，实际观看时长:', Math.round(actualWatchTime.value), '秒')
}

function onTimeUpdate() {
  if (videoRef.value) {
    currentTime.value = videoRef.value.currentTime
    progressPercent.value = (currentTime.value / duration.value) * 100
    
    // 更新埋点工具中的视频位置
    behaviorTracker.updateVideoPosition(Math.round(currentTime.value))
  }
}

function onSeeking() {
  lastSeekTime.value = currentTime.value
}

function onSeeked() {
  const newTime = videoRef.value.currentTime
  const timeDiff = Math.abs(newTime - lastSeekTime.value)
  
  // 只记录跳转超过3秒的行为
  if (timeDiff > 3) {
    if (newTime > lastSeekTime.value) {
      behaviorTracker.trackSeekForward(lastSeekTime.value, newTime)
    } else {
      behaviorTracker.trackSeekBackward(lastSeekTime.value, newTime)
    }
  }
}

function onRateChange() {
  const oldRate = playbackRate.value
  const newRate = videoRef.value.playbackRate
  
  if (oldRate !== newRate) {
    behaviorTracker.trackSpeedChange(oldRate, newRate)
    playbackRate.value = newRate
  }
}

// 控制功能
function togglePlay() {
  if (videoRef.value) {
    if (isPlaying.value) {
      videoRef.value.pause()
    } else {
      videoRef.value.play()
    }
  }
}

function seekTo(event) {
  if (videoRef.value && duration.value > 0) {
    const rect = event.target.getBoundingClientRect()
    const percent = (event.clientX - rect.left) / rect.width
    const newTime = percent * duration.value
    
    videoRef.value.currentTime = newTime
  }
}

function changeSpeed() {
  if (videoRef.value) {
    videoRef.value.playbackRate = parseFloat(playbackRate.value)
  }
}

// 书签功能
function addBookmark() {
  const bookmark = {
    id: Date.now(),
    time: currentTime.value,
    note: `书签 ${bookmarks.value.length + 1}`,
    timestamp: new Date().toLocaleString()
  }
  
  bookmarks.value.push(bookmark)
  behaviorTracker.trackBookmark()
  
  console.log('🔖 添加书签:', bookmark)
}

function jumpToBookmark(time) {
  if (videoRef.value) {
    videoRef.value.currentTime = time
    behaviorTracker.trackSeekForward(currentTime.value, time)
  }
}

// 笔记功能
function toggleNotes() {
  showNotes.value = !showNotes.value
  
  if (showNotes.value) {
    behaviorTracker.trackBehavior('note_panel_open', {
      video_position: currentTime.value
    })
  }
}

function onNoteInput() {
  // 防抖处理，避免频繁记录
  if (noteInputTimer.value) {
    clearTimeout(noteInputTimer.value)
  }
  
  noteInputTimer.value = setTimeout(() => {
    if (noteContent.value.trim().length > 0) {
      behaviorTracker.trackNoteTaking(noteContent.value, 'text')
    }
  }, 2000) // 2秒后记录
}

function saveNote() {
  if (noteContent.value.trim().length > 0) {
    behaviorTracker.trackNoteTaking(noteContent.value, 'saved')
    
    // 这里可以调用API保存笔记到服务器
    console.log('💾 保存笔记:', noteContent.value)
    
    // 清空笔记内容
    noteContent.value = ''
    showNotes.value = false
  }
}

// 时间格式化
function formatTime(seconds) {
  if (!seconds || isNaN(seconds)) return '00:00'
  
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
}
</script>

<style scoped>
.video-player-container {
  max-width: 800px;
  margin: 0 auto;
  background: #000;
  border-radius: 8px;
  overflow: hidden;
}

.video-wrapper {
  position: relative;
}

.video-element {
  width: 100%;
  height: auto;
  display: block;
}

.custom-controls {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0,0,0,0.8));
  padding: 20px 15px 15px;
  display: flex;
  align-items: center;
  gap: 15px;
  color: white;
}

.play-btn {
  background: none;
  border: none;
  color: white;
  font-size: 18px;
  cursor: pointer;
  padding: 8px;
  border-radius: 4px;
  transition: background 0.3s;
}

.play-btn:hover {
  background: rgba(255,255,255,0.2);
}

.progress-container {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10px;
}

.progress-bar {
  flex: 1;
  height: 4px;
  background: rgba(255,255,255,0.3);
  border-radius: 2px;
  cursor: pointer;
  position: relative;
}

.progress-filled {
  height: 100%;
  background: #4a6cf7;
  border-radius: 2px;
  transition: width 0.1s;
}

.time-display {
  font-size: 12px;
  white-space: nowrap;
}

.speed-controls select {
  background: rgba(255,255,255,0.2);
  border: none;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.bookmark-btn, .notes-btn {
  background: none;
  border: none;
  color: white;
  font-size: 16px;
  cursor: pointer;
  padding: 8px;
  border-radius: 4px;
  transition: background 0.3s;
}

.bookmark-btn:hover, .notes-btn:hover {
  background: rgba(255,255,255,0.2);
}

.notes-panel {
  background: white;
  padding: 20px;
  border-top: 1px solid #eee;
}

.notes-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.notes-header h4 {
  margin: 0;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  color: #666;
}

.note-textarea {
  width: 100%;
  height: 120px;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 10px;
  font-size: 14px;
  resize: vertical;
}

.notes-actions {
  margin-top: 10px;
  text-align: right;
}

.save-note-btn {
  background: #4a6cf7;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.save-note-btn:hover {
  background: #3a5ce7;
}

.bookmarks-panel {
  background: #f8f9fa;
  padding: 15px;
  border-top: 1px solid #eee;
}

.bookmarks-panel h4 {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 16px;
}

.bookmark-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.bookmark-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 12px;
  background: white;
  border-radius: 4px;
  cursor: pointer;
  transition: background 0.3s;
}

.bookmark-item:hover {
  background: #e9ecef;
}

.bookmark-item i {
  color: #4a6cf7;
}

.bookmark-note {
  color: #666;
  font-size: 12px;
  flex: 1;
}

@media (max-width: 768px) {
  .custom-controls {
    padding: 15px 10px 10px;
    gap: 10px;
  }
  
  .time-display {
    font-size: 10px;
  }
  
  .notes-panel {
    padding: 15px;
  }
}
</style>