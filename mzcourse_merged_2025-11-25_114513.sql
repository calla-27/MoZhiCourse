-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: mzcourse_merged
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `t_ai_chat_log`
--

DROP TABLE IF EXISTS `t_ai_chat_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_ai_chat_log` (
  `chat_log_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `video_id` int NOT NULL,
  `prompt_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `response_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`chat_log_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_video` (`video_id`),
  KEY `idx_timestamp` (`timestamp`),
  CONSTRAINT `t_ai_chat_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`),
  CONSTRAINT `t_ai_chat_log_ibfk_2` FOREIGN KEY (`video_id`) REFERENCES `t_course_video` (`video_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_ai_chat_log`
--

/*!40000 ALTER TABLE `t_ai_chat_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_ai_chat_log` ENABLE KEYS */;

--
-- Table structure for table `t_course`
--

DROP TABLE IF EXISTS `t_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_course` (
  `course_id` int NOT NULL AUTO_INCREMENT,
  `course_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cover_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `teacher_user_id` int NOT NULL,
  `difficulty_level` enum('beginner','intermediate','advanced') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `course_duration` int DEFAULT '0',
  `is_online` tinyint DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `student_count` int DEFAULT '0' COMMENT '学生人数',
  `rating` decimal(3,1) DEFAULT '0.0' COMMENT '课程评分',
  `rating_count` int DEFAULT '0' COMMENT '评分人数',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`course_id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_teacher` (`teacher_user_id`),
  KEY `idx_difficulty` (`difficulty_level`),
  CONSTRAINT `t_course_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `t_course_category` (`category_id`),
  CONSTRAINT `t_course_ibfk_2` FOREIGN KEY (`teacher_user_id`) REFERENCES `t_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_course`
--

/*!40000 ALTER TABLE `t_course` DISABLE KEYS */;
INSERT INTO `t_course` VALUES (1,'Python编程入门','从零开始学习Python编程，掌握基础语法和编程思维','https://via.placeholder.com/400x250/667eea/ffffff?text=Python',1,1,'beginner',1680,1,'2025-11-24 06:47:32','2025-11-24 06:47:32',12589,4.8,2456,'2025-11-24 06:47:32','2025-11-24 06:47:32'),(2,'机器学习实战','掌握机器学习核心算法，完成真实项目实践','https://via.placeholder.com/400x250/f093fb/ffffff?text=ML',3,2,'intermediate',2400,1,'2025-11-24 06:47:32','2025-11-24 06:47:32',1800,4.9,856,'2025-11-24 06:47:32','2025-11-24 06:47:32'),(3,'React全栈开发','从前端到后端，掌握现代Web开发全流程','https://via.placeholder.com/400x250/4facfe/ffffff?text=React',1,3,'advanced',3200,1,'2025-11-24 06:47:32','2025-11-24 06:47:32',3200,4.7,1250,'2025-11-24 06:47:32','2025-11-24 06:47:32'),(4,'数据结构与算法','系统学习数据结构，提升编程思维能力','https://via.placeholder.com/400x250/43e97b/ffffff?text=Algorithm',1,1,'beginner',2800,1,'2025-11-24 06:47:32','2025-11-24 06:47:32',4100,4.8,1856,'2025-11-24 06:47:32','2025-11-24 06:47:32'),(5,'深度学习入门','理解神经网络原理，掌握深度学习框架','https://via.placeholder.com/400x250/fa709a/ffffff?text=DL',3,2,'intermediate',2600,1,'2025-11-24 06:47:32','2025-11-24 06:47:32',2900,4.9,1125,'2025-11-24 06:47:32','2025-11-24 06:47:32'),(7,'Ubuntu Linux系统管理','全面学习Ubuntu Linux系统操作、网络配置、用户管理和故障排查','/images/ubuntu-course.jpg',1,1,'beginner',8308,1,'2025-11-21 21:34:46','2025-11-21 21:36:12',0,0.0,0,'2025-11-21 21:34:46','2025-11-21 21:36:12');
/*!40000 ALTER TABLE `t_course` ENABLE KEYS */;

--
-- Table structure for table `t_course_category`
--

DROP TABLE IF EXISTS `t_course_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_course_category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_category_id` int DEFAULT NULL,
  `category_icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类图标',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  KEY `idx_parent_category` (`parent_category_id`),
  CONSTRAINT `t_course_category_ibfk_1` FOREIGN KEY (`parent_category_id`) REFERENCES `t_course_category` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_course_category`
--

/*!40000 ALTER TABLE `t_course_category` DISABLE KEYS */;
INSERT INTO `t_course_category` VALUES (1,'编程开发',NULL,'fa-code',1,'2025-11-24 06:47:27','2025-11-24 06:47:27'),(2,'数据科学',NULL,'fa-chart-bar',2,'2025-11-24 06:47:27','2025-11-24 06:47:27'),(3,'人工智能',NULL,'fa-brain',3,'2025-11-24 06:47:27','2025-11-24 06:47:27'),(4,'移动开发',NULL,'fa-mobile-alt',4,'2025-11-24 06:47:27','2025-11-24 06:47:27'),(5,'UI/UX设计',NULL,'fa-palette',5,'2025-11-24 06:47:27','2025-11-24 06:47:27'),(6,'后端开发',NULL,'fa-server',6,'2025-11-24 06:47:27','2025-11-24 06:47:27');
/*!40000 ALTER TABLE `t_course_category` ENABLE KEYS */;

--
-- Table structure for table `t_course_chapter`
--

DROP TABLE IF EXISTS `t_course_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_course_chapter` (
  `chapter_id` int NOT NULL AUTO_INCREMENT,
  `course_id` int NOT NULL,
  `chapter_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_index` int DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`chapter_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_order` (`order_index`),
  CONSTRAINT `t_course_chapter_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_course_chapter`
--

/*!40000 ALTER TABLE `t_course_chapter` DISABLE KEYS */;
INSERT INTO `t_course_chapter` VALUES (1,7,'网络与共享配置',1,'2025-11-21 21:34:48','2025-11-21 21:34:48'),(2,7,'系统工具与用户管理',2,'2025-11-21 21:34:48','2025-11-21 21:34:48'),(3,7,'故障诊断与解决',3,'2025-11-21 21:34:48','2025-11-21 21:34:48'),(4,1,'第四章：函数与模块',4,'2025-11-24 06:47:33','2025-11-24 06:47:33');
/*!40000 ALTER TABLE `t_course_chapter` ENABLE KEYS */;

--
-- Table structure for table `t_course_review`
--

DROP TABLE IF EXISTS `t_course_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_course_review` (
  `review_id` int NOT NULL AUTO_INCREMENT COMMENT '评价唯一ID',
  `course_id` int NOT NULL COMMENT '课程ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `rating` int NOT NULL COMMENT '评分(1-5)',
  `review_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '评价内容',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `t_course_review_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `t_course_review_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程评价表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_course_review`
--

/*!40000 ALTER TABLE `t_course_review` DISABLE KEYS */;
INSERT INTO `t_course_review` VALUES (1,1,5,5,'非常适合零基础学习者的课程！张老师讲解得非常清晰，每个概念都配有实际案例。','2025-11-24 06:47:38','2025-11-24 06:47:38'),(2,1,4,5,'课程结构合理，内容充实，受益匪浅！','2025-11-24 06:47:38','2025-11-24 06:47:38'),(3,3,5,4,'内容很好，不过有些地方讲得有点快，需要反复观看。','2025-11-24 06:47:38','2025-11-24 06:47:38'),(4,4,4,5,'数据结构讲解透彻，配合算法实战，帮助很大！','2025-11-24 06:47:38','2025-11-24 06:47:38'),(5,1,5,5,'非常适合零基础学习者的课程！张老师讲解得非常清晰，每个概念都配有实际案例。','2025-11-24 06:47:50','2025-11-24 06:47:50'),(6,1,4,5,'课程结构合理，内容充实，受益匪浅！','2025-11-24 06:47:50','2025-11-24 06:47:50'),(7,3,5,4,'内容很好，不过有些地方讲得有点快，需要反复观看。','2025-11-24 06:47:50','2025-11-24 06:47:50'),(8,4,4,5,'数据结构讲解透彻，配合算法实战，帮助很大！','2025-11-24 06:47:50','2025-11-24 06:47:50');
/*!40000 ALTER TABLE `t_course_review` ENABLE KEYS */;

--
-- Table structure for table `t_course_video`
--

DROP TABLE IF EXISTS `t_course_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_course_video` (
  `video_id` int NOT NULL AUTO_INCREMENT,
  `chapter_id` int NOT NULL,
  `video_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `video_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `video_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `duration_seconds` int DEFAULT '0',
  `order_index` int DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`video_id`),
  KEY `idx_chapter` (`chapter_id`),
  KEY `idx_order` (`order_index`),
  CONSTRAINT `t_course_video_ibfk_1` FOREIGN KEY (`chapter_id`) REFERENCES `t_course_chapter` (`chapter_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_course_video`
--

/*!40000 ALTER TABLE `t_course_video` DISABLE KEYS */;
INSERT INTO `t_course_video` VALUES (1,1,'使用共享文件夹和ssh实现ubuntu与...','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','掌握共享文件夹和SSH远程连接的使用方法',1862,1,'2025-11-21 21:36:12','2025-11-21 21:36:12'),(2,2,'Ubuntu Linux终端和命令基本操作','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%201428511.mp4','学习Linux终端的基本操作和常用命令',2607,1,'2025-11-21 21:36:12','2025-11-21 21:36:12'),(3,2,'virtualbox虚拟系统备份与恢复','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','掌握VirtualBox虚拟系统的备份和恢复技术',300,2,'2025-11-21 21:36:12','2025-11-21 21:36:12'),(4,2,'Ubuntu Linux创建新用户和授予权限','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','学习在Ubuntu中创建用户和管理权限的方法',1363,3,'2025-11-21 21:36:12','2025-11-21 21:36:12'),(5,3,'Ubuntu18.04 终端登录不了','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','解决Ubuntu终端无法登录的常见问题',580,1,'2025-11-21 21:36:12','2025-11-21 21:36:12'),(6,3,'终端管道失效与环境变量','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','学习终端管道故障和环境变量配置问题',1596,2,'2025-11-21 21:36:12','2025-11-21 21:36:12'),(7,4,'Python简介和开发环境搭建','https://example.com/video1.mp4','了解Python语言特点，配置开发环境',1500,1,'2025-11-24 06:47:34','2025-11-24 06:47:34'),(8,4,'第一个Python程序','https://example.com/video2.mp4','编写并运行第一个Python程序',1800,2,'2025-11-24 06:47:34','2025-11-24 06:47:34');
/*!40000 ALTER TABLE `t_course_video` ENABLE KEYS */;

--
-- Table structure for table `t_learning_detail`
--

DROP TABLE IF EXISTS `t_learning_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_learning_detail` (
  `learn_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int NOT NULL,
  `video_id` int NOT NULL,
  `learn_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `learn_duration` int NOT NULL,
  `play_speed` decimal(3,2) DEFAULT '1.00',
  `pause_count` int DEFAULT '0',
  `complete_rate` decimal(5,2) DEFAULT '0.00',
  `current_position` int DEFAULT '0',
  PRIMARY KEY (`learn_id`),
  KEY `video_id` (`video_id`),
  KEY `idx_user_video` (`user_id`,`video_id`),
  KEY `idx_learn_time` (`learn_time`),
  KEY `idx_course` (`course_id`),
  CONSTRAINT `t_learning_detail_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`),
  CONSTRAINT `t_learning_detail_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`),
  CONSTRAINT `t_learning_detail_ibfk_3` FOREIGN KEY (`video_id`) REFERENCES `t_course_video` (`video_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_learning_detail`
--

/*!40000 ALTER TABLE `t_learning_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_learning_detail` ENABLE KEYS */;

--
-- Table structure for table `t_user`
--

DROP TABLE IF EXISTS `t_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `user_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` char(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `occupation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `learning_goal` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('learner','instructor','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'learner',
  `register_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login_time` datetime DEFAULT NULL,
  `is_active` tinyint DEFAULT '1',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像URL',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_phone` (`phone`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_user`
--

/*!40000 ALTER TABLE `t_user` DISABLE KEYS */;
INSERT INTO `t_user` VALUES (1,'11','13800138000','teacher@icoursera.com','$2b$10$examplehashedpassword',NULL,'Python讲师','培养编程人才','instructor','2025-11-21 21:34:44',NULL,1,NULL,'2025-11-21 21:34:44','2025-11-21 21:34:44'),(2,'李教授','13800138002','li@example.com','$2b$10$YQN9L7v0HZhVrF4VYhZKZeKGYj7M8rZxZc8V8ZGYk7YQN9L7v0HZh','数据科学领域权威，前Google工程师','数据科学家',NULL,'instructor','2025-11-24 14:47:29',NULL,1,'https://via.placeholder.com/100','2025-11-24 06:47:29','2025-11-24 06:47:29'),(3,'王工程师','13800138003','wang@example.com','$2b$10$YQN9L7v0HZhVrF4VYhZKZeKGYj7M8rZxZc8V8ZGYk7YQN9L7v0HZh','全栈开发专家，10年项目经验','全栈工程师',NULL,'instructor','2025-11-24 14:47:29',NULL,1,'https://via.placeholder.com/100','2025-11-24 06:47:29','2025-11-24 06:47:29'),(4,'张三','13900139001','zhangsan@example.com','$2b$10$YQN9L7v0HZhVrF4VYhZKZeKGYj7M8rZxZc8V8ZGYk7YQN9L7v0HZh','热爱学习的程序员','学生',NULL,'learner','2025-11-24 14:47:29',NULL,1,'https://via.placeholder.com/100','2025-11-24 06:47:29','2025-11-24 06:47:29'),(5,'李四','13900139002','lisi@example.com','$2b$10$YQN9L7v0HZhVrF4VYhZKZeKGYj7M8rZxZc8V8ZGYk7YQN9L7v0HZh','前端开发工程师','前端工程师',NULL,'learner','2025-11-24 14:47:29',NULL,1,'https://via.placeholder.com/100','2025-11-24 06:47:29','2025-11-24 06:47:29');
/*!40000 ALTER TABLE `t_user` ENABLE KEYS */;

--
-- Table structure for table `t_user_behavior`
--

DROP TABLE IF EXISTS `t_user_behavior`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_behavior` (
  `behavior_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int DEFAULT NULL,
  `video_id` int DEFAULT NULL,
  `behavior_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `keyword` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `behavior_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `stay_duration` int DEFAULT '0',
  `current_time` int DEFAULT '0',
  `play_speed` decimal(3,2) DEFAULT '1.00',
  PRIMARY KEY (`behavior_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_video` (`video_id`),
  KEY `idx_behavior_type` (`behavior_type`),
  KEY `idx_behavior_time` (`behavior_time`),
  CONSTRAINT `t_user_behavior_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`),
  CONSTRAINT `t_user_behavior_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`),
  CONSTRAINT `t_user_behavior_ibfk_3` FOREIGN KEY (`video_id`) REFERENCES `t_course_video` (`video_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_user_behavior`
--

/*!40000 ALTER TABLE `t_user_behavior` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_user_behavior` ENABLE KEYS */;

--
-- Table structure for table `t_user_course`
--

DROP TABLE IF EXISTS `t_user_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_course` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `course_id` int NOT NULL COMMENT '课程ID',
  `enroll_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  `progress` int DEFAULT '0' COMMENT '学习进度(百分比)',
  `last_learn_time` datetime DEFAULT NULL COMMENT '最后学习时间',
  `is_favorite` tinyint DEFAULT '0' COMMENT '是否收藏',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_course` (`user_id`,`course_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  CONSTRAINT `t_user_course_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `t_user_course_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户课程关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_user_course`
--

/*!40000 ALTER TABLE `t_user_course` DISABLE KEYS */;
INSERT INTO `t_user_course` VALUES (1,4,1,'2025-11-24 14:47:37',35,'2025-11-24 14:47:37',1,'2025-11-24 06:47:37','2025-11-24 06:47:37'),(2,4,4,'2025-11-24 14:47:37',60,'2025-11-24 14:47:37',1,'2025-11-24 06:47:37','2025-11-24 06:47:37'),(3,5,1,'2025-11-24 14:47:37',80,'2025-11-24 14:47:37',0,'2025-11-24 06:47:37','2025-11-24 06:47:37'),(4,5,3,'2025-11-24 14:47:37',45,'2025-11-24 14:47:37',1,'2025-11-24 06:47:37','2025-11-24 06:47:37');
/*!40000 ALTER TABLE `t_user_course` ENABLE KEYS */;

--
-- Table structure for table `t_user_enrollment`
--

DROP TABLE IF EXISTS `t_user_enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user_enrollment` (
  `enrollment_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int NOT NULL,
  `enroll_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `learn_progress` decimal(5,2) DEFAULT '0.00',
  `status` enum('in_progress','completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'in_progress',
  `last_learn_time` datetime DEFAULT NULL,
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `uk_user_course` (`user_id`,`course_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `t_user_enrollment_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`),
  CONSTRAINT `t_user_enrollment_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_user_enrollment`
--

/*!40000 ALTER TABLE `t_user_enrollment` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_user_enrollment` ENABLE KEYS */;

--
-- Table structure for table `t_video_ai_quiz`
--

DROP TABLE IF EXISTS `t_video_ai_quiz`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_video_ai_quiz` (
  `quiz_id` int NOT NULL AUTO_INCREMENT,
  `video_id` int NOT NULL,
  `question_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`quiz_id`),
  KEY `idx_video` (`video_id`),
  CONSTRAINT `t_video_ai_quiz_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `t_course_video` (`video_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_video_ai_quiz`
--

/*!40000 ALTER TABLE `t_video_ai_quiz` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_video_ai_quiz` ENABLE KEYS */;

--
-- Table structure for table `t_video_ai_quiz_option`
--

DROP TABLE IF EXISTS `t_video_ai_quiz_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_video_ai_quiz_option` (
  `option_id` int NOT NULL AUTO_INCREMENT,
  `quiz_id` int NOT NULL,
  `option_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_correct` tinyint DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`option_id`),
  KEY `idx_quiz` (`quiz_id`),
  KEY `idx_correct` (`is_correct`),
  CONSTRAINT `t_video_ai_quiz_option_ibfk_1` FOREIGN KEY (`quiz_id`) REFERENCES `t_video_ai_quiz` (`quiz_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_video_ai_quiz_option`
--

/*!40000 ALTER TABLE `t_video_ai_quiz_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_video_ai_quiz_option` ENABLE KEYS */;

--
-- Table structure for table `t_video_ai_summary`
--

DROP TABLE IF EXISTS `t_video_ai_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_video_ai_summary` (
  `summary_id` int NOT NULL AUTO_INCREMENT,
  `video_id` int NOT NULL,
  `content_summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `learning_objectives` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `key_takeaways` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`summary_id`),
  UNIQUE KEY `uk_video` (`video_id`),
  KEY `idx_video` (`video_id`),
  CONSTRAINT `t_video_ai_summary_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `t_course_video` (`video_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_video_ai_summary`
--

/*!40000 ALTER TABLE `t_video_ai_summary` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_video_ai_summary` ENABLE KEYS */;

--
-- Table structure for table `t_video_comment`
--

DROP TABLE IF EXISTS `t_video_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_video_comment` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `video_id` int NOT NULL,
  `user_id` int NOT NULL,
  `parent_comment_id` int DEFAULT NULL,
  `comment_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `like_count` int DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`),
  KEY `idx_video` (`video_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_parent` (`parent_comment_id`),
  KEY `idx_created_time` (`created_time`),
  CONSTRAINT `t_video_comment_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `t_course_video` (`video_id`) ON DELETE CASCADE,
  CONSTRAINT `t_video_comment_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`),
  CONSTRAINT `t_video_comment_ibfk_3` FOREIGN KEY (`parent_comment_id`) REFERENCES `t_video_comment` (`comment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_video_comment`
--

/*!40000 ALTER TABLE `t_video_comment` DISABLE KEYS */;
INSERT INTO `t_video_comment` VALUES (1,3,1,NULL,'这个备份操作非常实用！请问制作快照和导出OVF有什么区别？',15,'2025-11-22 12:51:21','2025-11-22 18:33:07'),(2,3,1,1,'快照是针对当前虚拟机的快速回滚点，OVF是可移植的完整备份文件，可以导入到其他机器。',7,'2025-11-22 13:51:32','2025-11-22 16:37:25'),(3,3,1,NULL,'视频中提到的恢复步骤能再演示慢一点吗？有点没看清。',1,'2025-11-22 14:51:34','2025-11-22 14:51:34'),(4,3,1,NULL,'视频中提到的恢复步骤能再演示慢一点吗？有点没看清。',1,'2025-11-22 14:52:57','2025-11-22 14:52:57'),(5,1,1,NULL,'test',4,'2025-11-22 15:44:32','2025-11-22 18:33:30'),(6,3,1,1,'你好',2,'2025-11-22 16:36:57','2025-11-22 16:37:28'),(7,3,1,1,'test3',4,'2025-11-22 16:58:35','2025-11-22 16:58:43'),(8,1,1,5,'你好棒',0,'2025-11-22 17:41:19','2025-11-22 17:41:19'),(9,1,1,NULL,'你好',0,'2025-11-22 17:56:42','2025-11-22 17:56:42'),(10,3,1,1,'你好',0,'2025-11-22 18:33:14','2025-11-22 18:33:14');
/*!40000 ALTER TABLE `t_video_comment` ENABLE KEYS */;

--
-- Temporary view structure for view `v_course_detail`
--

DROP TABLE IF EXISTS `v_course_detail`;
/*!50001 DROP VIEW IF EXISTS `v_course_detail`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_course_detail` AS SELECT 
 1 AS `course_id`,
 1 AS `course_name`,
 1 AS `course_desc`,
 1 AS `cover_img`,
 1 AS `category_id`,
 1 AS `teacher_user_id`,
 1 AS `difficulty_level`,
 1 AS `course_duration`,
 1 AS `is_online`,
 1 AS `student_count`,
 1 AS `rating`,
 1 AS `rating_count`,
 1 AS `created_at`,
 1 AS `updated_at`,
 1 AS `category_name`,
 1 AS `teacher_name`,
 1 AS `teacher_intro`,
 1 AS `teacher_avatar`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_user_learning`
--

DROP TABLE IF EXISTS `v_user_learning`;
/*!50001 DROP VIEW IF EXISTS `v_user_learning`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_user_learning` AS SELECT 
 1 AS `id`,
 1 AS `user_id`,
 1 AS `course_id`,
 1 AS `enroll_time`,
 1 AS `progress`,
 1 AS `last_learn_time`,
 1 AS `is_favorite`,
 1 AS `created_at`,
 1 AS `updated_at`,
 1 AS `course_name`,
 1 AS `cover_img`,
 1 AS `course_duration`,
 1 AS `teacher_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'mzcourse_merged'
--

--
-- Final view structure for view `v_course_detail`
--

/*!50001 DROP VIEW IF EXISTS `v_course_detail`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_course_detail` AS select `c`.`course_id` AS `course_id`,`c`.`course_name` AS `course_name`,`c`.`course_desc` AS `course_desc`,`c`.`cover_img` AS `cover_img`,`c`.`category_id` AS `category_id`,`c`.`teacher_user_id` AS `teacher_user_id`,`c`.`difficulty_level` AS `difficulty_level`,`c`.`course_duration` AS `course_duration`,`c`.`is_online` AS `is_online`,`c`.`student_count` AS `student_count`,`c`.`rating` AS `rating`,`c`.`rating_count` AS `rating_count`,`c`.`created_at` AS `created_at`,`c`.`updated_at` AS `updated_at`,`cat`.`category_name` AS `category_name`,`u`.`user_name` AS `teacher_name`,`u`.`user_intro` AS `teacher_intro`,`u`.`avatar_url` AS `teacher_avatar` from ((`t_course` `c` left join `t_course_category` `cat` on((`c`.`category_id` = `cat`.`category_id`))) left join `t_user` `u` on((`c`.`teacher_user_id` = `u`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_learning`
--

/*!50001 DROP VIEW IF EXISTS `v_user_learning`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_learning` AS select `uc`.`id` AS `id`,`uc`.`user_id` AS `user_id`,`uc`.`course_id` AS `course_id`,`uc`.`enroll_time` AS `enroll_time`,`uc`.`progress` AS `progress`,`uc`.`last_learn_time` AS `last_learn_time`,`uc`.`is_favorite` AS `is_favorite`,`uc`.`created_at` AS `created_at`,`uc`.`updated_at` AS `updated_at`,`c`.`course_name` AS `course_name`,`c`.`cover_img` AS `cover_img`,`c`.`course_duration` AS `course_duration`,`u`.`user_name` AS `teacher_name` from ((`t_user_course` `uc` left join `t_course` `c` on((`uc`.`course_id` = `c`.`course_id`))) left join `t_user` `u` on((`c`.`teacher_user_id` = `u`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-25 11:45:17
