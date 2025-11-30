<template>
  <div class="course-card" @click="handleCardClick">
    <div class="course-image" :style="coverStyle">
      <span class="course-difficulty">{{ course.difficulty }}</span>
    </div>
    <div class="course-content">
      <h3 class="course-title">{{ course.title }}</h3>
      <p class="course-description">{{ course.description }}</p>
      <div class="course-meta">
        <span class="instructor">{{ course.instructor }}</span>
        <div class="course-stats">
          <span class="stat"><i class="fas fa-users"></i> {{ course.students }}</span>
          <span class="stat"><i class="fas fa-star"></i> {{ course.rating }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  course: {
    type: Object,
    required: true
  }
})

const router = useRouter()

// 封面样式：优先使用后端返回的 cover_img，其次回退到原有的 course.image
const coverStyle = computed(() => {
  const c = props.course || {}

  if (c.cover_img) {
    return {
      backgroundImage: `url(${c.cover_img})`
    }
  }

  if (c.image) {
    // 兼容之前使用的渐变/纯色背景
    return {
      background: c.image
    }
  }

  return {
    backgroundColor: '#f5f5f5'
  }
})

const handleCardClick = () => {
  router.push(`/course/${props.course.id}`)
}
</script>

<style scoped>
.course-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 3px 15px rgba(0,0,0,0.08);
  transition: all 0.3s ease;
  cursor: pointer;
}

.course-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.15);
}

.course-image {
  width: 100%;
  height: 180px;
  position: relative;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
}

.course-difficulty {
  position: absolute;
  top: 15px;
  right: 15px;
  background: rgba(255,255,255,0.9);
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 12px;
  font-weight: 500;
}

.course-content {
  padding: 20px;
}

.course-title {
  font-size: 1.2rem;
  font-weight: 600;
  margin-bottom: 10px;
  color: #202124;
  line-height: 1.4;
}

.course-description {
  color: #5f6368;
  font-size: 0.9rem;
  margin-bottom: 15px;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.course-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #5f6368;
  font-size: 0.85rem;
}

.instructor {
  font-weight: 500;
}

.course-stats {
  display: flex;
  gap: 15px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 4px;
}
</style>