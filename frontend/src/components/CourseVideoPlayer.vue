<template>
  <div class="video-section">
    <div class="video-container">
      <div class="video-player" :style="{ background: videoBackground }">
        <video 
          v-if="effectiveVideoUrl"
          ref="videoPlayer"
          :key="videoKey" 
          preload="metadata"
          @timeupdate="handleTimeUpdate"
          @loadedmetadata="handleVideoLoaded"
          @play="handlePlay"
          @pause="handlePause"
          @ended="handleVideoEnd"
          @seeking="handleSeeking"
          @ratechange="handleRateChange"
          @error="handleVideoError"
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
        
        <div v-if="!isPlaying && effectiveVideoUrl && !loading && !videoError" class="video-overlay" @click="togglePlay">
          <button class="play-btn">
            <i class="fas fa-play"></i>
          </button>
        </div>
      </div>
    </div>
    
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
      
      <div class="progress-bar" @click="handleProgressClick">
        <div class="progress-fill" :style="{ width: progressPercentage + '%' }"></div>
      </div>
      
      <div class="time-display">{{ currentTimeFormatted }} / {{ durationFormatted }}</div>
      
      <button class="control-btn" @click="toggleMute">
        <i :class="isMuted ? 'fas fa-volume-mute' : 'fas fa-volume-up'"></i>
      </button>
      
      <div class="speed-control">
        <select v-model="playbackRate" @change="handleSpeedChange" class="speed-select">
          <option value="0.5">0.5x</option>
          <option value="0.75">0.75x</option>
          <option value="1">1x</option>
          <option value="1.25">1.25x</option>
          <option value="1.5">1.5x</option>
          <option value="2">2x</option>
        </select>
      </div>
      
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
import { recordLearningBehavior } from '@/api/courseVideo'

export default {
  name: 'CourseVideoPlayer',
  props: {
    video: {
      type: Object,
      default: () => ({})
    },
    videoUrl: {
      type: String,
      default: ''
    }
  },
  emits: ['progress-update', 'behavior-record'],
  setup(props, { emit }) {
    const videoPlayer = ref(null)
    const isPlaying = ref(false)
    const isMuted = ref(false)
    const currentTime = ref(0)
    const duration = ref(0)
    const progressPercentage = ref(0)
    const playbackRate = ref(1)
    const lastProgressUpdate = ref(0)
    const loading = ref(false)
    const videoError = ref('')
    const videoKey = ref(0) // 用于强制重新渲染video元素

    // 计算有效的视频URL - 修复URL处理逻辑
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
      videoKey.value++ // 强制重新渲染video元素
      
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
          await recordBehavior('pause')
        } else {
          await videoPlayer.value.play()
          await recordBehavior('play')
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
      recordBehavior('seek')
    }

    const skipForward = () => {
      if (!videoPlayer.value) return
      videoPlayer.value.currentTime = Math.min(duration.value, videoPlayer.value.currentTime + 10)
      recordBehavior('seek')
    }

    const handleTimeUpdate = () => {
      if (!videoPlayer.value) return
      currentTime.value = videoPlayer.value.currentTime
      progressPercentage.value = (currentTime.value / duration.value) * 100
      
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
      console.log('视频加载完成，时长:', duration.value)
    }

    const handleVideoEnd = async () => {
      isPlaying.value = false
      emit('progress-update', 100)
      await recordBehavior('complete')
    }

    const handleProgressClick = (event) => {
      if (!videoPlayer.value) return
      const progressBar = event.currentTarget
      const rect = progressBar.getBoundingClientRect()
      const clickPosition = (event.clientX - rect.left) / progressBar.offsetWidth
      videoPlayer.value.currentTime = clickPosition * duration.value
      recordBehavior('seek')
    }

    const handleSpeedChange = () => {
      if (!videoPlayer.value) return
      videoPlayer.value.playbackRate = parseFloat(playbackRate.value)
      recordBehavior('speed_change', { playSpeed: playbackRate.value })
    }

    const handleSeeking = () => {
      recordBehavior('seek')
    }

    const handleRateChange = () => {
      if (!videoPlayer.value) return
      playbackRate.value = videoPlayer.value.playbackRate
    }

    const toggleFullscreen = () => {
      if (!videoPlayer.value) return
      
      if (!document.fullscreenElement) {
        videoPlayer.value.requestFullscreen?.()
      } else {
        document.exitFullscreen?.()
      }
    }

    // 记录学习行为
    const recordBehavior = async (behaviorType, extraData = {}) => {
      try {
        await recordLearningBehavior({
          videoId: props.video?.video_id,
          behaviorType,
          currentTime: currentTime.value,
          duration: duration.value,
          playSpeed: playbackRate.value,
          timestamp: new Date().toISOString(),
          ...extraData
        })
        
        emit('behavior-record', {
          behaviorType,
          currentTime: currentTime.value,
          duration: duration.value,
          playSpeed: playbackRate.value
        })
      } catch (error) {
        console.error('记录学习行为失败:', error)
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
        videoKey.value++ // 强制重新渲染
      }
    })

    return {
      videoPlayer,
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
      handleSpeedChange,
      handleSeeking,
      handleRateChange,
      toggleFullscreen,
      handlePlay,
      handlePause,
      handleVideoError,
      retryLoad
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
}

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
}

.control-btn:hover {
  background: rgba(255,255,255,0.1);
}

.progress-bar {
  flex: 1;
  height: 6px;
  background: rgba(255,255,255,0.3);
  border-radius: 3px;
  position: relative;
  cursor: pointer;
}

.progress-fill {
  position: absolute;
  height: 100%;
  background: var(--primary);
  border-radius: 3px;
  transition: width 0.1s ease;
}

.time-display {
  color: white;
  font-size: 0.9rem;
  min-width: 100px;
  text-align: center;
}

.speed-control {
  position: relative;
}

.speed-select {
  background: rgba(255,255,255,0.1);
  border: 1px solid rgba(255,255,255,0.3);
  color: white;
  padding: 6px 10px;
  border-radius: 4px;
  font-size: 0.8rem;
  cursor: pointer;
}

.speed-select:focus {
  outline: none;
  border-color: var(--primary);
}
</style>