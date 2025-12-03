
## 🚀 快速开始

### 1. 环境要求

- Node.js >= 16
- MySQL >= 8.0
- npm 或 yarn

### 2. 数据库配置

```bash
# 创建数据库并导入数据
mysql -u root -p

# 在MySQL中执行
CREATE DATABASE mzcourse_merged;
USE mzcourse_merged;
SOURCE mzcourse_2025-12-02_082336.sql;
```

### 3. 后端配置

```bash
cd backend

# 安装依赖
npm install

# 配置数据库连接 (修改 .env 文件)
# DB_HOST=localhost
# DB_USER=root
# DB_PASSWORD=你的密码
# DB_NAME=mzcourse_merged

# 启动后端服务
node server.js
```

后端服务运行在: http://localhost:4000

### 4. 前端配置

```bash
cd frontend

# 安装依赖
npm install

# 启动前端服务
npm run dev
```

前端服务运行在: http://localhost:8080

---

## 🔐 测试账号

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 教师 | `admintr` | `test123` | 可查看教师中心数据统计图表 |

---

## 📊 教师中心数据统计功能

登录教师账号后，进入 **教师中心 → 数据统计** 可查看：

### 1. 学生知识掌握分布（环状图）
- 展示学生对知识点的掌握程度分布
- 分类：精通、熟练、理解、入门、待学习

### 2. 学习行为词云
- 展示学生的学习行为关键词
- 包含：专注、暂停、回滚、笔记、提问、讨论、练习、复习等

---

## 📁 SQL 测试数据说明

SQL 文件 `mzcourse_2025-12-02_082336.sql` 包含以下测试数据：

### chapter_progress 表（章节进度）
- 24 条测试记录
- 用于生成"知识掌握分布环状图"
- 包含不同用户对不同章节的学习进度（0-100%）

### student_learning_log 表（学习行为日志）
- 42 条测试记录
- 用于生成"学习行为词云"
- 行为类型包括：
  - `focus` - 专注学习
  - `pause` - 暂停
  - `replay` - 回滚/重播
  - `note` - 记笔记
  - `question` - 提问
  - `discuss` - 讨论
  - `exercise` - 练习
  - `review` - 复习
  - `summary` - 总结
  - 等等...

---


## 📝 注意事项

1. 确保 MySQL 服务已启动
2. 导入 SQL 文件前先创建数据库
3. 修改 `backend/.env` 中的数据库密码为你本地的密码
4. 教师账号 `admintr` 的密码已使用 bcrypt 加密存储在数据库中
