<template>
  <div class="study-trend-chart">
    <h3>学习时长趋势</h3>
    <div class="filter-controls">
      <button 
        v-for="period in timePeriods" 
        :key="period"
        @click="changePeriod(period)"
        :class="{ active: currentPeriod === period }"
      >
        {{ period }}
      </button>
    </div>
    <div ref="chartRef" style="width: 100%; height: 400px;"></div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';

export default {
  name: 'StudyTrendChart',
  setup() {
    const chartRef = ref(null);
    const currentPeriod = ref('本周');
    const timePeriods = ['本周', '本月', '本学期'];
    
    const initChart = () => {
      if (!chartRef.value) return;
      
      const chart = echarts.init(chartRef.value);
      const option = {
        title: {
          text: '学习时长趋势'
        },
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['每日学习时长']
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          boundaryGap: false,
          data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
        },
        yAxis: {
          type: 'value',
          name: '分钟'
        },
        series: [
          {
            name: '每日学习时长',
            type: 'line',
            smooth: true,
            data: [120, 132, 101, 134, 90, 230, 210],
            itemStyle: {
              color: '#67C23A'
            },
            areaStyle: {
              color: {
                type: 'linear',
                x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [{
                  offset: 0, color: 'rgba(103, 194, 58, 0.3)'
                }, {
                  offset: 1, color: 'rgba(103, 194, 58, 0.1)'
                }]
              }
            }
          }
        ]
      };
      chart.setOption(option);
    };
    
    onMounted(() => {
      initChart();
    });
    
    const changePeriod = (period) => {
      currentPeriod.value = period;
      console.log('切换到:', period);
    };

    return {
      chartRef,
      currentPeriod,
      timePeriods,
      changePeriod
    };
  }
};
</script>

<style scoped>
.filter-controls {
  margin-bottom: 20px;
}
.filter-controls button {
  margin: 0 5px;
  padding: 5px 15px;
  border: 1px solid #dcdfe6;
  background: white;
  cursor: pointer;
  border-radius: 4px;
}
.filter-controls button.active {
  background: #409eff;
  color: white;
  border-color: #409eff;
}
</style>