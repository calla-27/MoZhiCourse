<!-- 统计卡片样式变体组件 -->
<template>
  <div class="style-selector">
    <h3>选择卡片样式：</h3>
    <div class="style-options">
      <button @click="changeStyle('modern')" :class="{ active: currentStyle === 'modern' }">
        现代简约
      </button>
      <button @click="changeStyle('gradient')" :class="{ active: currentStyle === 'gradient' }">
        渐变风格
      </button>
      <button @click="changeStyle('glass')" :class="{ active: currentStyle === 'glass' }">
        玻璃拟态
      </button>
      <button @click="changeStyle('dashboard')" :class="{ active: currentStyle === 'dashboard' }">
        仪表盘风格
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, emit } from 'vue'

const currentStyle = ref('dashboard')
const emit = defineEmits(['style-change'])

function changeStyle(style) {
  currentStyle.value = style
  emit('style-change', style)
}
</script>

<style scoped>
.style-selector {
  margin-bottom: 20px;
  padding: 20px;
  background: rgba(255,255,255,0.9);
  border-radius: 12px;
}

.style-options {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.style-options button {
  padding: 8px 16px;
  border: 1px solid #ddd;
  border-radius: 6px;
  background: white;
  cursor: pointer;
  transition: all 0.2s ease;
}

.style-options button:hover {
  background: #f5f5f5;
}

.style-options button.active {
  background: #4a6cf7;
  color: white;
  border-color: #4a6cf7;
}
</style>