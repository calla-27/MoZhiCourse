##  目录

- 项目概述
- 技术栈
- 项目结构
- 快速开始
- API 文档
- 数据库设计
- 功能模块
- 开发指南

## 项目概述

iCoursera 个人中心后端提供完整的用户管理、课程学习、社区互动和成就系统功能，支持学生和教师两种角色的差异化服务。

### 核心功能

- 用户认证与授权（JWT）
- 课程管理（学生端/教师端）
- 学习数据统计
- 成就系统
- 社区功能（组队学习、自习室）
- 文件上传（头像、课程封面）

## 🛠 技术栈

- **运行环境**: Node.js 16+
- **Web 框架**: Express 4.18.2
- **数据库**: MySQL 8.0
- **身份验证**: JWT (jsonwebtoken 9.0.2)
- **密码加密**: bcryptjs 2.4.3
- **数据验证**: express-validator 7.0.1
- **文件上传**: multer 1.4.5
- **跨域处理**: cors 2.8.5
- **环境变量**: dotenv 16.3.1

## 项目结构

````
PersonalCenter_RearEnd/
├── src/
│   ├── server.js                 # 应用入口
│   ├── config/
│   │   └── database.js           # 数据库连接配置
│   ├── middleware/
│   │   └── auth.middleware.js    # JWT 认证中间件
│   ├── models/                   # 数据模型层
│   │   ├── user.model.js         # 用户模型
│   │   ├── course.model.js       # 课程模型
│   │   ├── community.model.js    # 社区模型
│   │   └── achievement.model.js  # 成就模型
│   ├── services/                 # 业务逻辑层
│   │   ├── auth.service.js       # 认证服务
│   │   ├── user.service.js       # 用户服务
│   │   ├── student.service.js    # 学生服务
│   │   └── teacher.service.js    # 教师服务
│   └── routes/                   # 路由层
│       ├── auth.routes.js        # 认证路由
│       ├── user.routes.js        # 用户路由
│       ├── student.routes.js     # 学生路由
│       └── teacher.routes.js     # 教师路由
├── uploads/                      # 上传文件目录
│   ├── avatars/                  # 用户头像
│   └── courses/                  # 课程封面
├── .env                          # 环境变量配置
├── package.json                  # 项目依赖
└── README.md                     # 项目文档
````

## 准备工作

### 1. 环境要求

- Node.js >= 16.0.0
- MySQL >= 8.0
- npm 或 yarn

### 2. 安装依赖

```bash
cd PersonalCenter_RearEnd
npm install
```

### 3. 配置环境变量

创建 .env 文件并配置以下参数：

```env
# 服务器配置
PORT=8080
NODE_ENV=development

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=jjy20041001jjy
DB_NAME=icoursera_centers

# JWT配置
JWT_SECRET=your_jwt_secret_key_change_this_in_production
JWT_EXPIRES_IN=7d

# 文件上传配置
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880
```

### 4. 初始化数据库

执行 SQL 脚本创建数据库和表：

```bash
mysql -u root -p < icoursera_centers.sql
```

### 5. 启动服务

```bash
# 开发模式（热重载）
npm run dev

# 生产模式
npm start
```

服务将运行在 `http://localhost:8080`

### 6. 验证启动

访问健康检查接口：

```bash
curl http://localhost:8080/api/health
```

## API 文档

### 认证相关

| 接口                 | 方法 | 说明     | 权限 |
| -------------------- | ---- | -------- | ---- |
| `/api/auth/register` | POST | 用户注册 | 公开 |
| `/api/auth/login`    | POST | 用户登录 | 公开 |
| `/api/health`        | GET  | 健康检查 | 公开 |

### 用户模块

| 接口                | 方法 | 说明         | 权限 |
| ------------------- | ---- | ------------ | ---- |
| `/api/user/profile` | GET  | 获取用户信息 | 认证 |
| `/api/user/profile` | PUT  | 更新用户信息 | 认证 |
| `/api/user/avatar`  | POST | 上传头像     | 认证 |

### 学生模块

| 接口                                        | 方法   | 说明         | 权限 |
| ------------------------------------------- | ------ | ------------ | ---- |
| `/api/student/stats`                        | GET    | 获取学习统计 | 学生 |
| `/api/student/courses`                      | GET    | 获取我的课程 | 学生 |
| `/api/student/favorites`                    | GET    | 获取收藏课程 | 学生 |
| `/api/student/favorites/:courseId`          | POST   | 添加收藏     | 学生 |
| `/api/student/favorites/:courseId`          | DELETE | 取消收藏     | 学生 |
| `/api/student/community`                    | GET    | 获取社区数据 | 学生 |
| `/api/student/achievements`                 | GET    | 获取成就列表 | 学生 |
| `/api/student/community/teams/:teamId/join` | POST   | 加入组队     | 学生 |
| `/api/student/community/rooms/:roomId/join` | POST   | 加入自习室   | 学生 |

### 教师模块

| 接口                                      | 方法   | 说明             | 权限 |
| ----------------------------------------- | ------ | ---------------- | ---- |
| `/api/teacher/stats`                      | GET    | 获取教学统计     | 教师 |
| `/api/teacher/courses`                    | GET    | 获取我的课程     | 教师 |
| `/api/teacher/courses`                    | POST   | 创建新课程       | 教师 |
| `/api/teacher/courses/:courseId`          | PUT    | 更新课程信息     | 教师 |
| `/api/teacher/courses/:courseId`          | DELETE | 删除课程         | 教师 |
| `/api/teacher/courses/:courseId/toggle`   | PATCH  | 发布/下线课程    | 教师 |
| `/api/teacher/courses/:courseId/students` | GET    | 获取课程学生列表 | 教师 |

详细的 API 文档请查看 `iCuorseraPersonalCenter_APItest.md`

## 数据库设计

### 核心数据表

#### 用户表 (t_user)
- `user_id`: 用户ID（主键）
- `user_name`: 用户名
- `phone`: 手机号
- `email`: 邮箱
- `password_hash`: 加密密码
- `role`: 角色（learner/instructor）
- `avatar`: 头像URL
- `user_intro`: 个人简介

#### 课程表 (t_course)
- `course_id`: 课程ID（主键）
- `course_name`: 课程名称
- `teacher_user_id`: 教师ID
- `category_id`: 分类ID
- `difficulty_level`: 难度级别
- `is_online`: 上线状态

#### 组队表 (t_study_team)
- `team_id`: 组队ID（主键）
- `team_name`: 组队名称
- `created_by_user_id`: 创建者ID
- `description`: 组队描述

#### 自习室表 (t_study_room)
- `room_id`: 自习室ID（主键）
- `room_name`: 自习室名称
- `description`: 描述
- `rules`: 规则

#### 成就表 (t_achievement)
- `achievement_id`: 成就ID（主键）
- `name`: 成就名称
- `achievement_type`: 类型（learning/social/other）
- `required_value`: 达成所需数值

完整的数据库结构请查看 `icoursera_centers.sql`

## 功能模块

### 1. 认证模块 (AuthService)

**功能**:
- 用户注册（支持学生和教师角色）
- 用户登录（JWT Token 生成）
- 密码加密存储

**关键代码**:
```javascript
// 注册
await AuthService.register({
  user_name, phone, email, password, role
});

// 登录
const { token, user } = await AuthService.login({
  phone, password
});
```

### 2. 学生服务模块 (StudentService)

**功能**:
- 学习统计（总学时、完成课程数、连续学习天数）
- 课程管理（报名、收藏、进度更新）
- 社区互动（组队学习、自习室）
- 成就系统

**核心方法**:
- `getLearningStats`: 获取学习统计
- `getCommunityData`: 获取社区数据
- `getAchievements`: 获取成就列表

### 3. 教师服务模块 (TeacherService)

**功能**:
- 课程管理（创建、编辑、删除、上下线）
- 学生管理（查看课程学生列表）
- 教学统计（课程数、学生数、平均评分）

**核心方法**:
- `createCourse`: 创建课程
- `getTeachingStats`: 获取教学统计
- `toggleCourseStatus`: 发布/下线课程

### 4. 社区模块 (CommunityModel)

**功能**:
- 学习组队（创建、加入、退出）
- 自习室（加入、离开、在线状态）
- 任务管理
- 留言互动

**核心方法**:
- `findUserTeams`: 获取用户组队
- `findUserRooms`: 获取用户自习室
- `joinTeam`: 加入组队
- `joinRoom`: 加入自习室

### 5. 成就系统 (AchievementModel)

**成就类型**:
- **学习类**: 连续学习天数、完成课程数
- **社交类**: 加入组队数、邀请好友数
- **其他类**: 特殊成就

**核心方法**:
- `getUserAchievementProgress`: 获取成就进度
- `grantAchievement`: 授予成就

## 开发指南

### 中间件使用

#### 1. 身份认证中间件

```javascript
import { authenticate } from '../middleware/auth.middleware.js';

router.get('/profile', authenticate, async (req, res) => {
  // req.user 包含解码后的用户信息
  const userId = req.user.userId;
});
```

#### 2. 角色验证中间件

```javascript
import { requireRole } from '../middleware/auth.middleware.js';

// 仅学生可访问
router.use(requireRole('learner'));

// 仅教师可访问
router.use(requireRole('instructor'));
```

### 文件上传配置

头像上传示例（user.routes.js）:

```javascript
const storage = multer.diskStorage({
  destination: 'uploads/avatars/',
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'avatar-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    // 验证文件类型
  }
});
```

### 数据验证

使用 express-validator 进行请求验证:

```javascript
import { body, validationResult } from 'express-validator';

router.post('/courses',
  [
    body('course_name').trim().notEmpty().withMessage('课程名称不能为空'),
    body('category_id').isInt().withMessage('请选择课程分类'),
    body('difficulty_level').isIn(['beginner', 'intermediate', 'advanced'])
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ status: 'error', errors: errors.array() });
    }
    // 处理请求
  }
);
```

### 错误处理

统一的错误响应格式:

```javascript
// 成功响应
res.json({
  status: 'success',
  data: result
});

// 错误响应
res.status(400).json({
  status: 'error',
  message: '错误信息'
});
```

### 数据库查询示例

```javascript
// 使用连接池
import { pool } from '../config/database.js';

// 查询
const [rows] = await pool.query(
  'SELECT * FROM t_user WHERE user_id = ?',
  [userId]
);

// 插入
const [result] = await pool.query(
  'INSERT INTO t_course (course_name, teacher_user_id) VALUES (?, ?)',
  [courseName, teacherId]
);
const courseId = result.insertId;
```

##  常见问题

### 1. 数据库连接失败

检查 .env 文件中的数据库配置是否正确:
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=icoursera_centers
```

### 2. JWT Token 过期

Token 默认有效期为 7 天，过期后需重新登录获取新 token。

### 3. 文件上传失败

确保 `uploads/avatars/` 和 `uploads/courses/` 目录存在且有写入权限。

### 4. CORS 跨域问题

已配置 CORS 中间件，如需特定配置可修改 server.js:
```javascript
app.use(cors({
  origin: 'http://localhost:3000',
  credentials: true
}));
```

---

**最后更新**: 2025-11-19