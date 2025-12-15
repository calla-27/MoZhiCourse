# 墨知课堂 - 智能在线教育平台

![Version](https://img.shields.io/badge/version-v1.0.0-blue.svg)
![Node](https://img.shields.io/badge/node-%3E%3D16.0.0-green.svg)
![Vue](https://img.shields.io/badge/vue-3.3.4-brightgreen.svg)
![MySQL](https://img.shields.io/badge/mysql-8.0-orange.svg)
![License](https://img.shields.io/badge/license-MIT-yellow.svg)

## 📖 项目简介

墨知课堂是一个功能完善的智能在线教育平台，采用前后端分离架构，集成了课程管理、学习行为分析、AI智能助手等核心功能。平台支持教师和学生双角色体系，提供完整的在线教学与学习解决方案。

### 📋 版本信息
- **当前版本**：v2
- **发布日期**：2025年12月14日
- **开发状态**：稳定版本
- **兼容性**：支持现代浏览器（Chrome 90+, Firefox 88+, Safari 14+）

## 🏗️ 系统架构

### 技术架构
- **前端**：Vue 3 + Composition API + Pinia + Vue Router
- **后端**：Node.js + Express.js + MySQL
- **AI服务**：DeepSeek API集成
- **认证**：JWT Token + bcrypt加密
- **文件处理**：Multer文件上传

### 数据库设计
- **用户系统**：用户管理、角色权限、认证授权
- **课程系统**：课程、章节、视频、分类管理
- **学习系统**：学习记录、进度跟踪、行为分析
- **社区系统**：评论、讨论、互动功能
- **AI系统**：聊天记录、智能分析数据

## 🎯 核心功能板块

### 1. 🎓 学生学习系统

#### 1.1 视频学习模块
- **智能视频播放器**：支持多倍速播放(0.5x-2.0x)、进度记忆、断点续播
- **学习行为追踪**：自动记录播放、暂停、快进、倍速调节等操作
- **学习进度管理**：实时同步学习进度，支持跨设备续播
- **章节导航**：清晰的课程结构，便捷的章节切换

#### 1.2 学习行为分析
- **学习数据统计**：学习时长、完成进度、知识掌握度分析
- **学习风格识别**：基于行为数据自动识别学习偏好和习惯
- **个性化建议**：根据学习表现提供针对性学习建议
- **可视化报表**：使用ECharts展示学习趋势和统计数据

#### 1.3 课程管理
- **课程浏览**：分类浏览、搜索筛选、课程详情查看
- **报名学习**：一键报名、学习库管理、收藏功能
- **学习记录**：详细的学习历史、成绩记录、证书管理

### 2. 👨‍🏫 教师教学系统

#### 2.1 课程创建与管理
- **课程编辑器**：富文本课程描述、封面上传、分类设置
- **章节管理**：灵活的章节结构、视频上传、内容编辑
- **发布控制**：草稿保存、预览功能、上线管理

#### 2.2 学生管理与分析
- **学生监控**：实时查看学生学习状态、进度统计
- **行为分析**：深度分析学生学习行为、识别学习问题
- **教学效果评估**：课程完成率、学生满意度、知识掌握情况

#### 2.3 教师中心
- **数据仪表板**：课程统计、学生数量、评分概览
- **收入管理**：课程收益、学生付费情况统计
- **教学工具**：课程管理工具、学生互动功能

### 3. 🤖 AI智能助手系统

#### 3.1 智能问答
- **DeepSeek集成**：基于先进AI模型的智能对话
- **上下文理解**：结合课程内容提供精准答疑
- **多轮对话**：支持连续对话，保持上下文关联

#### 3.2 学习分析AI
- **行为模式识别**：AI分析学习行为，识别学习模式
- **个性化推荐**：基于学习数据推荐适合的学习路径
- **学习效果预测**：预测学习效果，提前预警学习问题

### 4. 💬 社区互动系统

#### 4.1 评论讨论
- **课程评论**：学生可对课程进行评价和讨论
- **问答互动**：学生提问、教师答疑、同学互助
- **学习小组**：创建学习小组，促进协作学习

#### 4.2 社交功能
- **用户关注**：关注感兴趣的教师和同学
- **学习动态**：分享学习心得、进度更新
- **成就系统**：学习成就、徽章奖励、排行榜

### 5. 📊 数据分析系统

#### 5.1 学习数据分析
- **学习时长统计**：详细的时间分布分析
- **进度跟踪**：课程完成情况、章节掌握度
- **行为分析**：学习习惯、专注度、效率分析

#### 5.2 教学数据分析
- **课程表现**：课程受欢迎程度、完成率统计
- **学生表现**：班级整体学习情况、个体差异分析
- **趋势预测**：基于历史数据预测学习趋势

### 6. 🔐 用户管理系统

#### 6.1 身份认证
- **JWT认证**：安全的Token认证机制
- **角色权限**：学生、教师角色权限管理
- **密码安全**：bcrypt加密，安全存储

#### 6.2 个人中心
- **资料管理**：个人信息编辑、头像上传
- **学习档案**：学习记录、成绩单、证书管理
- **偏好设置**：个性化设置、通知管理

## 🛠 技术栈详解

### 前端技术栈
```
Vue 3 生态系统
├── 核心框架：Vue 3.3.4 + Composition API
├── 状态管理：Pinia 3.0.4 (替代Vuex)
├── 路由管理：Vue Router 4.2.4
├── HTTP客户端：Axios 1.13.2
├── 数据可视化：ECharts 5.6.0 + ECharts WordCloud 2.1.0
├── 时间处理：date-fns 4.1.0
├── JWT解析：jwt-decode 4.0.0
└── 构建工具：Vue CLI 5.0.8
```

### 后端技术栈
```
Node.js 生态系统
├── 运行环境：Node.js
├── Web框架：Express.js 4.18.2
├── 数据库：MySQL 8.0 + mysql2 3.6.0
├── 身份认证：JWT (jsonwebtoken 9.0.2)
├── 密码加密：bcrypt 5.1.1 + bcryptjs 3.0.3
├── 文件上传：Multer 2.0.2
├── 数据验证：Joi 17.9.2 + express-validator 7.3.1
├── 跨域处理：CORS 2.8.5
├── 时间处理：Moment.js 2.29.4
├── HTTP客户端：Axios 1.13.2
├── 环境配置：dotenv 16.3.1
└── 开发工具：nodemon 3.0.1
```

### AI服务集成
- **DeepSeek API**：智能问答、学习分析
- **自然语言处理**：课程内容理解、学习建议生成
- **行为分析算法**：学习模式识别、个性化推荐

### 数据库架构
```
MySQL 数据库设计
├── 用户系统
│   ├── user (用户基础信息)
│   ├── user_course (用户课程关联)
│   └── achievement (成就系统)
├── 课程系统  
│   ├── course (课程信息)
│   ├── course_chapter (课程章节)
│   ├── course_video (课程视频)
│   ├── category (课程分类)
│   └── course_review (课程评价)
├── 学习系统
│   ├── learning_detail (学习详情记录)
│   ├── learning_behavior (学习行为数据)
│   ├── learning_trend (学习趋势分析)
│   └── student_course_performance (学生课程表现)
├── 社区系统
│   ├── comment (评论系统)
│   ├── community_post (社区帖子)
│   └── community_reply (社区回复)
└── AI系统
    └── ai_chat_log (AI聊天记录)
```

## 📁 项目结构详解

```
mzcourse/                           # 项目根目录
├── backend/                        # 后端服务 (Node.js + Express)
│   ├── config/                     # 配置文件目录
│   │   ├── database.js            # MySQL数据库连接配置
│   │   └── deepseek.js            # DeepSeek AI API配置
│   ├── controllers/               # 业务逻辑控制器
│   │   ├── aiController.js        # AI智能助手控制器
│   │   ├── authController.js      # 用户认证控制器
│   │   ├── categoryController.js  # 课程分类控制器
│   │   ├── commentController.js   # 评论系统控制器
│   │   ├── courseController.js    # 课程管理控制器
│   │   ├── learningBehaviorController.js # 学习行为分析
│   │   ├── personalCenterController.js   # 个人中心控制器
│   │   ├── reviewController.js    # 课程评价控制器
│   │   ├── studentBehaviorController.js  # 学生行为分析
│   │   ├── teacherCenterController.js    # 教师中心控制器
│   │   ├── teacherController.js   # 教师管理控制器
│   │   ├── userCourseController.js # 用户课程关联控制器
│   │   └── community/             # 社区功能控制器
│   ├── models/                    # 数据模型层
│   │   ├── categoryModel.js       # 分类数据模型
│   │   ├── Chapter.js             # 章节数据模型
│   │   ├── Comment.js             # 评论数据模型
│   │   ├── Course.js              # 课程数据模型
│   │   ├── courseModel.js         # 课程业务模型
│   │   ├── learningBehaviorModel.js # 学习行为模型
│   │   ├── learningTrendModel.js  # 学习趋势模型
│   │   ├── reviewModel.js         # 评价数据模型
│   │   ├── teacherModel.js        # 教师数据模型
│   │   ├── userCourseModel.js     # 用户课程关联模型
│   │   ├── userModel.js           # 用户数据模型
│   │   ├── centeruser/            # 个人中心相关模型
│   │   ├── community/             # 社区功能模型
│   │   └── coursevideo/           # 课程视频模型
│   ├── routes/                    # 路由定义
│   │   ├── auth.js               # 认证路由
│   │   ├── courses.js            # 课程路由
│   │   ├── categories.js         # 分类路由
│   │   ├── reviews.js            # 评价路由
│   │   ├── teachers.js           # 教师路由
│   │   ├── commentRoutes.js      # 评论路由
│   │   ├── community.js          # 社区路由
│   │   ├── personalCenter.js     # 个人中心路由
│   │   ├── teacherCenter.js      # 教师中心路由
│   │   ├── userCourses.js        # 用户课程路由
│   │   ├── studentBehaviorRoutes.js # 学生行为路由
│   │   ├── learningBehavior.js   # 学习行为路由
│   │   └── deepseek.js           # AI助手路由
│   ├── middleware/               # 中间件
│   │   ├── auth.js              # JWT认证中间件
│   │   ├── errorHandler.js      # 全局错误处理
│   │   └── upload.js            # 文件上传中间件
│   ├── utils/                   # 工具函数
│   │   └── courseStatsUpdater.js # 课程统计更新工具
│   ├── services/                # 业务服务层
│   ├── sql/                     # SQL脚本文件
│   ├── uploads/                 # 文件上传存储目录
│   ├── node_modules/            # 后端依赖包
│   ├── package.json             # 后端依赖配置
│   ├── package-lock.json        # 依赖版本锁定
│   ├── .env                     # 环境变量配置
│   ├── index.js                 # 应用入口文件
│   └── server.js                # 服务器启动文件
├── frontend/                    # 前端应用 (Vue 3)
│   ├── src/                     # 源代码目录
│   │   ├── api/                 # API接口封装
│   │   │   ├── studentBehavior.js # 学生行为API
│   │   │   └── teacher.js       # 教师相关API
│   │   ├── components/          # Vue组件库
│   │   │   ├── CourseVideoPlayer.vue    # 课程视频播放器
│   │   │   ├── StatCardVariants.vue     # 统计卡片组件
│   │   │   └── VideoPlayerWithTracking.vue # 带追踪的视频播放器
│   │   ├── views/               # 页面视图组件
│   │   │   ├── CourseEdit.vue   # 课程编辑页面
│   │   │   ├── CourseVideo.vue  # 视频播放页面
│   │   │   ├── StudentBehaviorAnalysis.vue # 学生行为分析页
│   │   │   ├── TeacherAnalysis.vue # 教师分析页面
│   │   │   ├── TeacherAnalysisStyles.vue # 教师分析样式
│   │   │   └── TeacherCenter.vue # 教师中心页面
│   │   ├── utils/               # 前端工具函数
│   │   │   └── behaviorTracker.js # 行为追踪工具
│   │   ├── router/              # 路由配置
│   │   ├── stores/              # Pinia状态管理
│   │   ├── assets/              # 静态资源
│   │   ├── main.js              # 应用入口文件
│   │   └── README.md            # 前端说明文档
│   ├── public/                  # 公共静态资源
│   ├── node_modules/            # 前端依赖包
│   ├── package.json             # 前端依赖配置
│   └── package-lock.json        # 依赖版本锁定
├── .git/                        # Git版本控制
├── .idea/                       # IDE配置文件
├── .vscode/                     # VS Code配置
├── .gitignore                   # Git忽略文件配置
├── mzcourse_2025-12-13_184829.sql # 数据库结构导出文件
└── README.md                    # 项目说明文档
```

### 关键文件说明

#### 后端核心文件
- `server.js` - Express服务器启动和配置
- `config/database.js` - MySQL数据库连接池配置
- `config/deepseek.js` - DeepSeek AI API配置
- `middleware/auth.js` - JWT认证中间件
- `controllers/studentBehaviorController.js` - 学习行为分析核心逻辑
- `controllers/teacherCenterController.js` - 教师数据统计和管理

#### 前端核心文件
- `src/main.js` - Vue应用入口，Pinia状态管理初始化
- `src/components/CourseVideoPlayer.vue` - 智能视频播放器组件
- `src/views/StudentBehaviorAnalysis.vue` - 学习行为分析界面
- `src/views/TeacherCenter.vue` - 教师管理中心界面
- `src/utils/behaviorTracker.js` - 前端行为追踪工具

## 🚀 快速开始

### 环境要求
- Node.js >= 16.0.0
- MySQL >= 8.0
- npm 或 yarn

### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd mzcourse
```

2. **安装后端依赖**
```bash
cd backend
npm install
```

3. **安装前端依赖**
```bash
cd ../frontend
npm install
```

4. **数据库配置**
```bash
# 创建数据库
mysql -u root -p
CREATE DATABASE mzcourse CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 导入数据结构
mysql -u root -p mzcourse < mzcourse_2025-12-13_184829.sql
```

5. **环境变量配置**
```bash
# 在backend目录下创建.env文件
cd backend
cp .env.example .env

# 编辑.env文件，配置数据库连接信息
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=mzcourse
JWT_SECRET=your_jwt_secret
DEEPSEEK_API_KEY=your_deepseek_api_key
```

6. **启动服务**
```bash
# 启动后端服务
cd backend
npm run dev

# 启动前端服务（新终端）
cd frontend
npm run serve
```

7. **访问应用**
- 前端地址：http://localhost:8080
- 后端API：http://localhost:4000
- API文档：http://localhost:4000

## 🔧 开发指南

### API接口说明

#### 认证接口
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/register` - 用户注册
- `GET /api/auth/profile` - 获取用户信息

#### 课程接口
- `GET /api/courses` - 获取课程列表
- `GET /api/courses/:id` - 获取课程详情
- `POST /api/courses` - 创建课程（教师）
- `PUT /api/courses/:id` - 更新课程（教师）

#### 学习行为分析
- `GET /api/student/behavior/overview` - 学习概览
- `GET /api/student/behavior/course/:id` - 课程分析
- `GET /api/student/behavior/trend` - 学习趋势

#### AI助手
- `POST /api/deepseek/chat` - AI聊天对话

### 前端开发

#### 组件开发规范
```vue
<template>
  <!-- 模板内容 -->
</template>

<script>
import { ref, onMounted } from 'vue'

export default {
  name: 'ComponentName',
  setup() {
    // 组合式API逻辑
    return {
      // 返回响应式数据和方法
    }
  }
}
</script>

<style scoped>
/* 组件样式 */
</style>
```

#### 状态管理
```javascript
// stores/example.js
import { defineStore } from 'pinia'

export const useExampleStore = defineStore('example', {
  state: () => ({
    // 状态定义
  }),
  actions: {
    // 动作定义
  }
})
```

### 后端开发

#### 控制器开发规范
```javascript
// controllers/exampleController.js
exports.getExample = async (req, res) => {
  try {
    // 业务逻辑
    res.json({
      success: true,
      data: result
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    })
  }
}
```

## 📊 核心功能详解

### 学习行为分析系统
- **数据收集**：自动记录学习时长、视频播放速度、完成率等
- **行为分析**：分析学习模式、专注度、学习效率
- **可视化展示**：使用ECharts展示学习趋势和统计数据
- **个性化推荐**：基于学习行为提供个性化建议

### AI智能助手
- **集成DeepSeek API**：提供智能问答功能
- **上下文理解**：结合课程内容提供精准答疑
- **学习建议**：基于学习数据提供个性化学习建议

### 视频播放系统
- **多倍速播放**：支持0.5x-2.0x倍速播放
- **进度跟踪**：自动记录观看进度和完成情况
- **行为追踪**：记录暂停、快进、倍速等操作行为

## 🔒 安全特性

- **JWT身份认证**：安全的用户身份验证
- **密码加密**：使用bcrypt加密用户密码
- **CORS配置**：跨域请求安全控制
- **输入验证**：使用express-validator进行数据验证
- **SQL注入防护**：使用参数化查询防止SQL注入

## 📈 性能优化

- **数据库索引**：关键字段建立索引提升查询性能
- **API缓存**：合理使用缓存减少数据库查询
- **图片压缩**：上传图片自动压缩优化
- **懒加载**：前端组件和路由懒加载
- **代码分割**：webpack代码分割优化加载速度

## 🧪 测试

### 后端测试
```bash
cd backend
npm test
```

### 前端测试
```bash
cd frontend
npm run test
```

## 📦 部署

### 生产环境部署

1. **构建前端**
```bash
cd frontend
npm run build
```

2. **配置生产环境变量**
```bash
# 设置生产环境配置
NODE_ENV=production
```

3. **启动生产服务**
```bash
cd backend
npm start
```