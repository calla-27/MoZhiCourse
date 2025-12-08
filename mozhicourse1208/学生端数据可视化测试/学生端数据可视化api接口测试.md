---
title: 默认模块
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

# 默认模块

Base URLs:

* <a href="http://localhost:4000">开发环境: http://localhost:4000</a>

# Authentication

- HTTP Authentication, scheme: bearer

# 登录

## POST 学生登录

POST /api/auth/login

> Body 请求参数

```json
{
  "username": "student",
  "password": "123456"
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
  "success": true,
  "message": "登录成功",
  "data": {
    "user": {
      "user_id": 14,
      "user_name": "student",
      "email": "behavior.student@mzcourse.local",
      "avatar_url": null,
      "role": "learner",
      "is_active": 1,
      "register_time": "2025-12-01T05:11:25.000Z",
      "last_login_time": "2025-12-04T08:45:01.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjE0LCJ1c2VyTmFtZSI6InN0dWRlbnQiLCJyb2xlIjoibGVhcm5lciIsImlhdCI6MTc2NDkyNjU1NSwiZXhwIjoxNzY1NTMxMzU1fQ.E3kcLe91E7sNVYNQC-u6xubygLDw65LpX1KWpu10umY"
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

# 学生端数据可视化测试

## GET 每日学习时长趋势

GET /api/student-behavior/learning-duration-trend

> 返回示例

> 200 Response

```json
{
  "success": true,
  "data": {
    "studyTrend": [
      {
        "date": "2025-11-28T16:00:00.000Z",
        "total_duration": "900",
        "videos_watched": 1,
        "avg_completion_rate": "100.000000"
      },
      {
        "date": "2025-11-29T16:00:00.000Z",
        "total_duration": "720",
        "videos_watched": 1,
        "avg_completion_rate": "100.000000"
      },
      {
        "date": "2025-11-30T16:00:00.000Z",
        "total_duration": "1766",
        "videos_watched": 2,
        "avg_completion_rate": "50.662000"
      },
      {
        "date": "2025-12-01T16:00:00.000Z",
        "total_duration": "2356",
        "videos_watched": 3,
        "avg_completion_rate": "38.930000"
      },
      {
        "date": "2025-12-02T16:00:00.000Z",
        "total_duration": "900",
        "videos_watched": 1,
        "avg_completion_rate": "100.000000"
      },
      {
        "date": "2025-12-03T16:00:00.000Z",
        "total_duration": "9414",
        "videos_watched": 6,
        "avg_completion_rate": "58.537000"
      }
    ],
    "focusTrend": [
      {
        "date": "2025-11-24T16:00:00.000Z",
        "avg_focus_rate": "75.000000",
        "total_focus_duration": "45"
      },
      {
        "date": "2025-11-25T16:00:00.000Z",
        "avg_focus_rate": "75.950000",
        "total_focus_duration": "110"
      },
      {
        "date": "2025-11-26T16:00:00.000Z",
        "avg_focus_rate": "66.700000",
        "total_focus_duration": "30"
      },
      {
        "date": "2025-11-27T16:00:00.000Z",
        "avg_focus_rate": "70.000000",
        "total_focus_duration": "35"
      },
      {
        "date": "2025-11-28T16:00:00.000Z",
        "avg_focus_rate": "71.250000",
        "total_focus_duration": "85"
      },
      {
        "date": "2025-11-29T16:00:00.000Z",
        "avg_focus_rate": "78.600000",
        "total_focus_duration": "55"
      },
      {
        "date": "2025-11-30T16:00:00.000Z",
        "avg_focus_rate": "72.566667",
        "total_focus_duration": "120"
      }
    ],
    "days": 30
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 视频倍速播放-环状图接口

GET /api/student-behavior/playback-speed-stats

> 返回示例

> 200 Response

```json
{
  "success": true,
  "data": {
    "usage": [
      {
        "speed": 0.75,
        "count": 2,
        "total_duration": "756"
      },
      {
        "speed": 1,
        "count": 31,
        "total_duration": "11760"
      },
      {
        "speed": 1.25,
        "count": 2,
        "total_duration": "1440"
      },
      {
        "speed": 1.5,
        "count": 1,
        "total_duration": "900"
      },
      {
        "speed": 2,
        "count": 1,
        "total_duration": "1200"
      }
    ],
    "total": 37,
    "averageSpeed": 1.0405405405405406,
    "mostUsedSpeed": {
      "speed": 1,
      "count": 31,
      "total_duration": "11760"
    },
    "distribution": [
      {
        "speed": 0.75,
        "count": 2,
        "percentage": 5
      },
      {
        "speed": 1,
        "count": 31,
        "percentage": 84
      },
      {
        "speed": 1.25,
        "count": 2,
        "percentage": 5
      },
      {
        "speed": 1.5,
        "count": 1,
        "percentage": 3
      },
      {
        "speed": 2,
        "count": 1,
        "percentage": 3
      }
    ]
  }
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

## GET 课程/章节表现分析

GET /api/student-behavior/course-performance

> 返回示例

> 200 Response

```json
{
  "success": true,
  "data": [
    {
      "course_id": 5,
      "course_name": "1小时教你学会申论",
      "course_desc": "公务员考试申论科目的快速入门课程，1小时掌握申论写作的核心技巧。",
      "cover_img": "https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA.jpg",
      "difficulty_level": "beginner",
      "student_count": 3681,
      "rating": "4.7",
      "progress": 45,
      "last_learn_time": "2025-12-01T10:00:00.000Z",
      "total_learn_duration": 120,
      "is_completed": 0,
      "completion_rate": "30.10",
      "mastery_level": "45.20",
      "efficiency_score": "60.30",
      "total_study_time": 150
    },
    {
      "course_id": 2,
      "course_name": "高等数学(上) - 3小时速成",
      "course_desc": "超级通俗易懂的高等数学上册速成课程，3小时掌握核心概念，期末不挂科。",
      "cover_img": "https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/13408799812653464.jpeg",
      "difficulty_level": "beginner",
      "student_count": 3416,
      "rating": "4.9",
      "progress": 45,
      "last_learn_time": null,
      "total_learn_duration": 0,
      "is_completed": 0,
      "completion_rate": "45.30",
      "mastery_level": "58.70",
      "efficiency_score": "65.40",
      "total_study_time": 210
    },
    {
      "course_id": 3,
      "course_name": "英语四级听力原文训练",
      "course_desc": "专注于英语四级听力部分的原文训练，提高听力理解能力和应试技巧。",
      "cover_img": "https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/%E5%B0%81%E9%9D%A2.jpeg",
      "difficulty_level": "intermediate",
      "student_count": 2150,
      "rating": "4.6",
      "progress": 80,
      "last_learn_time": null,
      "total_learn_duration": 0,
      "is_completed": 0,
      "completion_rate": "80.20",
      "mastery_level": "85.60",
      "efficiency_score": "88.90",
      "total_study_time": 380
    },
    {
      "course_id": 7,
      "course_name": "申论系统课 - 小马哥",
      "course_desc": "由知名讲师小马哥主讲的申论系统课程，全面提升申论写作和分析能力。",
      "cover_img": "https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA2.jpg",
      "difficulty_level": "advanced",
      "student_count": 2940,
      "rating": "4.8",
      "progress": 0,
      "last_learn_time": null,
      "total_learn_duration": 0,
      "is_completed": 0,
      "completion_rate": "0.00",
      "mastery_level": "0.00",
      "efficiency_score": "0.00",
      "total_study_time": 0
    },
    {
      "course_id": 8,
      "course_name": "清华大学 - 如何逗自己一周达到《公考140+》",
      "course_desc": "清华大学出品的公务员考试高分秘籍，一周内掌握140+分数的核心方法。",
      "cover_img": "https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E8%A1%8C%E6%B5%8B1.jpg",
      "difficulty_level": "advanced",
      "student_count": 1850,
      "rating": "4.7",
      "progress": 0,
      "last_learn_time": null,
      "total_learn_duration": 0,
      "is_completed": 0,
      "completion_rate": "0.00",
      "mastery_level": "0.00",
      "efficiency_score": "0.00",
      "total_study_time": 0
    },
    {
      "course_id": 15,
      "course_name": "行测数量关系速解",
      "course_desc": "公务员考试行测数量关系专项训练，快速提分技巧。",
      "cover_img": "https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E8%A1%8C%E6%B5%8B1.jpg",
      "difficulty_level": "intermediate",
      "student_count": 1420,
      "rating": "4.7",
      "progress": 0,
      "last_learn_time": null,
      "total_learn_duration": 0,
      "is_completed": 0,
      "completion_rate": "0.00",
      "mastery_level": "0.00",
      "efficiency_score": "0.00",
      "total_study_time": 0
    }
  ]
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|none|Inline|

### 返回数据结构

# 数据模型

