<template>
  <div class="video-section">
    <div class="video-container">
      <div class="video-player" :style="{ background: videoBackground }">
        <video 
          v-if="effectiveVideoUrl"
          ref="videoPlayer"
          :key="videoKey" 
          preload="metadata"
          playsinline
          webkit-playsinline
          x5-playsinline
          disablePictureInPicture
          controlslist="nodownload noplaybackrate noremoteplayback"
          @contextmenu.prevent
          @timeupdate="handleTimeUpdate"
          @loadedmetadata="handleVideoLoaded"
          @play="handlePlay"
          @pause="handlePause"
          @ended="handleVideoEnd"
          @seeking="handleSeeking"
          @ratechange="handleRateChangeEvent"
          @error="handleVideoError"
          @click="togglePlay"
        >
          <source :src="effectiveVideoUrl" type="video/mp4">
          <source :src="effectiveVideoUrl" type="video/webm">
          <source :src="effectiveVideoUrl" type="video/ogg">
          您的浏览器不支持HTML5视频播放。
        </video>
        
        <div v-if="loading" class="video-loading">
          <div class="loading-spinner"></div>
          <p>视频加载中...</p>
        </div>
        
        <div v-if="videoError" class="video-error">
          <i class="fas fa-exclamation-triangle"></i>
          <p>视频加载失败</p>
          <p class="error-detail">{{ videoError }}</p>
          <button class="retry-btn" @click="retryLoad">重试</button>
        </div>
        
        <!-- 自定义播放控制覆盖层 -->
        <div v-if="!isPlaying && effectiveVideoUrl && !loading && !videoError" 
             class="video-overlay" 
             @click="togglePlay">
          <button class="play-btn">
            <i class="fas fa-play"></i>
          </button>
        </div>
      </div>
    </div>
    
    <!-- 自定义控制条 -->
    <div class="video-controls" v-if="effectiveVideoUrl && !videoError">
      <button class="control-btn" @click="togglePlay">
        <i :class="isPlaying ? 'fas fa-pause' : 'fas fa-play'"></i>
      </button>
      
      <button class="control-btn" @click="skipBackward">
        <i class="fas fa-step-backward"></i>
      </button>
      
      <button class="control-btn" @click="skipForward">
        <i class="fas fa-step-forward"></i>
      </button>
      
      <!-- 进度条 -->
      <div class="progress-container">
        <div class="time-display">{{ currentTimeFormatted }}</div>
        
        <div class="progress-bar" @click="handleProgressClick" ref="progressBar">
          <div class="progress-background"></div>
          <div class="progress-fill" :style="{ width: progressPercentage + '%' }"></div>
          <div class="progress-thumb" 
               :style="{ left: progressPercentage + '%' }"
               @mousedown="startDrag"
               @touchstart="startDrag">
          </div>
        </div>
        
        <div class="time-display">{{ durationFormatted }}</div>
      </div>
      
      <button class="control-btn" @click="toggleMute">
        <i :class="isMuted ? 'fas fa-volume-mute' : 'fas fa-volume-up'"></i>
      </button>
      
      <button class="control-btn" @click="toggleFullscreen">
        <i class="fas fa-expand"></i>
      </button>
    </div>
    
    <div v-if="!effectiveVideoUrl && !loading" class="video-unavailable">
      <i class="fas fa-video-slash"></i>
      <p>视频暂不可用</p>
      <p class="video-url-debug">视频URL: {{ videoUrl }}</p>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import courseApi from '@/api/courses'

export default {
  name: 'CourseVideoPlayer',
  props: {
    videoUrl: {
      type: String,
      default: ''
    },
    initialProgress: {
      type: Number,
      default: 0
    },
    videoId: {  // 添加videoId属性
      type: Number,
      required: true
    },
    courseId: {  // 添加courseId属性
      type: Number,
      required: true
    }
  },
  emits: ['progress-update', 'behavior-record'],
  setup(props, { emit }) {
    const videoPlayer = ref(null)
    const progressBar = ref(null)
    const isPlaying = ref(false)
    const isMuted = ref(false)
    const currentTime = ref(0)
    const duration = ref(0)
    const progressPercentage = ref(0)
    const playbackRate = ref(1)
    const lastProgressUpdate = ref(0)
    const loading = ref(false)
    const videoError = ref('')
    const videoKey = ref(0)
    const isDragging = ref(false)
    const lastSpeed = ref(1)
    const suppressRecord = ref(false)

    // 计算有效的视频URL
    const effectiveVideoUrl = computed(() => {
      if (!props.videoUrl) {
        console.log('视频URL为空')
        return ''
      }
      
      console.log('原始视频URL:', props.videoUrl)
      
      // 处理本地视频路径
      if (props.videoUrl.startsWith('/videos/')) {
        const localUrl = props.videoUrl
        console.log('使用本地视频路径:', localUrl)
        return localUrl
      }
      
      // 处理完整URL
      if (props.videoUrl.startsWith('http')) {
        console.log('使用完整视频URL:', props.videoUrl)
        return props.videoUrl
      }
      
      console.log('无法识别的视频URL格式:', props.videoUrl)
      return ''
    })

    // 计算属性
    const videoBackground = computed(() => {
      return 'linear-gradient(135deg, #1a1a2e, #16213e)'
    })

    const currentTimeFormatted = computed(() => {
      return formatTime(currentTime.value)
    })

    const durationFormatted = computed(() => {
      return formatTime(duration.value)
    })

    // 时间格式化
    const formatTime = (seconds) => {
      if (!seconds || isNaN(seconds)) return '00:00'
      const mins = Math.floor(seconds / 60)
      const secs = Math.floor(seconds % 60)
      return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
    }

    // 视频错误处理
    const handleVideoError = (event) => {
      console.error('视频加载错误:', event)
      const video = event.target
      loading.value = false
      
      switch(video.error.code) {
        case video.error.MEDIA_ERR_ABORTED:
          videoError.value = '视频加载被中止'
          break
        case video.error.MEDIA_ERR_NETWORK:
          videoError.value = '网络错误，请检查网络连接'
          break
        case video.error.MEDIA_ERR_DECODE:
          videoError.value = '视频格式不支持或文件损坏'
          break
        case video.error.MEDIA_ERR_SRC_NOT_SUPPORTED:
          videoError.value = '视频格式不支持，请尝试其他格式'
          break
        default:
          videoError.value = '视频加载失败'
      }
      
      isPlaying.value = false
    }

    // 重试加载
    const retryLoad = async () => {
      videoError.value = ''
      loading.value = true
      videoKey.value++
      
      await nextTick()
      
      if (videoPlayer.value) {
        videoPlayer.value.load()
      }
    }

    // 视频控制方法
    const togglePlay = async () => {
      if (!videoPlayer.value || !effectiveVideoUrl.value || videoError.value) {
        console.log('无法播放: 视频元素或URL无效')
        return
      }
      
      try {
        if (isPlaying.value) {
          videoPlayer.value.pause()
        } else {
          await videoPlayer.value.play()
        }
      } catch (error) {
        console.error('播放控制失败:', error)
        videoError.value = '播放失败: ' + error.message
      }
    }

    const handlePlay = () => {
      isPlaying.value = true
      loading.value = false
      console.log('视频开始播放')
    }

    const handlePause = () => {
      isPlaying.value = false
      console.log('视频暂停')
    }

    const toggleMute = () => {
      if (!videoPlayer.value) return
      videoPlayer.value.muted = !videoPlayer.value.muted
      isMuted.value = videoPlayer.value.muted
    }

    const skipBackward = () => {
      if (!videoPlayer.value) return
      videoPlayer.value.currentTime = Math.max(0, videoPlayer.value.currentTime - 10)
    }

    const skipForward = () => {
      if (!videoPlayer.value) return
      videoPlayer.value.currentTime = Math.min(duration.value, videoPlayer.value.currentTime + 10)
    }

    const handleTimeUpdate = () => {
      if (!videoPlayer.value || isDragging.value) return
      
      currentTime.value = videoPlayer.value.currentTime
      
      if (duration.value > 0) {
        progressPercentage.value = (currentTime.value / duration.value) * 100
      }
      
      // 每5秒上报一次进度，避免频繁请求
      const currentSeconds = Math.floor(currentTime.value)
      if (currentSeconds > 0 && currentSeconds % 5 === 0 && currentSeconds !== lastProgressUpdate.value) {
        lastProgressUpdate.value = currentSeconds
        emit('progress-update', progressPercentage.value)
      }
    }

    const handleVideoLoaded = () => {
      if (!videoPlayer.value) return
      duration.value = videoPlayer.value.duration
      loading.value = false
      
      // 设置初始进度
      if (props.initialProgress > 0 && duration.value > 0) {
        const targetTime = (props.initialProgress / 100) * duration.value
        videoPlayer.value.currentTime = targetTime
        currentTime.value = targetTime
        progressPercentage.value = props.initialProgress
      }
      
      console.log('视频加载完成，时长:', duration.value)
    }

    const handleVideoEnd = () => {
      isPlaying.value = false
      progressPercentage.value = 100
      emit('progress-update', 100)
    }

    // 进度条点击跳转
    const handleProgressClick = (event) => {
      if (!videoPlayer.value || !progressBar.value) return
      
      const rect = progressBar.value.getBoundingClientRect()
      const clickPosition = (event.clientX - rect.left) / progressBar.value.offsetWidth
      const newTime = clickPosition * duration.value
      
      videoPlayer.value.currentTime = newTime
      currentTime.value = newTime
      progressPercentage.value = clickPosition * 100
    }

    // 进度条拖拽功能
    const startDrag = (event) => {
      isDragging.value = true
      event.preventDefault()
      
      const handleDrag = (moveEvent) => {
        if (!videoPlayer.value || !progressBar.value || !isDragging.value) return
        
        const rect = progressBar.value.getBoundingClientRect()
        const clientX = moveEvent.clientX || (moveEvent.touches && moveEvent.touches[0].clientX)
        if (!clientX) return
        
        let position = (clientX - rect.left) / progressBar.value.offsetWidth
        position = Math.max(0, Math.min(1, position))
        
        progressPercentage.value = position * 100
      }
      
      const stopDrag = () => {
        if (!videoPlayer.value || !isDragging.value) return
        
        const newTime = (progressPercentage.value / 100) * duration.value
        videoPlayer.value.currentTime = newTime
        currentTime.value = newTime
        
        isDragging.value = false
        document.removeEventListener('mousemove', handleDrag)
        document.removeEventListener('touchmove', handleDrag)
        document.removeEventListener('mouseup', stopDrag)
        document.removeEventListener('touchend', stopDrag)
      }
      
      document.addEventListener('mousemove', handleDrag)
      document.addEventListener('touchmove', handleDrag, { passive: false })
      document.addEventListener('mouseup', stopDrag)
      document.addEventListener('touchend', stopDrag)
    }

    const handleSpeedChange = async () => {
      if (!videoPlayer.value) return
      
      const newSpeed = parseFloat(playbackRate.value)
      videoPlayer.value.playbackRate = newSpeed
      
      console.log(`🎚️ 倍速改变: ${newSpeed}x`)
      
      // 记录倍速行为
      try {
        const behaviorData = {
          videoId: props.videoId,
          courseId: props.courseId,
          behaviorType: 'speed_change',
          playSpeed: newSpeed,
          currentTime: Math.floor(currentTime.value),
          duration: Math.floor(duration.value),
          progress: Math.floor(progressPercentage.value)
        }
        
        // 发送到API
        await courseApi.recordLearningBehavior(behaviorData)
        console.log('✅ 倍速记录已发送到服务器')
        
        // 触发事件
        emit('behavior-record', {
          type: 'speed_change',
          speed: newSpeed,
          timestamp: new Date().toISOString()
        })
        
      } catch (error) {
        console.error('❌ 记录倍速数据失败:', error)
      }
    }

    const handleSeeking = () => {
      console.log('视频跳转中...')
    }

    const handleRateChangeEvent = async () => {
      if (!videoPlayer.value) return
      
      const newSpeed = videoPlayer.value.playbackRate
      playbackRate.value = newSpeed
      
      console.log(`🎚️ 检测到倍速变化: ${newSpeed}x`)
      
      // 若是外部触发（父组件调用），避免在子组件重复埋点
      if (suppressRecord.value) {
        lastSpeed.value = newSpeed
        return
      }

      // 避免重复记录
      if (lastSpeed.value !== newSpeed) {
        lastSpeed.value = newSpeed
        
        // 记录倍速行为
        try {
          const behaviorData = {
            videoId: props.videoId,
            courseId: props.courseId,
            behaviorType: 'speed_change',
            playSpeed: newSpeed,
            currentTime: Math.floor(currentTime.value),
            duration: Math.floor(duration.value),
            progress: Math.floor(progressPercentage.value)
          }
          
          await courseApi.recordLearningBehavior(behaviorData)
          console.log('✅ 自动倍速记录已发送')
          
        } catch (error) {
          console.error('❌ 自动记录倍速失败:', error)
        }
      }
    }

    // 提供给父组件调用：只改变实际播放速度与本地UI，不做埋点
    const setPlaybackSpeed = (speed) => {
      const s = parseFloat(speed)
      if (Number.isNaN(s) || s <= 0) return
      suppressRecord.value = true
      playbackRate.value = s
      if (videoPlayer.value) {
        try { videoPlayer.value.playbackRate = s } catch (e) { /* noop */ }
      }
      lastSpeed.value = s
      // 微任务后恢复，避免触发的 ratechange 被记录
      Promise.resolve().then(() => { suppressRecord.value = false })
    }

    const toggleFullscreen = () => {
      if (!videoPlayer.value) return
      
      if (!document.fullscreenElement) {
        videoPlayer.value.requestFullscreen?.()
      } else {
        document.exitFullscreen?.()
      }
    }

    // 键盘快捷键
    const handleKeyPress = (event) => {
      if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') return
      
      switch(event.key) {
        case ' ':
          event.preventDefault()
          togglePlay()
          break
        case 'ArrowLeft':
          event.preventDefault()
          skipBackward()
          break
        case 'ArrowRight':
          event.preventDefault()
          skipForward()
          break
        case 'm':
          event.preventDefault()
          toggleMute()
          break
        case 'f':
          event.preventDefault()
          toggleFullscreen()
          break
      }
    }

    onMounted(() => {
      document.addEventListener('keydown', handleKeyPress)
      console.log('视频播放器已挂载，URL:', effectiveVideoUrl.value)
      
      // 开始加载视频
      if (effectiveVideoUrl.value) {
        loading.value = true
      }

      lastSpeed.value = videoPlayer.value?.playbackRate || 1
    })

    onUnmounted(() => {
      document.removeEventListener('keydown', handleKeyPress)
    })

    // 监听视频变化
    watch(() => props.videoUrl, (newUrl) => {
      console.log('视频URL变化:', newUrl)
      loading.value = true
      videoError.value = ''
      
      if (videoPlayer.value) {
        // 重置播放器状态
        isPlaying.value = false
        currentTime.value = 0
        progressPercentage.value = 0
        lastProgressUpdate.value = 0
        videoKey.value++
      }
    })

    // 监听初始进度变化
    watch(() => props.initialProgress, (newProgress) => {
      if (videoPlayer.value && duration.value > 0 && newProgress > 0) {
        const targetTime = (newProgress / 100) * duration.value
        videoPlayer.value.currentTime = targetTime
        currentTime.value = targetTime
        progressPercentage.value = newProgress
      }
    })

    return {
      videoPlayer,
      progressBar,
      isPlaying,
      isMuted,
      currentTime,
      duration,
      progressPercentage,
      playbackRate,
      effectiveVideoUrl,
      videoBackground,
      currentTimeFormatted,
      durationFormatted,
      loading,
      videoError,
      videoKey,
      togglePlay,
      toggleMute,
      skipBackward,
      skipForward,
      handleTimeUpdate,
      handleVideoLoaded,
      handleVideoEnd,
      handleProgressClick,
      startDrag,
      handleSpeedChange,
      handleSeeking,
      handleRateChange: handleRateChangeEvent,
      toggleFullscreen,
      handlePlay,
      handlePause,
      handleVideoError,
      retryLoad,
      lastSpeed,
      setPlaybackSpeed
    }
  }
}
</script>

<style scoped>
.video-section {
  background: #000;
  position: relative;
  display: flex;
  flex-direction: column;
  flex: 1;
}

.video-container {
  flex: 1;
  background: #000;
  display: flex;
  align-items: stretch;
}

.video-player {
  width: 100%;
  background: linear-gradient(135deg, #1a1a2e, #16213e);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  position: relative;
  min-height: 400px;
}

.video-player video {
  width: 100%;
  height: 100%;
  object-fit: contain;
  max-height: 70vh;
  cursor: pointer;
}

/* 强制隐藏各浏览器可能出现的原生视频控件 */
.video-player :deep(video::-webkit-media-controls-enclosure) { display: none !important; }
.video-player :deep(video::-webkit-media-controls) { display: none !important; }
.video-player :deep(video::-webkit-media-controls-panel) { display: none !important; }
.video-player :deep(video::-webkit-media-controls-play-button) { display: none !important; }
.video-player :deep(video::-webkit-media-controls-timeline) { display: none !important; }
.video-player :deep(video::-webkit-media-controls-volume-slider) { display: none !important; }
.video-player :deep(video::-webkit-media-controls-fullscreen-button) { display: none !important; }
.video-player :deep(video::-webkit-media-controls-mute-button) { display: none !important; }

.video-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
  color: white;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid rgba(255,255,255,0.3);
  border-top: 4px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.video-error {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 15px;
  color: white;
  text-align: center;
  padding: 20px;
}

.video-error i {
  font-size: 3rem;
  color: #ff6b6b;
}

.error-detail {
  font-size: 0.9rem;
  opacity: 0.8;
}

.retry-btn {
  background: var(--primary);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background 0.3s ease;
}

.retry-btn:hover {
  background: #0d5bb9;
}

.video-unavailable {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 15px;
  color: white;
  height: 100%;
}

.video-unavailable i {
  font-size: 3rem;
  opacity: 0.5;
}

.video-url-debug {
  font-size: 0.8rem;
  opacity: 0.7;
  word-break: break-all;
  text-align: center;
  max-width: 90%;
}

.video-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0,0,0,0.3);
  cursor: pointer;
  transition: opacity 0.3s ease;
  z-index: 10;
}

.play-btn {
  background: rgba(255,255,255,0.2);
  border: none;
  color: white;
  width: 80px;
  height: 80px;
  border-radius: 50%;
  font-size: 2rem;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.play-btn:hover {
  background: rgba(255,255,255,0.3);
  transform: scale(1.1);
}

.video-controls {
  background: rgba(0,0,0,0.8);
  padding: 15px 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  z-index: 20;
}

.control-btn {
  background: none;
  border: none;
  color: white;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  transition: background 0.3s ease;
  flex-shrink: 0;
}

.control-btn:hover {
  background: rgba(255,255,255,0.1);
}

.progress-container {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.time-display {
  color: white;
  font-size: 0.9rem;
  min-width: 45px;
  text-align: center;
  flex-shrink: 0;
}

.progress-bar {
  flex: 1;
  height: 6px;
  background: rgba(255,255,255,0.3);
  border-radius: 3px;
  position: relative;
  cursor: pointer;
  min-width: 100px;
}

.progress-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255,255,255,0.3);
  border-radius: 3px;
}

.progress-fill {
  position: absolute;
  height: 100%;
  background: var(--primary);
  border-radius: 3px;
  transition: width 0.1s ease;
  z-index: 1;
}

.progress-thumb {
  position: absolute;
  width: 12px;
  height: 12px;
  background: white;
  border-radius: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  z-index: 2;
  cursor: pointer;
  transition: all 0.2s ease;
}

.progress-thumb:hover {
  transform: translate(-50%, -50%) scale(1.2);
}

/* 移除了内置倍速选择器，布局由播放/跳转/进度/音量/全屏构成 */

/* 响应式设计 */
@media (max-width: 768px) {
  .video-controls {
    padding: 10px 15px;
    gap: 10px;
  }
  
  .control-btn {
    font-size: 1rem;
    padding: 6px;
  }
  
  .time-display {
    font-size: 0.8rem;
    min-width: 40px;
  }
  
  .progress-container {
    gap: 8px;
  }
}
</style>