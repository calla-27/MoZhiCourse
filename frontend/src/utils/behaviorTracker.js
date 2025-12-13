// 学习行为埋点工具
import { apiRecordBehavior, apiRecordBehaviors } from '../api/teacher.js'

class BehaviorTracker {
  constructor() {
    this.behaviorQueue = [] // 行为队列
    this.batchSize = 10 // 批量上传大小
    this.uploadInterval = 30000 // 30秒上传一次
    this.currentCourse = null
    this.currentChapter = null
    this.currentVideoPosition = 0
    this.sessionStartTime = Date.now()
    this.lastActivityTime = Date.now()
    
    // 启动定时上传
    this.startBatchUpload()
    
    // 页面卸载时上传剩余数据
    window.addEventListener('beforeunload', () => {
      this.flushQueue()
    })
  }

  // 设置当前学习上下文
  setContext(courseId, chapterId = null) {
    this.currentCourse = courseId
    this.currentChapter = chapterId
    console.log('📍 设置学习上下文:', { courseId, chapterId })
  }

  // 更新视频位置
  updateVideoPosition(position) {
    this.currentVideoPosition = position
    this.lastActivityTime = Date.now()
  }

  // 记录学习行为
  async trackBehavior(behaviorType, behaviorData = {}, duration = 0) {
    const behavior = {
      course_id: this.currentCourse,
      chapter_id: this.currentChapter,
      behavior_type: behaviorType,
      behavior_data: {
        ...behaviorData,
        timestamp: Date.now(),
        session_id: this.getSessionId(),
        user_agent: navigator.userAgent
      },
      duration,
      video_position: this.currentVideoPosition
    }

    // 添加到队列
    this.behaviorQueue.push(behavior)
    console.log('📊 记录学习行为:', behaviorType, behavior)

    // 如果队列满了，立即上传
    if (this.behaviorQueue.length >= this.batchSize) {
      await this.flushQueue()
    }
  }

  // 获取会话ID
  getSessionId() {
    let sessionId = sessionStorage.getItem('learning_session_id')
    if (!sessionId) {
      sessionId = 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9)
      sessionStorage.setItem('learning_session_id', sessionId)
    }
    return sessionId
  }

  // 启动批量上传
  startBatchUpload() {
    setInterval(() => {
      if (this.behaviorQueue.length > 0) {
        this.flushQueue()
      }
    }, this.uploadInterval)
  }

  // 上传队列中的所有行为
  async flushQueue() {
    if (this.behaviorQueue.length === 0) return

    const behaviors = [...this.behaviorQueue]
    this.behaviorQueue = []

    try {
      const result = await apiRecordBehaviors(behaviors)
      if (result.success) {
        console.log('✅ 批量上传学习行为成功:', behaviors.length, '条')
      } else {
        console.error('❌ 批量上传学习行为失败:', result.message)
        // 失败时重新加入队列
        this.behaviorQueue.unshift(...behaviors)
      }
    } catch (error) {
      console.error('❌ 上传学习行为异常:', error)
      // 异常时重新加入队列
      this.behaviorQueue.unshift(...behaviors)
    }
  }

  // ==================== 具体行为追踪方法 ====================

  // 开始学习
  async trackPlayStart(videoData = {}) {
    await this.trackBehavior('play', {
      action: 'start',
      video_info: videoData
    })
  }

  // 暂停学习
  async trackPause(reason = 'user') {
    await this.trackBehavior('pause', {
      reason,
      pause_position: this.currentVideoPosition
    })
  }

  // 快进
  async trackSeekForward(fromPosition, toPosition) {
    await this.trackBehavior('seek_forward', {
      from_position: fromPosition,
      to_position: toPosition,
      skip_duration: toPosition - fromPosition
    })
  }

  // 回退
  async trackSeekBackward(fromPosition, toPosition) {
    await this.trackBehavior('seek_backward', {
      from_position: fromPosition,
      to_position: toPosition,
      rewind_duration: fromPosition - toPosition
    })
  }

  // 调整播放速度
  async trackSpeedChange(oldSpeed, newSpeed) {
    const behaviorType = newSpeed > oldSpeed ? 'speed_up' : 'speed_down'
    await this.trackBehavior(behaviorType, {
      old_speed: oldSpeed,
      new_speed: newSpeed
    })
  }

  // 记录笔记
  async trackNoteTaking(noteContent, noteType = 'text') {
    await this.trackBehavior('note_taking', {
      note_type: noteType,
      note_length: noteContent.length,
      has_content: noteContent.trim().length > 0
    })
  }

  // 提问
  async trackQuestion(questionContent, questionType = 'text') {
    await this.trackBehavior('question_ask', {
      question_type: questionType,
      question_length: questionContent.length
    })
  }

  // 参与讨论
  async trackDiscussion(discussionType = 'comment') {
    await this.trackBehavior('discussion', {
      discussion_type: discussionType
    })
  }

  // 添加书签
  async trackBookmark() {
    await this.trackBehavior('bookmark', {
      bookmark_position: this.currentVideoPosition
    })
  }

  // 重复播放
  async trackReplay(startPosition, endPosition) {
    await this.trackBehavior('replay', {
      start_position: startPosition,
      end_position: endPosition,
      replay_duration: endPosition - startPosition
    })
  }

  // 注意力分散（页面失焦）
  async trackFocusLost() {
    await this.trackBehavior('focus_lost', {
      lost_at_position: this.currentVideoPosition
    })
  }

  // 重新专注（页面获得焦点）
  async trackFocusRegain() {
    const focusLostTime = Date.now() - this.lastActivityTime
    await this.trackBehavior('focus_regain', {
      regain_at_position: this.currentVideoPosition,
      focus_lost_duration: focusLostTime
    })
  }

  // 章节完成
  async trackChapterComplete(completionRate = 100, actualWatchTime = null) {
    const totalTime = Date.now() - this.sessionStartTime
    const watchTime = actualWatchTime || Math.round(totalTime / 1000)
    
    await this.trackBehavior('chapter_complete', {
      completion_rate: completionRate,
      total_time: totalTime,
      session_duration: Math.round(totalTime / 1000),
      actual_watch_time: watchTime,
      efficiency_rate: watchTime / Math.round(totalTime / 1000)
    }, watchTime) // duration字段存储实际观看时间
    
    console.log('🎉 章节完成记录:', {
      course_id: this.currentCourse,
      chapter_id: this.currentChapter,
      completion_rate: completionRate,
      actual_watch_time: watchTime,
      session_duration: Math.round(totalTime / 1000)
    })
  }

  // 测验尝试
  async trackQuizAttempt(quizData) {
    await this.trackBehavior('quiz_attempt', {
      quiz_id: quizData.id,
      quiz_type: quizData.type,
      attempt_number: quizData.attemptNumber || 1
    })
  }

  // 资源下载
  async trackResourceDownload(resourceType, resourceName) {
    await this.trackBehavior('resource_download', {
      resource_type: resourceType,
      resource_name: resourceName
    })
  }

  // 学习时长统计 - 基于实际观看时间
  async trackStudyDuration(actualWatchTime, totalSessionTime = null) {
    const sessionTime = totalSessionTime || (Date.now() - this.sessionStartTime);
    
    await this.trackBehavior('study_duration', {
      actual_watch_seconds: actualWatchTime, // 实际观看时间（秒）
      session_duration_seconds: Math.round(sessionTime / 1000), // 会话总时长（秒）
      efficiency_rate: actualWatchTime / Math.round(sessionTime / 1000), // 学习效率
      timestamp: Date.now()
    }, actualWatchTime) // duration字段存储实际观看时间
  }

  // 记录视频观看进度
  async trackVideoProgress(currentTime, duration, playbackRate = 1) {
    await this.trackBehavior('video_progress', {
      current_time: currentTime,
      total_duration: duration,
      progress_percent: (currentTime / duration) * 100,
      playback_rate: playbackRate,
      effective_watch_time: currentTime / playbackRate // 考虑播放速度的有效观看时间
    })
  }

  // 计算有效学习时长（排除暂停、失焦等时间）
  calculateEffectiveDuration(totalDuration) {
    // 这里可以根据暂停、失焦等行为计算有效时长
    // 简化实现，假设有效时长为总时长的80%
    return Math.round(totalDuration * 0.8)
  }

  // ==================== 自动追踪设置 ====================

  // 设置视频播放器自动追踪
  setupVideoTracking(videoElement) {
    if (!videoElement) return

    // 播放开始
    videoElement.addEventListener('play', () => {
      this.trackPlayStart({
        video_duration: videoElement.duration,
        video_current_time: videoElement.currentTime
      })
    })

    // 暂停
    videoElement.addEventListener('pause', () => {
      this.trackPause('user')
    })

    // 跳转
    let lastSeekTime = 0
    videoElement.addEventListener('seeked', () => {
      const currentTime = videoElement.currentTime
      if (Math.abs(currentTime - lastSeekTime) > 5) { // 跳转超过5秒才记录
        if (currentTime > lastSeekTime) {
          this.trackSeekForward(lastSeekTime, currentTime)
        } else {
          this.trackSeekBackward(lastSeekTime, currentTime)
        }
      }
      lastSeekTime = currentTime
    })

    // 播放速度变化
    let lastPlaybackRate = 1
    videoElement.addEventListener('ratechange', () => {
      this.trackSpeedChange(lastPlaybackRate, videoElement.playbackRate)
      lastPlaybackRate = videoElement.playbackRate
    })

    // 定时更新视频位置
    videoElement.addEventListener('timeupdate', () => {
      this.updateVideoPosition(Math.round(videoElement.currentTime))
    })
  }

  // 设置页面焦点追踪
  setupFocusTracking() {
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        this.trackFocusLost()
      } else {
        this.trackFocusRegain()
      }
    })

    window.addEventListener('blur', () => {
      this.trackFocusLost()
    })

    window.addEventListener('focus', () => {
      this.trackFocusRegain()
    })
  }
}

// 创建全局实例
const behaviorTracker = new BehaviorTracker()

// 设置全局焦点追踪
behaviorTracker.setupFocusTracking()

export default behaviorTracker