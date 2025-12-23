<!-- frontend/src/views/TeacherAnalysis.vue -->
<template>
  <div class="teacher-analysis-wrapper">
    <!-- 主内容区域 -->
    <main class="container" v-if="mounted">
      <!-- 页面标题和筛选 -->
      <section class="analysis-header">
        <div class="header-top">
          <button class="back-btn" @click="goBack">
            <i class="fas fa-arrow-left"></i> 返回教师中心
          </button>
          <h1>学情分析看板</h1>
          <div class="user-info">
            <div class="teacher-badge">教师</div>
            <div class="avatar">
              <span>{{ userName?.charAt(0) || 'T' }}</span>
            </div>
          </div>
        </div>
        <div class="class-info">
          <span><i class="fas fa-users"></i> 总学生数：{{ totalStudents || 0 }}人</span>
          <span><i class="fas fa-user-check"></i> 活跃学生：{{ activeStudents || 0 }}人</span>
          <span><i class="fas fa-play-circle"></i> 平均完播率：{{ avgCompletionRate || '0%' }}</span>
          <span><i class="fas fa-star"></i> 优秀学生：{{ excellentStudents || 0 }}人</span>
        </div>
        <div class="filter-section">
          <button 
            v-for="filter in filters" 
            :key="filter.key"
            class="filter-btn" 
            :class="{ active: currentFilter === filter.key }"
            @click="changeFilter(filter.key)"
          >
            {{ filter.label }}
          </button>
        </div>
      </section>

      <!-- 统计卡片 -->
      <section class="stats-grid">
        <div class="stat-card">
          <div class="stat-label">学生平均专注时长</div>
          <div class="stat-value">{{ avgFocusDuration || '0' }}分钟</div>
          <div class="stat-trend">↑ 较上周提升15%</div>
          <div class="positive-feedback">
            <div class="feedback-title">🎉 教学亮点</div>
            <div class="feedback-content">学生专注度持续提升，说明您的课程内容吸引力强，教学方法有效。</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-label">整体完播率</div>
          <div class="stat-value">{{ avgCompletionRate || '0%' }}</div>
          <div class="stat-trend">↑ 较上月提升8%</div>
          <div class="positive-feedback">
            <div class="feedback-title">💡 优化建议</div>
            <div class="feedback-content">完播率持续上升，建议继续保持当前教学节奏和内容难度。</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-label">学生互动参与度</div>
          <div class="stat-value">{{ avgInteractionRate || '0%' }}</div>
          <div class="stat-trend">↑ 提升明显</div>
          <div class="positive-feedback">
            <div class="feedback-title">🌟 优秀表现</div>
            <div class="feedback-content">学生互动积极，课堂氛围活跃，说明您的互动设计非常成功。</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-label">知识掌握度</div>
          <div class="stat-value">{{ avgMasteryRate || '0%' }}</div>
          <div class="stat-trend">↑ 稳步提升</div>
          <div class="positive-feedback">
            <div class="feedback-title">📚 教学成果</div>
            <div class="feedback-content">学生知识掌握度持续提升，证明您的教学内容设计合理有效。</div>
          </div>
        </div>
      </section>

      <!-- 图表区域 -->
      <section class="charts-grid">
        <div class="chart-row">
          <!-- 知识掌握分布环状图 -->
          <div class="chart-container">
            <div class="chart-title">
              <i class="fas fa-chart-pie"></i> 学生知识掌握分布
            </div>
            <div v-if="chartLoaded" ref="masteryChartRef" class="chart"></div>
            <div v-else class="loading">正在加载图表...</div>
          </div>

          <!-- 学习行为词云图 -->
          <div class="chart-container">
            <div class="chart-title">
              <i class="fas fa-cloud"></i> 学习行为词云
            </div>
            <div v-if="chartLoaded" ref="wordCloudChartRef" class="chart"></div>
            <div v-else class="loading">正在加载图表...</div>
          </div>
        </div>

        <!-- 学习行为趋势图 -->
        <div class="chart-container">
          <div class="chart-title">
            <i class="fas fa-chart-line"></i> 学习行为趋势分析
          </div>
          <div v-if="chartLoaded" ref="trendChartRef" class="chart"></div>
          <div v-else class="loading">正在加载图表...</div>
        </div>
      </section>
    </main>

    <!-- 加载中状态 -->
    <div v-if="!mounted" class="loading-container">
      <div class="loading-spinner">
        <i class="fas fa-spinner fa-spin"></i>
        <p>加载中...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user.js'
import * as echarts from 'echarts'
import 'echarts-wordcloud'
import {
  apiTeacherStats,
  apiTeacherCourses,
  apiMasteryDistribution,
  apiKnowledgeWordCloud,
  apiLearningTrend,
  apiTrendOverview
} from '../api/teacher.js'

const router = useRouter()
const userStore = useUserStore()

// 组件挂载状态
const mounted = ref(false)

// 数据状态
const userName = ref('')
const totalStudents = ref(0)
const activeStudents = ref(0)
const avgCompletionRate = ref('0%')
const excellentStudents = ref(0)
const avgFocusDuration = ref('0')
const avgInteractionRate = ref('0%')
const avgMasteryRate = ref('0%')

// 图表相关
const masteryChartRef = ref(null)
const wordCloudChartRef = ref(null)
const trendChartRef = ref(null)
let masteryChart = null
let wordCloudChart = null
let trendChart = null
const chartLoaded = ref(false)
const masteryData = ref([])
const wordCloudData = ref([])

// 趋势数据状态
const trendData = ref({
  weeks: [],
  completion: [],
  interaction: [],
  mastery: [],
  focusDuration: []
})

// 统计卡片数据状态
const statsData = ref({
  overall: {
    focusDuration: '24',
    completionRate: '78%',
    interactionRate: '82%',
    masteryRate: '76%'
  },
  'data-structure': {
    focusDuration: '25',
    completionRate: '82%',
    interactionRate: '80%',
    masteryRate: '79%'
  },
  algorithm: {
    focusDuration: '22',
    completionRate: '78%',
    interactionRate: '78%',
    masteryRate: '75%'
  },
  programming: {
    focusDuration: '27',
    completionRate: '85%',
    interactionRate: '86%',
    masteryRate: '82%'
  }
})


// 筛选器
const filters = ref([
  { key: 'overall', label: '总体教学风格' }
])
const currentFilter = ref('overall')

// 课程统计映射
const courseStatsMap = ref({})

// 初始化页面
onMounted(async () => {
  console.log('📊 学情分析页面加载中...')
  
  try {
    // 获取用户信息
    userName.value = userStore.userName || '教师'
    
    // 获取统计数据
    const statsRes = await apiTeacherStats()
    if (statsRes.success && statsRes.data) {
      totalStudents.value = statsRes.data.students?.total || 0
      activeStudents.value = Math.round(totalStudents.value * 0.8)
      excellentStudents.value = Math.round(totalStudents.value * 0.3)
    }


    // 加载课程筛选器
    await loadCourseFilters()
    
    // 获取趋势概览数据，初始化统计卡片
    const trendRes = await apiTrendOverview()
    if (trendRes.success && trendRes.data && trendRes.data.latest_stats) {
      updateStatsDataFromResponse(trendRes.data.latest_stats)
    }

    await fetchTrendData('overall')
    await loadChartData()
    await nextTick()
    
    mounted.value = true
    await nextTick()

    initCharts()
    chartLoaded.value = true
    
    console.log('✅ 学情分析页面加载完成')
  } catch (error) {
    console.error('❌ 学情分析页面加载失败:', error)
    mounted.value = true
  }
})


// 加载图表数据
async function loadChartData() {
  try {
    // 获取当前筛选器对应的课程ID
    const courseId = currentFilter.value !== 'overall' ? 
      currentFilter.value.replace('course-', '') : null
    
    console.log('📊 正在获取图表数据，当前筛选器:', currentFilter.value, '课程ID:', courseId)
    
    // 获取知识掌握分布数据
    console.log('📊 正在获取知识掌握分布数据...')
    const masteryRes = await apiMasteryDistribution(courseId)
    console.log('📊 知识掌握分布API响应:', masteryRes)
    
    if (masteryRes.success && masteryRes.data && masteryRes.data.length > 0) {
      masteryData.value = masteryRes.data
      console.log('📊 成功获取知识掌握分布数据:', masteryData.value)
    } else {
      console.error('❌ 获取知识掌握分布数据失败')
      console.error('失败详情:', {
        success: masteryRes.success,
        message: masteryRes.message,
        dataLength: masteryRes.data ? masteryRes.data.length : 'undefined'
      })
      masteryData.value = []
    }

    // 获取词云数据（基于学习行为分析）
    
    console.log('📊 正在获取词云数据，当前筛选器:', currentFilter.value)
    console.log('📊 解析的courseId:', courseId)
    
    const wordCloudRes = await apiKnowledgeWordCloud(courseId)
    console.log('📊 词云API完整响应:', JSON.stringify(wordCloudRes, null, 2))
    
    if (wordCloudRes.success && wordCloudRes.data && wordCloudRes.data.length > 0) {
      wordCloudData.value = wordCloudRes.data
      console.log('☁️ 成功获取词云数据:', wordCloudData.value)
    } else {
      console.error('❌ 获取词云数据失败')
      console.error('失败详情:', {
        success: wordCloudRes.success,
        message: wordCloudRes.message,
        error: wordCloudRes.error,
        dataLength: wordCloudRes.data ? wordCloudRes.data.length : 'undefined',
        data: wordCloudRes.data
      })
      
      // 清空词云数据
      wordCloudData.value = []
    }
  } catch (error) {
    console.error('获取图表数据失败:', error)
    // 清空词云数据
    wordCloudData.value = []
  }
}

// 初始化所有图表
function initCharts() {
  // 确保DOM元素存在
  if (!masteryChartRef.value || !wordCloudChartRef.value || !trendChartRef.value) {
    console.warn('图表DOM元素未找到，等待重新初始化...')
    setTimeout(initCharts, 100)
    return
  }
  
  initMasteryChart()
  initWordCloudChart()
  initTrendChart()
  
  // 添加窗口resize监听
  window.addEventListener('resize', handleResize)
  console.log('✅ 所有图表初始化完成')
}

// 初始化知识掌握分布环状图
function initMasteryChart() {
  try {
    if (!masteryChartRef.value) {
      console.error('masteryChartRef元素不存在')
      return
    }
    
    // 销毁旧实例
    if (masteryChart && !masteryChart.isDisposed()) {
      masteryChart.dispose()
    }
    
    masteryChart = echarts.init(masteryChartRef.value)
    
    // 检查是否有掌握度数据
    if (!masteryData.value || masteryData.value.length === 0) {
      console.log('📊 没有知识掌握数据，显示空状态')
      const option = {
        title: {
          text: '暂无学生掌握度数据',
          left: 'center',
          top: 'middle',
          textStyle: {
            color: '#999',
            fontSize: 16
          }
        }
      }
      masteryChart.setOption(option)
      return
    }
    
    console.log('📊 初始化知识掌握分布图，数据:', masteryData.value)
    
    const option = {
      tooltip: {
        trigger: 'item',
        backgroundColor: 'rgba(255, 255, 255, 0.95)',
        borderColor: '#ddd',
        borderWidth: 1,
        borderRadius: 8,
        padding: [10, 15],
        textStyle: {
          color: '#333'
        },
        formatter: function(params) {
          return `
            <div style="font-weight: bold; margin-bottom: 5px;">${params.seriesName}</div>
            <div style="display: flex; align-items: center; gap: 8px;">
              <span style="display: inline-block; width: 10px; height: 10px; background: ${params.color}; border-radius: 50%;"></span>
              <span>${params.name}: ${params.value}人 (${params.percent}%)</span>
            </div>
          `
        }
      },
      legend: {
        orient: 'vertical',
        right: 15,
        top: 'center',
        textStyle: { 
          fontSize: 12,
          color: '#666'
        },
        itemWidth: 12,
        itemHeight: 12,
        itemGap: 8
      },
      series: [{
        name: '知识掌握分布',
        type: 'pie',
        radius: ['45%', '75%'],
        center: ['40%', '50%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 6,
          borderColor: '#fff',
          borderWidth: 2,
          shadowBlur: 10,
          shadowColor: 'rgba(0, 0, 0, 0.1)'
        },
        label: {
          show: true,
          formatter: function(params) {
            if (params.value === 0) return ''
            return `${params.name}\n${params.value}人`
          },
          fontSize: 11,
          color: '#333',
          fontWeight: 'bold'
        },
        labelLine: {
          show: true,
          length: 15,
          length2: 8,
          smooth: true
        },
        emphasis: {
          itemStyle: {
            shadowBlur: 15,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.2)'
          },
          label: {
            show: true,
            fontSize: 14,
            fontWeight: 'bold'
          }
        },
        animationType: 'scale',
        animationEasing: 'elasticOut',
        animationDelay: function (idx) {
          return Math.random() * 200
        },
        data: masteryData.value.filter(item => item.value > 0) // 过滤掉值为0的项
      }]
    }
    
    masteryChart.setOption(option)
    
    // 添加点击事件
    masteryChart.off('click')
    masteryChart.on('click', function(params) {
      console.log(`点击了${params.name}: ${params.value}人`)
      // 这里可以添加点击后的详细展示逻辑
    })
    
    console.log('✅ 知识掌握分布图初始化完成')
  } catch (error) {
    console.error('初始化知识掌握分布图失败:', error)
  }
}

// 初始化学习行为词云图
function initWordCloudChart() {
  try {
    if (!wordCloudChartRef.value) {
      console.error('wordCloudChartRef元素不存在')
      return
    }
    
    // 销毁旧实例
    if (wordCloudChart && !wordCloudChart.isDisposed()) {
      wordCloudChart.dispose()
    }
    
    wordCloudChart = echarts.init(wordCloudChartRef.value)
    
    // 检查是否有词云数据
    if (!wordCloudData.value || wordCloudData.value.length === 0) {
      console.log('📊 没有词云数据，显示空状态')
      const option = {
        title: {
          text: '暂无学习行为数据',
          left: 'center',
          top: 'middle',
          textStyle: {
            color: '#999',
            fontSize: 16
          }
        },
        graphic: {
          elements: [{
            type: 'text',
            left: 'center',
            top: '60%',
            style: {
              text: '开始学习后将显示学习行为词云',
              fontSize: 14,
              fill: '#ccc'
            }
          }]
        }
      }
      wordCloudChart.setOption(option)
      return
    }
    
    console.log('📊 初始化词云图，数据条数:', wordCloudData.value.length)
    console.log('📊 词云数据示例:', wordCloudData.value.slice(0, 3))
    
    // 计算词云数据的权重范围，确保视觉效果明显
    const values = wordCloudData.value.map(item => item.value || item.count || 1)
    const maxValue = Math.max(...values)
    const minValue = Math.min(...values)
    
    // 动态计算字体大小范围，确保差异明显
    const minSize = 14
    const maxSize = Math.max(50, Math.min(80, maxValue / 2))
    
    console.log('📊 词云字体大小范围:', minSize, '-', maxSize, '最大值:', maxValue, '最小值:', minValue)
    
    const option = {
      tooltip: {
        show: true,
        backgroundColor: 'rgba(255, 255, 255, 0.95)',
        borderColor: '#ddd',
        borderWidth: 1,
        borderRadius: 8,
        padding: [10, 15],
        textStyle: {
          color: '#333',
          fontSize: 14
        },
        formatter: function(params) {
          const count = params.data.count || params.value
          const userCount = params.data.userCount || ''
          const avgDuration = params.data.avgDuration || ''
          
          let tooltip = `<div style="font-weight: bold; margin-bottom: 8px; color: #4a6cf7;">${params.name}</div>`
          tooltip += `<div style="margin: 4px 0;">📊 出现次数: <span style="font-weight: bold; color: #52c41a;">${count}次</span></div>`
          
          if (userCount) {
            tooltip += `<div style="margin: 4px 0;">👥 涉及学生: <span style="font-weight: bold; color: #1890ff;">${userCount}人</span></div>`
          }
          
          if (avgDuration) {
            tooltip += `<div style="margin: 4px 0;">⏱️ 平均时长: <span style="font-weight: bold; color: #faad14;">${avgDuration}秒</span></div>`
          }
          
          return tooltip
        }
      },
      series: [{
        type: 'wordCloud',
        shape: 'circle',
        left: 'center',
        top: 'center',
        width: '95%',
        height: '95%',
        sizeRange: [minSize, maxSize],
        rotationRange: [-30, 30],
        rotationStep: 15,
        gridSize: 12,
        drawOutOfBound: false,
        layoutAnimation: true,
        animationDuration: 1000,
        animationEasing: 'cubicOut',
        textStyle: {
          fontFamily: 'Microsoft YaHei, PingFang SC, Helvetica Neue, sans-serif',
          fontWeight: function(params) {
            // 根据数值大小调整字体粗细
            const value = params.value || params.count || 1
            const ratio = value / maxValue
            if (ratio > 0.7) return 'bold'
            if (ratio > 0.4) return '600'
            return 'normal'
          },
          color: function(params) {
            // 根据数值大小使用不同的颜色强度
            const value = params.value || params.count || 1
            const ratio = value / maxValue
            
            const colors = [
              '#4a6cf7', '#6a5af9', '#52c41a', '#1890ff',
              '#faad14', '#f5222d', '#722ed1', '#13c2c2',
              '#eb2f96', '#fa8c16', '#a0d911', '#36cfc9'
            ]
            
            // 高频词使用更鲜艳的颜色
            if (ratio > 0.6) {
              return colors[Math.floor(Math.random() * 4)] // 前4个更鲜艳的颜色
            } else if (ratio > 0.3) {
              return colors[Math.floor(Math.random() * 8)] // 前8个颜色
            } else {
              // 低频词使用较淡的颜色
              const color = colors[Math.floor(Math.random() * colors.length)]
              return color + '80' // 添加透明度
            }
          }
        },
        emphasis: {
          focus: 'self',
          textStyle: {
            textShadowBlur: 15,
            textShadowColor: 'rgba(0, 0, 0, 0.3)',
            fontSize: function(params) {
              const currentSize = params.textStyle.fontSize || minSize
              return Math.min(currentSize * 1.2, maxSize + 10)
            }
          }
        },
        data: wordCloudData.value.map(item => ({
          ...item,
          // 确保value字段存在且合理
          value: Math.max(item.value || item.count || 1, 1)
        }))
      }]
    }
    
    wordCloudChart.setOption(option)
    
    // 添加点击事件
    wordCloudChart.off('click')
    wordCloudChart.on('click', function(params) {
      console.log(`点击了学习行为: ${params.name}, 出现${params.value}次`)
      // 可以添加点击后的详细分析
    })
    
    console.log('✅ 词云图初始化完成')
  } catch (error) {
    console.error('初始化词云图失败:', error)
  }
}

// 使用备选趋势数据
function useFallbackTrendData(type) {
  console.log(`📊 使用${type}的备选趋势数据`);
  
  // 生成模拟的趋势数据
  trendData.value = {
    weeks: ['第1周', '第2周', '第3周', '第4周', '第5周', '第6周', '第7周', '第8周'],
    completion: [72, 75, 78, 76, 80, 82, 85, 83],
    interaction: [68, 71, 74, 72, 76, 78, 81, 79],
    mastery: [65, 68, 71, 69, 73, 75, 78, 76],
    focusDuration: [22, 23, 24, 23, 25, 26, 27, 26]
  };
  
  // 更新趋势图表
  updateTrendChart();
  
  // 更新统计卡片数据
  updateStatsCards(type);
}

// 获取趋势数据
async function fetchTrendData(type = 'overall') {
  try {
    console.log(`📈 正在获取${type}的趋势数据...`);
    const res = await apiLearningTrend(type)
    
    if (res.success && res.data) {
      trendData.value = res.data
      console.log('✅ 趋势数据获取成功:', trendData.value)
      
      // 更新趋势图表
      updateTrendChart()
      
      // 更新统计卡片数据
      updateStatsCards(type)
    } else {
      console.warn('❌ 获取趋势数据失败，使用备选数据')
      useFallbackTrendData(type)
    }
  } catch (error) {
    console.error('获取趋势数据失败:', error)
    useFallbackTrendData(type)
  }
}

// 获取课程趋势数据
async function fetchCourseTrendData(courseId, filterKey) {
  try {
    console.log(`📈 正在获取课程${courseId}的趋势数据...`);
    
    // 调用修改后的API，传递课程ID作为第二个参数
    const res = await apiLearningTrend('course', courseId);
    
    if (res.success && res.data) {
      trendData.value = res.data
      console.log('✅ 课程趋势数据获取成功:', trendData.value)
      
      // 更新趋势图表
      updateTrendChart()
      
      // 从趋势数据中获取最新一周的数据更新统计卡片
      updateCourseStatsFromTrendData(res.data, filterKey)
    } else {
      console.warn('❌ 获取课程趋势数据失败，使用备选数据')
      useFallbackTrendData(filterKey)
    }
  } catch (error) {
    console.error('获取课程趋势数据失败:', error)
    useFallbackTrendData(filterKey)
  }
}

// 从趋势数据更新课程统计
function updateCourseStatsFromTrendData(trendData, filterKey) {
  if (trendData && trendData.weeks && trendData.weeks.length > 0) {
    // 获取最新一周的数据
    const lastIndex = trendData.weeks.length - 1;
    
    // 确保数据存在
    const lastCompletion = trendData.completion && trendData.completion[lastIndex] 
      ? trendData.completion[lastIndex] 
      : 0;
    const lastInteraction = trendData.interaction && trendData.interaction[lastIndex] 
      ? trendData.interaction[lastIndex] 
      : 0;
    const lastMastery = trendData.mastery && trendData.mastery[lastIndex] 
      ? trendData.mastery[lastIndex] 
      : 0;
    const lastFocusDuration = trendData.focusDuration && trendData.focusDuration[lastIndex] 
      ? trendData.focusDuration[lastIndex] 
      : 0;
    
    // 更新显示值
    avgFocusDuration.value = Math.round(lastFocusDuration).toString();
    avgCompletionRate.value = Math.round(lastCompletion) + '%';
    avgInteractionRate.value = Math.round(lastInteraction) + '%';
    avgMasteryRate.value = Math.round(lastMastery) + '%';
    
    // 更新统计数据对象
    statsData.value[filterKey] = {
      focusDuration: Math.round(lastFocusDuration).toString(),
      completionRate: Math.round(lastCompletion) + '%',
      interactionRate: Math.round(lastInteraction) + '%',
      masteryRate: Math.round(lastMastery) + '%'
    };
    
    console.log(`📊 更新课程${filterKey}统计:`, statsData.value[filterKey]);
  } else {
    console.warn('趋势数据为空或格式不正确');
  }
}


// 更新统计卡片
function updateStatsCards(type) {
  const stats = statsData.value[type] || statsData.value.overall
  
  avgFocusDuration.value = stats.focusDuration
  avgCompletionRate.value = stats.completionRate
  avgInteractionRate.value = stats.interactionRate
  avgMasteryRate.value = stats.masteryRate
}

// 加载课程筛选器
async function loadCourseFilters() {
  try {
    // 获取教师的课程列表
    const coursesRes = await apiTeacherCourses()
    console.log('📚 获取到的课程列表:', coursesRes)
    
    if (coursesRes.success && coursesRes.data && coursesRes.data.length > 0) {
      // 动态添加课程筛选器
      const courseFilters = coursesRes.data.map(course => {
        const courseKey = `course-${course.course_id}`
        
        return {
          key: courseKey,
          label: course.course_name,
          courseId: course.course_id
        }
      })
      
      // 更新筛选器数组（保留"总体教学风格"）
      filters.value = [
        { key: 'overall', label: '总体教学风格' },
        ...courseFilters
      ]
      
      console.log('✅ 动态筛选器生成完成:', filters.value)
    } else {
      console.warn('⚠️ 未获取到课程数据，使用默认筛选器')
      // 保持原有的 overall 筛选器
      filters.value = [
        { key: 'overall', label: '总体教学风格' }
      ]
    }
  } catch (error) {
    console.error('加载课程筛选器失败:', error)
    filters.value = [
      { key: 'overall', label: '总体教学风格' }
    ]
  }
}

// 从响应更新统计数据
function updateStatsDataFromResponse(latestStats) {
  if (latestStats) {
    Object.keys(latestStats).forEach(type => {
      const stats = latestStats[type]
      if (stats) {
        // 更新总体数据
        if (type === 'overall') {
          statsData.value.overall = {
            focusDuration: Math.round(stats.focus_duration).toString(),
            completionRate: Math.round(stats.completion_rate) + '%',
            interactionRate: Math.round(stats.interaction_rate) + '%',
            masteryRate: Math.round(stats.mastery_rate) + '%'
          }
        }
        // 更新课程数据（如果前端有对应的课程筛选器）
        else if (type.startsWith('course-')) {
          statsData.value[type] = {
            focusDuration: Math.round(stats.focus_duration).toString(),
            completionRate: Math.round(stats.completion_rate) + '%',
            interactionRate: Math.round(stats.interaction_rate) + '%',
            masteryRate: Math.round(stats.mastery_rate) + '%'
          }
        }
      }
    })
    
    // 初始化显示总体数据
    updateStatsCards('overall')
  }
}


async function changeFilter(filterKey) {
  console.log('切换筛选器:', filterKey);
  console.log('当前筛选器数组:', filters.value);
  currentFilter.value = filterKey;
  
  // 获取课程ID（如果是课程筛选器）
  const courseId = filterKey.startsWith('course-') 
    ? filterKey.replace('course-', '')
    : null;
  console.log('课程ID:', courseId);
  
  // 根据筛选器类型获取数据
  if (filterKey === 'overall') {
    console.log('获取总体数据...');
    fetchTrendData('overall');
  } else if (courseId) {
    console.log(`获取课程${courseId}的数据...`);
    fetchCourseTrendData(courseId, filterKey);
  }
  
  // 重新加载词云数据
  await loadChartData();
  
  // 等待数据加载完成后重新渲染图表
  await nextTick();
  
  setTimeout(() => {
    if (masteryChart && !masteryChart.isDisposed()) {
      console.log('重新初始化知识掌握分布图');
      masteryChart.dispose();
      initMasteryChart();
    }
    if (trendChart && !trendChart.isDisposed()) {
      console.log('重新初始化趋势图');
      trendChart.dispose();
      initTrendChart();
    }
    if (wordCloudChart && !wordCloudChart.isDisposed()) {
      console.log('重新初始化词云图，新数据条数:', wordCloudData.value.length);
      wordCloudChart.dispose();
      initWordCloudChart();
    }
  }, 200);
}

// 初始化趋势图函数
function initTrendChart() {
  try {
    if (!trendChartRef.value) {
      console.error('trendChartRef元素不存在')
      return
    }
    
    // 销毁旧实例
    if (trendChart && !trendChart.isDisposed()) {
      trendChart.dispose()
    }
    
    trendChart = echarts.init(trendChartRef.value)
    
    // 使用实际数据
    updateTrendChart()
    
    console.log('✅ 趋势图初始化完成')
  } catch (error) {
    console.error('初始化趋势图失败:', error)
  }
}

// 更新趋势图函数
function updateTrendChart() {
  if (!trendChart || trendChart.isDisposed()) {
    return
  }
  
  const option = {
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255, 255, 255, 0.95)',
      borderColor: '#ddd',
      borderWidth: 1,
      borderRadius: 8,
      padding: [10, 15],
      textStyle: {
        color: '#333'
      },
      formatter: function(params) {
        const weekName = params[0].axisValue || params[0].name || `第${params[0].dataIndex + 1}周`;
        let html = `<div style="font-weight: bold; margin-bottom: 5px;">${weekName}数据</div>`;

        params.forEach(param => {
          let icon = '📊'
          if (param.seriesName.includes('完播')) icon = '🎯'
          else if (param.seriesName.includes('互动')) icon = '💬'
          else if (param.seriesName.includes('掌握')) icon = '🎓'

          let value = param.value;
          let unit = param.seriesName.includes('时长') ? '分钟' : '%';
          
          html += `<div style="display: flex; justify-content: space-between; margin: 3px 0;">
          <span>${icon} ${param.seriesName}:</span>
          <span style="font-weight: bold; color:${param.color}">
            ${param.value}${param.seriesName.includes('专注时长') ? '分钟' : '%'}
          </span>
        </div>`
        })
        return html
      }
    },
    legend: {
      data: ['课程完播率', '互动参与度', '知识掌握度', '平均专注时长'],
      top: 10,
      textStyle: {
        fontSize: 12
      },
      itemWidth: 15,
      itemHeight: 10,
      itemGap: 15
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '15%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: trendData.value.weeks,
      axisLine: {
        lineStyle: {
          color: '#ccc'
        }
      },
      axisLabel: {
        color: '#666'
      }
    },
    yAxis: [
      {
        type: 'value',
        name: '百分比(%)',
        min: 60,
        max: 100,
        position: 'left',
        axisLine: {
          lineStyle: {
            color: '#4a6cf7'
          }
        },
        splitLine: {
          lineStyle: {
            type: 'dashed',
            color: '#f0f0f0'
          }
        }
      },
      {
        type: 'value',
        name: '分钟',
        min: 15,
        max: 30,
        position: 'right',
        axisLine: {
          lineStyle: {
            color: '#f5222d'
          }
        },
        splitLine: {
          show: false
        }
      }
    ],
    series: [
      {
        name: '课程完播率',
        type: 'line',
        data: trendData.value.completion,
        smooth: true,
        lineStyle: {
          width: 3,
          color: '#4a6cf7'
        },
        itemStyle: {
          color: '#4a6cf7'
        },
        symbol: 'circle',
        symbolSize: 8,
        areaStyle: {
          color: {
            type: 'linear',
            x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(74,108,247,0.3)' },
              { offset: 1, color: 'rgba(74,108,247,0.05)' }
            ]
          }
        },
        emphasis: {
          focus: 'series',
          itemStyle: {
            color: '#4a6cf7',
            borderColor: '#fff',
            borderWidth: 2,
            shadowBlur: 10,
            shadowColor: 'rgba(74,108,247,0.5)'
          }
        }
      },
      {
        name: '互动参与度',
        type: 'line',
        data: trendData.value.interaction,
        smooth: true,
        lineStyle: {
          width: 3,
          color: '#52c41a'
        },
        itemStyle: {
          color: '#52c41a'
        },
        symbol: 'circle',
        symbolSize: 8,
        emphasis: {
          focus: 'series'
        }
      },
      {
        name: '知识掌握度',
        type: 'line',
        data: trendData.value.mastery,
        smooth: true,
        lineStyle: {
          width: 3,
          color: '#faad14'
        },
        itemStyle: {
          color: '#faad14'
        },
        symbol: 'circle',
        symbolSize: 8,
        emphasis: {
          focus: 'series'
        }
      },
      {
        name: '平均专注时长',
        type: 'line',
        yAxisIndex: 1,
        data: trendData.value.focusDuration,
        smooth: true,
        lineStyle: {
          width: 2,
          type: 'dashed',
          color: '#f5222d'
        },
        itemStyle: {
          color: '#f5222d'
        },
        symbol: 'diamond',
        symbolSize: 6,
        emphasis: {
          focus: 'series'
        }
      }
    ],
    dataZoom: [
      {
        type: 'inside',
        xAxisIndex: [0],
        start: 0,
        end: 100
      }
    ]
  }
  
  trendChart.setOption(option, true)
  
  // 添加图表点击事件
  trendChart.off('click')
  trendChart.on('click', function(params) {
    if (params.componentType === 'series') {
      console.log(`点击了第${params.dataIndex + 1}周的${params.seriesName}: ${params.value}`)
      // 这里可以添加更详细的弹窗显示
    }
  })
}


// 窗口resize处理
function handleResize() {
  if (masteryChart && !masteryChart.isDisposed()) masteryChart.resize()
  if (wordCloudChart && !wordCloudChart.isDisposed()) wordCloudChart.resize()
  if (trendChart && !trendChart.isDisposed()) trendChart.resize()
}

// 返回教师中心
function goBack() {
  router.push('/personal/teacher')
}

// 组件卸载时清理
onUnmounted(() => {
  console.log('🔄 清理图表实例...')
  
  // 移除事件监听
  window.removeEventListener('resize', handleResize)
  
  // 安全地销毁图表实例
  const safeDispose = (chartInstance) => {
    if (chartInstance && typeof chartInstance.dispose === 'function' && !chartInstance.isDisposed()) {
      try {
        chartInstance.dispose()
      } catch (error) {
        console.warn('销毁图表实例时出错:', error)
      }
    }
  }
  
  safeDispose(masteryChart)
  safeDispose(wordCloudChart)
  safeDispose(trendChart)
  
  masteryChart = null
  wordCloudChart = null
  trendChart = null
  
  console.log('✅ 图表实例清理完成')
})

</script>

<style scoped>
.teacher-analysis-wrapper {
  min-height: 100vh;
  background: #f5f7fa;
  padding: 10px 0;
  position: relative;
  overflow-x: hidden;
}

.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 20px;
}

.analysis-header {
  background: #ffffff;
  border: 1px solid #e8eaed;
  color: #333;
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 15px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
}

.analysis-header:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

.analysis-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: #1976d2;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.back-btn {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  color: #495057;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  transition: all 0.3s ease;
}

.back-btn:hover {
  background: #e9ecef;
  border-color: #adb5bd;
}

.back-btn i {
  font-size: 16px;
}

.analysis-header h1 {
  font-size: 28px;
  font-weight: 600;
  margin: 0;
  text-align: center;
  flex: 1;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.teacher-badge {
  background: #f9ab00;
  color: white;
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 0.9rem;
  font-weight: 500;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #1976d2;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 18px;
}

.class-info {
  display: flex;
  gap: 30px;
  font-size: 16px;
  opacity: 0.9;
  margin-bottom: 15px;
  flex-wrap: wrap;
  justify-content: center;
}

.class-info span {
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-section {
  display: flex;
  gap: 15px;
  margin-top: 15px;
  flex-wrap: wrap;
  justify-content: center;
}

.filter-btn {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  color: #495057;
  padding: 8px 16px;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 14px;
}

.filter-btn:hover {
  background: #e9ecef;
  border-color: #adb5bd;
}

.filter-btn.active {
  background: #1976d2;
  color: white;
  border-color: #1976d2;
  font-weight: bold;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 15px;
  margin-bottom: 20px;
}

/* 紧凑型数据卡片 */
.stat-card {
  padding: 16px 18px;
  border-radius: 8px;
  position: relative;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  color: #333;
  border: 1px solid #e8eaed;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  background: #ffffff;
  min-height: 120px;
}

.stat-card:nth-child(1) {
  border-left: 4px solid #1976d2;
}
.stat-card:nth-child(2) {
  border-left: 4px solid #388e3c;
}
.stat-card:nth-child(3) {
  border-left: 4px solid #f57c00;
}
.stat-card:nth-child(4) {
  border-left: 4px solid #7b1fa2;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
}

.stat-label {
  color: #666;
  font-size: 12px;
  font-weight: 500;
  margin-bottom: 6px;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #333;
  margin: 8px 0 6px 0;
  line-height: 1;
}

.stat-trend {
  font-size: 11px;
  color: #28a745;
  font-weight: 500;
  background: #f8f9fa;
  padding: 4px 8px;
  border-radius: 12px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  border: 1px solid #e9ecef;
}

.stat-trend::before {
  content: '↗';
  font-size: 12px;
  color: #28a745;
}






/* 在TeacherAnalysis.vue的style部分添加以下样式 */

/* 简化的交互效果 */
.stat-card {
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

/* 加载动画保持简单 */
.loading-spinner {
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}

/* 响应式调整 */
@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .filter-section {
    justify-content: flex-start;
    overflow-x: auto;
    padding-bottom: 10px;
  }
  
  .filter-btn {
    flex-shrink: 0;
  }
}

@media (max-width: 480px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
}






.positive-feedback {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  padding: 8px 10px;
  border-radius: 6px;
  margin-top: 8px;
}

.feedback-title {
  font-weight: 600;
  color: #495057;
  margin-bottom: 4px;
  font-size: 11px;
}

.feedback-content {
  color: #6c757d;
  line-height: 1.4;
  font-size: 10px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.charts-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 15px;
  margin-bottom: 20px;
}

.chart-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

@media (max-width: 992px) {
  .chart-row {
    grid-template-columns: 1fr;
  }
}

.chart-container {
  background: #ffffff;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  border: 1px solid #e8eaed;
  min-height: 300px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.chart-container:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

.chart-title {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 10px;
  color: #333;
  padding-bottom: 8px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  align-items: center;
  gap: 6px;
}

.chart-title i {
  color: #1976d2;
  font-size: 12px;
}

.chart {
  width: 100%;
  height: 250px;
}

.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 250px;
  color: #999;
  font-size: 14px;
}

.loading-container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
}

.loading-spinner {
  text-align: center;
}

.loading-spinner i {
  font-size: 48px;
  color: #1976d2;
  margin-bottom: 20px;
}

.loading-spinner p {
  color: #666;
  font-size: 18px;
}

@media (max-width: 768px) {
  .teacher-analysis-wrapper {
    padding: 10px 0;
  }
  
  .header-top {
    flex-direction: column;
    gap: 15px;
  }
  
  .analysis-header {
    padding: 20px;
  }
  
  .analysis-header h1 {
    font-size: 24px;
    order: 1;
  }
  
  .back-btn {
    order: 2;
    margin-top: 10px;
  }
  
  .user-info {
    order: 3;
    margin-top: 10px;
  }
  
  .class-info {
    flex-direction: column;
    gap: 10px;
  }
  
  .filter-section {
    flex-wrap: wrap;
  }
  
  .chart-container {
    min-height: 400px;
  }
}
</style>