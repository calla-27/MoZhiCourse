# 墨知课堂 - 前端文档

## 📋 项目概述

墨知课堂前端是一个基于 Vue 3 + Vite 的现代化在线教育平台前端应用，提供课程学习、社区互动、个人中心等功能。

## 🛠️ 技术栈

- **框架**: Vue 3 (Composition API)
- **构建工具**: Vite 5.x
- **路由**: Vue Router 4.x
- **状态管理**: Pinia
- **HTTP客户端**: Axios
- **UI组件**: 自定义组件
- **图标**: Font Awesome
- **样式**: CSS3 + 自定义样式

## 📁 项目结构

```
frontend/
├── public/                 # 静态资源
│   ├── favicon.ico
│   └── index.html
├── src/
│   ├── api/               # API接口封装
│   │   ├── comment.js     # 评论接口
│   │   ├── community.js   # 社区接口
│   │   ├── courseVideo.js # 课程视频接口
│   │   └── like.js        # 点赞接口
│   ├── assets/            # 资源文件
│   │   ├── student.css    # 学生中心样式
│   │   └── teacher.css    # 教师中心样式
│   ├── components/        # 公共组件
│   │   ├── AIAssistant.vue        # AI助手
│   │   ├── AvatarModal.vue        # 头像上传模态框
│   │   ├── ChapterList.vue        # 章节列表
│   │   ├── DiscussionPanel.vue    # 讨论面板
│   │   ├── EditProfileModal.vue   # 编辑资料模态框
│   │   └── SettingsModal.vue      # 设置模态框
│   ├── router/            # 路由配置
│   │   └── index.js
│   ├── stores/            # Pinia状态管理
│   │   └── user.js        # 用户状态
│   ├── utils/             # 工具函数
│   │   └── request.js     # Axios封装
│   ├── views/             # 页面组件
│   │   ├── Community.vue          # 社区页面
│   │   ├── CourseVideo.vue        # 课程视频页面
│   │   ├── Home.vue               # 首页
│   │   ├── Login.vue              # 登录页面
│   │   ├── PersonalCenterRouter.vue # 个人中心路由
│   │   ├── StudentCenter.vue      # 学生中心
│   │   ├── StudyPair.vue          # 学习组队
│   │   ├── StudyRoom.vue          # 自习室
│   │   └── TeacherCenter.vue      # 教师中心
│   ├── App.vue            # 根组件
│   └── main.js            # 入口文件
├── .gitignore
├── index.html             # HTML模板
├── package.json           # 项目依赖
├── vite.config.js         # Vite配置
└── README.md              # 项目文档
```

## 🚀 快速开始

### 1. 环境要求

- Node.js >= 16.0.0
- npm 或 yarn

### 2. 安装依赖

```bash
cd frontend
npm install
```

### 3. 开发模式

```bash
npm run dev
```

应用将在 `http://localhost:8080` 启动（或其他可用端口）

### 4. 生产构建

```bash
npm run build
```

构建产物将生成在 `dist/` 目录

### 5. 预览生产构建

```bash
npm run preview
```

## 🎨 页面结构

### 1. 首页 (Home.vue)

**功能**:
- 课程展示
- 分类筛选
- 课程搜索
- 热门推荐

**路由**: `/`

### 2. 登录页面 (Login.vue)

**功能**:
- 用户登录
- 用户注册
- 表单验证

**路由**: `/login`

### 3. 课程视频页面 (CourseVideo.vue)

**功能**:
- 视频播放
- 章节列表
- 课程评论
- 学习进度记录
- AI助手

**路由**: `/course/:id`

**组件**:
- `ChapterList`: 章节列表
- `DiscussionPanel`: 讨论面板
- `AIAssistant`: AI助手

### 4. 学生中心 (StudentCenter.vue)

**功能**:
- 个人信息展示
- 学习统计
- 我的学习库
- 我的收藏
- 我的社区
- 我的成就

**路由**: `/personal/student`

**标签页**:
- 学情分析
- 我的学习库
- 我的收藏
- 我的社区
- 我的成就

### 5. 教师中心 (TeacherCenter.vue)

**功能**:
- 课程管理
- 学生管理
- 教学统计
- 课程创建/编辑

**路由**: `/personal/teacher`

### 6. 社区页面 (Community.vue)

**功能**:
- 帖子列表
- 发布帖子
- 评论互动
- 点赞功能
- 学习小组
- 自习室

**路由**: `/community`

**子页面**:
- `/community/teams` - 学习小组
- `/community/rooms` - 自习室
- `/community/posts/:id` - 帖子详情

### 7. 学习组队 (StudyPair.vue)

**功能**:
- 创建学习小组
- 加入小组
- 小组讨论
- 成员管理

**路由**: `/community/teams/:id`

### 8. 自习室 (StudyRoom.vue)

**功能**:
- 创建自习室
- 加入自习室
- 实时互动
- 学习打卡

**路由**: `/community/rooms/:id`

## 🔧 核心功能

### 1. 用户认证

**实现**: `stores/user.js`

```javascript
// 登录
await userStore.login(email, password)

// 登出
await userStore.logout()

// 检查认证状态
const isLoggedIn = userStore.isLoggedIn

// 获取用户信息
await userStore.fetchUserProfile()
```

### 2. 路由守卫

**实现**: `router/index.js`

```javascript
router.beforeEach((to, from, next) => {
  // 检查是否需要认证
  if (to.meta.requiresAuth) {
    // 验证token
    // 检查角色权限
  }
  next()
})
```

### 3. API请求

**实现**: `utils/request.js`

```javascript
// 基础配置
const request = axios.create({
  baseURL: 'http://localhost:4000/api',
  timeout: 30000
})

// 请求拦截器 - 添加Token
request.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// 响应拦截器 - 处理错误
request.interceptors.response.use(
  response => response.data,
  error => {
    // 错误处理
    return Promise.reject(error)
  }
)
```

### 4. 状态管理

**实现**: `stores/user.js`

```javascript
export const useUserStore = defineStore('user', {
  state: () => ({
    userId: null,
    userName: '',
    email: '',
    avatarUrl: '',
    role: '',
    learningStats: {}
  }),
  
  getters: {
    isLoggedIn: (state) => !!state.userId,
    avatar: (state) => state.avatarUrl || ''
  },
  
  actions: {
    async login(email, password) { },
    async logout() { },
    async fetchUserProfile() { },
    async updateProfile(data) { }
  }
})
```

## 📡 API接口调用

### 1. 课程接口

```javascript
// api/courseVideo.js

// 获取课程详情
export const getCourseDetail = (courseId) => {
  return request.get(`/courses/${courseId}`)
}

// 获取课程章节
export const getCourseChapters = (courseId) => {
  return request.get(`/courses/${courseId}/chapters`)
}

// 获取课程视频
export const getCourseVideos = (courseId) => {
  return request.get(`/courses/${courseId}/videos`)
}
```

### 2. 评论接口

```javascript
// api/comment.js

// 获取课程评论
export const getCourseComments = (courseId) => {
  return request.get(`/comments/course/${courseId}`)
}

// 发表评论
export const postComment = (courseId, content) => {
  return request.post(`/comments/course/${courseId}`, { content })
}

// 点赞评论
export const likeComment = (commentId) => {
  return request.post(`/comments/${commentId}/like`)
}
```

### 3. 社区接口

```javascript
// api/community.js

// 获取帖子列表
export const getPosts = (params) => {
  return request.get('/community/posts', { params })
}

// 发布帖子
export const createPost = (data) => {
  return request.post('/community/posts', data)
}

// 获取学习小组
export const getTeams = () => {
  return request.get('/community/teams')
}

// 获取自习室
export const getRooms = () => {
  return request.get('/community/rooms')
}
```

## 🎨 样式规范

### 1. CSS变量

```css
:root {
  --primary-color: #1a73e8;
  --secondary-color: #34a853;
  --danger-color: #ea4335;
  --warning-color: #fbbc04;
  --text-color: #333;
  --border-color: #ddd;
  --bg-color: #f5f7fa;
}
```

### 2. 响应式设计

```css
/* 移动端 */
@media (max-width: 768px) {
  .container {
    padding: 1rem;
  }
}

/* 平板 */
@media (min-width: 769px) and (max-width: 1024px) {
  .container {
    padding: 2rem;
  }
}

/* 桌面端 */
@media (min-width: 1025px) {
  .container {
    padding: 3rem;
  }
}
```

### 3. 组件样式

```vue
<style scoped>
/* 使用 scoped 避免样式污染 */
.component {
  /* 组件样式 */
}
</style>
```

## 🔐 安全机制

### 1. Token管理

```javascript
// 存储Token
localStorage.setItem('token', token)

// 获取Token
const token = localStorage.getItem('token')

// 清除Token
localStorage.removeItem('token')
```

### 2. 路由权限控制

```javascript
// router/index.js
{
  path: '/personal/teacher',
  component: TeacherCenter,
  meta: {
    requiresAuth: true,
    role: 'instructor'
  }
}
```

### 3. XSS防护

- 使用 Vue 的模板语法自动转义
- 避免使用 `v-html`
- 对用户输入进行验证

### 4. CSRF防护

- 使用Token认证
- 避免在URL中传递敏感信息

## 📱 响应式设计

### 断点设置

```javascript
// 移动端: < 768px
// 平板: 768px - 1024px
// 桌面: > 1024px
```

### 适配策略

1. **移动优先**: 先设计移动端，再适配大屏
2. **弹性布局**: 使用 Flexbox 和 Grid
3. **相对单位**: 使用 rem、em、%
4. **媒体查询**: 针对不同设备调整样式

## 🧪 测试

### 单元测试

```bash
npm run test:unit
```

### E2E测试

```bash
npm run test:e2e
```

## 🐛 常见问题

### 1. 跨域问题

**问题**: API请求被CORS阻止

**解决方案**:
```javascript
// vite.config.js
export default {
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true
      }
    }
  }
}
```

### 2. 路由404

**问题**: 刷新页面后404

**解决方案**:
- 使用 Hash 模式
- 或配置服务器重定向到 index.html

### 3. 图片加载失败

**问题**: 课程封面图片不显示

**解决方案**:
- 检查图片URL是否正确
- 确认后端静态文件服务配置
- 使用默认图片作为fallback

### 4. Token过期

**问题**: 401 Unauthorized

**解决方案**:
```javascript
// 在响应拦截器中处理
if (error.response?.status === 401) {
  // 清除Token
  localStorage.removeItem('token')
  // 跳转到登录页
  router.push('/login')
}
```

## 📝 开发规范

### 1. 组件命名

- 使用大驼峰命名: `MyComponent.vue`
- 组件名应该是多个单词
- 基础组件以 `Base` 开头

### 2. Props定义

```javascript
props: {
  title: {
    type: String,
    required: true
  },
  count: {
    type: Number,
    default: 0
  }
}
```

### 3. 事件命名

- 使用 kebab-case: `@update-value`
- 使用动词: `@click`, `@submit`

### 4. 代码注释

```javascript
/**
 * 组件说明
 * @component
 */

/**
 * 方法说明
 * @param {类型} 参数名 - 参数说明
 * @returns {类型} 返回值说明
 */
```
