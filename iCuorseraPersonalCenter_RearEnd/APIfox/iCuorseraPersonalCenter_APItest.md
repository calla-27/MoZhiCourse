---
title: iCuorseraPersonalCenter_APItest
language_tabs:
  - shell: Shell
  - http: HTTP
  - javascript: JavaScript
  - ruby: Ruby
  - python: Python
  - php: PHP
  - java: Java
  - go: Go
toc_footers: []
includes: []
search: true
code_clipboard: true
highlight_theme: darkula
headingLevel: 2
generator: "@tarslib/widdershins v4.0.30"

---

# iCuorseraPersonalCenter_APItest

Base URLs:

* <a href="http://localhost:8080">本地开发环境: http://localhost:8080</a>

# Authentication

- HTTP Authentication, scheme: bearer

# 1. 认证模块

## GET 健康检查

GET /api/health

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "message": "Personal Center API is running",
  "timestamp": "2025-11-18T13:31:23.484Z"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## POST 用户注册（教师）

POST /api/auth/register

> Body 请求参数

```json
{
  "user_name": "测试教师01",
  "phone": "13900139001",
  "email": "teacher01@test.com",
  "password": "123456",
  "role": "instructor"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|Content-Type|header|string| 否 |none|
|body|body|object| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "message": "注册成功",
  "data": {
    "userId": 5,
    "user_name": "测试教师01",
    "phone": "13900139001",
    "email": "teacher01@test.com",
    "role": "instructor"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## POST 用户登录（学生端）

POST /api/auth/login

> Body 请求参数

```json
{
  "phone": "13800138001",
  "password": "123456"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInJvbGUiOiJsZWFybmVyIiwiaWF0IjoxNzYzNDc1Mzk0LCJleHAiOjE3NjQwODAxOTR9.nBdQ8G0Q3JnsUNwxGoZY7VKz-5DdSm0EjCmLS3Eadvs",
    "user": {
      "user_id": 1,
      "user_name": "测试学生01",
      "phone": "13800138001",
      "email": "student01@test.com",
      "role": "learner"
    }
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

# 2. 用户模块

## GET 获取用户信息

GET /api/user/profile

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "data": {
    "user_id": 1,
    "user_name": "测试学生01",
    "phone": "13800138001",
    "email": "student01@test.com",
    "user_intro": null,
    "occupation": null,
    "learning_goal": null,
    "role": "learner",
    "register_time": "2025-11-18T13:38:20.000Z",
    "last_login_time": "2025-11-18T14:19:44.000Z"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## PUT 更新用户信息

PUT /api/user/profile

> Body 请求参数

```json
{
  "user_name": "修改后的姓名",
  "user_intro": "这是我的个人简介",
  "occupation": "学生",
  "learning_goal": "掌握前端开发技术"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "message": "更新成功",
  "data": {
    "user_id": 1,
    "user_name": "修改后的姓名",
    "phone": "13800138001",
    "email": "student01@test.com",
    "user_intro": "这是我的个人简介",
    "occupation": "学生",
    "learning_goal": "掌握前端开发技术",
    "role": "learner",
    "register_time": "2025-11-18T13:38:20.000Z",
    "last_login_time": "2025-11-18T14:19:44.000Z"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## POST 上传头像

POST /api/user/avatar

> Body 请求参数

```yaml
avatar: file://C:\Users\17971\Desktop\iCuorsera\示例头像.png

```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|
|» avatar|body|string(binary)| 否 |none|

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "message": "头像上传成功",
  "data": {
    "avatar_url": "/uploads/avatars/avatar-1763478949208-952408466.png"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

# 3. 学生模块

## GET 获取我的课程列表

GET /api/student/courses

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "data": []
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 获取收藏课程

GET /api/student/favorites

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "data": []
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 获取社区数据

GET /api/student/community

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "data": {
    "my_teams": [],
    "my_rooms": [],
    "available_teams": [],
    "available_rooms": [],
    "stats": {
      "teams_count": 0,
      "rooms_count": 0
    }
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 获取学习统计

GET /api/student/stats

> 返回示例

> 200 Response

```json
{
  "status": "string",
  "data": {
    "total_learning_hours": 0,
    "courses_completed": 0,
    "courses_in_progress": 0,
    "total_courses": 0,
    "continuous_days": 0
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» status|string|true|none||none|
|» data|object|true|none||none|
|»» total_learning_hours|integer|true|none||none|
|»» courses_completed|integer|true|none||none|
|»» courses_in_progress|integer|true|none||none|
|»» total_courses|integer|true|none||none|
|»» continuous_days|integer|true|none||none|

## GET 获取成就列表

GET /api/student/achievements

> 返回示例

> 200 Response

```json
{
  "status": "string",
  "data": {
    "achievements": {
      "learning": [
        {
          "achievement_id": 0,
          "name": "string",
          "description": "string",
          "icon_class": "string",
          "achievement_type": "string",
          "required_value": 0,
          "earned_time": null,
          "is_earned": 0
        }
      ],
      "social": [
        {
          "achievement_id": 0,
          "name": "string",
          "description": "string",
          "icon_class": "string",
          "achievement_type": "string",
          "required_value": 0,
          "earned_time": null,
          "is_earned": 0
        }
      ],
      "other": [
        null
      ]
    },
    "all_achievements": [
      {
        "achievement_id": 0,
        "name": "string",
        "description": "string",
        "icon_class": "string",
        "achievement_type": "string",
        "required_value": 0,
        "earned_time": null,
        "is_earned": 0
      }
    ],
    "stats": {
      "earned_count": 0,
      "total_count": 0,
      "completion_rate": "string"
    }
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» status|string|true|none||none|
|» data|object|true|none||none|
|»» achievements|object|true|none||none|
|»»» learning|[object]|true|none||none|
|»»»» achievement_id|integer|false|none||none|
|»»»» name|string|false|none||none|
|»»»» description|string|false|none||none|
|»»»» icon_class|string|false|none||none|
|»»»» achievement_type|string|false|none||none|
|»»»» required_value|integer|false|none||none|
|»»»» earned_time|null|false|none||none|
|»»»» is_earned|integer|false|none||none|
|»»» social|[object]|true|none||none|
|»»»» achievement_id|integer|false|none||none|
|»»»» name|string|false|none||none|
|»»»» description|string|false|none||none|
|»»»» icon_class|string|false|none||none|
|»»»» achievement_type|string|false|none||none|
|»»»» required_value|integer|false|none||none|
|»»»» earned_time|null|false|none||none|
|»»»» is_earned|integer|false|none||none|
|»»» other|[any]|true|none||none|
|»» all_achievements|[object]|true|none||none|
|»»» achievement_id|integer|true|none||none|
|»»» name|string|true|none||none|
|»»» description|string|true|none||none|
|»»» icon_class|string|true|none||none|
|»»» achievement_type|string|true|none||none|
|»»» required_value|integer|true|none||none|
|»»» earned_time|null|true|none||none|
|»»» is_earned|integer|true|none||none|
|»» stats|object|true|none||none|
|»»» earned_count|integer|true|none||none|
|»»» total_count|integer|true|none||none|
|»»» completion_rate|string|true|none||none|

## POST 添加收藏

POST /api/student/favorites/{courseId}

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|courseId|path|string| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "string",
  "data": {
    "message": "string"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» status|string|true|none||none|
|» data|object|true|none||none|
|»» message|string|true|none||none|

## DELETE 取消收藏

DELETE /api/student/favorites/{courseId}

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|courseId|path|string| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "string",
  "data": {
    "message": "string"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» status|string|true|none||none|
|» data|object|true|none||none|
|»» message|string|true|none||none|

## POST 报名课程

POST /api/student/enroll/{courseId}

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|courseId|path|string| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "string",
  "data": {
    "message": "string"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» status|string|true|none||none|
|» data|object|true|none||none|
|»» message|string|true|none||none|

## PUT 更新进度

PUT /api/student/courses/{courseId}/progress

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|courseId|path|string| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "string",
  "data": {
    "message": "string"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» status|string|true|none||none|
|» data|object|true|none||none|
|»» message|string|true|none||none|

# 4. 教师模块

## GET 获取教学统计

GET /api/teacher/stats

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "data": {
    "total_courses": 0,
    "total_students": 0,
    "total_duration": null,
    "avg_rating": null
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 获取我的课程列表 

GET /api/teacher/courses

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "data": []
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## POST 创建新课程

POST /api/teacher/courses

> Body 请求参数

```json
{
  "course_name": "Vue3 全栈开发实战",
  "course_desc": "从零开始学习Vue3框架，包含TypeScript、Pinia、Vue Router等核心技术栈",
  "category_id": 5,
  "difficulty_level": "intermediate",
  "course_duration": 7200,
  "cover_img": "/uploads/courses/vue3-cover.jpg"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|Content-Type|header|string| 否 |none|
|body|body|object| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "success",
  "data": {
    "message": "课程创建成功",
    "course": {
      "course_id": 4,
      "course_name": "Vue3 全栈开发实战",
      "course_desc": "从零开始学习Vue3框架，包含TypeScript、Pinia、Vue Router等核心技术栈",
      "cover_img": "/uploads/courses/vue3-cover.jpg",
      "category_id": 5,
      "teacher_user_id": 5,
      "difficulty_level": "intermediate",
      "course_duration": 7200,
      "is_online": 0,
      "category_name": "前端开发",
      "teacher_name": "测试教师01"
    }
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 获取课程学生列表

GET /api/teacher/courses/{courseId}/students

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|courseId|path|string| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "error",
  "message": "无权访问该课程"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## PUT 更新课程信息

PUT /api/teacher/courses/{courseId}

> Body 请求参数

```json
{
  "course_name": "Vue3 全栈开发实战（2025版）",
  "course_desc": "2025年最新Vue3课程，包含最新特性和最佳实践",
  "category_id": 5,
  "difficulty_level": "advanced",
  "course_duration": 10800,
  "cover_img": "/uploads/courses/vue3-2025.jpg"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|courseId|path|string| 是 |none|
|Content-Type|header|string| 否 |none|
|body|body|object| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "string",
  "data": {
    "message": "string",
    "course": {
      "course_id": 0,
      "course_name": "string",
      "course_desc": "string",
      "cover_img": "string",
      "category_id": 0,
      "teacher_user_id": 0,
      "difficulty_level": "string",
      "course_duration": 0,
      "is_online": 0,
      "category_name": "string",
      "teacher_name": "string"
    }
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» status|string|true|none||none|
|» data|object|true|none||none|
|»» message|string|true|none||none|
|»» course|object|true|none||none|
|»»» course_id|integer|true|none||none|
|»»» course_name|string|true|none||none|
|»»» course_desc|string|true|none||none|
|»»» cover_img|string|true|none||none|
|»»» category_id|integer|true|none||none|
|»»» teacher_user_id|integer|true|none||none|
|»»» difficulty_level|string|true|none||none|
|»»» course_duration|integer|true|none||none|
|»»» is_online|integer|true|none||none|
|»»» category_name|string|true|none||none|
|»»» teacher_name|string|true|none||none|

## DELETE 删除课程

DELETE /api/teacher/courses/{courseId}

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|courseId|path|string| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "string",
  "data": {
    "message": "string"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» status|string|true|none||none|
|» data|object|true|none||none|
|»» message|string|true|none||none|

## PATCH 发布/下线课程

PATCH /api/teacher/courses/{courseId}/toggle

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|courseId|path|string| 是 |none|

> 返回示例

> 200 Response

```json
{
  "status": "string",
  "data": {
    "message": "string",
    "is_online": 0
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» status|string|true|none||none|
|» data|object|true|none||none|
|»» message|string|true|none||none|
|»» is_online|integer|true|none||none|

# 数据模型

