# 墨知课堂 - 后端文档

## 📋 项目概述

墨知课堂后端是一个基于 Node.js + Express + MySQL 的在线教育平台后端系统，提供课程管理、用户管理、社区互动、AI助手等功能。

## 🛠️ 技术栈

- **运行环境**: Node.js v20.17.0
- **Web框架**: Express.js
- **数据库**: MySQL 8.0
- **身份验证**: JWT (jsonwebtoken)
- **密码加密**: bcryptjs
- **文件上传**: multer
- **跨域处理**: cors
- **环境变量**: dotenv
- **AI服务**: DeepSeek API

## 📁 项目结构

```
backend/
├── config/                 # 配置文件
│   ├── database.js        # 数据库配置
│   └── deepseek.js        # DeepSeek AI配置
├── controllers/           # 控制器层
│   ├── community/         # 社区相关控制器
│   │   ├── commentController.js
│   │   ├── postCommentController.js
│   │   ├── roomController.js
│   │   └── teamController.js
│   ├── coursevideo/       # 课程视频控制器
│   ├── aiController.js
│   ├── authController.js
│   ├── categoryController.js
│   ├── commentController.js
│   ├── courseController.js
│   ├── learningBehaviorController.js
│   ├── likeController.js
│   ├── personalCenterController.js
│   ├── reviewController.js
│   ├── studentBehaviorController.js
│   ├── teacherCenterController.js
│   ├── teacherController.js
│   └── userCourseController.js
├── middleware/            # 中间件
│   ├── auth.js           # 认证中间件
│   ├── errorHandler.js   # 错误处理中间件
│   └── upload.js         # 文件上传中间件
├── migrations/           # 数据库迁移文件
│   ├── create_comment_like_table.sql
│   └── update_user_avatars.sql
├── models/               # 数据模型
│   ├── community/        # 社区模型
│   │   ├── Post.js
│   │   ├── Room.js
│   │   └── Team.js
│   ├── Comment.js
│   ├── Course.js
│   └── userModel.js
├── routes/               # 路由
│   ├── community/        # 社区路由
│   │   ├── commentRoutes.js
│   │   ├── index.js
│   │   ├── postRoutes.js
│   │   ├── roomRoutes.js
│   │   └── teamRoutes.js
│   ├── auth.js
│   ├── categories.js
│   ├── commentRoutes.js
│   ├── courses.js
│   ├── deepseek.js
│   ├── learningBehavior.js
│   ├── personalCenter.js
│   ├── reviews.js
│   ├── studentBehaviorRoutes.js
│   ├── teacherCenter.js
│   ├── teachers.js
│   └── userCourses.js
├── services/             # 服务层
│   ├── deepseekService.js
│   └── studentService.js
├── uploads/              # 上传文件目录
│   ├── avatars/         # 用户头像
│   ├── room-avatars/    # 自习室头像
│   └── videos/          # 视频文件
├── utils/                # 工具函数
│   └── courseStatsUpdater.js
├── .env                  # 环境变量配置
├── server.js            # 服务器入口文件
└── package.json         # 项目依赖配置
```

## 🚀 快速开始

### 1. 环境要求

- Node.js >= 16.0.0
- MySQL >= 8.0
- npm 或 yarn

### 2. 安装依赖

```bash
cd backend
npm install
```

### 3. 配置环境变量

创建 `.env` 文件并配置以下变量：

```env
# 服务器配置
PORT=4000
NODE_ENV=development

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=mzcourse

# JWT配置
JWT_SECRET=mozhicourse-secret-key-2024
JWT_EXPIRES_IN=24h

# DeepSeek AI配置
DEEPSEEK_API_KEY=your_deepseek_api_key
DEEPSEEK_API_URL=https://api.deepseek.com

# 跨域配置
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:8083
```

### 4. 初始化数据库

```bash
# 导入数据库结构
mysql -u root -p mzcourse < ../mzcourse.sql

# 运行迁移文件（如果需要）
mysql -u root -p mzcourse < migrations/create_comment_like_table.sql
mysql -u root -p mzcourse < migrations/update_user_avatars.sql
```

### 5. 启动服务

```bash
# 开发模式
npm run dev

# 生产模式
npm start
```

服务器将在 `http://localhost:4000` 启动

## 📡 API 接口文档

### 基础URL

```
http://localhost:4000/api
```

### 认证方式

大部分接口需要在请求头中携带 JWT Token：

```
Authorization: Bearer <your_token>
```

### 主要接口模块

#### 1. 认证模块 (`/api/auth`)

| 方法 | 路径 | 说明 | 是否需要认证 |
|------|------|------|-------------|
| POST | `/register` | 用户注册 | ❌ |
| POST | `/login` | 用户登录 | ❌ |
| POST | `/logout` | 用户登出 | ✅ |

#### 2. 课程模块 (`/api/courses`)

| 方法 | 路径 | 说明 | 是否需要认证 |
|------|------|------|-------------|
| GET | `/` | 获取课程列表 | ❌ |
| GET | `/:id` | 获取课程详情 | ❌ |
| POST | `/` | 创建课程 | ✅ (教师) |
| PUT | `/:id` | 更新课程 | ✅ (教师) |
| DELETE | `/:id` | 删除课程 | ✅ (教师) |
| GET | `/:id/chapters` | 获取课程章节 | ❌ |
| GET | `/:id/videos` | 获取课程视频 | ✅ |

#### 3. 个人中心模块 (`/api/personal`)

| 方法 | 路径 | 说明 | 是否需要认证 |
|------|------|------|-------------|
| GET | `/profile` | 获取用户信息 | ✅ |
| PUT | `/profile` | 更新用户信息 | ✅ |
| POST | `/avatar` | 上传头像 | ✅ |
| PUT | `/password` | 修改密码 | ✅ |
| GET | `/courses` | 获取我的课程 | ✅ |
| GET | `/library` | 获取学习库 | ✅ |
| GET | `/favorites` | 获取收藏课程 | ✅ |
| POST | `/favorites/:courseId/toggle` | 切换收藏状态 | ✅ |
| GET | `/stats` | 获取学习统计 | ✅ |
| GET | `/achievements` | 获取成就列表 | ✅ |
| GET | `/community` | 获取社区数据 | ✅ |

#### 4. 社区模块 (`/api/community`)

| 方法 | 路径 | 说明 | 是否需要认证 |
|------|------|------|-------------|
| GET | `/posts` | 获取帖子列表 | ❌ |
| POST | `/posts` | 发布帖子 | ✅ |
| GET | `/posts/:id` | 获取帖子详情 | ❌ |
| POST | `/posts/:id/comments` | 评论帖子 | ✅ |
| POST | `/posts/:id/like` | 点赞帖子 | ✅ |
| GET | `/teams` | 获取学习小组列表 | ❌ |
| POST | `/teams` | 创建学习小组 | ✅ |
| POST | `/teams/:id/join` | 加入小组 | ✅ |
| GET | `/rooms` | 获取自习室列表 | ❌ |
| POST | `/rooms` | 创建自习室 | ✅ |
| POST | `/rooms/:id/join` | 加入自习室 | ✅ |

#### 5. 评论模块 (`/api/comments`)

| 方法 | 路径 | 说明 | 是否需要认证 |
|------|------|------|-------------|
| GET | `/course/:courseId` | 获取课程评论 | ❌ |
| POST | `/course/:courseId` | 发表课程评论 | ✅ |
| POST | `/:commentId/like` | 点赞评论 | ✅ |
| POST | `/:commentId/reply` | 回复评论 | ✅ |

#### 6. AI助手模块 (`/api/deepseek`)

| 方法 | 路径 | 说明 | 是否需要认证 |
|------|------|------|-------------|
| POST | `/chat` | AI对话 | ✅ |
| POST | `/analyze` | 学习分析 | ✅ |

#### 7. 教师中心模块 (`/api/teacher-center`)

| 方法 | 路径 | 说明 | 是否需要认证 |
|------|------|------|-------------|
| GET | `/courses` | 获取我的课程 | ✅ (教师) |
| GET | `/students` | 获取学生列表 | ✅ (教师) |
| GET | `/stats` | 获取教学统计 | ✅ (教师) |

## 🗄️ 数据库设计

### 核心表

#### user - 用户表
```sql
- user_id (主键)
- user_name (用户名)
- email (邮箱)
- password_hash (密码哈希)
- avatar_url (头像URL)
- role (角色: learner/instructor/admin)
- register_time (注册时间)
- last_login_time (最后登录时间)
```

#### course - 课程表
```sql
- course_id (主键)
- course_name (课程名称)
- course_desc (课程描述)
- cover_img (封面图片)
- teacher_user_id (教师ID)
- category_id (分类ID)
- difficulty_level (难度等级)
- course_duration (课程时长)
- rating (评分)
- student_count (学生数量)
- created_at (创建时间)
```

#### user_course - 用户课程关系表
```sql
- id (主键)
- user_id (用户ID)
- course_id (课程ID)
- is_enrolled (是否报名)
- is_favorite (是否收藏)
- progress (学习进度)
- enroll_time (报名时间)
- total_learn_duration (总学习时长)
- last_learn_time (最后学习时间)
```

#### course_chapter - 课程章节表
```sql
- chapter_id (主键)
- course_id (课程ID)
- chapter_title (章节标题)
- chapter_order (章节顺序)
- created_at (创建时间)
```

#### course_video - 课程视频表
```sql
- video_id (主键)
- chapter_id (章节ID)
- video_title (视频标题)
- video_url (视频URL)
- video_duration (视频时长)
- video_order (视频顺序)
```

### 社区表

#### community_post - 社区帖子表
```sql
- post_id (主键)
- author_id (作者ID)
- title (标题)
- content (内容)
- likes_count (点赞数)
- comments_count (评论数)
- created_at (创建时间)
```

#### study_team - 学习小组表
```sql
- team_id (主键)
- team_name (小组名称)
- description (描述)
- creator_id (创建者ID)
- current_members (当前成员数)
- max_members (最大成员数)
- created_at (创建时间)
```

#### study_room - 自习室表
```sql
- room_id (主键)
- room_name (自习室名称)
- description (描述)
- host_id (主持人ID)
- current_participants (当前参与人数)
- max_participants (最大参与人数)
- created_at (创建时间)
```

## 🔐 安全机制

### 1. 身份认证

- 使用 JWT (JSON Web Token) 进行身份认证
- Token 有效期：24小时
- Token 包含：userId, username, email, role

### 2. 密码安全

- 使用 bcryptjs 进行密码加密
- Salt rounds: 10
- 密码长度要求：6-20位

### 3. 权限控制

- 基于角色的访问控制 (RBAC)
- 角色类型：
  - `learner`: 学习者
  - `instructor`: 教师
  - `admin`: 管理员

### 4. 文件上传安全

- 文件类型验证
- 文件大小限制：
  - 头像：5MB
  - 视频：100MB
- 文件名随机化

### 5. SQL注入防护

- 使用参数化查询
- 输入验证和清理

## 📊 日志系统

### 日志级别

- `console.log()`: 一般信息
- `console.warn()`: 警告信息
- `console.error()`: 错误信息

### 日志格式

```javascript
console.log('🔍 [功能名称] 操作描述:', 数据);
console.error('❌ [功能名称] 错误描述:', error);
```

### 日志示例

```javascript
console.log('🔐 收到密码修改请求，用户ID:', userId);
console.log('✅ 密码修改成功');
console.error('❌ 修改密码失败:', error);
```

## 🧪 测试

### 运行测试

```bash
npm test
```

### API测试工具

推荐使用以下工具测试API：

- Postman
- Insomnia
- Thunder Client (VS Code插件)

### 测试用户

```javascript
// 学生账号
{
  "email": "student@example.com",
  "password": "123456"
}

// 教师账号
{
  "email": "zhang.teacher@example.com",
  "password": "123456"
}
```

## 🐛 常见问题

### 1. 数据库连接失败

**问题**: `Error: connect ECONNREFUSED`

**解决方案**:
- 检查 MySQL 服务是否启动
- 检查 `.env` 中的数据库配置
- 确认数据库用户权限

### 2. JWT Token 无效

**问题**: `401 Unauthorized`

**解决方案**:
- 检查 Token 是否过期
- 确认 Authorization 头格式正确
- 检查 JWT_SECRET 配置

### 3. 文件上传失败

**问题**: 文件上传返回 400 错误

**解决方案**:
- 检查文件大小是否超限
- 确认文件类型是否支持
- 检查 uploads 目录权限

### 4. CORS 错误

**问题**: `Access-Control-Allow-Origin` 错误

**解决方案**:
- 检查 `.env` 中的 ALLOWED_ORIGINS 配置
- 确认前端请求地址在允许列表中

## 📝 开发规范

### 1. 代码风格

- 使用 2 空格缩进
- 使用单引号
- 文件名使用小驼峰命名
- 类名使用大驼峰命名

### 2. 命名规范

- 控制器：`xxxController.js`
- 路由：`xxxRoutes.js` 或 `xxx.js`
- 模型：`XxxModel.js` 或 `Xxx.js`
- 服务：`xxxService.js`

### 3. 注释规范

```javascript
/**
 * 函数说明
 * @param {类型} 参数名 - 参数说明
 * @returns {类型} 返回值说明
 */
```

### 4. 错误处理

```javascript
try {
  // 业务逻辑
} catch (error) {
  console.error('❌ 错误描述:', error);
  res.status(500).json({ 
    success: false, 
    message: '错误信息' 
  });
}
```
