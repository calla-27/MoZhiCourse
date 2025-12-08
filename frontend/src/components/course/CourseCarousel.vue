<template>
  <div class="course-carousel" v-if="courses && courses.length">
    <div class="carousel-inner">
      <div class="carousel-slide" :style="backgroundStyle" @click="goDetail">
        <div class="carousel-tag">精品课程推荐</div>
        <div class="carousel-info">
          <h2 class="carousel-title">{{ currentCourse.title }}</h2>
          <p class="carousel-desc">{{ currentCourse.description }}</p>
          <div class="carousel-meta">
            <span class="teacher">{{ currentCourse.instructor }}</span>
            <span class="stat">{{ currentCourse.students }} 人学习</span>
          </div>
        </div>
      </div>
      <button class="nav-btn prev" @click="prev">‹</button>
      <button class="nav-btn next" @click="next">›</button>
    </div>
    <div class="dots">
      <span
        v-for="(c, index) in courses"
        :key="c.id"
        class="dot"
        :class="{ active: index === currentIndex }"
        @click="goIndex(index)"
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  courses: {
    type: Array,
    default: () => []
  }
})

const router = useRouter()
const currentIndex = ref(0)

watch(
  () => props.courses,
  (list) => {
    if (!list || !list.length) {
      currentIndex.value = 0
    } else if (currentIndex.value >= list.length) {
      currentIndex.value = 0
    }
  },
  { immediate: true }
)

const currentCourse = computed(() => {
  return props.courses[currentIndex.value] || {}
})

const backgroundStyle = computed(() => {
  const c = currentCourse.value
  if (c.cover_img) {
    return {
      backgroundImage: `linear-gradient(120deg, rgba(0,0,0,0.55), rgba(0,0,0,0.35)), url(${c.cover_img})`
    }
  }
  if (c.image) {
    return {
      background: c.image
    }
  }
  return {
    background: 'linear-gradient(135deg, #667eea, #764ba2)'
  }
})

const next = () => {
  if (!props.courses.length) return
  currentIndex.value = (currentIndex.value + 1) % props.courses.length
}

const prev = () => {
  if (!props.courses.length) return
  currentIndex.value = (currentIndex.value - 1 + props.courses.length) % props.courses.length
}

const goIndex = (index) => {
  currentIndex.value = index
}

const goDetail = () => {
  const c = currentCourse.value
  if (c && c.id) {
    router.push(`/course/${c.id}`)
  }
}
</script>

<style scoped>
.course-carousel {
  margin: 40px 0;
}

.carousel-inner {
  position: relative;
  border-radius: 18px;
  overflow: hidden;
  box-shadow: 0 18px 40px rgba(0,0,0,0.12);
}

.carousel-slide {
  height: 260px;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  display: flex;
  align-items: flex-end;
  cursor: pointer;
}

.carousel-tag {
  position: absolute;
  top: 18px;
  left: 22px;
  padding: 4px 12px;
  border-radius: 999px;
  background: rgba(255,255,255,0.9);
  font-size: 12px;
  color: #202124;
}

.carousel-info {
  padding: 22px 26px 24px;
  color: #fff;
  max-width: 70%;
}

.carousel-title {
  font-size: 22px;
  font-weight: 600;
  margin-bottom: 8px;
}

.carousel-desc {
  font-size: 14px;
  opacity: 0.9;
  line-height: 1.6;
  max-height: 3.2em;
  overflow: hidden;
}

.carousel-meta {
  margin-top: 14px;
  font-size: 13px;
  opacity: 0.9;
  display: flex;
  gap: 18px;
}

.nav-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: none;
  background: rgba(255,255,255,0.9);
  box-shadow: 0 2px 6px rgba(0,0,0,0.15);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}

.nav-btn.prev { left: 14px; }
.nav-btn.next { right: 14px; }

.dots {
  display: flex;
  justify-content: center;
  gap: 6px;
  margin-top: 10px;
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #dadce0;
  cursor: pointer;
}

.dot.active {
  background: #1a73e8;
}

@media (max-width: 768px) {
  .carousel-slide {
    height: 220px;
  }
  .carousel-info {
    max-width: 100%;
  }
}
</style>
