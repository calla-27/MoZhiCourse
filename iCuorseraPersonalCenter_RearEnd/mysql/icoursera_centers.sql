/*
 Navicat Premium Dump SQL

 Source Server         : jjy
 Source Server Type    : MySQL
 Source Server Version : 80043 (8.0.43)
 Source Host           : localhost:3306
 Source Schema         : icoursera_centers

 Target Server Type    : MySQL
 Target Server Version : 80043 (8.0.43)
 File Encoding         : 65001

 Date: 19/11/2025 08:53:34
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for t_achievement
-- ----------------------------
DROP TABLE IF EXISTS `t_achievement`;
CREATE TABLE `t_achievement`  (
  `achievement_id` int NOT NULL COMMENT '成就ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '成就名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '描述',
  `icon_class` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图标',
  `achievement_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '成就类型',
  `required_value` int NULL DEFAULT 0 COMMENT '达成所需数值',
  `created_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`achievement_id`) USING BTREE,
  INDEX `idx_achievement_type`(`achievement_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '成就定义表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_achievement
-- ----------------------------
INSERT INTO `t_achievement` VALUES (1, '坚持之星', '连续学习7天', 'fas fa-fire', 'learning', 7, '2025-11-19 08:13:29');
INSERT INTO `t_achievement` VALUES (2, '社交达人', '加入5个学习组队', 'fas fa-users', 'social', 5, '2025-11-19 08:13:29');

-- ----------------------------
-- Table structure for t_course
-- ----------------------------
DROP TABLE IF EXISTS `t_course`;
CREATE TABLE `t_course`  (
  `course_id` int NOT NULL AUTO_INCREMENT COMMENT '课程唯一ID',
  `course_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '课程名称',
  `course_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '课程简介',
  `cover_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '课程封面图URL',
  `category_id` int NULL DEFAULT NULL COMMENT '课程分类ID',
  `teacher_user_id` int NULL DEFAULT NULL COMMENT '讲师的用户ID',
  `difficulty_level` enum('beginner','intermediate','advanced') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '难度级别',
  `course_duration` int NULL DEFAULT NULL COMMENT '总时长（分钟）',
  `is_online` tinyint NULL DEFAULT 0 COMMENT '是否上线/课程状态',
  PRIMARY KEY (`course_id`) USING BTREE,
  INDEX `idx_category`(`category_id` ASC) USING BTREE,
  INDEX `idx_teacher`(`teacher_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_course_category` FOREIGN KEY (`category_id`) REFERENCES `t_course_category` (`category_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_course_teacher` FOREIGN KEY (`teacher_user_id`) REFERENCES `t_user` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '课程主表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_course
-- ----------------------------
INSERT INTO `t_course` VALUES (1, 'Python基础教程', NULL, '/uploads/courses/python.jpg', 3, 2, 'beginner', 3600, 1);
INSERT INTO `t_course` VALUES (2, 'Java高级编程', NULL, '/uploads/courses/java.jpg', 4, 2, 'advanced', 7200, 1);
INSERT INTO `t_course` VALUES (3, '前端开发实战', NULL, '/uploads/courses/frontend.jpg', 5, 2, 'intermediate', 5400, 1);

-- ----------------------------
-- Table structure for t_course_analytics_summary
-- ----------------------------
DROP TABLE IF EXISTS `t_course_analytics_summary`;
CREATE TABLE `t_course_analytics_summary`  (
  `summary_id` int NOT NULL AUTO_INCREMENT COMMENT '概要ID',
  `course_id` int NULL DEFAULT NULL COMMENT '课程ID',
  `avg_focus_time_min` int NULL DEFAULT NULL COMMENT '平均专注时长',
  `avg_completion_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '平均完播率',
  `avg_interaction_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '平均互动参与度',
  `avg_mastery_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '平均知识掌握度',
  `mastery_distribution_json` json NULL COMMENT '掌握度分布 (用于饼图)',
  `behavior_word_cloud_json` json NULL COMMENT '学习行为词云数据',
  `last_updated` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  PRIMARY KEY (`summary_id`) USING BTREE,
  UNIQUE INDEX `course_id`(`course_id` ASC) USING BTREE,
  CONSTRAINT `fk_summary_course` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '课程分析概要表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_course_analytics_summary
-- ----------------------------

-- ----------------------------
-- Table structure for t_course_category
-- ----------------------------
DROP TABLE IF EXISTS `t_course_category`;
CREATE TABLE `t_course_category`  (
  `category_id` int NOT NULL AUTO_INCREMENT COMMENT '分类唯一ID',
  `category_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类名称（如：编程、设计）',
  `parent_category_id` int NULL DEFAULT NULL COMMENT '父分类ID（用于支持多级分类）',
  PRIMARY KEY (`category_id`) USING BTREE,
  INDEX `idx_parent_category`(`parent_category_id` ASC) USING BTREE,
  CONSTRAINT `fk_parent_category` FOREIGN KEY (`parent_category_id`) REFERENCES `t_course_category` (`category_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '课程分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_course_category
-- ----------------------------
INSERT INTO `t_course_category` VALUES (1, '编程开发', NULL);
INSERT INTO `t_course_category` VALUES (2, '设计创作', NULL);
INSERT INTO `t_course_category` VALUES (3, 'Python', 1);
INSERT INTO `t_course_category` VALUES (4, 'Java', 1);
INSERT INTO `t_course_category` VALUES (5, '前端开发', 1);
INSERT INTO `t_course_category` VALUES (6, 'UI设计', 2);

-- ----------------------------
-- Table structure for t_course_chapter
-- ----------------------------
DROP TABLE IF EXISTS `t_course_chapter`;
CREATE TABLE `t_course_chapter`  (
  `chapter_id` int NOT NULL AUTO_INCREMENT COMMENT '章节唯一ID',
  `course_id` int NOT NULL COMMENT '所属课程ID',
  `chapter_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '章节标题',
  `order_index` int NULL DEFAULT 0 COMMENT '章节排序位置',
  PRIMARY KEY (`chapter_id`) USING BTREE,
  INDEX `idx_course`(`course_id` ASC) USING BTREE,
  INDEX `idx_order`(`order_index` ASC) USING BTREE,
  CONSTRAINT `fk_chapter_course` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '课程章节表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_course_chapter
-- ----------------------------

-- ----------------------------
-- Table structure for t_course_review
-- ----------------------------
DROP TABLE IF EXISTS `t_course_review`;
CREATE TABLE `t_course_review`  (
  `review_id` int NOT NULL AUTO_INCREMENT COMMENT '反馈唯一ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `course_id` int NOT NULL COMMENT '课程ID',
  `overall_score` decimal(3, 1) NOT NULL COMMENT '总体评分(1.0-5.0)',
  `content_score` decimal(3, 1) NULL DEFAULT NULL COMMENT '内容评分',
  `teacher_score` decimal(3, 1) NULL DEFAULT NULL COMMENT '讲师评分',
  `comment_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '详细评论',
  `feedback_time` datetime NOT NULL COMMENT '反馈时间',
  PRIMARY KEY (`review_id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_course`(`course_id` ASC) USING BTREE,
  CONSTRAINT `fk_review_course` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_review_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '课程评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_course_review
-- ----------------------------

-- ----------------------------
-- Table structure for t_course_video
-- ----------------------------
DROP TABLE IF EXISTS `t_course_video`;
CREATE TABLE `t_course_video`  (
  `video_id` int NOT NULL AUTO_INCREMENT COMMENT '视频唯一ID',
  `chapter_id` int NOT NULL COMMENT '所属章节ID',
  `video_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '视频标题/课时名称',
  `video_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频URL',
  `video_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '视频描述',
  `duration_seconds` int NULL DEFAULT NULL COMMENT '视频时长（秒）',
  `order_index` int NULL DEFAULT 0 COMMENT '课时在章节内的排序',
  PRIMARY KEY (`video_id`) USING BTREE,
  INDEX `idx_chapter`(`chapter_id` ASC) USING BTREE,
  INDEX `idx_order`(`order_index` ASC) USING BTREE,
  CONSTRAINT `fk_video_chapter` FOREIGN KEY (`chapter_id`) REFERENCES `t_course_chapter` (`chapter_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '课程视频表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_course_video
-- ----------------------------

-- ----------------------------
-- Table structure for t_learning_detail
-- ----------------------------
DROP TABLE IF EXISTS `t_learning_detail`;
CREATE TABLE `t_learning_detail`  (
  `learn_id` bigint NOT NULL AUTO_INCREMENT COMMENT '学习记录唯一ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `course_id` int NOT NULL COMMENT '课程ID',
  `video_id` int NOT NULL COMMENT '关联到具体视频，使分析更精确',
  `learn_time` datetime NOT NULL COMMENT '学习时间（事件开始时间）',
  `learn_duration` int NOT NULL COMMENT '单次学习时长（秒）',
  `play_speed` decimal(3, 2) NULL DEFAULT 1.00 COMMENT '播放倍速',
  `pause_count` int NULL DEFAULT 0 COMMENT '暂停次数',
  `complete_rate` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '视频完成率',
  PRIMARY KEY (`learn_id`) USING BTREE,
  INDEX `fk_learning_course`(`course_id` ASC) USING BTREE,
  INDEX `idx_user_course`(`user_id` ASC, `course_id` ASC) USING BTREE,
  INDEX `idx_user_video`(`user_id` ASC, `video_id` ASC) USING BTREE,
  INDEX `idx_learn_time`(`learn_time` ASC) USING BTREE,
  INDEX `idx_complete_rate`(`complete_rate` ASC) USING BTREE,
  INDEX `idx_video_time`(`video_id` ASC, `learn_time` ASC) USING BTREE,
  CONSTRAINT `fk_learning_course` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_learning_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_learning_video` FOREIGN KEY (`video_id`) REFERENCES `t_course_video` (`video_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `chk_complete_rate` CHECK ((`complete_rate` >= 0) and (`complete_rate` <= 100)),
  CONSTRAINT `chk_pause_count` CHECK (`pause_count` >= 0),
  CONSTRAINT `chk_play_speed` CHECK ((`play_speed` > 0) and (`play_speed` <= 3.0))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '学习详情日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_learning_detail
-- ----------------------------

-- ----------------------------
-- Table structure for t_room_comment
-- ----------------------------
DROP TABLE IF EXISTS `t_room_comment`;
CREATE TABLE `t_room_comment`  (
  `comment_id` int NOT NULL AUTO_INCREMENT COMMENT '留言 ID',
  `room_id` int NULL DEFAULT NULL COMMENT '自习室 ID',
  `user_id` int NULL DEFAULT NULL COMMENT '留言用户 ID',
  `comment_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '留言内容',
  `create_time` datetime NULL DEFAULT NULL COMMENT '留言时间',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `fk_room_comment_room`(`room_id` ASC) USING BTREE,
  INDEX `fk_room_comment_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_room_comment_room` FOREIGN KEY (`room_id`) REFERENCES `t_study_room` (`room_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_room_comment_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '自习室留言表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_room_comment
-- ----------------------------

-- ----------------------------
-- Table structure for t_room_member
-- ----------------------------
DROP TABLE IF EXISTS `t_room_member`;
CREATE TABLE `t_room_member`  (
  `room_member_id` int NOT NULL AUTO_INCREMENT COMMENT '记录 ID',
  `room_id` int NULL DEFAULT NULL COMMENT '自习室 ID',
  `user_id` int NULL DEFAULT NULL COMMENT '用户 ID',
  `is_online` tinyint NULL DEFAULT 0 COMMENT '是否在线 (0=离线, 1=在线)',
  PRIMARY KEY (`room_member_id`) USING BTREE,
  INDEX `fk_room_member_room`(`room_id` ASC) USING BTREE,
  INDEX `fk_room_member_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_room_member_room` FOREIGN KEY (`room_id`) REFERENCES `t_study_room` (`room_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_room_member_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '自习室成员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_room_member
-- ----------------------------

-- ----------------------------
-- Table structure for t_room_task
-- ----------------------------
DROP TABLE IF EXISTS `t_room_task`;
CREATE TABLE `t_room_task`  (
  `task_id` int NOT NULL AUTO_INCREMENT COMMENT '任务 ID',
  `room_id` int NULL DEFAULT NULL COMMENT '自习室 ID',
  `user_id` int NULL DEFAULT NULL COMMENT '用户 ID',
  `task_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务标题',
  `task_date` date NULL DEFAULT NULL COMMENT '任务日期 (用于按天筛选)',
  `is_completed` tinyint NULL DEFAULT 0 COMMENT '是否完成',
  PRIMARY KEY (`task_id`) USING BTREE,
  INDEX `fk_room_task_room`(`room_id` ASC) USING BTREE,
  INDEX `fk_room_task_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_room_task_room` FOREIGN KEY (`room_id`) REFERENCES `t_study_room` (`room_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_room_task_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '自习室个人任务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_room_task
-- ----------------------------

-- ----------------------------
-- Table structure for t_study_room
-- ----------------------------
DROP TABLE IF EXISTS `t_study_room`;
CREATE TABLE `t_study_room`  (
  `room_id` int NOT NULL AUTO_INCREMENT COMMENT '自习室 ID',
  `room_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '自习室名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '描述',
  `rules` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '自习室规则',
  PRIMARY KEY (`room_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '自习室表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_study_room
-- ----------------------------

-- ----------------------------
-- Table structure for t_study_team
-- ----------------------------
DROP TABLE IF EXISTS `t_study_team`;
CREATE TABLE `t_study_team`  (
  `team_id` int NOT NULL AUTO_INCREMENT COMMENT '组队ID',
  `team_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组队名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '组队描述',
  `created_by_user_id` int NULL DEFAULT NULL COMMENT '创建者',
  PRIMARY KEY (`team_id`) USING BTREE,
  INDEX `fk_team_creator`(`created_by_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_team_creator` FOREIGN KEY (`created_by_user_id`) REFERENCES `t_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组队表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_study_team
-- ----------------------------

-- ----------------------------
-- Table structure for t_team_comment
-- ----------------------------
DROP TABLE IF EXISTS `t_team_comment`;
CREATE TABLE `t_team_comment`  (
  `comment_id` int NOT NULL AUTO_INCREMENT COMMENT '留言ID',
  `team_id` int NULL DEFAULT NULL COMMENT '组队ID',
  `user_id` int NULL DEFAULT NULL COMMENT '留言用户ID',
  `comment_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '留言内容',
  `create_time` datetime NULL DEFAULT NULL COMMENT '留言时间',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `fk_team_comment_team`(`team_id` ASC) USING BTREE,
  INDEX `fk_team_comment_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_team_comment_team` FOREIGN KEY (`team_id`) REFERENCES `t_study_team` (`team_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_team_comment_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组队留言表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_team_comment
-- ----------------------------

-- ----------------------------
-- Table structure for t_team_member
-- ----------------------------
DROP TABLE IF EXISTS `t_team_member`;
CREATE TABLE `t_team_member`  (
  `team_member_id` int NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `team_id` int NULL DEFAULT NULL COMMENT '组队ID',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `join_time` datetime NULL DEFAULT NULL COMMENT '加入时间',
  PRIMARY KEY (`team_member_id`) USING BTREE,
  INDEX `fk_team_member_team`(`team_id` ASC) USING BTREE,
  INDEX `fk_team_member_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_team_member_team` FOREIGN KEY (`team_id`) REFERENCES `t_study_team` (`team_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_team_member_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组队成员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_team_member
-- ----------------------------

-- ----------------------------
-- Table structure for t_team_task
-- ----------------------------
DROP TABLE IF EXISTS `t_team_task`;
CREATE TABLE `t_team_task`  (
  `task_id` int NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `team_id` int NULL DEFAULT NULL COMMENT '组队ID',
  `assigned_user_id` int NULL DEFAULT NULL COMMENT '任务分配给的用户ID',
  `task_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务标题',
  `is_completed` tinyint NULL DEFAULT 0 COMMENT '是否完成 (0=未完成, 1=已完成)',
  `confirmed_by_partner_id` int NULL DEFAULT NULL COMMENT '由哪个伙伴确认完成',
  `due_date` date NULL DEFAULT NULL COMMENT '截止日期',
  PRIMARY KEY (`task_id`) USING BTREE,
  INDEX `fk_task_team`(`team_id` ASC) USING BTREE,
  INDEX `fk_task_assigned_user`(`assigned_user_id` ASC) USING BTREE,
  INDEX `fk_task_confirmer`(`confirmed_by_partner_id` ASC) USING BTREE,
  CONSTRAINT `fk_task_assigned_user` FOREIGN KEY (`assigned_user_id`) REFERENCES `t_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_task_confirmer` FOREIGN KEY (`confirmed_by_partner_id`) REFERENCES `t_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_task_team` FOREIGN KEY (`team_id`) REFERENCES `t_study_team` (`team_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组队任务监督表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_team_task
-- ----------------------------

-- ----------------------------
-- Table structure for t_user
-- ----------------------------
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user`  (
  `user_id` int NOT NULL AUTO_INCREMENT COMMENT '用户唯一ID',
  `user_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `phone` char(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码',
  `user_intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '个人简介',
  `occupation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '职业',
  `learning_goal` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学习目标',
  `role` enum('learner','instructor','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'learner' COMMENT '用户角色',
  `register_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `is_active` tinyint NOT NULL DEFAULT 1 COMMENT '是否活跃',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE,
  INDEX `idx_register_time`(`register_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_user
-- ----------------------------
INSERT INTO `t_user` VALUES (1, '修改后的姓名', '13800138001', 'student01@test.com', '$2a$10$7UmUfIH1jf5Lp17Ypp.ZqeiCZXkIUvv7AHSl7eFdk9g1edecros6C', '这是我的个人简介', '学生', '掌握前端开发技术', 'learner', '2025-11-18 21:38:20', '2025-11-18 22:33:39', 1);
INSERT INTO `t_user` VALUES (2, '测试学生02', '13031243561', 'student02@test.com', '$2a$10$VuCkw/c4Y04UUXO5uj5JFuPal5byoKDmXV0kCkRHfNsAgJJbiggfC', NULL, NULL, NULL, 'learner', '2025-11-18 21:40:52', NULL, 1);
INSERT INTO `t_user` VALUES (3, '测试学生03', '18031293661', 'student03@test.com', '$2a$10$Jyvs.dnPqAiexWVg8tTHEuDI7UMMKP5xr0sCRtOrfsJOShuEIvOtW', NULL, NULL, NULL, 'learner', '2025-11-18 21:43:37', NULL, 1);
INSERT INTO `t_user` VALUES (4, '测试学生04', '18031293554', 'student04@test.com', '$2a$10$rkQGrctOGS.y3cRqtzLHBuyvi3mPndNbRgjy/fC15ZDyV64MtCU2C', NULL, NULL, NULL, 'learner', '2025-11-18 21:56:09', NULL, 1);
INSERT INTO `t_user` VALUES (5, '测试教师01', '13900139001', 'teacher01@test.com', '$2a$10$kzk58IDtGYzDKl9wzjTtWODHxETkMhveRDzGihBAUndx6/7AYud4a', NULL, NULL, NULL, 'instructor', '2025-11-18 22:12:53', '2025-11-18 22:42:06', 1);

-- ----------------------------
-- Table structure for t_user_achievement
-- ----------------------------
DROP TABLE IF EXISTS `t_user_achievement`;
CREATE TABLE `t_user_achievement`  (
  `user_achieve_id` int NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` int NOT NULL COMMENT '获得用户ID',
  `achievement_id` int NOT NULL COMMENT '获得的成就ID',
  `earned_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '获得时间',
  PRIMARY KEY (`user_achieve_id`) USING BTREE,
  UNIQUE INDEX `uk_user_achievement`(`user_id` ASC, `achievement_id` ASC) USING BTREE,
  INDEX `idx_user_achievements`(`user_id` ASC, `earned_time` DESC) USING BTREE,
  INDEX `idx_achievement_users`(`achievement_id` ASC, `earned_time` DESC) USING BTREE,
  INDEX `idx_earned_time`(`earned_time` ASC) USING BTREE,
  CONSTRAINT `fk_user_achievement_achievement` FOREIGN KEY (`achievement_id`) REFERENCES `t_achievement` (`achievement_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_user_achievement_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户成就表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_user_achievement
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_analytics_profile
-- ----------------------------
DROP TABLE IF EXISTS `t_user_analytics_profile`;
CREATE TABLE `t_user_analytics_profile`  (
  `profile_id` int NOT NULL AUTO_INCREMENT COMMENT '档案ID',
  `user_id` int NULL DEFAULT NULL COMMENT '用户ID',
  `course_id` int NULL DEFAULT NULL COMMENT '针对特定课程的分析',
  `learning_style` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '学习风格',
  `avg_focus_time_min` int NULL DEFAULT NULL COMMENT '平均专注时长（分钟）',
  `avg_completion_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '平均完播率',
  `efficiency_index` int NULL DEFAULT NULL COMMENT '学习效率指数',
  `mastery_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '知识掌握度',
  `last_updated` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  PRIMARY KEY (`profile_id`) USING BTREE,
  INDEX `fk_profile_user`(`user_id` ASC) USING BTREE,
  INDEX `fk_profile_course`(`course_id` ASC) USING BTREE,
  CONSTRAINT `fk_profile_course` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_profile_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '学生分析档案表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_user_analytics_profile
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_behavior
-- ----------------------------
DROP TABLE IF EXISTS `t_user_behavior`;
CREATE TABLE `t_user_behavior`  (
  `behavior_id` bigint NOT NULL AUTO_INCREMENT COMMENT '行为唯一ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `course_id` int NULL DEFAULT NULL COMMENT '关联的课程ID',
  `behavior_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '行为类型（搜索、浏览课程、收藏等）',
  `keyword` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '搜索关键词（来自CSV）',
  `behavior_time` datetime NOT NULL COMMENT '行为发生时间',
  `stay_duration` int NULL DEFAULT 0 COMMENT '停留时长（秒）（来自CSV）',
  PRIMARY KEY (`behavior_id`) USING BTREE,
  INDEX `idx_user_time`(`user_id` ASC, `behavior_time` ASC) USING BTREE,
  INDEX `idx_behavior_type`(`behavior_type` ASC) USING BTREE,
  INDEX `idx_course`(`course_id` ASC) USING BTREE,
  INDEX `idx_behavior_time`(`behavior_time` ASC) USING BTREE,
  CONSTRAINT `fk_behavior_course` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_behavior_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户行为日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_user_behavior
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_enrollment
-- ----------------------------
DROP TABLE IF EXISTS `t_user_enrollment`;
CREATE TABLE `t_user_enrollment`  (
  `enrollment_id` int NOT NULL AUTO_INCREMENT COMMENT '报名记录ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `course_id` int NOT NULL COMMENT '课程ID',
  `enroll_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  `learn_progress` decimal(5, 2) NULL DEFAULT 0.00 COMMENT '课程学习进度(0-100%)',
  `status` enum('in_progress','completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'in_progress' COMMENT '学习状态',
  PRIMARY KEY (`enrollment_id`) USING BTREE,
  UNIQUE INDEX `uk_user_course`(`user_id` ASC, `course_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_course`(`course_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_enrollment_course` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_enrollment_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户报名表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_user_enrollment
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_favorite
-- ----------------------------
DROP TABLE IF EXISTS `t_user_favorite`;
CREATE TABLE `t_user_favorite`  (
  `favorite_id` int NOT NULL AUTO_INCREMENT COMMENT '收藏记录ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `course_id` int NOT NULL COMMENT '课程ID',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`favorite_id`) USING BTREE,
  UNIQUE INDEX `uk_user_course`(`user_id` ASC, `course_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_course`(`course_id` ASC) USING BTREE,
  CONSTRAINT `fk_favorite_course` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_favorite_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户收藏表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_user_favorite
-- ----------------------------

-- ----------------------------
-- Table structure for t_video_comment
-- ----------------------------
DROP TABLE IF EXISTS `t_video_comment`;
CREATE TABLE `t_video_comment`  (
  `comment_id` int NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `video_id` int NOT NULL COMMENT '评论所属视频ID',
  `user_id` int NOT NULL COMMENT '评论用户ID',
  `parent_comment_id` int NULL DEFAULT NULL COMMENT '父评论ID（用于实现回复）',
  `comment_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `like_count` int NULL DEFAULT 0 COMMENT '评论点赞数',
  PRIMARY KEY (`comment_id`) USING BTREE,
  INDEX `idx_video`(`video_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_parent`(`parent_comment_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_comment_id`) REFERENCES `t_video_comment` (`comment_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_video` FOREIGN KEY (`video_id`) REFERENCES `t_course_video` (`video_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '视频评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_video_comment
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
