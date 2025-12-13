<!-- frontend/src/views/CourseEdit.vue -->
<template>
  <div class="course-edit-wrapper">
    <div class="course-edit">
      <!-- 页面头部 -->
      <div class="page-header">
        <div class="header-content">
          <button class="back-btn" @click="goBack">
            <i class="fas fa-arrow-left"></i>
            <span>返回</span>
          </button>
          <div class="header-title">
            <h1><i class="fas fa-edit"></i> 编辑课程</h1>
            <p>{{ form.course_name || '加载中...' }}</p>
          </div>
        </div>
        
        <!-- 标签页 -->
        <div class="tabs">
          <button class="tab" :class="{ active: activeTab === 'info' }" @click="activeTab = 'info'">
            <i class="fas fa-info-circle"></i> 基本信息
          </button>
          <button class="tab" :class="{ active: activeTab === 'chapters' }" @click="activeTab = 'chapters'">
            <i class="fas fa-list-ol"></i> 章节视频
          </button>
        </div>
      </div>

      <!-- 加载中 -->
      <div v-if="loading" class="loading-container">
        <i class="fas fa-spinner fa-spin"></i>
        <p>加载课程信息...</p>
      </div>

      <!-- 内容区域 -->
      <div v-else class="form-container">
        <!-- 基本信息标签页 -->
        <div v-show="activeTab === 'info'" class="tab-content">
          <div class="form-section">
            <div class="section-title">
              <i class="fas fa-info-circle"></i>
              <span>课程基本信息</span>
            </div>
            
            <div class="form-group">
              <label class="form-label required">课程名称</label>
              <input v-model="form.course_name" type="text" class="form-input"
                placeholder="请输入课程名称" maxlength="100" />
            </div>

            <div class="form-group">
              <label class="form-label required">课程简介</label>
              <textarea v-model="form.description" class="form-textarea"
                placeholder="请输入课程简介..." rows="4" maxlength="500"></textarea>
            </div>

            <div class="form-row">
              <div class="form-group half">
                <label class="form-label">课程分类</label>
                <select v-model="form.category_id" class="form-select">
                  <option value="">请选择分类</option>
                  <option v-for="cat in categories" :key="cat.category_id" :value="cat.category_id">
                    {{ cat.category_name }}
                  </option>
                </select>
              </div>
              <div class="form-group half">
                <label class="form-label">难度等级</label>
                <select v-model="form.difficulty" class="form-select">
                  <option value="beginner">入门级</option>
                  <option value="intermediate">进阶级</option>
                  <option value="advanced">高级</option>
                </select>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">发布状态</label>
              <div class="status-toggle">
                <label class="toggle-option" :class="{ active: form.is_online === 0 }">
                  <input type="radio" v-model="form.is_online" :value="0" />
                  <i class="fas fa-edit"></i> 草稿
                </label>
                <label class="toggle-option" :class="{ active: form.is_online === 1 }">
                  <input type="radio" v-model="form.is_online" :value="1" />
                  <i class="fas fa-globe"></i> 已发布
                </label>
              </div>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" class="btn btn-primary" @click="saveBasicInfo" :disabled="saving">
              <i :class="saving ? 'fas fa-spinner fa-spin' : 'fas fa-save'"></i>
              {{ saving ? '保存中...' : '保存修改' }}
            </button>
          </div>
        </div>

        <!-- 章节视频标签页 -->
        <div v-show="activeTab === 'chapters'" class="tab-content">
          <div class="form-section">
            <div class="section-title">
              <i class="fas fa-list-ol"></i>
              <span>课程章节与视频</span>
              <span class="chapter-count">共 {{ chapters.length }} 章</span>
            </div>
            
            <!-- 章节列表 -->
            <div class="chapters-container">
              <div v-for="(chapter, cIndex) in chapters" :key="chapter.chapter_id || cIndex" class="chapter-card">
                <div class="chapter-header">
                  <div class="chapter-title-row">
                    <span class="chapter-badge">第{{ cIndex + 1 }}章</span>
                    <input v-model="chapter.chapter_title" type="text" class="chapter-title-input"
                      placeholder="输入章节标题..." @blur="updateChapter(chapter)" />
                    <button type="button" class="remove-chapter-btn" @click="deleteChapter(chapter, cIndex)">
                      <i class="fas fa-trash-alt"></i>
                    </button>
                  </div>
                </div>
                
                <!-- 视频列表 -->
                <div class="videos-list">
                  <div v-for="(video, vIndex) in chapter.videos" :key="video.video_id || vIndex" class="video-item">
                    <div class="video-info">
                      <span class="video-index">{{ cIndex + 1 }}.{{ vIndex + 1 }}</span>
                      <input v-model="video.video_title" type="text" class="video-title-input"
                        placeholder="视频标题..." />
                      
                      <div class="video-upload-area">
                        <div v-if="video.video_url || video.file" class="video-preview">
                          <i class="fas fa-video"></i>
                          <span class="video-name">{{ video.file?.name || '已上传' }}</span>
                          <span v-if="video.duration_seconds" class="video-duration">
                            {{ formatDuration(video.duration_seconds) }}
                          </span>
                        </div>
                        <button v-else type="button" class="upload-video-btn" 
                          @click="triggerVideoUpload(cIndex, vIndex, chapter.chapter_id)">
                          <i class="fas fa-cloud-upload-alt"></i> 上传视频
                        </button>
                      </div>
                      
                      <button type="button" class="remove-video-btn" @click="deleteVideo(chapter, video, vIndex)">
                        <i class="fas fa-times"></i>
                      </button>
                    </div>
                    
                    <div v-if="video.uploading" class="upload-progress">
                      <div class="progress-bar">
                        <div class="progress-fill" :style="{ width: video.progress + '%' }"></div>
                      </div>
                      <span class="progress-text">{{ video.progress }}%</span>
                    </div>
                  </div>
                  
                  <button type="button" class="add-video-btn" @click="addVideo(chapter, cIndex)">
                    <i class="fas fa-plus"></i> 添加视频
                  </button>
                </div>
              </div>
              
              <button type="button" class="add-chapter-btn" @click="addChapter">
                <i class="fas fa-plus-circle"></i> 添加新章节
              </button>
            </div>
          </div>
        </div>

        <!-- 隐藏的视频上传input -->
        <input ref="videoInput" type="file" accept="video/mp4,video/webm,video/ogg" 
          @change="handleVideoChange" style="display: none" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  apiGetCategories, apiUpdateCourse, apiCreateChapter, 
  apiUploadVideo, apiCreateVideo, apiGetCourseDetail, apiGetCourseChapters
} from '../api/teacher.js'

const router = useRouter()
const route = useRoute()
const videoInput = ref(null)

const loading = ref(true)
const saving = ref(false)
const activeTab = ref('info')
const categories = ref([])
const chapters = ref([])
const currentVideoTarget = ref({ chapterIndex: 0, videoIndex: 0, chapterId: null })

const form = ref({
  course_id: null,
  course_name: '',
  description: '',
  category_id: '',
  difficulty: 'beginner',
  is_online: 0
})

onMounted(async () => {
  const courseId = route.params.courseId
  console.log('🎯 CourseEdit页面加载，课程ID:', courseId)
  console.log('🎯 完整路由参数:', route.params)
  console.log('🎯 完整路由信息:', route)
  
  if (!courseId) {
    console.error('❌ 课程ID不存在')
    alert('课程ID不存在')
    router.push('/personal/teacher')
    return
  }
  
  form.value.course_id = courseId
  console.log('📝 设置表单课程ID:', form.value.course_id)
  
  try {
    console.log('🔄 开始加载课程数据...')
    
    // 获取分类
    console.log('📂 获取分类列表...')
    const catRes = await apiGetCategories()
    console.log('📂 分类API响应:', catRes)
    if (catRes.code === 200 || catRes.success) {
      categories.value = catRes.data || []
      console.log('✅ 分类数据加载成功:', categories.value.length, '个分类')
    } else {
      console.error('❌ 分类加载失败:', catRes)
    }
    
    // 获取课程详情
    console.log('📚 获取课程详情，课程ID:', courseId)
    const courseRes = await apiGetCourseDetail(courseId)
    console.log('📚 课程详情API响应:', courseRes)
    console.log('🔍 检查API响应结构:', {
      code: courseRes.code,
      hasData: !!courseRes.data,
      responseKeys: Object.keys(courseRes)
    })
    
    // 修复：后端返回的是 {code: 200, message: '成功', data: ...} 格式
    if (courseRes.code === 200 && courseRes.data) {
      const course = courseRes.data
      console.log('📝 课程数据:', course)
      console.log('📝 课程数据字段:', Object.keys(course))
      
      // 确保字段正确映射
      form.value.course_name = course.course_name || ''
      form.value.description = course.course_desc || course.description || ''
      form.value.category_id = course.category_id || ''
      form.value.difficulty = course.difficulty_level || course.difficulty || 'beginner'
      form.value.is_online = Number(course.is_online) || 0
      
      console.log('✅ 表单数据已填充:', form.value)
    } else {
      console.error('❌ 获取课程详情失败:', courseRes.message || courseRes)
      console.error('❌ 完整响应:', courseRes)
      alert('获取课程信息失败：' + (courseRes.message || '请稍后重试'))
    }
    
    // 获取章节和视频
    const chaptersRes = await apiGetCourseChapters(courseId)
    console.log('📖 章节API响应:', chaptersRes)
    if (chaptersRes.code === 200 && chaptersRes.data) {
      chapters.value = chaptersRes.data.map(ch => ({
        ...ch,
        videos: ch.videos || []
      }))
      console.log('✅ 章节数据加载成功:', chapters.value.length, '个章节')
    } else {
      console.log('⚠️ 没有章节数据或加载失败')
    }
  } catch (error) {
    console.error('加载课程失败:', error)
    alert('加载课程信息时发生错误，请检查网络连接或稍后重试')
  } finally {
    loading.value = false
  }
})

function goBack() {
  router.push('/personal/teacher')
}

// 保存基本信息
async function saveBasicInfo() {
  if (!form.value.course_name.trim()) {
    alert('请输入课程名称')
    return
  }
  
  saving.value = true
  try {
    const res = await apiUpdateCourse(form.value.course_id, {
      course_name: form.value.course_name,
      course_desc: form.value.description,  // 使用正确的字段名
      category_id: form.value.category_id,
      difficulty_level: form.value.difficulty,  // 使用正确的字段名
      is_online: form.value.is_online
    })
    
    if (res.success) {
      alert('保存成功')
    } else {
      alert(res.message || '保存失败')
    }
  } catch (error) {
    alert('保存失败')
  } finally {
    saving.value = false
  }
}

// 添加章节
async function addChapter() {
  const newChapter = {
    chapter_title: '',
    order_index: chapters.value.length + 1,
    videos: [],
    isNew: true
  }
  chapters.value.push(newChapter)
}

// 更新章节（失去焦点时保存）
async function updateChapter(chapter) {
  if (!chapter.chapter_title.trim()) return
  
  if (chapter.isNew && !chapter.chapter_id) {
    // 新章节，创建
    try {
      const res = await apiCreateChapter(form.value.course_id, {
        chapter_title: chapter.chapter_title,
        order_index: chapter.order_index
      })
      if (res.success) {
        chapter.chapter_id = res.data.chapter_id
        chapter.isNew = false
        console.log('✅ 章节创建成功')
      }
    } catch (error) {
      console.error('创建章节失败:', error)
    }
  }
}

// 删除章节
async function deleteChapter(chapter, index) {
  if (!confirm('确定删除该章节吗？')) return
  chapters.value.splice(index, 1)
}

// 添加视频
function addVideo(chapter, chapterIndex) {
  if (!chapter.videos) chapter.videos = []
  chapter.videos.push({
    video_title: '',
    video_url: '',
    duration_seconds: 0,
    order_index: chapter.videos.length + 1,
    uploading: false,
    progress: 0,
    isNew: true
  })
}

// 删除视频
function deleteVideo(chapter, video, index) {
  if (!confirm('确定删除该视频吗？')) return
  chapter.videos.splice(index, 1)
}

function triggerVideoUpload(chapterIndex, videoIndex, chapterId) {
  currentVideoTarget.value = { chapterIndex, videoIndex, chapterId }
  videoInput.value?.click()
}

async function handleVideoChange(e) {
  const file = e.target.files[0]
  if (!file) return
  
  if (file.size > 500 * 1024 * 1024) {
    alert('视频大小不能超过500MB')
    return
  }
  
  const { chapterIndex, videoIndex, chapterId } = currentVideoTarget.value
  const chapter = chapters.value[chapterIndex]
  const video = chapter.videos[videoIndex]
  
  video.file = file
  video.uploading = true
  video.progress = 0
  
  // 获取视频时长
  const videoEl = document.createElement('video')
  videoEl.preload = 'metadata'
  videoEl.onloadedmetadata = () => {
    video.duration_seconds = Math.round(videoEl.duration)
    URL.revokeObjectURL(videoEl.src)
  }
  videoEl.src = URL.createObjectURL(file)
  
  if (!video.video_title) {
    video.video_title = file.name.replace(/\.[^/.]+$/, '')
  }
  
  try {
    // 上传视频
    const uploadRes = await apiUploadVideo(file, (progress) => {
      video.progress = progress
    })
    
    if (uploadRes.success) {
      video.video_url = uploadRes.data.url
      
      // 如果章节已保存，创建视频记录
      if (chapterId) {
        await apiCreateVideo(chapterId, {
          video_title: video.video_title,
          video_url: uploadRes.data.url,
          duration_seconds: video.duration_seconds,
          order_index: videoIndex + 1
        })
      }
      console.log('✅ 视频上传成功')
    }
  } catch (error) {
    console.error('上传失败:', error)
    alert('上传失败')
  } finally {
    video.uploading = false
    e.target.value = ''
  }
}

function formatDuration(seconds) {
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}
</script>

<style scoped>
.course-edit-wrapper {
  min-height: 100vh;
  background: linear-gradient(135deg, #f0f4ff 0%, #e8f0fe 50%, #f5f7fa 100%);
  padding-bottom: 60px;
}

.course-edit {
  max-width: 1000px;
  margin: 0 auto;
  padding: 0 24px;
}

.page-header { padding: 30px 0; }

.header-content {
  display: flex;
  align-items: flex-start;
  gap: 20px;
  margin-bottom: 20px;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 10px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s;
}

.back-btn:hover { background: #f5f5f5; color: #1a73e8; border-color: #1a73e8; }

.header-title h1 {
  font-size: 1.6rem;
  color: #202124;
  margin: 0 0 4px 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-title h1 i { color: #1a73e8; }
.header-title p { color: #5f6368; margin: 0; font-size: 0.95rem; }

/* 标签页 */
.tabs {
  display: flex;
  gap: 8px;
  background: white;
  padding: 8px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.tab {
  flex: 1;
  padding: 12px 20px;
  border: none;
  background: transparent;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.95rem;
  color: #666;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.tab:hover { background: #f5f5f5; }
.tab.active { background: linear-gradient(135deg, #1a73e8, #4285f4); color: white; }

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 20px;
  color: #666;
}

.loading-container i { font-size: 2rem; color: #1a73e8; margin-bottom: 16px; }

.form-container {
  background: white;
  border-radius: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  padding: 32px;
  margin-top: 20px;
}

.form-section { margin-bottom: 24px; }

.section-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.1rem;
  font-weight: 600;
  color: #202124;
  margin-bottom: 20px;
}

.section-title i { color: #1a73e8; }
.chapter-count { font-size: 0.85rem; color: #9aa0a6; font-weight: normal; margin-left: auto; }

.form-group { margin-bottom: 20px; }
.form-group.half { flex: 1; }
.form-row { display: flex; gap: 20px; }

.form-label {
  display: block;
  font-size: 0.95rem;
  font-weight: 500;
  color: #3c4043;
  margin-bottom: 8px;
}

.form-label.required::after { content: '*'; color: #ea4335; margin-left: 4px; }

.form-input, .form-select, .form-textarea {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #e8e8e8;
  border-radius: 10px;
  font-size: 1rem;
  color: #202124;
  transition: all 0.3s;
  background: #fafafa;
  box-sizing: border-box;
}

.form-input:focus, .form-select:focus, .form-textarea:focus {
  outline: none;
  border-color: #1a73e8;
  background: white;
}

.form-textarea { resize: vertical; min-height: 100px; }

/* 状态切换 */
.status-toggle { display: flex; gap: 12px; }

.toggle-option {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px;
  border: 2px solid #e8e8e8;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s;
  color: #666;
}

.toggle-option input { display: none; }
.toggle-option:hover { border-color: #1a73e8; }
.toggle-option.active { border-color: #1a73e8; background: #e8f0fe; color: #1a73e8; }

/* 章节样式 */
.chapters-container { display: flex; flex-direction: column; gap: 16px; }

.chapter-card {
  background: #f8fafc;
  border: 1px solid #e8e8e8;
  border-radius: 12px;
  overflow: hidden;
}

.chapter-header {
  background: linear-gradient(135deg, #1a73e8, #4285f4);
  padding: 14px 16px;
}

.chapter-title-row { display: flex; align-items: center; gap: 10px; }

.chapter-badge {
  background: rgba(255,255,255,0.2);
  color: white;
  padding: 4px 10px;
  border-radius: 16px;
  font-size: 0.8rem;
  font-weight: 600;
}

.chapter-title-input {
  flex: 1;
  padding: 8px 12px;
  border: none;
  border-radius: 6px;
  font-size: 0.95rem;
  background: rgba(255,255,255,0.95);
}

.chapter-title-input:focus { outline: none; }

.remove-chapter-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: rgba(255,255,255,0.2);
  color: white;
  border-radius: 6px;
  cursor: pointer;
}

.remove-chapter-btn:hover { background: #ea4335; }

/* 视频列表 */
.videos-list { padding: 16px; display: flex; flex-direction: column; gap: 10px; }

.video-item {
  background: white;
  border: 1px solid #e8e8e8;
  border-radius: 10px;
  padding: 12px;
}

.video-info { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

.video-index {
  background: #e8f0fe;
  color: #1a73e8;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.video-title-input {
  flex: 1;
  min-width: 180px;
  padding: 8px 12px;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  font-size: 0.9rem;
}

.video-title-input:focus { outline: none; border-color: #1a73e8; }

.video-upload-area { display: flex; align-items: center; }

.upload-video-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  background: #e8f0fe;
  border: 1px dashed #1a73e8;
  border-radius: 6px;
  color: #1a73e8;
  cursor: pointer;
  font-size: 0.85rem;
}

.upload-video-btn:hover { background: #d2e3fc; }

.video-preview {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: #e6f4ea;
  border-radius: 6px;
  color: #137333;
  font-size: 0.85rem;
}

.video-name { max-width: 120px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.video-duration { color: #5f6368; }

.remove-video-btn {
  width: 28px;
  height: 28px;
  border: none;
  background: transparent;
  color: #ea4335;
  cursor: pointer;
  border-radius: 50%;
}

.remove-video-btn:hover { background: #ffebee; }

.add-video-btn, .add-chapter-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px;
  border: 2px dashed #d0d0d0;
  border-radius: 10px;
  background: transparent;
  color: #5f6368;
  cursor: pointer;
  transition: all 0.3s;
}

.add-video-btn:hover, .add-chapter-btn:hover { border-color: #1a73e8; color: #1a73e8; background: #f0f7ff; }

.add-chapter-btn { border-color: #1a73e8; background: #f0f7ff; color: #1a73e8; font-weight: 600; }

.upload-progress { display: flex; align-items: center; gap: 10px; margin-top: 10px; }
.upload-progress .progress-bar { flex: 1; height: 5px; background: #e8e8e8; border-radius: 3px; overflow: hidden; }
.upload-progress .progress-fill { height: 100%; background: linear-gradient(90deg, #1a73e8, #34a853); }
.upload-progress .progress-text { font-size: 0.8rem; color: #1a73e8; font-weight: 600; }

/* 按钮 */
.form-actions { display: flex; justify-content: flex-end; gap: 12px; padding-top: 20px; border-top: 1px solid #f0f0f0; }

.btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: all 0.3s;
}

.btn-primary {
  background: linear-gradient(135deg, #1a73e8, #4285f4);
  color: white;
  box-shadow: 0 4px 12px rgba(26, 115, 232, 0.3);
}

.btn-primary:hover:not(:disabled) { transform: translateY(-2px); }
.btn-primary:disabled { opacity: 0.7; cursor: not-allowed; }

@media (max-width: 768px) {
  .form-container { padding: 20px; }
  .form-row { flex-direction: column; }
  .video-info { flex-direction: column; align-items: stretch; }
}
</style>
