<!-- frontend/src/views/CourseCreate.vue -->
<template>
  <div class="course-create-wrapper">
    <div class="course-create">
      <!-- 页面头部 -->
      <div class="page-header">
        <div class="header-content">
          <button class="back-btn" @click="goBack">
            <i class="fas fa-arrow-left"></i>
            <span>返回</span>
          </button>
          <div class="header-title">
            <h1><i class="fas fa-plus-circle"></i> 创建新课程</h1>
            <p>填写课程信息并上传视频，开始您的教学之旅</p>
          </div>
        </div>
        <!-- 步骤指示器 -->
        <div class="steps-indicator">
          <div class="step" :class="{ active: currentStep === 1, completed: currentStep > 1 }">
            <span class="step-num">1</span>
            <span class="step-label">基本信息</span>
          </div>
          <div class="step-line" :class="{ active: currentStep > 1 }"></div>
          <div class="step" :class="{ active: currentStep === 2, completed: currentStep > 2 }">
            <span class="step-num">2</span>
            <span class="step-label">章节视频</span>
          </div>
          <div class="step-line" :class="{ active: currentStep > 2 }"></div>
          <div class="step" :class="{ active: currentStep === 3 }">
            <span class="step-num">3</span>
            <span class="step-label">完成创建</span>
          </div>
        </div>
      </div>

      <!-- 表单容器 -->
      <div class="form-container">
        <!-- 步骤1: 基本信息 -->
        <div v-show="currentStep === 1" class="step-content">
          <div class="form-section">
            <div class="section-title">
              <i class="fas fa-info-circle"></i>
              <span>基本信息</span>
            </div>
            
            <div class="form-group">
              <label class="form-label required">课程名称</label>
              <input v-model="form.course_name" type="text" class="form-input"
                placeholder="请输入课程名称，如：Python从入门到精通" maxlength="100" />
              <span class="char-count">{{ form.course_name.length }}/100</span>
            </div>

            <div class="form-group">
              <label class="form-label required">课程简介</label>
              <textarea v-model="form.description" class="form-textarea"
                placeholder="请输入课程简介，介绍课程的主要内容和学习目标..." rows="4" maxlength="500"></textarea>
              <span class="char-count">{{ form.description.length }}/500</span>
            </div>

            <div class="form-row">
              <div class="form-group half">
                <label class="form-label required">课程分类</label>
                <select v-model="form.category_id" class="form-select">
                  <option value="">请选择分类</option>
                  <option v-for="cat in categories" :key="cat.category_id" :value="cat.category_id">
                    {{ cat.category_name }}
                  </option>
                </select>
              </div>
              <div class="form-group half">
                <label class="form-label required">难度等级</label>
                <select v-model="form.difficulty" class="form-select">
                  <option value="beginner">入门级</option>
                  <option value="intermediate">进阶级</option>
                  <option value="advanced">高级</option>
                </select>
              </div>
            </div>

            <!-- 课程封面 -->
            <div class="form-group">
              <label class="form-label">课程封面 <span class="optional-tag">选填</span></label>
              <div class="cover-upload">
                <div class="upload-area small" @click="triggerCoverUpload" :class="{ 'has-image': form.cover_img }">
                  <img v-if="form.cover_img" :src="form.cover_img" alt="课程封面" class="preview-img" />
                  <div v-else class="upload-placeholder">
                    <i class="fas fa-image"></i>
                    <p>点击上传封面</p>
                  </div>
                </div>
                <input ref="coverInput" type="file" accept="image/jpeg,image/png" @change="handleCoverChange" style="display: none" />
              </div>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" class="btn btn-primary" @click="nextStep">
              下一步：添加章节视频 <i class="fas fa-arrow-right"></i>
            </button>
          </div>
        </div>

        <!-- 步骤2: 章节和视频 -->
        <div v-show="currentStep === 2" class="step-content">
          <div class="form-section">
            <div class="section-title">
              <i class="fas fa-list-ol"></i>
              <span>课程章节与视频</span>
            </div>
            
            <!-- 章节列表 -->
            <div class="chapters-container">
              <div v-for="(chapter, cIndex) in form.chapters" :key="cIndex" class="chapter-card">
                <div class="chapter-header">
                  <div class="chapter-title-row">
                    <span class="chapter-badge">第{{ cIndex + 1 }}章</span>
                    <input v-model="chapter.title" type="text" class="chapter-title-input"
                      placeholder="输入章节标题..." />
                    <button type="button" class="remove-chapter-btn" @click="removeChapter(cIndex)" 
                      v-if="form.chapters.length > 1">
                      <i class="fas fa-trash-alt"></i>
                    </button>
                  </div>
                </div>
                
                <!-- 视频列表 -->
                <div class="videos-list">
                  <div v-for="(video, vIndex) in chapter.videos" :key="vIndex" class="video-item">
                    <div class="video-info">
                      <span class="video-index">{{ cIndex + 1 }}.{{ vIndex + 1 }}</span>
                      <input v-model="video.title" type="text" class="video-title-input"
                        placeholder="视频标题..." />
                      
                      <!-- 视频上传/预览 -->
                      <div class="video-upload-area">
                        <div v-if="video.file || video.url" class="video-preview">
                          <i class="fas fa-video"></i>
                          <span class="video-name">{{ video.file?.name || '已上传' }}</span>
                          <span v-if="video.duration" class="video-duration">{{ formatDuration(video.duration) }}</span>
                        </div>
                        <button v-else type="button" class="upload-video-btn" @click="triggerVideoUpload(cIndex, vIndex)">
                          <i class="fas fa-cloud-upload-alt"></i> 上传视频
                        </button>
                      </div>
                      
                      <button type="button" class="remove-video-btn" @click="removeVideo(cIndex, vIndex)"
                        v-if="chapter.videos.length > 1">
                        <i class="fas fa-times"></i>
                      </button>
                    </div>
                    
                    <!-- 上传进度 -->
                    <div v-if="video.uploading" class="upload-progress">
                      <div class="progress-bar">
                        <div class="progress-fill" :style="{ width: video.progress + '%' }"></div>
                      </div>
                      <span class="progress-text">{{ video.progress }}%</span>
                    </div>
                  </div>
                  
                  <button type="button" class="add-video-btn" @click="addVideo(cIndex)">
                    <i class="fas fa-plus"></i> 添加视频
                  </button>
                </div>
              </div>
              
              <button type="button" class="add-chapter-btn" @click="addChapter">
                <i class="fas fa-plus-circle"></i> 添加新章节
              </button>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="prevStep">
              <i class="fas fa-arrow-left"></i> 上一步
            </button>
            <button type="button" class="btn btn-primary" @click="submitCourse" :disabled="submitting">
              <i :class="submitting ? 'fas fa-spinner fa-spin' : 'fas fa-check'"></i>
              {{ submitting ? '创建中...' : '创建课程' }}
            </button>
          </div>
        </div>

        <!-- 隐藏的视频上传input -->
        <input ref="videoInput" type="file" accept="video/mp4,video/webm,video/ogg" 
          @change="handleVideoChange" style="display: none" />

        <!-- 步骤3: 完成 -->
        <div v-show="currentStep === 3" class="step-content">
          <div class="success-container">
            <div class="success-icon">
              <i class="fas fa-check-circle"></i>
            </div>
            <h2>课程创建成功！</h2>
            <p>您的课程已成功创建，可以在教师中心查看和管理</p>
            <div class="success-actions">
              <button class="btn btn-secondary" @click="createAnother">
                <i class="fas fa-plus"></i> 继续创建
              </button>
              <button class="btn btn-primary" @click="goToTeacherCenter">
                <i class="fas fa-home"></i> 返回教师中心
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { apiCreateCourse, apiGetCategories, apiUploadVideo, apiCreateChapter, apiCreateVideo } from '../api/teacher.js'

const router = useRouter()
const coverInput = ref(null)
const videoInput = ref(null)
const submitting = ref(false)
const categories = ref([])
const currentStep = ref(1)
const currentVideoTarget = ref({ chapterIndex: 0, videoIndex: 0 })

// 表单数据
const form = ref({
  course_name: '',
  description: '',
  category_id: '',
  difficulty: 'beginner',
  cover_img: '',
  chapters: [
    {
      title: '',
      videos: [{ title: '', file: null, url: '', duration: 0, uploading: false, progress: 0 }]
    }
  ]
})

// 获取分类列表
onMounted(async () => {
  try {
    const res = await apiGetCategories()
    if (res.success) {
      categories.value = res.data || []
    }
  } catch (error) {
    console.error('获取分类失败:', error)
  }
})

function goBack() {
  router.push('/personal/teacher')
}

function triggerCoverUpload() {
  coverInput.value?.click()
}

function handleCoverChange(e) {
  const file = e.target.files[0]
  if (file) {
    if (file.size > 5 * 1024 * 1024) {
      alert('图片大小不能超过5MB')
      return
    }
    const reader = new FileReader()
    reader.onload = (event) => {
      form.value.cover_img = event.target.result
    }
    reader.readAsDataURL(file)
  }
}

// 章节操作
function addChapter() {
  form.value.chapters.push({
    title: '',
    videos: [{ title: '', file: null, url: '', duration: 0, uploading: false, progress: 0 }]
  })
}

function removeChapter(index) {
  if (form.value.chapters.length > 1) {
    form.value.chapters.splice(index, 1)
  }
}

// 视频操作
function addVideo(chapterIndex) {
  form.value.chapters[chapterIndex].videos.push({
    title: '', file: null, url: '', duration: 0, uploading: false, progress: 0
  })
}

function removeVideo(chapterIndex, videoIndex) {
  if (form.value.chapters[chapterIndex].videos.length > 1) {
    form.value.chapters[chapterIndex].videos.splice(videoIndex, 1)
  }
}

function triggerVideoUpload(chapterIndex, videoIndex) {
  currentVideoTarget.value = { chapterIndex, videoIndex }
  videoInput.value?.click()
}

function handleVideoChange(e) {
  const file = e.target.files[0]
  if (!file) return
  
  if (file.size > 500 * 1024 * 1024) {
    alert('视频大小不能超过500MB')
    return
  }
  
  const { chapterIndex, videoIndex } = currentVideoTarget.value
  const video = form.value.chapters[chapterIndex].videos[videoIndex]
  video.file = file
  
  // 获取视频时长
  const videoEl = document.createElement('video')
  videoEl.preload = 'metadata'
  videoEl.onloadedmetadata = () => {
    video.duration = Math.round(videoEl.duration)
    URL.revokeObjectURL(videoEl.src)
  }
  videoEl.src = URL.createObjectURL(file)
  
  // 如果没有标题，使用文件名
  if (!video.title) {
    video.title = file.name.replace(/\.[^/.]+$/, '')
  }
  
  e.target.value = ''
}

function formatDuration(seconds) {
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

// 步骤导航
function nextStep() {
  if (currentStep.value === 1) {
    if (!validateBasicInfo()) return
  }
  currentStep.value++
}

function prevStep() {
  currentStep.value--
}

function validateBasicInfo() {
  if (!form.value.course_name.trim()) {
    alert('请输入课程名称')
    return false
  }
  if (!form.value.description.trim()) {
    alert('请输入课程简介')
    return false
  }
  if (!form.value.category_id) {
    alert('请选择课程分类')
    return false
  }
  return true
}

// 提交课程
async function submitCourse() {
  // 验证章节和视频
  for (let i = 0; i < form.value.chapters.length; i++) {
    const chapter = form.value.chapters[i]
    if (!chapter.title.trim()) {
      alert(`请输入第${i + 1}章的标题`)
      return
    }
    for (let j = 0; j < chapter.videos.length; j++) {
      const video = chapter.videos[j]
      if (!video.title.trim()) {
        alert(`请输入第${i + 1}章第${j + 1}个视频的标题`)
        return
      }
      if (!video.file && !video.url) {
        alert(`请上传第${i + 1}章第${j + 1}个视频`)
        return
      }
    }
  }

  submitting.value = true
  try {
    // 1. 创建课程
    const courseData = {
      course_name: form.value.course_name.trim(),
      description: form.value.description.trim(),
      category_id: form.value.category_id || null,
      difficulty: form.value.difficulty,
      cover_img: form.value.cover_img || null
    }
    
    const courseRes = await apiCreateCourse(courseData)
    if (!courseRes.success) {
      alert(courseRes.message || '创建课程失败')
      return
    }
    
    const courseId = courseRes.data.course_id
    console.log('✅ 课程创建成功, ID:', courseId)

    // 2. 创建章节和上传视频
    for (let i = 0; i < form.value.chapters.length; i++) {
      const chapter = form.value.chapters[i]
      
      // 创建章节
      const chapterRes = await apiCreateChapter(courseId, {
        chapter_title: chapter.title,
        order_index: i + 1
      })
      
      if (!chapterRes.success) {
        console.error('创建章节失败:', chapterRes.message)
        continue
      }
      
      const chapterId = chapterRes.data.chapter_id
      console.log(`✅ 章节${i + 1}创建成功, ID:`, chapterId)

      // 上传视频
      for (let j = 0; j < chapter.videos.length; j++) {
        const video = chapter.videos[j]
        video.uploading = true
        video.progress = 0
        
        try {
          // 上传视频文件
          const uploadRes = await apiUploadVideo(video.file, (progress) => {
            video.progress = progress
          })
          
          if (uploadRes.success) {
            // 创建视频记录
            await apiCreateVideo(chapterId, {
              video_title: video.title,
              video_url: uploadRes.data.url,
              duration_seconds: video.duration,
              order_index: j + 1
            })
            console.log(`✅ 视频${j + 1}上传成功`)
          }
        } catch (err) {
          console.error('视频上传失败:', err)
        } finally {
          video.uploading = false
        }
      }
    }

    // 3. 完成
    currentStep.value = 3
  } catch (error) {
    console.error('创建课程失败:', error)
    alert('创建失败，请重试')
  } finally {
    submitting.value = false
  }
}

function createAnother() {
  form.value = {
    course_name: '',
    description: '',
    category_id: '',
    difficulty: 'beginner',
    cover_img: '',
    chapters: [{ title: '', videos: [{ title: '', file: null, url: '', duration: 0, uploading: false, progress: 0 }] }]
  }
  currentStep.value = 1
}

function goToTeacherCenter() {
  router.push('/personal/teacher')
}
</script>

<style scoped>
.course-create-wrapper {
  min-height: 100vh;
  background: linear-gradient(135deg, #f0f4ff 0%, #e8f0fe 50%, #f5f7fa 100%);
  padding-bottom: 60px;
}

.course-create {
  max-width: 1000px;
  margin: 0 auto;
  padding: 0 24px;
}

/* 页面头部 */
.page-header { padding: 30px 0; }

.header-content {
  display: flex;
  align-items: flex-start;
  gap: 20px;
  margin-bottom: 30px;
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

.back-btn:hover {
  background: #f5f5f5;
  color: #1a73e8;
  border-color: #1a73e8;
}

.header-title h1 {
  font-size: 1.8rem;
  color: #202124;
  margin: 0 0 8px 0;
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-title h1 i { color: #1a73e8; }
.header-title p { color: #5f6368; margin: 0; }

/* 步骤指示器 */
.steps-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0;
  background: white;
  padding: 20px 40px;
  border-radius: 16px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.06);
}

.step {
  display: flex;
  align-items: center;
  gap: 10px;
}

.step-num {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #e0e0e0;
  color: #666;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  transition: all 0.3s;
}

.step.active .step-num {
  background: linear-gradient(135deg, #1a73e8, #4285f4);
  color: white;
}

.step.completed .step-num {
  background: #34a853;
  color: white;
}

.step-label {
  color: #666;
  font-size: 0.95rem;
}

.step.active .step-label { color: #1a73e8; font-weight: 600; }

.step-line {
  width: 60px;
  height: 3px;
  background: #e0e0e0;
  margin: 0 16px;
  border-radius: 2px;
  transition: all 0.3s;
}

.step-line.active { background: #34a853; }

/* 表单容器 */
.form-container {
  background: white;
  border-radius: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  padding: 40px;
  margin-top: 24px;
}

.form-section { margin-bottom: 32px; }

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

/* 表单元素 */
.form-group { margin-bottom: 20px; position: relative; }
.form-group.half { flex: 1; }
.form-row { display: flex; gap: 20px; }

.form-label {
  display: block;
  font-size: 0.95rem;
  font-weight: 500;
  color: #3c4043;
  margin-bottom: 8px;
}

.form-label.required::after {
  content: '*';
  color: #ea4335;
  margin-left: 4px;
}

.optional-tag {
  font-size: 0.75rem;
  color: #9aa0a6;
  font-weight: normal;
}

.char-count {
  position: absolute;
  right: 12px;
  bottom: 12px;
  font-size: 0.8rem;
  color: #9aa0a6;
}

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
  box-shadow: 0 0 0 4px rgba(26, 115, 232, 0.1);
}

.form-textarea { resize: vertical; min-height: 100px; }

.form-select {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%235f6368' d='M6 8L1 3h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 16px center;
  padding-right: 40px;
}

/* 封面上传 */
.cover-upload { display: flex; gap: 12px; align-items: flex-start; }

.upload-area.small {
  width: 200px;
  height: 120px;
  border: 2px dashed #d0d0d0;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
  background: #fafafa;
  overflow: hidden;
}

.upload-area.small:hover { border-color: #1a73e8; background: #f0f7ff; }
.upload-area.has-image { border-style: solid; border-color: #1a73e8; }

.upload-placeholder { text-align: center; color: #9aa0a6; }
.upload-placeholder i { font-size: 2rem; color: #1a73e8; margin-bottom: 8px; }
.upload-placeholder p { font-size: 0.9rem; margin: 0; }

.preview-img { width: 100%; height: 100%; object-fit: cover; }

/* 章节样式 */
.chapters-container { display: flex; flex-direction: column; gap: 20px; }

.chapter-card {
  background: #f8fafc;
  border: 1px solid #e8e8e8;
  border-radius: 16px;
  overflow: hidden;
}

.chapter-header {
  background: linear-gradient(135deg, #1a73e8, #4285f4);
  padding: 16px 20px;
}

.chapter-title-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.chapter-badge {
  background: rgba(255,255,255,0.2);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  white-space: nowrap;
}

.chapter-title-input {
  flex: 1;
  padding: 10px 14px;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  background: rgba(255,255,255,0.95);
}

.chapter-title-input:focus { outline: none; box-shadow: 0 0 0 3px rgba(255,255,255,0.3); }

.remove-chapter-btn {
  width: 36px;
  height: 36px;
  border: none;
  background: rgba(255,255,255,0.2);
  color: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.remove-chapter-btn:hover { background: #ea4335; }

/* 视频列表 */
.videos-list { padding: 20px; display: flex; flex-direction: column; gap: 12px; }

.video-item {
  background: white;
  border: 1px solid #e8e8e8;
  border-radius: 12px;
  padding: 16px;
}

.video-info {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.video-index {
  background: #e8f0fe;
  color: #1a73e8;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 600;
}

.video-title-input {
  flex: 1;
  min-width: 200px;
  padding: 10px 14px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 0.95rem;
}

.video-title-input:focus { outline: none; border-color: #1a73e8; }

.video-upload-area { display: flex; align-items: center; }

.upload-video-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: #e8f0fe;
  border: 1px dashed #1a73e8;
  border-radius: 8px;
  color: #1a73e8;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 0.9rem;
}

.upload-video-btn:hover { background: #d2e3fc; }

.video-preview {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  background: #e6f4ea;
  border-radius: 8px;
  color: #137333;
}

.video-preview i { font-size: 1.1rem; }
.video-name { font-size: 0.9rem; max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.video-duration { font-size: 0.8rem; color: #5f6368; }

.remove-video-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  color: #ea4335;
  cursor: pointer;
  border-radius: 50%;
  transition: all 0.3s;
}

.remove-video-btn:hover { background: #ffebee; }

.add-video-btn {
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

.add-video-btn:hover { border-color: #1a73e8; color: #1a73e8; background: #f0f7ff; }

.add-chapter-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 16px;
  border: 2px dashed #1a73e8;
  border-radius: 16px;
  background: #f0f7ff;
  color: #1a73e8;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.3s;
}

.add-chapter-btn:hover { background: #e8f0fe; }

/* 上传进度 */
.upload-progress {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 12px;
}

.upload-progress .progress-bar {
  flex: 1;
  height: 6px;
  background: #e8e8e8;
  border-radius: 3px;
  overflow: hidden;
}

.upload-progress .progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #1a73e8, #34a853);
  transition: width 0.3s;
}

.upload-progress .progress-text {
  font-size: 0.85rem;
  color: #1a73e8;
  font-weight: 600;
}

/* 成功页面 */
.success-container {
  text-align: center;
  padding: 60px 20px;
}

.success-icon {
  width: 100px;
  height: 100px;
  margin: 0 auto 24px;
  background: linear-gradient(135deg, #34a853, #4caf50);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.success-icon i {
  font-size: 3rem;
  color: white;
}

.success-container h2 {
  font-size: 1.8rem;
  color: #202124;
  margin: 0 0 12px 0;
}

.success-container p {
  color: #5f6368;
  margin: 0 0 32px 0;
}

.success-actions {
  display: flex;
  justify-content: center;
  gap: 16px;
}

/* 按钮 */
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  padding-top: 24px;
  border-top: 1px solid #f0f0f0;
}

.btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 28px;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
}

.btn-primary {
  background: linear-gradient(135deg, #1a73e8, #4285f4);
  color: white;
  box-shadow: 0 4px 15px rgba(26, 115, 232, 0.3);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(26, 115, 232, 0.4);
}

.btn-primary:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.btn-secondary {
  background: white;
  color: #5f6368;
  border: 2px solid #e0e0e0;
}

.btn-secondary:hover {
  background: #f5f5f5;
  border-color: #d0d0d0;
}

/* 响应式 */
@media (max-width: 768px) {
  .form-container { padding: 24px; }
  .form-row { flex-direction: column; }
  .steps-indicator { padding: 16px 20px; flex-wrap: wrap; gap: 10px; }
  .step-line { width: 30px; margin: 0 8px; }
  .video-info { flex-direction: column; align-items: stretch; }
  .video-title-input { min-width: auto; }
}
</style>
