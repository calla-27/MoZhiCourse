-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: mzcourse
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
  `prompt_text` text COLLATE utf8mb4_unicode_ci,
  `response_text` text COLLATE utf8mb4_unicode_ci,
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
  `course_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_desc` text COLLATE utf8mb4_unicode_ci,
  `cover_img` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `teacher_user_id` int NOT NULL,
  `difficulty_level` enum('beginner','intermediate','advanced') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `course_duration` int DEFAULT '0',
  `is_online` tinyint DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
INSERT INTO `t_course` VALUES (7,'Ubuntu Linux系统管理','全面学习Ubuntu Linux系统操作、网络配置、用户管理和故障排查','/images/ubuntu-course.jpg',1,1,'beginner',8308,1,'2025-11-21 21:34:46','2025-11-21 21:36:12');
/*!40000 ALTER TABLE `t_course` ENABLE KEYS */;

--
-- Table structure for table `t_course_category`
--

DROP TABLE IF EXISTS `t_course_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_course_category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_category_id` int DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  KEY `idx_parent_category` (`parent_category_id`),
  CONSTRAINT `t_course_category_ibfk_1` FOREIGN KEY (`parent_category_id`) REFERENCES `t_course_category` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_course_category`
--

/*!40000 ALTER TABLE `t_course_category` DISABLE KEYS */;
INSERT INTO `t_course_category` VALUES (1,'编程开发',NULL);
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
  `chapter_title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_index` int DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`chapter_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_order` (`order_index`),
  CONSTRAINT `t_course_chapter_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_course_chapter`
--

/*!40000 ALTER TABLE `t_course_chapter` DISABLE KEYS */;
INSERT INTO `t_course_chapter` VALUES (1,7,'网络与共享配置',1,'2025-11-21 21:34:48'),(2,7,'系统工具与用户管理',2,'2025-11-21 21:34:48'),(3,7,'故障诊断与解决',3,'2025-11-21 21:34:48');
/*!40000 ALTER TABLE `t_course_chapter` ENABLE KEYS */;

--
-- Table structure for table `t_course_video`
--

DROP TABLE IF EXISTS `t_course_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_course_video` (
  `video_id` int NOT NULL AUTO_INCREMENT,
  `chapter_id` int NOT NULL,
  `video_title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `video_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `video_desc` text COLLATE utf8mb4_unicode_ci,
  `duration_seconds` int DEFAULT '0',
  `order_index` int DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`video_id`),
  KEY `idx_chapter` (`chapter_id`),
  KEY `idx_order` (`order_index`),
  CONSTRAINT `t_course_video_ibfk_1` FOREIGN KEY (`chapter_id`) REFERENCES `t_course_chapter` (`chapter_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_course_video`
--

/*!40000 ALTER TABLE `t_course_video` DISABLE KEYS */;
INSERT INTO `t_course_video` VALUES (1,1,'使用共享文件夹和ssh实现ubuntu与...','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','掌握共享文件夹和SSH远程连接的使用方法',1862,1,'2025-11-21 21:36:12'),(2,2,'Ubuntu Linux终端和命令基本操作','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%201428511.mp4','学习Linux终端的基本操作和常用命令',2607,1,'2025-11-21 21:36:12'),(3,2,'virtualbox虚拟系统备份与恢复','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','掌握VirtualBox虚拟系统的备份和恢复技术',300,2,'2025-11-21 21:36:12'),(4,2,'Ubuntu Linux创建新用户和授予权限','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','学习在Ubuntu中创建用户和管理权限的方法',1363,3,'2025-11-21 21:36:12'),(5,3,'Ubuntu18.04 终端登录不了','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','解决Ubuntu终端无法登录的常见问题',580,1,'2025-11-21 21:36:12'),(6,3,'终端管道失效与环境变量','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','学习终端管道故障和环境变量配置问题',1596,2,'2025-11-21 21:36:12');
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
  `user_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` char(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_intro` text COLLATE utf8mb4_unicode_ci,
  `occupation` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `learning_goal` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('learner','instructor','admin') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'learner',
  `register_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login_time` datetime DEFAULT NULL,
  `is_active` tinyint DEFAULT '1',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_phone` (`phone`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_user`
--

/*!40000 ALTER TABLE `t_user` DISABLE KEYS */;
INSERT INTO `t_user` VALUES (1,'11','13800138000','teacher@icoursera.com','$2b$10$examplehashedpassword',NULL,'Python讲师','培养编程人才','instructor','2025-11-21 21:34:44',NULL,1);
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
  `behavior_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `keyword` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `status` enum('in_progress','completed') COLLATE utf8mb4_unicode_ci DEFAULT 'in_progress',
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
  `question_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `option_text` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `content_summary` text COLLATE utf8mb4_unicode_ci,
  `learning_objectives` text COLLATE utf8mb4_unicode_ci,
  `key_takeaways` text COLLATE utf8mb4_unicode_ci,
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
  `comment_content` text COLLATE utf8mb4_unicode_ci NOT NULL,
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
-- Dumping routines for database 'mzcourse'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-23 11:22:59
