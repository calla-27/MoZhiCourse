<template>
  <div class="behavior-analysis-container">
    <!-- 添加刷新按钮 -->
    <div class="refresh-button" @click="refreshData" title="刷新数据">
      <i class="fas fa-sync-alt"></i>
    </div>
    <div class="container">
      <!-- 头部区域 -->
      <div class="header">
        <div class="user-info">
          <div class="avatar">
            {{ getUserAvatarText() }}
          </div>
          <div class="user-details">
            <h1>{{ isTeacherView ? `学生学习行为分析` : '我的学习行为分析' }}</h1>
            <p>{{ isTeacherView ? `查看学生在「${courseName || '课程'}」中的学习表现` : '持续进步，每天都是更好的自己' }}</p>
            <div class="learning-type" v-if="learningStyle" :title="learningStyle.learning_style_type">
              学习类型：{{ learningStyle.learning_style_type }}
            </div>
            <div class="learning-type" v-else>学习类型：分析中...</div>
          </div>
        </div>
        
        <!-- 课程筛选 - 只显示已成功报名/学习库中的课程 -->
        <div class="filter-section">
          <button 
            class="filter-btn" 
            :class="{ active: selectedCourseId === 'overall' }"
            @click="selectOverall"
          >
            总体学习风格
          </button>
          <button 
            v-for="course in enrolledCourses" 
            :key="course.course_id"
            class="filter-btn" 
            :class="{ active: selectedCourseId === course.course_id }"
            @click="selectCourse(course.course_id)"
            :title="course.course_name"
          >
            {{ formatCourseName(course.course_name) }}
          </button>
          <div v-if="enrolledCourses.length === 0" class="no-course-hint">
            <i class="fas fa-book"></i> 暂无已报名课程
          </div>
        </div>
      </div>

      <!-- 关键指标区域 -->
      <div class="metrics">
        <div class="metric-card">
          <div class="metric-label">
            <span>⏱️</span> 学习总时长
          </div>
          <div class="metric-value">
            {{ getTotalStudyTime() }}
          </div>
          <div class="learning-suggestion">
            <div class="suggestion-title">⏰ 时间管理建议</div>
            <div class="suggestion-content">你的总学习时长表现良好，建议保持每日学习习惯，合理分配各科目时间。</div>
          </div>
        </div>
        
        <div class="metric-card progress-card">
          <div class="progress-header">
            <div class="progress-title">
              <span>📈</span> 学习进度
            </div>
            <div class="progress-number">{{ getStudyProgress() }}</div>
          </div>
          <div class="progress-bar-container">
            <div class="progress-bar">
              <div class="progress-fill" :style="{ width: getStudyProgressValue() }"></div>
            </div>
          </div>
          <div class="learning-suggestion">
            <div class="suggestion-title">📚 进度建议</div>
            <div class="suggestion-content">整体进度稳步推进，建议按照课程计划持续学习，及时完成课后练习。</div>
          </div>
        </div>
        
        <div class="metric-card">
          <div class="metric-label">
            <span>🧠</span> 知识掌握度
          </div>
          <div class="metric-value">
            {{ getMasteryLevel() }}
          </div>
          <div class="learning-suggestion">
            <div class="suggestion-title">🎯 掌握度建议</div>
            <div class="suggestion-content">知识掌握度持续提升，建议多做练习题巩固知识点，及时查漏补缺。</div>
          </div>
        </div>
      </div>

      <!-- 图表区域 -->
      <div class="charts-grid">
        <!-- 在倍速图表区域 -->
        <div class="speed-chart-wrapper">
          <!-- 添加一个包装层，确保尺寸稳定 -->
          <div class="chart-container-inner" style="width: 100%; height: 100%; position: relative;">
          <div class="chart-title">
            <span>📚</span> 倍速使用环状图
          </div>
            <div ref="speedChartRef" 
                class="speed-chart" 
                style="width: 100%; height: 100%; position: absolute; top: 0; left: 0;">
            </div>
            <div class="speed-chart-center" style="position: absolute; top: 50%; left: 40%; transform: translate(-50%, -50%);">
              <div class="center-value">{{ playbackSpeedTotal }}</div>
              <div class="center-label">总次数</div>
              <div class="center-course">{{ getCurrentViewName() }}</div>
            </div>
          </div>
        </div>
        
        <!-- 词云图 -->
        <div class="chart-container wordcloud-card">
          <div class="chart-title">
            <span>📚</span> 学习内容词云图
          </div>
          <div class="wordcloud-container">
            <LearningWordCloud 
              v-if="showWordCloud"
              :word-data="wordcloudData"
              :type="wordcloudType"
              :key="wordcloudKey"
            />
            <div v-else class="wordcloud-placeholder">
              <i class="fas fa-cloud fa-3x text-muted"></i>
              <p class="mt-3 text-muted">学习词云图</p>
              <small>{{ placeholderText }}</small>
            </div>
          </div>
        </div>
        
        <div class="chart-container full-width">
          <div class="chart-title">
            <span>📅</span> 每日学习时长趋势
          </div>
          <div ref="trendChartRef" style="width: 100%; height: 300px;">
          </div>
        </div>
      </div>

      <!-- 总体分析 -->
      <div v-if="selectedCourseId === 'overall'" class="course-analysis">
        <div class="analysis-title">课程表现分析</div>
        <div v-if="enrolledCourses.length === 0" class="no-course-panel">
          <div class="no-course-content">
            <i class="fas fa-book-open fa-3x"></i>
            <h4>暂无已报名课程</h4>
            <p>您还没有报名任何课程，请先报名课程开始学习</p>
            <router-link to="/courses" class="enroll-btn">
              <i class="fas fa-search"></i> 去选课中心
            </router-link>
          </div>
        </div>
        <div v-else class="course-cards">
          <div v-for="course in enrolledCourses.slice(0, 2)" :key="course.course_id" 
              class="course-card" :class="getCoursePerformanceClass(course)">
            <div class="course-header">
              <div class="course-name">{{ course.course_name }}</div>
              <div class="course-tag" :class="getCourseTagClass(course)">
                {{ getCoursePerformanceText(course) }}
              </div>
            </div>
            
            <!-- 三个关键指标并排显示 -->
            <div class="three-metrics-row">
              <!-- 学习总时长 -->
              <div class="metric-item">
                <div class="metric-icon">
                  <i class="fas fa-clock"></i>
                </div>
                <div class="metric-content">
                  <div class="metric-label">学习总时长</div>
                  <div class="metric-value">
                    {{ formatStudyTime(course.total_study_time || course.total_study_minutes || course.total_learn_duration || 0) }}
                  </div>
                </div>
              </div>
              
              <!-- 学习进度 -->
              <div class="metric-item">
                <div class="metric-icon">
                  <i class="fas fa-chart-line"></i>
                </div>
                <div class="metric-content">
                  <div class="metric-label">学习进度</div>
                  <div class="metric-value">{{ Math.round(course.progress || 0) }}%</div>
                </div>
              </div>
              
              <!-- 知识掌握度 -->
              <div class="metric-item">
                <div class="metric-icon">
                  <i class="fas fa-brain"></i>
                </div>
                <div class="metric-content">
                  <div class="metric-label">知识掌握度</div>
                  <div class="metric-value">{{ Math.round(course.mastery_level || 0) }}%</div>
                </div>
              </div>
            </div>
            
            <div class="course-suggestion">
              <strong>学习建议：</strong> {{ getCourseSuggestion(course) }}
            </div>
          </div>
        </div>
      </div>

      <!-- 具体课程分析 -->
      <div v-else-if="selectedCourseAnalysis && selectedCourseId !== 'overall'" class="course-analysis">
        <div class="analysis-title">{{ selectedCourseAnalysis.courseInfo?.course_name }} - 章节分析</div>
        <div v-if="!selectedCourseAnalysis.chapterProgress || selectedCourseAnalysis.chapterProgress.length === 0" 
             class="no-chapter-data">
          <i class="fas fa-clipboard-list fa-3x"></i>
          <h4>暂无章节学习数据</h4>
          <p>开始学习该课程以生成详细的分析报告</p>
        </div>
        <div v-else class="chapter-analysis">
          <div class="chapter-cards">
            <div v-for="chapter in selectedCourseAnalysis.chapterProgress" :key="chapter.chapter_id"
                 class="chapter-card" :class="getChapterPerformanceClass(chapter)">
              <div class="chapter-name">{{ chapter.chapter_title }}</div>
              <div class="chapter-mastery">掌握度: {{ Math.round(chapter.progress_rate || chapter.chapter_progress_rate || 0) }}%</div>
              <div class="chapter-suggestion">
                <strong>学习建议：</strong> {{ getChapterSuggestion(chapter) }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-overlay">
      <div class="spinner">
        <div class="spinner-circle"></div>
      </div>
      <p class="loading-text">正在加载学习数据...</p>
    </div>

    <!-- 错误状态 -->
    <div v-if="error && !loading" class="error-overlay">
      <div class="error-content">
        <i class="fas fa-exclamation-triangle error-icon"></i>
        <h3>加载失败</h3>
        <p class="error-message">{{ error }}</p>
        <button @click="loadData" class="retry-btn">
          <i class="fas fa-redo"></i> 重新加载
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed, onBeforeUnmount, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import studentBehaviorApi from '@/api/studentBehavior'
import LearningWordCloud from '@/components/chart/LearningWordCloud.vue'
import * as echarts from 'echarts'

export default {
  name: 'StudentBehaviorAnalysis',

  components: {
    LearningWordCloud
  },
  
  setup() {
    const router = useRouter()
    
    // 获取URL参数 - 检查是否是教师查看学生数据
    const route = router.currentRoute.value
    const isTeacherView = route.query.viewAs === 'teacher'
    const targetStudentId = route.query.studentId
    const targetCourseId = route.query.courseId
    const courseName = route.query.courseName
    
    console.log('🎯 学生行为分析页面参数:', {
      isTeacherView,
      targetStudentId,
      targetCourseId,
      courseName
    })
    
    // 响应式数据
    const loading = ref(true)
    const error = ref(null)
    const enrolledCourses = ref([])
    const overview = ref({})
    const learningStyle = ref(null)
    
    const selectedCourseId = ref(targetCourseId || 'overall')
    const selectedCourseAnalysis = ref(null)
    const loadingCourseAnalysis = ref(false)
    
    // 添加刷新状态
    const isRefreshing = ref(false)
    
    // 添加词云图key，用于强制重绘
    const wordcloudKey = ref('overall')

    // 倍速使用可视化
    const speedChartRef = ref(null)
    const playbackSpeedLoading = ref(true)
    const playbackSpeedData = ref([])
    const playbackSpeedTotal = ref(0)
    const hasSpeedUsageData = computed(() =>
      playbackSpeedData.value.some(item => item.value > 0)
    )

    let speedChartInstance = null
    // --- 新增：学习时长趋势图相关 ---
    const trendChartRef = ref(null)
    const learningTrendData = ref([])
    let trendChartInstance = null

    const disposeSpeedChart = () => {
      if (speedChartInstance) {
        speedChartInstance.dispose()
        speedChartInstance = null
      }
    }

    // --- 新增：清理趋势图实例的函数 ---
    const disposeTrendChart = () => {
      if (trendChartInstance) {
        trendChartInstance.dispose()
        trendChartInstance = null
      }
    }

    // --- 新增：更新学习时长趋势图的函数 ---
    const updateTrendChart = () => {
      if (!trendChartRef.value || learningTrendData.value.length === 0) return;
      
      if (!trendChartInstance) {
        trendChartInstance = echarts.init(trendChartRef.value);
      }

      const dates = learningTrendData.value.map(item => item.date);
      const durations = learningTrendData.value.map(item => Math.round((item.total_duration || 0) / 60)); // 将秒转换为分钟

      const option = {
        tooltip: {
          trigger: 'axis',
          formatter: '{b}<br/>学习时长: {c} 分钟'
        },
        grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
        xAxis: {
          type: 'category',
          boundaryGap: false,
          data: dates,
        },
        yAxis: {
          type: 'value',
          name: '分钟',
        },
        series: [{
          name: '学习时长',
          type: 'line',
          smooth: true,
          data: durations,
          itemStyle: { color: 'rgb(74, 108, 247)' },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
              offset: 0, color: 'rgba(74, 108, 247, 0.3)'
            }, {
              offset: 1, color: 'rgba(74, 108, 247, 0)'
            }])
          }
        }]
      };
      trendChartInstance.setOption(option);
    };

    // --- 新增：加载学习趋势数据的函数 ---
    const loadLearningTrend = async () => {
      try {
        console.log('📈 加载学习趋势数据 - 学生ID:', isTeacherView ? targetStudentId : '当前用户');
        
        // 清除旧数据
        learningTrendData.value = []
        
        const response = await studentBehaviorApi.getLearningTrend('7d', isTeacherView ? targetStudentId : null);
        if (response.success && response.data.studyTrend) {
          learningTrendData.value = response.data.studyTrend;
          nextTick(() => {
            updateTrendChart();
          });
        }
      } catch (err) {
        console.error('加载学习趋势数据失败:', err);
      }
    };

    const initSpeedChart = () => {
      if (!speedChartRef.value) return
      if (!speedChartInstance) {
        speedChartInstance = echarts.init(speedChartRef.value)
      }
    }

    const formatSpeedLabel = (speed) => {
      const num = Number(speed)
      if (Number.isNaN(num)) return `${speed}x`
      const isInt = Number.isInteger(num)
      return `${isInt ? num : Number(num.toFixed(2))}x`
    }

    // 在 updateSpeedChart 函数之前添加 handleResize 函数
const handleResize = () => {
  if (speedChartInstance) {
    console.log('🔄 调整图表大小');
    speedChartInstance.resize();
  }
};

  const updateSpeedChart = () => {
    console.log('📊 开始更新图表');
    
    // 防抖处理，避免频繁调用
    if (window.updateChartTimeout) {
      clearTimeout(window.updateChartTimeout);
    }
    
    window.updateChartTimeout = setTimeout(() => {
      nextTick(() => {
        if (!speedChartRef.value) {
          console.log('⚠️ 图表容器不存在');
          return;
        }

        // 检查容器是否可见
        const container = speedChartRef.value;
        if (!container.offsetParent || container.offsetWidth === 0 || container.offsetHeight === 0) {
          console.log('⚠️ 容器不可见或无尺寸，跳过更新');
          return;
        }

        // 过滤有效数据
        const validData = playbackSpeedData.value.filter(item => item.value > 0);
        
        if (validData.length === 0) {
          console.log('⚠️ 没有有效数据');
          // 不清除图表，保持空白状态
          if (speedChartInstance) {
            speedChartInstance.clear();
          }
          return;
        }

        // 确保只有一个图表实例
        if (speedChartInstance) {
          try {
            speedChartInstance.dispose();
          } catch (e) {
            console.log('清理旧实例时出错:', e);
          }
          speedChartInstance = null;
        }

        // 重新初始化图表实例
        try {
          speedChartInstance = echarts.init(container);
          console.log('🔄 创建新图表实例');
        } catch (error) {
          console.error('❌ 初始化图表失败:', error);
          return;
        }

        // 准备图表选项
        const option = {
          backgroundColor: 'transparent',
          tooltip: {
            trigger: 'item',
            formatter: ({ name, value, percent }) => {
              return `${name}<br/>使用次数：${value}<br/>占比：${percent}%`;
            }
          },
          legend: {
            show: true,
            orient: 'vertical',
            right: 10,
            top: 'middle',
            textStyle: {
              color: '#666',
              fontSize: 12
            },
            formatter: (name) => {
              const item = validData.find(d => d.name === name);
              return item ? `${name} ${item.value}次` : name;
            }
          },
          color: ['#4A6CF7', '#6A5AF9', '#D66EFD', '#FF9A9E', '#FFD166', '#5DD39E', '#36CFC9', '#1890FF'],
          series: [
            {
              name: '倍速分布',
              type: 'pie',
              radius: ['60%', '80%'],
              center: ['40%', '50%'],
              avoidLabelOverlap: false,
              label: {
                show: false
              },
              labelLine: {
                show: false
              },
              data: validData,
              emphasis: {
                itemStyle: {
                  shadowBlur: 10,
                  shadowOffsetX: 0,
                  shadowColor: 'rgba(0, 0, 0, 0.5)'
                }
              }
            }
          ],
          animation: true,
          animationDuration: 800
        };

        // 设置图表选项
        try {
          speedChartInstance.setOption(option);
          console.log('✅ 图表设置成功');
        } catch (error) {
          console.error('❌ 设置图表选项失败:', error);
        }

        // 调整图表大小
        const resizeChart = () => {
          if (speedChartInstance && container.offsetWidth > 0 && container.offsetHeight > 0) {
            try {
              speedChartInstance.resize();
              console.log('📏 图表调整大小成功');
            } catch (error) {
              console.error('❌ 调整图表大小失败:', error);
            }
          }
        };

        // 立即调整一次
        resizeChart();

        // 延迟再次调整，确保尺寸稳定
        setTimeout(resizeChart, 100);
        setTimeout(resizeChart, 300);
      });
    }, 100); // 100ms 防抖延迟
  };

  // 修改 loadPlaybackSpeedUsage 函数中的数据处理部分
  const loadPlaybackSpeedUsage = async (courseId = selectedCourseId.value) => {
    try {
      playbackSpeedLoading.value = true;
      
      console.log('🎯 加载倍速数据，课程ID:', courseId, '学生ID:', isTeacherView ? targetStudentId : '当前用户');
      
      // 清除旧图表
      if (speedChartInstance) {
        try {
          speedChartInstance.dispose();
          speedChartInstance = null;
        } catch (e) {
          console.log('清理旧图表时出错:', e);
        }
      }
      
      // 清除旧数据
      playbackSpeedData.value = []
      playbackSpeedTotal.value = 0
      
      const response = await studentBehaviorApi.getPlaybackSpeedUsage(courseId, isTeacherView ? targetStudentId : null);
      
      if (response.success) {
        const usageData = response.data?.usage || [];
        console.log('📋 获取到数据:', usageData.length, '条');
        
        playbackSpeedTotal.value = response.data?.total || 0;
        
        // 处理数据
        if (usageData.length > 0) {
          playbackSpeedData.value = usageData.map(item => ({
            value: item.count || item.usage_count || 0,
            name: formatSpeedLabel(item.speed || 1.0),
            rawSpeed: item.speed || 1.0
          })).filter(item => item.value > 0);
        } else {
          const defaultSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
          playbackSpeedData.value = defaultSpeeds.map(speed => ({
            value: 0,
            name: formatSpeedLabel(speed),
            rawSpeed: speed
          }));
        }
        
      } else {
        console.warn('⚠️ API返回失败');
        playbackSpeedData.value = [];
        playbackSpeedTotal.value = 0;
      }
    } catch (error) {
      console.error('❌ 获取倍速数据失败:', error);
    } finally {
      playbackSpeedLoading.value = false;
      
      // 等待 DOM 更新和渲染
      await nextTick();
      
      // 延迟更新图表，确保容器完全渲染
      setTimeout(() => {
        if (speedChartRef.value && speedChartRef.value.offsetWidth > 0) {
          console.log('🔄 开始更新图表');
          updateSpeedChart();
        } else {
          console.log('⏳ 容器未准备好，延迟更新');
          setTimeout(() => {
            updateSpeedChart();
          }, 200);
        }
      }, 100);
    }
  };

    // 1. 首先定义所有基础函数
    // 格式化课程名称（用于按钮显示）
    const formatCourseName = (name) => {
      if (!name) return '未知课程'
      if (name.length > 8) {
        return name.substring(0, 8) + '...'
      }
      return name
    }

    // 获取用户头像文字（简化版）
    const getUserAvatarText = () => {
      return '我'
    }

    // 添加 formatStudyTime 函数
    const formatStudyTime = (minutes) => {
      // 确保输入是数字
      const totalMinutes = Number(minutes) || 0;
      
      if (totalMinutes <= 0) {
        return '0h 0m';
      }
      
      const hours = Math.floor(totalMinutes / 60);
      const mins = Math.round(totalMinutes % 60);
      
      // 如果小时为0，只显示分钟
      if (hours === 0) {
        return `${mins}m`;
      }
      
      return `${hours}h ${mins}m`;
    };

    // 获取当前查看的名称
    const getCurrentViewName = () => {
      if (selectedCourseId.value === 'overall') {
        return '总体学习情况'
      } else {
        const course = enrolledCourses.value.find(c => c.course_id === selectedCourseId.value)
        return course ? course.course_name : '课程详情'
      }
    }

    // 获取学习总时长
    const getTotalStudyTime = () => {
      try {
        if (selectedCourseId.value === 'overall') {
          if (!enrolledCourses.value || enrolledCourses.value.length === 0) {
            return '0h 0m';
          }
          
          // 使用安全的reduce函数
          const totalMinutes = enrolledCourses.value.reduce((sum, course) => {
            // 尝试多种可能的字段名
            const studyTime = 
              course.total_study_time ||
              course.total_study_minutes ||
              course.total_learn_duration ||
              0;
            
            // 确保是数字
            const numValue = Number(studyTime);
            return sum + (isNaN(numValue) ? 0 : numValue);
          }, 0);
          
          // 确保是有效的数字
          if (isNaN(totalMinutes) || totalMinutes <= 0) {
            return '0h 0m';
          }
          
          const hours = Math.floor(totalMinutes / 60);
          const minutes = Math.round(totalMinutes % 60);
          return `${hours}h ${minutes}m`;
          
        } else if (selectedCourseAnalysis.value?.courseInfo) {
          const totalMinutes = 
            selectedCourseAnalysis.value.courseInfo.total_study_time ||
            selectedCourseAnalysis.value.courseInfo.total_study_minutes ||
            selectedCourseAnalysis.value.courseInfo.total_learn_duration ||
            0;
          
          const numMinutes = Number(totalMinutes);
          if (isNaN(numMinutes) || numMinutes <= 0) {
            return '0h 0m';
          }
          
          const hours = Math.floor(numMinutes / 60);
          const minutes = Math.round(numMinutes % 60);
          return `${hours}h ${minutes}m`;
        }
        
        return '0h 0m';
      } catch (error) {
        console.error('计算学习总时长出错:', error);
        return '0h 0m';
      }
    }

    // 获取学习进度
    const getStudyProgress = () => {
      try {
        if (selectedCourseId.value === 'overall') {
          if (!enrolledCourses.value || enrolledCourses.value.length === 0) {
            return '0%';
          }
          
          const validCourses = enrolledCourses.value.filter(course => {
            const progress = course.progress || 0;
            return !isNaN(Number(progress));
          });
          
          if (validCourses.length === 0) {
            return '0%';
          }
          
          const totalProgress = validCourses.reduce((sum, course) => {
            return sum + Number(course.progress || 0);
          }, 0);
          
          const avgProgress = Math.round(totalProgress / validCourses.length);
          return `${avgProgress}%`;
          
        } else if (selectedCourseAnalysis.value?.courseInfo) {
          const progress = selectedCourseAnalysis.value.courseInfo.progress || 0;
          const numProgress = Number(progress);
          return isNaN(numProgress) ? '0%' : `${Math.round(numProgress)}%`;
        }
        
        return '0%';
      } catch (error) {
        console.error('计算学习进度出错:', error);
        return '0%';
      }
    }

    // 获取进度条宽度（数值格式，不含%）
    const getStudyProgressValue = () => {
      if (selectedCourseId.value === 'overall') {
        // 总体视图：计算平均值
        if (enrolledCourses.value.length === 0) return '0%';
        
        const totalProgress = enrolledCourses.value.reduce((sum, course) => {
          return sum + (course.progress || 0);
        }, 0);
        
        const avgProgress = Math.round(totalProgress / enrolledCourses.value.length);
        return `${avgProgress}%`;
      } else if (selectedCourseAnalysis.value && selectedCourseAnalysis.value.courseInfo) {
        // 单个课程：直接使用
        const progress = selectedCourseAnalysis.value.courseInfo.progress || 0;
        return `${Math.round(progress)}%`;
      }
      return '0%';
    }

    // 获取知识掌握度
    const getMasteryLevel = () => {
      try {
        if (selectedCourseId.value === 'overall') {
          if (!enrolledCourses.value || enrolledCourses.value.length === 0) {
            return '0%';
          }
          
          const validCourses = enrolledCourses.value.filter(course => {
            const mastery = course.mastery_level || course.course_mastery || 0;
            return !isNaN(Number(mastery));
          });
          
          if (validCourses.length === 0) {
            return '0%';
          }
          
          const totalMastery = validCourses.reduce((sum, course) => {
            const mastery = course.mastery_level || course.course_mastery || 0;
            return sum + Number(mastery);
          }, 0);
          
          const avgMastery = Math.round(totalMastery / validCourses.length);
          return `${avgMastery}%`;
          
        } else if (selectedCourseAnalysis.value?.courseInfo) {
          const mastery = 
            selectedCourseAnalysis.value.courseInfo.mastery_level ||
            selectedCourseAnalysis.value.courseInfo.course_mastery ||
            0;
          
          const numMastery = Number(mastery);
          return isNaN(numMastery) ? '0%' : `${Math.round(numMastery)}%`;
        }
        
        return '0%';
      } catch (error) {
        console.error('计算知识掌握度出错:', error);
        return '0%';
      }
    }

    // 课程表现评估 - 根据真实数据评估
    const getCoursePerformanceClass = (course) => {
      const progress = course.progress || 0
      if (progress >= 80) return 'excellent'
      if (progress >= 50) return 'good'
      return 'unstable'
    }

    const getCourseTagClass = (course) => {
      const progress = course.progress || 0
      if (progress >= 80) return 'tag-excellent'
      if (progress >= 50) return 'tag-good'
      return 'tag-unstable'
    }

    const getCoursePerformanceText = (course) => {
      const progress = course.progress || 0
      if (progress >= 80) return '表现优秀'
      if (progress >= 50) return '表现良好'
      return '需要关注'
    }

    // 修改 getCourseSuggestion 函数，基于三个关键指标提供建议
    const getCourseSuggestion = (course) => {
      try {
        // 获取三个关键指标
        const studyTime = course.total_study_time || course.total_study_minutes || course.total_learn_duration || 0;
        const progress = course.progress || 0;
        const mastery = course.mastery_level || 0;
        
        console.log(`课程 "${course.course_name}" 建议计算:`, {
          学习时长: studyTime,
          进度: progress,
          掌握度: mastery
        });
        
        // 基于三个指标的综合评估
        if (progress >= 80 && mastery >= 80) {
          return `您在这门课程中表现优异！学习时长${formatStudyTime(studyTime)}，进度${Math.round(progress)}%，掌握度${Math.round(mastery)}%。建议继续保持，可以挑战更高难度的学习内容。`;
        } else if (progress >= 60 && mastery >= 60) {
          return `学习情况良好。当前学习时长${formatStudyTime(studyTime)}，进度${Math.round(progress)}%，掌握度${Math.round(mastery)}%。建议适当增加练习时间，巩固已学知识。`;
        } else if (progress < 50) {
          return `学习进度偏低（${Math.round(progress)}%）。当前学习时长${formatStudyTime(studyTime)}，建议增加学习频率，制定每日学习计划，优先完成基础章节。`;
        } else if (mastery < 50) {
          return `知识掌握度不足（${Math.round(mastery)}%）。当前学习时长${formatStudyTime(studyTime)}，进度${Math.round(progress)}%，建议重新学习重点章节，多做练习题巩固理解。`;
        } else if (studyTime < 60) { // 学习时长少于1小时
          return `学习时长不足（${formatStudyTime(studyTime)}）。当前进度${Math.round(progress)}%，掌握度${Math.round(mastery)}%，建议增加学习投入，保证每周至少2小时的学习时间。`;
        } else {
          return `继续保持当前学习节奏。学习时长${formatStudyTime(studyTime)}，进度${Math.round(progress)}%，掌握度${Math.round(mastery)}%，均衡发展各项能力。`;
        }
      } catch (error) {
        console.error('生成学习建议出错:', error);
        return '根据您的学习数据，建议保持规律学习，逐步提升各项指标。';
      }
    };

    const getChapterPerformanceClass = (chapter) => {
      const progress = chapter.progress_rate || chapter.chapter_progress_rate || 0;
      if (progress >= 80) return 'excellent'
      if (progress >= 50) return 'good'
      return 'unstable'
    }

    const getChapterSuggestion = (chapter) => {
      const progress = chapter.progress_rate || chapter.chapter_progress_rate || 0;
      if (progress >= 80) {
        return '你对这一章节掌握得很好，概念理解清晰，解题思路明确。建议继续保持，并尝试挑战更高难度的综合题目。'
      } else if (progress >= 50) {
        return '这部分内容掌握情况一般，建议多做练习题加深理解，特别是重点难点的巩固。'
      } else {
        return '这部分内容掌握不够扎实，建议重新学习相关知识点，多做基础练习，加强理解和记忆。'
      }
    }

    // 词云数据函数 - 使用真实数据
    const getOverallWordCloudData = () => {
      if (!enrolledCourses.value || enrolledCourses.value.length === 0) {
        return []
      }
      
      return enrolledCourses.value.map(course => {
        const progress = course.progress || 0
        const mastery = course.mastery_level || 0
        const duration = course.total_learn_duration || 0
        
        return {
          ...course,
          progress,
          mastery,
          studyDuration: duration,
          course_name: course.course_name,
          progress_rate: progress,
          mastery_level: mastery
        }
      }).sort((a, b) => b.progress - a.progress)
    }

    const getCourseChapterWordCloudData = () => {
      if (!selectedCourseAnalysis.value || 
          !selectedCourseAnalysis.value.chapterProgress || 
          selectedCourseAnalysis.value.chapterProgress.length === 0) {
        return []
      }
      
      return selectedCourseAnalysis.value.chapterProgress.map(chapter => {
        const progress = chapter.progress_rate || chapter.chapter_progress_rate || 0
        const duration = chapter.study_duration_minutes || 0
        
        return {
          ...chapter,
          progress,
          mastery: progress,
          studyDuration: duration,
          chapter_title: chapter.chapter_title,
          progress_rate: progress,
          course_name: selectedCourseAnalysis.value.courseInfo?.course_name || '当前课程'
        }
      }).sort((a, b) => b.progress - a.progress)
    }

    // 2. 然后定义计算属性（它们依赖上面的函数）
    const showWordCloud = computed(() => {
      if (selectedCourseId.value === 'overall') {
        return getOverallWordCloudData().length > 0
      } else {
        return selectedCourseAnalysis.value && getCourseChapterWordCloudData().length > 0
      }
    })

    const wordcloudData = computed(() => {
      if (selectedCourseId.value === 'overall') {
        return getOverallWordCloudData()
      } else {
        return getCourseChapterWordCloudData()
      }
    })

    const wordcloudType = computed(() => {
      return selectedCourseId.value === 'overall' ? 'course' : 'chapter'
    })

    const placeholderText = computed(() => {
      if (selectedCourseId.value === 'overall') {
        return '暂无课程数据'
      } else if (!selectedCourseAnalysis.value) {
        return '正在加载课程数据...'
      } else {
        return '暂无章节数据'
      }
    })

    // 3. 数据加载相关函数
    const loadData = async (force = false) => {
      try {
        loading.value = true
        error.value = null
        
        const token = localStorage.getItem('token')
        if (!token) {
          router.push('/login')
          return
        }

        console.log('开始加载数据，force:', force)
        console.log('🎯 教师查看模式:', isTeacherView, '目标学生ID:', targetStudentId)
        
        // 清除之前的数据，避免缓存问题
        if (force || isTeacherView) {
          enrolledCourses.value = []
          overview.value = {}
          learningStyle.value = null
          selectedCourseAnalysis.value = null
        }
        
        // 调用API获取概览数据 - 如果是教师查看模式，传递学生ID
        const response = await studentBehaviorApi.getOverview(isTeacherView ? targetStudentId : null)
        
        if (response.success) {
          // 获取已报名课程数据
          enrolledCourses.value = response.data.enrolledCourses || []
          overview.value = response.data.overview || {}
          learningStyle.value = response.data.learningStyle || null
          
          console.log('学情分析数据加载成功，已获取课程:', enrolledCourses.value.length, '门')
          console.log('概览数据:', overview.value)
          console.log('学习风格:', learningStyle.value)
          
          // 如果没有课程，保持在总体分析
          if (enrolledCourses.value.length === 0) {
            selectedCourseId.value = 'overall'
            selectedCourseAnalysis.value = null
            wordcloudKey.value = 'overall'
          } else {
            // 检查当前选中的课程是否还在已报名列表中
            const currentCourseExists = enrolledCourses.value.some(
              c => c.course_id === selectedCourseId.value
            )
            
            // 如果当前选中的课程不存在了，默认选中第一个课程
            if (!currentCourseExists && selectedCourseId.value !== 'overall') {
              selectedCourseId.value = enrolledCourses.value[0]?.course_id || 'overall'
            }
            
            // 重新加载当前课程的详细分析
            if (selectedCourseId.value !== 'overall') {
              await loadCourseAnalysis(selectedCourseId.value)
            }
          }
          
          // 加载倍速使用数据
          await loadPlaybackSpeedUsage(selectedCourseId.value)
        } else {
          throw new Error(response.message || '加载数据失败')
        }
      } catch (err) {
        console.error('加载数据失败:', err)
        error.value = err.message || '网络请求失败'
        
        // 如果是认证错误，跳转到登录页
        if (err.message.includes('认证') || err.message.includes('token')) {
          router.push('/login')
        }
      } finally {
        loading.value = false
        isRefreshing.value = false
      }
    }

    // 加载课程详细分析
    const loadCourseAnalysis = async (courseId, force = false) => {
      if (!courseId || courseId === 'overall') {
        selectedCourseAnalysis.value = null
        wordcloudKey.value = 'overall'
        return
      }
      
      try {
        loadingCourseAnalysis.value = true
        
        // 清除之前的课程分析数据
        if (force || isTeacherView) {
          selectedCourseAnalysis.value = null
        }
        
        console.log('🔍 加载课程分析 - 课程ID:', courseId, '学生ID:', isTeacherView ? targetStudentId : '当前用户')
        const response = await studentBehaviorApi.getCourseAnalysis(courseId, isTeacherView ? targetStudentId : null)
        
        if (response.success) {
          selectedCourseAnalysis.value = response.data
          wordcloudKey.value = `course-${courseId}-${Date.now()}`
          console.log('课程分析数据加载成功:', response.data.courseInfo?.course_name)
        } else {
          console.warn('课程分析API返回失败，使用空数据')
          // 如果API返回失败，返回空数据
          const course = enrolledCourses.value.find(c => c.course_id === courseId)
          if (course) {
            selectedCourseAnalysis.value = {
              courseInfo: course,
              chapterProgress: [],
              focusData: [],
              performance: null
            }
            wordcloudKey.value = `course-${courseId}-${Date.now()}`
          } else {
            selectedCourseAnalysis.value = null
            wordcloudKey.value = 'overall'
          }
        }
      } catch (err) {
        console.error('加载课程分析失败:', err)
        error.value = err.message || '加载课程分析失败'
        
        // 返回空数据
        const course = enrolledCourses.value.find(c => c.course_id === courseId)
        if (course) {
          selectedCourseAnalysis.value = {
            courseInfo: course,
            chapterProgress: [],
            focusData: [],
            performance: null
          }
          wordcloudKey.value = `course-${courseId}-${Date.now()}`
        } else {
          wordcloudKey.value = 'overall'
        }
      } finally {
        loadingCourseAnalysis.value = false
      }
    }

    // 刷新数据函数
    const refreshData = async () => {
      console.log('刷新按钮被点击')
      
      if (isRefreshing.value) {
        console.log('正在刷新中，跳过')
        return
      }
      
      isRefreshing.value = true
      
      // 添加旋转动画
      const refreshIcon = document.querySelector('.refresh-button i')
      if (refreshIcon) {
        refreshIcon.classList.add('fa-spin')
      }
      
      try {
        // 强制刷新
        await loadData(true)
        
        // 如果当前查看的是具体课程，也刷新课程分析
        if (selectedCourseId.value !== 'overall') {
          await loadCourseAnalysis(selectedCourseId.value, true)
        }
        
        console.log('数据刷新完成')
      } finally {
        isRefreshing.value = false
        
        // 移除旋转动画
        if (refreshIcon) {
          setTimeout(() => {
            refreshIcon.classList.remove('fa-spin')
          }, 500)
        }
      }
    }

    // 课程选择函数
    const selectCourse = (courseId) => {
      selectedCourseId.value = courseId
      wordcloudKey.value = `course-${courseId}-${Date.now()}`
      loadCourseAnalysis(courseId)
      loadPlaybackSpeedUsage(courseId)
    }

    const selectOverall = () => {
      selectedCourseId.value = 'overall'
      selectedCourseAnalysis.value = null
      wordcloudKey.value = 'overall'
      loadPlaybackSpeedUsage('overall')
    }

    // 观察课程ID变化，更新词云图key
    watch(() => selectedCourseId.value, (newVal) => {
      if (newVal === 'overall') {
        wordcloudKey.value = 'overall'
      } else {
        wordcloudKey.value = `course-${newVal}-${Date.now()}`
      }
      loadPlaybackSpeedUsage(newVal)
    })

    watch(playbackSpeedData, () => {
      nextTick(() => {
        updateSpeedChart()
      })
    })

    // 初始化加载
    onMounted(async () => {
      await loadData();
      await loadLearningTrend();
      window.addEventListener('resize', handleResize);
  
  // 延迟初始化图表，确保DOM渲染完成
  setTimeout(() => {
    if (selectedCourseId.value) {
      loadPlaybackSpeedUsage(selectedCourseId.value);
    }
  }, 500);
});

    onBeforeUnmount(() => {
      window.removeEventListener('resize', handleResize)
      disposeSpeedChart()
      disposeTrendChart()
    })

    // 返回所有需要的函数和数据
    return {
      // 教师查看模式相关参数
      isTeacherView,
      targetStudentId,
      targetCourseId,
      courseName,
      
      // 数据
      loading,
      error,
      enrolledCourses,
      overview,
      learningStyle,
      selectedCourseId,
      selectedCourseAnalysis,
      loadingCourseAnalysis,
      isRefreshing,
      wordcloudKey,
      speedChartRef,
      playbackSpeedLoading,
      playbackSpeedTotal,
      hasSpeedUsageData,
      trendChartRef,

      // 计算属性
      showWordCloud,
      wordcloudData,
      wordcloudType,
      placeholderText,
      
      // 方法
      loadData,
      refreshData,
      loadCourseAnalysis,
      selectCourse,
      selectOverall,

      // 词云数据函数
      getOverallWordCloudData,
      getCourseChapterWordCloudData,
      
      // 格式化函数
      formatCourseName,
      formatStudyTime,
      getUserAvatarText,
      getCurrentViewName,
      
      // 新增的指标数据函数
      getTotalStudyTime,
      getStudyProgress,
      getMasteryLevel,
      getStudyProgressValue,
      
      // 课程评估函数
      getCoursePerformanceClass,
      getCourseTagClass,
      getCoursePerformanceText,
      getCourseSuggestion,
      
      // 章节评估函数
      getChapterPerformanceClass,
      getChapterSuggestion,
    }
  }
}
</script>

<style>
/* 全局变量定义 */
:root {
  --primary-color: #4a6cf7;
  --secondary-color: #6a5af9;
  --accent-color: #d66efd;
  --success-color: #52c41a;
  --warning-color: #faad14;
  --info-color: #1890ff;
  --light-bg: #f5f7fa;
  --card-bg: #ffffff;
  --text-primary: #333333;
  --text-secondary: #666666;
  --text-light: #999999;
}
</style>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.behavior-analysis-container {
  font-family: 'Microsoft YaHei', Arial, sans-serif;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%); /* 添加渐变背景 */
  color: var(--text-primary);
  line-height: 1.6;
  padding: 20px;
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  background: var(--card-bg);
  border-radius: 16px;
  box-shadow: 0 6px 20px rgba(0,0,0,0.08);
  overflow: hidden;
}

.header {
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  color: white;
  padding: 30px;
  position: relative;
  overflow: hidden;
}

.header::before {
  content: "";
  position: absolute;
  top: -50%;
  right: -20%;
  width: 300px;
  height: 300px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
}

.header::after {
  content: "";
  position: absolute;
  bottom: -30%;
  left: -10%;
  width: 200px;
  height: 200px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 50%;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 20px;
  position: relative;
  z-index: 2;
}

.avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: bold;
  backdrop-filter: blur(10px);
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.user-details h1 {
  font-size: 28px;
  margin-bottom: 8px;
}

.user-details p {
  opacity: 0.9;
  font-size: 16px;
}

.learning-type {
  background: rgba(255, 255, 255, 0.2);
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  margin-top: 10px;
  display: inline-block;
  backdrop-filter: blur(5px);
}

/* 筛选区域 */
.filter-section {
  display: flex;
  gap: 15px;
  margin-top: 15px;
  flex-wrap: wrap;
}

.filter-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
  white-space: nowrap;
}

.filter-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

.filter-btn.active {
  background: white;
  color: #4a6cf7;  /* 注意这里用的是#4a6cf7而不是var(--primary-color) */
  font-weight: bold;
}

.no-course-hint {
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

/* 关键指标区域 - 调整为三个卡片 */
.metrics {
  display: grid;
  grid-template-columns: repeat(3, 1fr); /* 改为3列 */
  gap: 20px;
  padding: 25px;
  background: var(--card-bg);
}

/* 响应式调整 */
@media (max-width: 992px) {
  .metrics {
    grid-template-columns: repeat(2, 1fr); /* 中等屏幕2列 */
  }
}

@media (max-width: 576px) {
  .metrics {
    grid-template-columns: 1fr; /* 小屏幕1列 */
  }
}

/* 卡片样式微调，适应三个卡片 */
.metric-card {
  background: var(--card-bg);
  padding: 24px; /* 稍微增加内边距 */
  border-radius: 16px; /* 圆角增大 */
  box-shadow: 0 6px 20px rgba(0,0,0,0.08); /* 阴影加深 */
  border-left: 5px solid var(--primary-color); /* 边框加粗 */
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.metric-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 24px rgba(0,0,0,0.12);
}

/* 调整三个卡片的颜色区分 */
.metric-card:nth-child(1) {
  border-left-color: #4a6cf7; /* 学习总时长 - 蓝色 */
}

/* .metric-card:nth-child(2) 改为.progress-card类控制 */
.metric-card:nth-child(3) {
  border-left-color: #ff6b6b; /* 知识掌握度 - 红色 */
}

.metric-label {
  font-size: 16px; /* 标签字体增大 */
  color: var(--text-primary);
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

/* 图标样式 */
.metric-label span {
  font-size: 24px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: rgba(74, 108, 247, 0.1);
  border-radius: 10px;
  margin-right: 10px;
}

/* ========== 新增：学习进度卡片特定样式 ========== */
.progress-card {
  border-left-color: #52c41a; /* 覆盖默认颜色 */
}

/* 进度卡片头部布局 */
.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.progress-title {
  font-size: 16px;
  color: var(--text-primary);
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.progress-title span {
  font-size: 24px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: rgba(82, 196, 26, 0.1); /* 绿色背景 */
  border-radius: 10px;
}

/* 进度数值显示在右上角 */
.progress-number {
  font-size: 32px;
  font-weight: bold;
  color: #52c41a; /* 绿色数字 */
  text-align: right;
}

/* 进度条容器 */
.progress-bar-container {
  margin: 10px 0 25px 0;
  flex-grow: 1;
}

/* 进度条样式 */
.progress-bar {
  width: 100%;
  height: 12px;
  background: rgba(82, 196, 26, 0.1);
  border-radius: 6px;
  overflow: hidden;
  box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.1);
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #52c41a, #73d13d);
  border-radius: 6px;
  transition: width 1s ease-in-out;
  box-shadow: 0 2px 8px rgba(82, 196, 26, 0.3);
  position: relative;
}

.progress-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(90deg, 
    transparent 0%, 
    rgba(255, 255, 255, 0.3) 50%, 
    transparent 100%);
  border-radius: 6px;
}

/* ========== 通用metric-value样式（其他两个卡片用） ========== */
.metric-value {
  font-size: 36px;
  font-weight: bold;
  color: var(--text-primary);
  margin: 10px 0 25px 0;
  line-height: 1.2;
}

/* 学习建议区域调整（保持不变） */
.learning-suggestion {
  background: linear-gradient(135deg, rgba(74, 108, 247, 0.05) 0%, rgba(74, 108, 247, 0.02) 100%);
  border-left: 4px solid rgba(74, 108, 247, 0.3);
  padding: 18px;
  border-radius: 12px;
  margin-top: auto; /* 让建议部分在卡片底部 */
}

.suggestion-title {
  font-weight: 600;
  color: var(--primary-color);
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
}

.suggestion-content {
  color: var(--text-secondary);
  line-height: 1.6;
  font-size: 14px;
}

/* 图表区域 */
.charts-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 25px;
  padding: 0 25px 25px;
}

@media (max-width: 992px) {
  .charts-grid {
    grid-template-columns: 1fr;
  }
}

.chart-container {
  background: var(--card-bg);
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.chart-title {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 15px;
  color: var(--text-primary);
  display: flex;
  align-items: center;
  gap: 8px;
}

.full-width {
  grid-column: 1 / -1;
}

.chart-placeholder {
  height: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: var(--text-light);
}

/* 课程分析区域 */
.course-analysis {
  background: var(--card-bg);
  padding: 25px;
  border-top: 1px solid rgba(0,0,0,0.05);
}

.analysis-title {
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 20px;
  color: var(--text-primary);
}

.course-cards {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 25px;
}

@media (max-width: 992px) {
  .course-cards {
    grid-template-columns: 1fr;
  }
}

.course-card {
  background: var(--card-bg);
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
  border-left: 4px solid var(--info-color);
}

.course-card.excellent {
  border-left-color: var(--success-color);
}

.course-card.good {
  border-left-color: var(--info-color);
}

.course-card.unstable {
  border-left-color: var(--warning-color);
}

.course-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.course-name {
  font-size: 18px;
  font-weight: 600;
}

.course-tag {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
}

.tag-excellent {
  background: rgba(82, 196, 26, 0.1);
  color: var(--success-color);
}

.tag-good {
  background: rgba(24, 144, 255, 0.1);
  color: var(--info-color);
}

.tag-unstable {
  background: rgba(250, 173, 20, 0.1);
  color: var(--warning-color);
}

.course-metrics {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
  margin-bottom: 15px;
}

.course-metric {
  text-align: center;
}

.course-metric-label {
  font-size: 12px;
  color: var(--text-secondary);
  margin-bottom: 5px;
}

.course-metric-value {
  font-size: 20px;
  font-weight: bold;
}

/* 三个指标并排显示的样式 */
.three-metrics-row {
  display: flex;
  justify-content: space-between;
  gap: 15px;
  margin: 20px 0;
}

.metric-item {
  flex: 1;
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, rgba(74, 108, 247, 0.05) 0%, rgba(74, 108, 247, 0.02) 100%);
  border-radius: 12px;
  padding: 15px;
  border: 1px solid rgba(74, 108, 247, 0.1);
  transition: all 0.3s ease;
}

.metric-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(74, 108, 247, 0.1);
  border-color: rgba(74, 108, 247, 0.2);
}

.metric-icon {
  width: 40px;
  height: 40px;
  background: rgba(74, 108, 247, 0.1);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
}

.metric-icon i {
  font-size: 18px;
  color: #4a6cf7;
}

.metric-content {
  flex: 1;
}

.metric-label {
  font-size: 12px;
  color: #666;
  margin-bottom: 5px;
  font-weight: 500;
}

.metric-value {
  font-size: 20px;
  font-weight: bold;
  color: #333;
  line-height: 1.2;
}

/* 不同指标的图标颜色 */
.metric-item:nth-child(1) .metric-icon {
  background: rgba(74, 108, 247, 0.1);
}

.metric-item:nth-child(1) .metric-icon i {
  color: #4a6cf7;
}

.metric-item:nth-child(2) .metric-icon {
  background: rgba(82, 196, 26, 0.1);
}

.metric-item:nth-child(2) .metric-icon i {
  color: #52c41a;
}

.metric-item:nth-child(3) .metric-icon {
  background: rgba(255, 107, 107, 0.1);
}

.metric-item:nth-child(3) .metric-icon i {
  color: #ff6b6b;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .three-metrics-row {
    flex-direction: column;
    gap: 10px;
  }
  
  .metric-item {
    width: 100%;
  }
}

/* 原有的课程卡片样式调整 */
.course-suggestion {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
  padding-top: 15px;
  border-top: 1px solid rgba(0,0,0,0.05);
  margin-top: 15px;
}

/* 章节分析 */
.chapter-analysis {
  margin-top: 25px;
}

.chapter-cards {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.chapter-card {
  background: var(--card-bg);
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border-left: 3px solid var(--info-color);
}

.chapter-card.excellent {
  border-left-color: var(--success-color);
}

.chapter-card.unstable {
  border-left-color: var(--warning-color);
}

.chapter-name {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 8px;
}

.chapter-mastery {
  font-size: 14px;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.chapter-suggestion {
  font-size: 13px;
  color: var(--text-secondary);
  line-height: 1.4;
}

/* 推荐课程 */
.recommendations {
  background: var(--card-bg);
  padding: 25px;
  border-top: 1px solid rgba(0,0,0,0.05);
}

.recommendation-cards {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.recommendation-card {
  background: var(--card-bg);
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
  border-left: 4px solid var(--primary-color);
}

.recommendation-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.recommendation-title {
  font-size: 18px;
  font-weight: 600;
}

.recommendation-tag {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
  background: rgba(74, 108, 247, 0.1);
  color: var(--primary-color);
}

.teacher-info {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
}

.teacher-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--primary-color);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 16px;
  font-weight: bold;
}

.teacher-name {
  font-size: 16px;
  font-weight: 600;
}

.teacher-title {
  font-size: 14px;
  color: var(--text-secondary);
}

.recommendation-desc {
  font-size: 14px;
  color: var(--text-secondary);
  line-height: 1.5;
}

/* 空状态 */
.no-course-panel {
  padding: 40px 20px;
  text-align: center;
  background: #f8f9fa;
  border-radius: 12px;
  margin-bottom: 25px;
}

.no-course-content {
  max-width: 400px;
  margin: 0 auto;
}

.no-course-content i {
  color: #6a5af9;
  margin-bottom: 20px;
}

.no-course-content h4 {
  color: #333333;
  margin-bottom: 10px;
}

.no-course-content p {
  color: #666666;
  margin-bottom: 25px;
}

.enroll-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: linear-gradient(135deg, #4a6cf7, #6a5af9);
  color: white;
  padding: 12px 24px;
  border-radius: 25px;
  text-decoration: none;
  font-weight: 600;
  transition: all 0.3s ease;
}

.enroll-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(74, 108, 247, 0.3);
}

.no-chapter-data {
  padding: 40px 20px;
  text-align: center;
  background: #f8f9fa;
  border-radius: 12px;
}

.no-chapter-data i {
  color: #faad14;
  margin-bottom: 20px;
}

.no-chapter-data h4 {
  color: #333333;
  margin-bottom: 10px;
}

.no-chapter-data p {
  color: #666666;
}

/* 加载状态 */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.95);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.spinner {
  width: 60px;
  height: 60px;
  position: relative;
}

.spinner-circle {
  width: 100%;
  height: 100%;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #4a6cf7;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-text {
  margin-top: 20px;
  color: #333333;
  font-size: 16px;
}

/* 错误状态 */
.error-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.error-content {
  text-align: center;
  max-width: 400px;
  padding: 40px;
}

.error-icon {
  font-size: 64px;
  color: #ff4d4f;
  margin-bottom: 20px;
}

.error-content h3 {
  color: #333333;
  margin-bottom: 10px;
}

.error-message {
  color: #666666;
  margin-bottom: 25px;
}

.retry-btn {
  background: #4a6cf7;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 25px;
  cursor: pointer;
  font-size: 16px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s ease;
}

.retry-btn:hover {
  background: #3a5ce5;
  transform: translateY(-2px);
}


.refresh-button {
  position: fixed;
  top: 80px;
  right: 20px;
  width: 40px;
  height: 40px;
  background: #4a6cf7; /* 直接使用颜色值，避免变量问题 */
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 1000;
  box-shadow: 0 4px 12px rgba(74, 108, 247, 0.3);
  transition: all 0.3s ease;
  border: none;
  outline: none;
}

.refresh-button:hover {
  transform: rotate(90deg);
  background: #6a5af9; /* 直接使用颜色值 */
  box-shadow: 0 6px 16px rgba(74, 108, 247, 0.4);
}

/* 刷新动画效果 */
.refresh-button i.fa-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* 词云卡片样式 */
.wordcloud-card {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 350px;
}

.wordcloud-container {
  flex: 1;
  width: 100%;
  height: 100%;
  position: relative;
  min-height: 280px;
}

/* 图表区域 */
.charts-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 25px;
  padding: 0 25px 25px;
}

@media (max-width: 992px) {
  .charts-grid {
    grid-template-columns: 1fr;
  }
}

.chart-container {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
  display: flex;
  flex-direction: column;
}

.chart-title {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 15px;
  color: #333;
  display: flex;
  align-items: center;
  gap: 8px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f0f0f0;
  flex-shrink: 0;
}

.full-width {
  grid-column: 1 / -1;
}

/* 词云图占位符 */
.wordcloud-placeholder {
  width: 100%;
  height: 100%;
  min-height: 280px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #999;
}

.wordcloud-placeholder i {
  margin-bottom: 15px;
  opacity: 0.5;
}

.wordcloud-placeholder p {
  font-size: 16px;
  margin-bottom: 5px;
}

.wordcloud-placeholder small {
  font-size: 12px;
  color: #ccc;
}

/* 其他图表占位符 */
.chart-placeholder {
  flex: 1;
  width: 100%;
  height: 100%;
  min-height: 280px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #999;
}

.chart-placeholder i {
  margin-bottom: 15px;
  opacity: 0.5;
}

.chart-placeholder p {
  font-size: 16px;
  margin-bottom: 5px;
}

.chart-placeholder small {
  font-size: 12px;
  color: #ccc;
}

/* 倍速分析容器样式 */
.speed-analysis-container {
  position: relative;
  background: linear-gradient(135deg, #f8f9ff 0%, #f0f4ff 100%);
  border: 1px solid rgba(74, 108, 247, 0.1);
  transition: all 0.3s ease;
  overflow: hidden;
}

.speed-analysis-container:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(74, 108, 247, 0.15);
}

.chart-header {
  padding: 20px 20px 10px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
}

.chart-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary, #2c3e50);
  margin-bottom: 5px;
}

.chart-icon {
  font-size: 20px;
  color: #4a6cf7;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
}

.chart-subtitle {
  font-size: 14px;
  color: var(--text-secondary, #7f8c8d);
  margin-left: 30px;
  opacity: 0.8;
}

.chart-content {
  padding: 20px;
  position: relative;
}

.speed-chart-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.speed-chart {
  width: 100%;
  height: 280px;
  min-width: 300px;
  min-height: 280px;
}

.speed-chart-center {
  position: absolute;
  top: 50%;
  left: 40%;
  transform: translate(-50%, -50%);
  text-align: center;
  pointer-events: none;
  z-index: 10;
}

.center-value {
  font-size: 32px;
  font-weight: bold;
  color: var(--primary-color, #4a6cf7);
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.center-label {
  font-size: 14px;
  color: var(--text-secondary, #7f8c8d);
  margin-top: 5px;
}

.center-course {
  font-size: 12px;
  color: var(--text-light, #95a5a6);
  margin-top: 3px;
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .header {
    padding: 20px;
  }
  
  .user-info {
    flex-direction: column;
    text-align: center;
    gap: 15px;
  }
  
  .user-details h1 {
    font-size: 24px;
  }
  
  .filter-section {
    justify-content: center;
  }
  
  .charts-grid,
  .recommendation-cards,
  .chapter-cards {
    grid-template-columns: 1fr;
  }
  
  .speed-chart {
    height: 250px;
    min-height: 250px;
  }
}

@media (max-width: 576px) {
  .metrics {
    grid-template-columns: 1fr;
  }
}
</style>