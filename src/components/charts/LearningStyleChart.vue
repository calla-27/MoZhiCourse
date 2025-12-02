<template>
  <div class="learning-style-chart">
    <h3>学习风格分析</h3>
    <div ref="chartRef" style="width: 100%; height: 400px;"></div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';

export default {
  name: 'LearningStyleChart',
  setup() {
    const chartRef = ref(null);
    
    onMounted(() => {
      if (chartRef.value) {
        const chart = echarts.init(chartRef.value);
        const option = {
          title: {
            text: '学习风格分析'
          },
          tooltip: {},
          radar: {
            shape: 'circle',
            indicator: [
              { name: '视觉学习', max: 100 },
              { name: '听觉学习', max: 100 },
              { name: '动手实践', max: 100 },
              { name: '逻辑分析', max: 100 },
              { name: '社交学习', max: 100 },
              { name: '自主学习', max: 100 }
            ]
          },
          series: [{
            name: '学习风格',
            type: 'radar',
            data: [
              {
                value: [85, 70, 60, 90, 50, 80],
                name: '当前风格',
                areaStyle: {
                  color: 'rgba(64, 158, 255, 0.6)'
                }
              }
            ]
          }]
        };
        chart.setOption(option);
      }
    });

    return {
      chartRef
    };
  }
};
</script>