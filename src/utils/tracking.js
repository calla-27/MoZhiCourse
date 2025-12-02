// 学习行为埋点工具
export const trackStudyBehavior = (eventType, data = {}) => {
  const trackingData = {
    event: eventType,
    userId: localStorage.getItem('userId') || 'anonymous',
    timestamp: new Date().toISOString(),
    page: window.location.pathname,
    ...data
  }
  
  console.log('📊 埋点数据:', trackingData)
  
  // 发送到后端埋点接口（先注释掉，等后端接口准备好再打开）
  // fetch('/api/tracking', {
  //   method: 'POST',
  //   headers: { 'Content-Type': 'application/json' },
  //   body: JSON.stringify(trackingData)
  // }).catch(err => console.error('埋点发送失败:', err))
}

// 具体的学习行为埋点方法
export const trackStudySession = {
  // 开始学习课程
  start: (courseId, courseName) => {
    trackStudyBehavior('study_session_start', {
      courseId,
      courseName,
      startTime: new Date().toISOString()
    })
  },
  
  // 结束学习课程
  end: (courseId, courseName, duration, progress) => {
    trackStudyBehavior('study_session_end', {
      courseId,
      courseName,
      duration, // 学习时长（秒）
      progress, // 学习进度
      endTime: new Date().toISOString()
    })
  },
  
  // 视频观看行为
  videoWatch: (courseId, videoId, watchTime, totalTime) => {
    trackStudyBehavior('video_watch', {
      courseId,
      videoId,
      watchTime,
      totalTime,
      completion: (watchTime / totalTime * 100).toFixed(2)
    })
  },
  
  // 测验完成
  quizComplete: (courseId, quizId, score, totalScore) => {
    trackStudyBehavior('quiz_complete', {
      courseId,
      quizId,
      score,
      totalScore,
      accuracy: (score / totalScore * 100).toFixed(2)
    })
  },
  
  // 页面访问
  pageView: (pageName, courseId = null) => {
    trackStudyBehavior('page_view', {
      pageName,
      courseId
    })
  }
}