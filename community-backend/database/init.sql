-- 创建 community 数据库
CREATE DATABASE IF NOT EXISTS community CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE community;

-- 用户表
CREATE TABLE IF NOT EXISTS t_user (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255),
    user_intro TEXT,
    role ENUM('learner', 'instructor', 'admin') DEFAULT 'learner',
    register_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login_time DATETIME,
    is_active TINYINT DEFAULT 1,
    avatar_url VARCHAR(255),
    learning_goal TEXT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 课程表
CREATE TABLE IF NOT EXISTS t_course (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    course_desc TEXT,
    cover_img VARCHAR(255),
    category_id INT,
    teacher_user_id INT NOT NULL,
    difficulty_level ENUM('beginner', 'intermediate', 'advanced'),
    course_duration INT,
    is_online TINYINT DEFAULT 0,
    tags JSON,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_user_id) REFERENCES t_user(user_id)
);

-- 课程分类表
CREATE TABLE IF NOT EXISTS t_course_category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 学习小组表
CREATE TABLE IF NOT EXISTS t_study_team (
    team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    description TEXT,
    course_id INT,
    creator_id INT NOT NULL,
    max_members INT DEFAULT 10,
    current_members INT DEFAULT 1,
    status ENUM('active', 'inactive', 'closed') DEFAULT 'active',
    tags JSON,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES t_user(user_id),
    FOREIGN KEY (course_id) REFERENCES t_course(course_id)
);

-- 学习小组任务表
CREATE TABLE IF NOT EXISTS t_team_task (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    creator_id INT NOT NULL,
    task_title VARCHAR(200) NOT NULL,
    task_content TEXT,
    deadline DATETIME,
    status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES t_study_team(team_id),
    FOREIGN KEY (creator_id) REFERENCES t_user(user_id)
);

-- 学习小组成员表
CREATE TABLE IF NOT EXISTS t_team_member (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('leader', 'member') DEFAULT 'member',
    join_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'active', 'inactive') DEFAULT 'pending',
    FOREIGN KEY (team_id) REFERENCES t_study_team(team_id),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id),
    UNIQUE KEY unique_team_user (team_id, user_id)
);

-- 成就类型表
CREATE TABLE IF NOT EXISTS t_achievement_type (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    achievement_name VARCHAR(100) NOT NULL,
    description TEXT,
    condition_type VARCHAR(50),
    condition_value INT,
    icon_url VARCHAR(255)
);

-- 自习室表
CREATE TABLE IF NOT EXISTS t_study_room (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_name VARCHAR(100) NOT NULL,
    description TEXT,
    creator_id INT NOT NULL,
    max_participants INT DEFAULT 50,
    current_participants INT DEFAULT 1,
    schedule_time VARCHAR(50),
    status ENUM('open', 'closed') DEFAULT 'open',
    tags JSON,
    rules TEXT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES t_user(user_id)
);

-- 自习室留言表
CREATE TABLE IF NOT EXISTS t_room_message (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    message_type ENUM('text', 'system') DEFAULT 'text',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES t_study_room(room_id),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id)
);

-- 社区帖子表
CREATE TABLE IF NOT EXISTS t_community_post (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    post_type ENUM('discussion', 'qa_help', 'qa_teacher') DEFAULT 'discussion',  
    title VARCHAR(200),
    content TEXT NOT NULL,
    course_id INT,
    tags JSON,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    status ENUM('normal', 'closed', 'deleted') DEFAULT 'normal',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES t_user(user_id),
    FOREIGN KEY (course_id) REFERENCES t_course(course_id)
);

-- 帖子评论表
CREATE TABLE IF NOT EXISTS t_post_comment (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    parent_comment_id INT,
    content TEXT NOT NULL,
    comment_type ENUM('discussion', 'qa_answer') DEFAULT 'discussion',
    like_count INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES t_community_post(post_id),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id),
    FOREIGN KEY (parent_comment_id) REFERENCES t_post_comment(comment_id)
);

-- 自习室成员表
CREATE TABLE IF NOT EXISTS t_room_member (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT NOT NULL,
    user_id INT NOT NULL,
    join_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    leave_time DATETIME,
    total_study_time INT DEFAULT 0,
    study_goal TEXT,
    current_task VARCHAR(255),
    FOREIGN KEY (room_id) REFERENCES t_study_room(room_id),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id)
);

-- 成就表
CREATE TABLE IF NOT EXISTS t_achievement (
    achievement_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    achievement_type VARCHAR(50) NOT NULL,
    achievement_name VARCHAR(100) NOT NULL,
    description TEXT,
    earned_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    icon_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id)
);

-- 用户行为日志表
CREATE TABLE IF NOT EXISTS t_user_behavior (
    behavior_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT,
    behavior_type VARCHAR(20) NOT NULL,
    keyword VARCHAR(100),
    behavior_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    stay_duration INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES t_user(user_id),
    FOREIGN KEY (course_id) REFERENCES t_course(course_id)
);

-- 学习详情日志表
CREATE TABLE IF NOT EXISTS t_learning_detail (
    learn_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    video_id INT,
    learn_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    learn_duration INT NOT NULL,
    play_speed DECIMAL(3,2) DEFAULT 1.00,
    pause_count INT DEFAULT 0,
    complete_rate DECIMAL(5,2) DEFAULT 0.00,
    video_progress DECIMAL(5,2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES t_user(user_id),
    FOREIGN KEY (course_id) REFERENCES t_course(course_id)
);

-- 帖子点赞表
CREATE TABLE IF NOT EXISTS t_post_like (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES t_community_post(post_id),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id),
    UNIQUE KEY unique_post_user (post_id, user_id)
);

-- 评论点赞表
CREATE TABLE IF NOT EXISTS t_comment_like (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    comment_id INT NOT NULL,
    user_id INT NOT NULL,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (comment_id) REFERENCES t_post_comment(comment_id),
    FOREIGN KEY (user_id) REFERENCES t_user(user_id),
    UNIQUE KEY unique_comment_user (comment_id, user_id)
);

-- 创建索引（使用条件判断避免重复创建）
CREATE INDEX idx_team_status ON t_study_team(status);
CREATE INDEX idx_room_status ON t_study_room(status);
CREATE INDEX idx_post_type ON t_community_post(post_type);
CREATE INDEX idx_post_status ON t_community_post(status);
CREATE INDEX idx_behavior_time ON t_user_behavior(behavior_time);
CREATE INDEX idx_learn_time ON t_learning_detail(learn_time);
CREATE INDEX idx_achievement_user ON t_achievement(user_id);

-- 添加示例课程分类
INSERT IGNORE INTO t_course_category (category_name, parent_category_id) VALUES 
('编程开发', NULL),
('数据科学', NULL),
('前端开发', 1),
('后端开发', 1),
('移动开发', 1);