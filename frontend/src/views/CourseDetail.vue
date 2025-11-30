<template>
  <CourseDetailView
    :course="course"
    :instructor="instructor"
    :chapters="chapters"
    :reviews="reviews"
    :related-courses="relatedCourses"
    :course-overview="courseOverview"
    :learning-objectives="learningObjectives"
    :course-features="courseFeatures"
    :active-tab="activeTab"
    :is-favorite="isFavorite"
    :new-rating="newRating"
    :new-review-content="newReviewContent"
    :is-submitting="isSubmitting"
    @update:active-tab="activeTab = $event"
    @toggle-chapter="toggleChapter"
    @go-to-first-video="goToFirstVideo"
    @go-to-video="goToVideo"
    @toggle-favorite="toggleFavorite"
    @update:new-rating="newRating = $event"
    @update:new-review-content="newReviewContent = $event"
    @handle-submit-review="handleSubmitReview"
  />
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import CourseDetailView from '@/components/layout/CourseDetailView.vue'
import { 
  getCourseDetail, 
  getCourseChapters,
  getCourseFavoriteStatus,
  toggleCourseFavorite,
  getCourseReviews,
  getRelatedCourses,
  submitCourseReview
} from '@/api/courseVideo'

const route = useRoute()
const router = useRouter()
const activeTab = ref('overview')
const isFavorite = ref(false)

const course = ref({
  id: null,
  title: '',
  description: '',
  rating: 0,
  reviewCount: 0,
  studentCount: '0',
  duration: 0,
  difficulty: '',
  categoryName: ''
})

const instructor = ref({
  name: '',
  title: '',
  intro: '',
  avatar: ''
})

const chapters = ref([])
const reviews = ref([])
const relatedCourses = ref([])

// 课程扩展信息
const courseOverview = ref('')
const learningObjectives = ref([])
const courseFeatures = ref([])

// 新评价表单
const newRating = ref(5)
const newReviewContent = ref('')
const isSubmitting = ref(false)

const toggleChapter = (chapterId) => {
  const chapter = chapters.value.find(ch => ch.id === chapterId)
  if (chapter) {
    chapter.isOpen = !chapter.isOpen
  }
}

const loadCourseData = async () => {
  const courseId = route.params.courseId || route.params.id
  if (!courseId) return

  try {
    const [courseRes, chaptersRes] = await Promise.all([
      getCourseDetail(courseId),
      getCourseChapters(courseId)
    ])

    const c = (courseRes && courseRes.data) || courseRes || {}
    course.value = {
      id: c.course_id,
      title: c.course_name || '未命名课程',
      description: c.course_desc || '',
      rating: c.rating || 0,
      reviewCount: c.rating_count || 0,
      studentCount: String(c.student_count || 0),
      duration: c.course_duration || 0,
      difficulty: c.difficulty_level || '初级',
      categoryName: c.category_name || '未分类'
    }

    // 解析讲师信息
    instructor.value = {
      name: c.teacher_name || '未知讲师',
      title: c.teacher_occupation || '讲师',
      intro: c.teacher_intro || '暂无介绍',
      avatar: c.teacher_avatar || ''
    }

    // 解析课程扩展信息
    courseOverview.value = c.course_overview || ''
    learningObjectives.value = Array.isArray(c.learning_objectives) ? c.learning_objectives : []
    courseFeatures.value = Array.isArray(c.course_features) ? c.course_features : []

    const rawChapters = (chaptersRes && chaptersRes.data) || chaptersRes || []
    chapters.value = rawChapters.map((ch, index) => {
      const videos = ch.videos || []
      return {
        id: ch.chapter_id,
        title: ch.chapter_title,
        lessonCount: videos.length,
        isOpen: index === 0,
        lessons: videos.map(v => ({
          id: v.video_id,
          title: v.video_title,
          duration: Math.round((v.duration_seconds || 0) / 60) || 0
        }))
      }
    })

    // 加载当前用户是否已收藏
    try {
      const favRes = await getCourseFavoriteStatus(courseId)
      const favData = (favRes && favRes.data) || favRes || {}
      if (typeof favData.isFavorite === 'boolean') {
        isFavorite.value = favData.isFavorite
      } else if (favData.data && typeof favData.data.isFavorite === 'boolean') {
        isFavorite.value = favData.data.isFavorite
      }
    } catch (err) {
      console.warn('获取课程收藏状态失败（可能未登录）:', err?.response?.status)
    }

    // 加载课程评价
    try {
      const reviewsRes = await getCourseReviews(courseId, 10)
      const reviewsData = (reviewsRes && reviewsRes.data) || reviewsRes || []
      reviews.value = (Array.isArray(reviewsData) ? reviewsData : reviewsData.data || []).map(r => ({
        id: r.comment_id,
        name: r.user_name,
        job: r.occupation || '学员',
        avatar: r.user_name ? r.user_name.charAt(0) : '用',
        content: r.comment_content,
        rating: r.rating || 5
      }))
    } catch (err) {
      console.warn('获取课程评价失败:', err)
    }

    // 加载相关课程推荐
    try {
      const relatedRes = await getRelatedCourses(courseId, 4)
      const relatedData = (relatedRes && relatedRes.data) || relatedRes || []
      const courses = Array.isArray(relatedData) ? relatedData : relatedData.data || []
      relatedCourses.value = courses.map(rc => ({
        id: rc.course_id,
        title: rc.course_name,
        description: rc.course_desc,
        instructor: rc.teacher_name || '未知讲师',
        students: String(rc.student_count || 0),
        rating: rc.rating || 0,
        difficulty: rc.difficulty_level || '初级',
        image: rc.cover_img
          ? (rc.cover_img.startsWith('http')
              ? `url(${rc.cover_img})`
              : `url(http://localhost:4000${rc.cover_img})`)
          : 'linear-gradient(135deg, #667eea, #764ba2)'
      }))
    } catch (err) {
      console.warn('获取相关课程失败:', err)
    }
  } catch (error) {
    console.error('加载课程详情失败:', error)
  }
}

const goToFirstVideo = () => {
  if (!course.value.id || !chapters.value.length) return
  const firstChapter = chapters.value[0]
  const firstLesson = firstChapter.lessons && firstChapter.lessons[0]
  if (!firstLesson) return

  router.push(`/course/${course.value.id}/video/${firstLesson.id}`)
}

// 跳转到指定视频
const goToVideo = (videoId) => {
  if (!course.value.id || !videoId) return
  router.push(`/course/${course.value.id}/video/${videoId}`)
}

const toggleFavorite = async () => {
  if (!course.value.id) return

  try {
    const targetStatus = !isFavorite.value
    const res = await toggleCourseFavorite(course.value.id, targetStatus)
    const data = (res && res.data) || res || {}
    const final =
      typeof data.isFavorite === 'boolean'
        ? data.isFavorite
        : data.data && typeof data.data.isFavorite === 'boolean'
          ? data.data.isFavorite
          : targetStatus

    isFavorite.value = final
  } catch (error) {
    console.error('更新收藏状态失败:', error)
  }
}

// 提交课程评价
const handleSubmitReview = async () => {
  if (!course.value.id || !newReviewContent.value.trim()) return
  
  isSubmitting.value = true
  try {
    await submitCourseReview(course.value.id, newRating.value, newReviewContent.value.trim())
    
    // 清空表单
    newRating.value = 5
    newReviewContent.value = ''
    
    // 重新加载评价列表
    const reviewsRes = await getCourseReviews(course.value.id, 10)
    const reviewsData = (reviewsRes && reviewsRes.data) || reviewsRes || []
    reviews.value = (Array.isArray(reviewsData) ? reviewsData : reviewsData.data || []).map(r => ({
      id: r.comment_id,
      name: r.user_name,
      job: r.occupation || '学员',
      avatar: r.user_name ? r.user_name.charAt(0) : '用',
      content: r.comment_content,
      rating: r.rating || 5
    }))
    
    alert('评价提交成功！')
  } catch (error) {
    console.error('提交评价失败:', error)
    if (error.response?.status === 401) {
      alert('请先登录后再发表评价')
    } else {
      alert('评价提交失败，请稍后重试')
    }
  } finally {
    isSubmitting.value = false
  }
}

onMounted(() => {
  loadCourseData()
})

watch(
  () => route.params.courseId,
  () => {
    isFavorite.value = false
    loadCourseData()
  }
)
</script>