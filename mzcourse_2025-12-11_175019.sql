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
-- Table structure for table `achievement`
--

DROP TABLE IF EXISTS `achievement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievement` (
  `achievement_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `achievement_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `achievement_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `earned_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `icon_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`achievement_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `achievement_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievement`
--

/*!40000 ALTER TABLE `achievement` DISABLE KEYS */;
/*!40000 ALTER TABLE `achievement` ENABLE KEYS */;

--
-- Table structure for table `achievement_type`
--

DROP TABLE IF EXISTS `achievement_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievement_type` (
  `type_id` int NOT NULL AUTO_INCREMENT,
  `achievement_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `condition_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `condition_value` int DEFAULT NULL,
  `icon_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievement_type`
--

/*!40000 ALTER TABLE `achievement_type` DISABLE KEYS */;
/*!40000 ALTER TABLE `achievement_type` ENABLE KEYS */;

--
-- Table structure for table `ai_chat_log`
--

DROP TABLE IF EXISTS `ai_chat_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_chat_log` (
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
  CONSTRAINT `ai_chat_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `ai_chat_log_ibfk_2` FOREIGN KEY (`video_id`) REFERENCES `course_video` (`video_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_chat_log`
--

/*!40000 ALTER TABLE `ai_chat_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_chat_log` ENABLE KEYS */;

--
-- Table structure for table `behavior_statistics`
--

DROP TABLE IF EXISTS `behavior_statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `behavior_statistics` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `course_id` int DEFAULT NULL,
  `behavior_name` varchar(50) NOT NULL,
  `behavior_count` int DEFAULT '0',
  `behavior_weight` decimal(5,2) DEFAULT '0.00',
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_teacher_course_behavior` (`teacher_id`,`course_id`,`behavior_name`),
  KEY `idx_teacher_id` (`teacher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `behavior_statistics`
--

/*!40000 ALTER TABLE `behavior_statistics` DISABLE KEYS */;
INSERT INTO `behavior_statistics` VALUES (1,15,NULL,'开始学习',15,25.50,'2025-12-11 09:08:56'),(2,15,NULL,'暂停思考',12,20.40,'2025-12-11 09:08:56'),(3,15,NULL,'记录笔记',8,13.60,'2025-12-11 09:08:56'),(4,15,NULL,'快进跳跃',6,10.20,'2025-12-11 09:08:56'),(5,15,NULL,'回看复习',5,8.50,'2025-12-11 09:08:56'),(6,15,NULL,'加速播放',4,6.80,'2025-12-11 09:08:56'),(7,15,NULL,'添加书签',3,5.10,'2025-12-11 09:08:56'),(8,15,NULL,'参与讨论',3,5.10,'2025-12-11 09:08:56'),(9,15,NULL,'提出问题',2,3.40,'2025-12-11 09:08:56'),(10,15,NULL,'重复播放',1,1.70,'2025-12-11 09:08:56'),(11,15,NULL,'注意力分散',8,13.60,'2025-12-11 09:08:56'),(12,15,NULL,'重新专注',7,11.90,'2025-12-11 09:08:56'),(13,15,NULL,'章节完成',2,3.40,'2025-12-11 09:08:56'),(14,15,NULL,'尝试测验',1,1.70,'2025-12-11 09:08:56'),(15,15,NULL,'下载资源',1,1.70,'2025-12-11 09:08:56'),(16,15,NULL,'开始学习',15,25.50,'2025-12-11 09:09:34'),(17,15,NULL,'暂停思考',12,20.40,'2025-12-11 09:09:34'),(18,15,NULL,'记录笔记',8,13.60,'2025-12-11 09:09:34'),(19,15,NULL,'快进跳跃',6,10.20,'2025-12-11 09:09:34'),(20,15,NULL,'回看复习',5,8.50,'2025-12-11 09:09:34'),(21,15,NULL,'加速播放',4,6.80,'2025-12-11 09:09:34'),(22,15,NULL,'添加书签',3,5.10,'2025-12-11 09:09:34'),(23,15,NULL,'参与讨论',3,5.10,'2025-12-11 09:09:34'),(24,15,NULL,'提出问题',2,3.40,'2025-12-11 09:09:34'),(25,15,NULL,'重复播放',1,1.70,'2025-12-11 09:09:34'),(26,15,NULL,'注意力分散',8,13.60,'2025-12-11 09:09:34'),(27,15,NULL,'重新专注',7,11.90,'2025-12-11 09:09:34'),(28,15,NULL,'章节完成',2,3.40,'2025-12-11 09:09:34'),(29,15,NULL,'尝试测验',1,1.70,'2025-12-11 09:09:34'),(30,15,NULL,'下载资源',1,1.70,'2025-12-11 09:09:34'),(31,15,NULL,'开始学习',25,25.50,'2025-12-11 09:20:24'),(32,15,NULL,'暂停思考',20,20.40,'2025-12-11 09:20:24'),(33,15,NULL,'记录笔记',15,15.30,'2025-12-11 09:20:24'),(34,15,NULL,'快进跳跃',12,12.20,'2025-12-11 09:20:24'),(35,15,NULL,'回看复习',10,10.20,'2025-12-11 09:20:24'),(36,15,NULL,'加速播放',8,8.20,'2025-12-11 09:20:24'),(37,15,NULL,'添加书签',6,6.10,'2025-12-11 09:20:24'),(38,15,NULL,'参与讨论',5,5.10,'2025-12-11 09:20:24'),(39,15,NULL,'提出问题',4,4.10,'2025-12-11 09:20:24'),(40,15,NULL,'重复播放',3,3.10,'2025-12-11 09:20:24'),(41,15,NULL,'注意力分散',12,12.20,'2025-12-11 09:20:24'),(42,15,NULL,'重新专注',10,10.20,'2025-12-11 09:20:24'),(43,15,NULL,'章节完成',8,8.20,'2025-12-11 09:20:24'),(44,15,NULL,'尝试测验',3,3.10,'2025-12-11 09:20:24'),(45,15,NULL,'下载资源',2,2.00,'2025-12-11 09:20:24');
/*!40000 ALTER TABLE `behavior_statistics` ENABLE KEYS */;

--
-- Table structure for table `chapter_progress`
--

DROP TABLE IF EXISTS `chapter_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chapter_progress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `progress_rate` decimal(5,2) DEFAULT '0.00' COMMENT '章节进度(%)',
  `completed_videos` int DEFAULT '0' COMMENT '已观看视频数',
  `total_videos` int DEFAULT '0' COMMENT '总视频数',
  `last_watched_at` timestamp NULL DEFAULT NULL COMMENT '最后观看时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_chapter` (`user_id`,`chapter_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_chapter` (`chapter_id`),
  KEY `idx_progress` (`progress_rate`),
  CONSTRAINT `fk_chapter_progress_chapter` FOREIGN KEY (`chapter_id`) REFERENCES `course_chapter` (`chapter_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_chapter_progress_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='章节学习进度表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chapter_progress`
--

/*!40000 ALTER TABLE `chapter_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `chapter_progress` ENABLE KEYS */;

--
-- Table structure for table `comment_like`
--

DROP TABLE IF EXISTS `comment_like`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comment_like` (
  `like_id` int NOT NULL AUTO_INCREMENT,
  `comment_id` int NOT NULL,
  `user_id` int NOT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `unique_comment_user` (`comment_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `comment_like_ibfk_1` FOREIGN KEY (`comment_id`) REFERENCES `post_comment` (`comment_id`) ON DELETE CASCADE,
  CONSTRAINT `comment_like_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_like`
--

/*!40000 ALTER TABLE `comment_like` DISABLE KEYS */;
INSERT INTO `comment_like` VALUES (1,5,8,'2025-12-01 12:30:00'),(2,5,9,'2025-12-01 13:00:00'),(3,6,8,'2025-12-02 11:30:00'),(4,6,10,'2025-12-02 12:00:00'),(5,9,8,'2025-12-02 14:30:00'),(6,12,7,'2025-12-03 17:30:00'),(7,12,101,'2025-12-03 18:00:00'),(8,14,6,'2025-12-04 18:30:00'),(9,14,8,'2025-12-04 19:00:00'),(10,14,9,'2025-12-04 19:30:00'),(11,16,6,'2025-12-05 12:30:00'),(12,16,8,'2025-12-05 13:00:00'),(13,16,10,'2025-12-05 13:30:00'),(14,19,7,'2025-12-05 15:30:00'),(15,19,8,'2025-12-05 16:00:00'),(16,24,7,'2025-12-07 18:30:00'),(17,24,103,'2025-12-07 19:00:00'),(18,28,6,'2025-12-08 16:30:00'),(19,31,8,'2025-12-09 12:30:00'),(20,31,9,'2025-12-09 13:00:00');
/*!40000 ALTER TABLE `comment_like` ENABLE KEYS */;

--
-- Table structure for table `community_message`
--

DROP TABLE IF EXISTS `community_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_message` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL,
  `receiver_id` int DEFAULT NULL,
  `team_id` int DEFAULT NULL,
  `room_id` int DEFAULT NULL,
  `message_type` enum('private','team','room','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'private',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint DEFAULT '0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `idx_sender` (`sender_id`),
  KEY `idx_receiver` (`receiver_id`),
  KEY `idx_team` (`team_id`),
  KEY `idx_room` (`room_id`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `community_message_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `community_message_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `community_message_ibfk_3` FOREIGN KEY (`team_id`) REFERENCES `study_team` (`team_id`) ON DELETE CASCADE,
  CONSTRAINT `community_message_ibfk_4` FOREIGN KEY (`room_id`) REFERENCES `study_room` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_message`
--

/*!40000 ALTER TABLE `community_message` DISABLE KEYS */;
INSERT INTO `community_message` VALUES (42,14,NULL,9,NULL,'team','英语六级冲刺小组成立！',0,'2025-12-08 21:00:00'),(43,105,NULL,9,NULL,'team','一起加油！六级必过！',0,'2025-12-08 21:05:00'),(44,14,NULL,9,NULL,'team','今天背了100个单词',0,'2025-12-08 22:00:00'),(45,105,NULL,9,NULL,'team','我做了一套听力真题',0,'2025-12-08 22:30:00'),(46,14,NULL,9,NULL,'team','听力正确率怎么样？',0,'2025-12-08 22:35:00'),(47,105,NULL,9,NULL,'team','70%左右，还需要多练习',0,'2025-12-08 22:40:00'),(48,14,NULL,9,NULL,'team','加油，坚持就是胜利！',0,'2025-12-08 23:00:00'),(49,6,NULL,10,NULL,'team','欢迎加入Python数据分析小组！',0,'2025-12-01 10:05:00'),(50,101,NULL,10,NULL,'team','谢谢组长！我是新手，请多指教',0,'2025-12-01 12:10:00'),(51,6,NULL,10,NULL,'team','pandas的DataFrame很重要，建议先从这里开始',0,'2025-12-02 09:00:00'),(52,101,NULL,10,NULL,'team','好的，我今天学习了数据读取，read_csv很方便',0,'2025-12-02 18:00:00'),(53,6,NULL,10,NULL,'team','不错！明天可以学习数据清洗',0,'2025-12-02 18:30:00'),(54,101,NULL,10,NULL,'team','遇到一个问题，缺失值怎么处理比较好？',0,'2025-12-03 10:00:00'),(55,6,NULL,10,NULL,'team','可以用fillna()填充或者dropna()删除，看具体情况',0,'2025-12-03 10:15:00'),(56,7,NULL,11,NULL,'team','React Hooks学习小组开始啦！',0,'2025-12-02 14:35:00'),(57,102,NULL,11,NULL,'team','终于找到组织了，一直想学Hooks',0,'2025-12-02 16:10:00'),(58,7,NULL,11,NULL,'team','useState是最基础的，先从这个开始',0,'2025-12-03 09:00:00'),(59,102,NULL,11,NULL,'team','useEffect的依赖数组有点难理解',0,'2025-12-03 15:00:00'),(60,7,NULL,11,NULL,'team','空数组只执行一次，有依赖就监听变化',0,'2025-12-03 15:20:00'),(61,102,NULL,11,NULL,'team','明白了！今天写了个计数器demo',0,'2025-12-04 18:00:00'),(62,8,NULL,12,NULL,'team','数据库学习组成立！SQL从零开始',0,'2025-12-03 09:05:00'),(63,103,NULL,12,NULL,'team','正好要学数据库，太及时了',0,'2025-12-03 10:35:00'),(64,8,NULL,12,NULL,'team','先学SELECT查询，这是最常用的',0,'2025-12-04 09:00:00'),(65,103,NULL,12,NULL,'team','WHERE条件筛选学会了，挺简单的',0,'2025-12-04 16:00:00'),(66,8,NULL,12,NULL,'team','JOIN多表联查是重点，要多练习',0,'2025-12-05 10:00:00'),(67,103,NULL,12,NULL,'team','LEFT JOIN和INNER JOIN的区别搞懂了',0,'2025-12-05 20:00:00'),(68,9,NULL,13,NULL,'team','算法刷题小组！每日一题，坚持打卡',0,'2025-12-04 20:05:00'),(69,104,NULL,13,NULL,'team','一起刷题！我刚开始刷LeetCode',0,'2025-12-04 21:10:00'),(70,9,NULL,13,NULL,'team','今天刷了两数之和，用哈希表O(n)解决',0,'2025-12-05 21:00:00'),(71,104,NULL,13,NULL,'team','我用的暴力解法，时间复杂度太高了',0,'2025-12-05 21:30:00'),(72,9,NULL,13,NULL,'team','哈希表是常用技巧，空间换时间',0,'2025-12-05 21:45:00'),(73,104,NULL,13,NULL,'team','二分查找的边界条件好难处理',0,'2025-12-06 22:00:00'),(74,9,NULL,13,NULL,'team','记住左闭右闭或左闭右开的模板就行',0,'2025-12-06 22:15:00'),(75,10,NULL,14,NULL,'team','TypeScript学习开始！类型安全很重要',0,'2025-12-05 14:05:00'),(76,105,NULL,14,NULL,'team','之前写JS总是类型报错，想学TS',0,'2025-12-05 14:10:00'),(77,10,NULL,14,NULL,'team','先学基础类型：string、number、boolean',0,'2025-12-06 09:00:00'),(78,105,NULL,14,NULL,'team','数组类型怎么定义？',0,'2025-12-06 14:00:00'),(79,10,NULL,14,NULL,'team','number[] 或者 Array<number> 都可以',0,'2025-12-06 14:15:00'),(80,105,NULL,14,NULL,'team','interface和type有什么区别？',0,'2025-12-07 10:00:00'),(81,10,NULL,14,NULL,'team','interface可以继承和声明合并，type更灵活',0,'2025-12-07 10:20:00'),(82,14,NULL,15,NULL,'team','计算机网络学习组！一起啃硬骨头',0,'2025-12-06 08:05:00'),(83,106,NULL,15,NULL,'team','网络知识太重要了，面试必考',0,'2025-12-06 10:10:00'),(84,14,NULL,15,NULL,'team','先从OSI七层模型开始理解',0,'2025-12-07 09:00:00'),(85,106,NULL,15,NULL,'team','物理层、数据链路层、网络层...记住了',0,'2025-12-07 15:00:00'),(86,14,NULL,15,NULL,'team','TCP三次握手是重点，要理解为什么是三次',0,'2025-12-08 10:00:00'),(87,106,NULL,15,NULL,'team','为了确认双方的收发能力都正常！',0,'2025-12-08 10:30:00'),(88,14,NULL,15,NULL,'team','对！四次挥手也要掌握',0,'2025-12-08 10:45:00');
/*!40000 ALTER TABLE `community_message` ENABLE KEYS */;

--
-- Table structure for table `community_post`
--

DROP TABLE IF EXISTS `community_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_post` (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_id` int NOT NULL,
  `category` enum('discussion','question','sharing','announcement') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'discussion',
  `course_id` int DEFAULT NULL,
  `likes_count` int DEFAULT '0',
  `comments_count` int DEFAULT '0',
  `views_count` int DEFAULT '0',
  `status` enum('published','draft','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'published',
  `is_pinned` tinyint DEFAULT '0',
  `tags` json DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`),
  KEY `idx_author` (`author_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `community_post_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `community_post_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_post`
--

/*!40000 ALTER TABLE `community_post` DISABLE KEYS */;
INSERT INTO `community_post` VALUES (1,'Java学习心得分享','经过一个月的学习，我终于完成了2026版AI新课的Java课程。这门课程真的很棒，从基础到AI应用都讲得非常清楚。\n\n特别是AI算法实现那部分，老师用很多实例来讲解，让我对机器学习有了更深的理解。推荐系统实战项目也很有意思，跟着做完之后感觉收获满满。\n\n给正在学习的同学几点建议：\n1. 一定要跟着敲代码，不要只看视频\n2. 每个章节的练习题都要做\n3. 实战项目一定要自己独立完成一遍\n\n加油！',6,'sharing',1,25,12,156,'published',0,'[\"Java\", \"AI\", \"学习心得\", \"编程\"]','2025-11-29 10:30:00','2025-11-29 10:30:00'),(2,'高数期末复习攻略 - 3小时速成真的有用！','马上就要期末考试了，分享一下我用3小时速成课程复习高数的经验。\n\n**课程优点：**\n- 讲解通俗易懂，不会让人听不懂\n- 重点突出，都是考试常考的内容\n- 例题很典型，掌握了就能应对大部分题目\n\n**我的复习计划：**\n第1小时：极限与连续（重点是求极限的方法）\n第2小时：导数与微分（各种求导法则要熟练）\n第3小时：积分学（定积分的应用很重要）\n\n**额外建议：**\n看完视频后一定要做题！我整理了一些常考题型，需要的同学可以留言。\n\n祝大家期末都能过！💪',7,'sharing',2,42,18,203,'published',1,'[\"高数\", \"期末复习\", \"学习方法\", \"考试\"]','2025-11-29 11:00:00','2025-11-29 11:00:00'),(3,'英语四级听力如何突破？求大神指点','听力一直是我的弱项，每次做题都错很多。最近在学四级听力原文训练这门课，感觉有点进步，但还是不够。\n\n**我的问题：**\n1. 短对话总是听不清关键信息\n2. 长对话容易走神，后面就跟不上了\n3. 短文听力速度太快，来不及反应\n\n**已经尝试的方法：**\n- 每天听1小时\n- 跟读练习\n- 做真题\n\n但效果不明显，有没有学长学姐分享一下经验？特别是如何提高听力速度和抓关键词的能力？\n\n谢谢大家！🙏',8,'question',3,28,15,187,'published',0,'[\"英语\", \"四级\", \"听力\", \"求助\"]','2025-11-29 12:15:00','2025-11-29 12:15:00'),(4,'申论写作模板分享 - 小马哥课程笔记整理','学完小马哥的申论系统课，整理了一些写作模板和技巧，分享给准备公考的同学。\n\n**归纳概括题模板：**\n根据材料X，主要问题有：一是...；二是...；三是...。\n\n**综合分析题思路：**\n1. 解释含义\n2. 分析原因/影响\n3. 提出对策\n4. 总结升华\n\n**申发论述题结构：**\n开头：引出话题+亮明观点\n分论点1：理论论证\n分论点2：事实论证  \n分论点3：对比论证\n结尾：总结全文+升华主题\n\n**小马哥强调的重点：**\n- 政府思维很重要\n- 材料分析要全面\n- 语言表达要规范\n\n完整笔记太长了，需要的同学可以私信我。希望大家都能考出好成绩！✊',9,'sharing',7,35,20,245,'published',0,'[\"申论\", \"公考\", \"写作模板\", \"笔记\"]','2025-11-29 13:30:00','2025-11-29 13:30:00'),(5,'Python数据分析项目实战经验分享','刚完成了销售数据分析项目，踩了不少坑，分享一些经验给大家。\n\n**项目难点：**\n1. 数据清洗：缺失值和异常值的处理\n2. 数据可视化：选择合适的图表类型\n3. 结果解读：从数据中得出有价值的结论\n\n**我的解决方案：**\n- 缺失值：根据业务逻辑选择填充或删除\n- 异常值：用箱线图识别，结合实际情况处理\n- 可视化：多尝试几种图表，选最直观的\n\n**推荐的学习资源：**\n- Pandas官方文档\n- Matplotlib画廊\n- Kaggle上的实战项目\n\n这门课程的项目设计很好，跟着做完真的能学到很多。建议大家不要只看视频，一定要自己动手做！\n\n有问题欢迎交流～',6,'sharing',9,22,10,134,'published',0,'[\"Python\", \"数据分析\", \"项目实战\", \"经验分享\"]','2025-11-29 14:30:00','2025-11-29 14:30:00'),(6,'Web前端学习路线推荐','作为一个刚入门的前端小白，分享一下我的学习路线，希望对大家有帮助。\n\n**第一阶段：基础（1-2个月）**\n- HTML5：语义化标签、表单\n- CSS3：布局（Flexbox、Grid）、动画\n- JavaScript：ES6基础语法\n\n**第二阶段：进阶（2-3个月）**\n- JavaScript深入：闭包、原型链、异步\n- 前端框架：Vue.js或React\n- 工程化：Webpack、Git\n\n**第三阶段：实战（持续）**\n- 做项目！做项目！做项目！\n- 参与开源项目\n- 写技术博客\n\n**学习建议：**\n1. 不要贪多，一个一个学\n2. 多写代码，少看视频\n3. 遇到问题先自己思考\n4. 加入学习社群，互相帮助\n\n一起加油！💪',10,'sharing',10,18,8,98,'published',0,'[\"前端\", \"学习路线\", \"Web开发\", \"新手\"]','2025-11-29 15:00:00','2025-11-29 15:00:00'),(7,'清华公考140+方法论真的有用吗？','看到清华大学的公考课程，一周达到140+，感觉有点不可思议。有学过的同学吗？效果怎么样？\n\n我现在行测大概120分左右，申论70分，想提高到140+。\n\n**我的疑问：**\n1. 一周时间真的够吗？\n2. 适合什么基础的人？\n3. 主要讲什么内容？\n\n准备报名，但有点犹豫，希望学过的同学给点建议。谢谢！',7,'question',8,15,9,76,'published',0,'[\"公考\", \"清华\", \"学习方法\", \"咨询\"]','2025-11-29 16:00:00','2025-11-29 16:00:00'),(8,'机器学习算法学习笔记 - 持续更新','开始学习机器学习算法精讲这门课，打算把学习笔记分享出来，也算是督促自己坚持学习。\n\n**第一周：机器学习概述**\n- 什么是机器学习\n- 监督学习 vs 非监督学习\n- 常见算法分类\n\n**第二周：线性回归**\n- 算法原理\n- 损失函数\n- 梯度下降\n- Python实现\n\n后续会继续更新，欢迎一起学习的同学交流！\n\n#机器学习 #学习笔记',6,'sharing',11,12,7,52,'published',0,'[\"机器学习\", \"算法\", \"学习笔记\", \"AI\"]','2025-11-29 17:00:00','2025-12-06 19:18:45'),(9,'前端创建示例帖子 0080','这是通过前端示例按钮创建的帖子，用于测试帖子接口。',14,'discussion',5,0,0,0,'published',0,'[\"示例\", \"讨论\"]','2025-12-01 22:41:10','2025-12-06 19:41:46'),(10,'线性代数学习方法总结','学完线性代数精讲课程后，总结一些学习心得：\n\n**矩阵运算要点：**\n1. 矩阵乘法不满足交换律，AB≠BA\n2. 单位矩阵是乘法的\"1\"\n3. 逆矩阵的求法要熟练\n\n**向量空间理解：**\n- 线性相关和线性无关的判断\n- 基和维数的概念\n- 子空间的性质\n\n**特征值计算：**\n1. 先求特征多项式\n2. 解方程得特征值\n3. 代入求特征向量\n\n希望对大家有帮助！',7,'sharing',14,5,3,178,'published',0,'[\"线性代数\", \"数学\", \"学习方法\"]','2025-12-01 09:00:00','2025-12-09 08:43:28'),(11,'求助：Python数据可视化图表选择问题','在做数据分析项目时，遇到一个问题：\n\n我有一组销售数据，包含：\n- 时间序列（12个月）\n- 不同产品类别（5类）\n- 销售额和销量\n\n**我的困惑：**\n1. 展示趋势用折线图还是面积图？\n2. 类别对比用柱状图还是饼图？\n3. 多维度数据怎么在一张图上展示？\n\n课程里讲了Matplotlib基础，但实际应用时还是不太会选择。有经验的同学能指点一下吗？',8,'question',9,3,4,95,'published',0,'[\"Python\", \"数据可视化\", \"Matplotlib\", \"求助\"]','2025-12-02 10:30:00','2025-12-09 08:43:29'),(12,'六级翻译技巧分享 - 亲测有效','刚考完六级，翻译部分感觉发挥不错，分享一些技巧：\n\n**翻译步骤：**\n1. 通读全文，理解大意\n2. 划分句子结构\n3. 确定主谓宾\n4. 添加修饰成分\n\n**常见句型转换：**\n- 中文无主句 → 英文被动语态\n- 中文流水句 → 英文从句结构\n- 四字成语 → 简洁英文表达\n\n**高频词汇积累：**\n经济发展 economic development\n文化遗产 cultural heritage\n可持续发展 sustainable development\n\n六级阅读理解突破这门课的翻译部分讲得很好，推荐！',9,'sharing',13,6,3,234,'published',0,'[\"英语\", \"六级\", \"翻译\", \"技巧\"]','2025-12-03 14:20:00','2025-12-09 08:43:30'),(13,'概率论期末复习重点整理','期末考试临近，整理了概率论的重点内容：\n\n**第一章：概率基础**\n- 古典概型计算\n- 条件概率公式\n- 全概率公式和贝叶斯公式\n\n**第二章：随机变量**\n- 离散型：二项分布、泊松分布\n- 连续型：均匀分布、正态分布、指数分布\n- 分布函数和密度函数\n\n**第三章：数字特征**\n- 期望和方差的计算\n- 协方差和相关系数\n\n**第四章：大数定律**\n- 切比雪夫不等式\n- 中心极限定理\n\n有需要详细笔记的同学可以留言～',10,'sharing',16,4,3,189,'published',1,'[\"概率论\", \"期末复习\", \"数学\", \"笔记\"]','2025-12-04 16:00:00','2025-12-09 08:43:30'),(14,'Vue.js和React该学哪个？新手求建议','刚学完Web前端全栈开发的HTML/CSS/JS部分，现在要选框架了。\n\n**我的情况：**\n- 编程基础一般\n- 想找前端工作\n- 学习时间有限（每天2-3小时）\n\n**我了解到的：**\nVue.js：\n- 中文文档友好\n- 上手相对容易\n- 国内用得多\n\nReact：\n- 生态更丰富\n- 大厂用得多\n- 学习曲线陡\n\n各位前辈怎么看？先学哪个比较好？',6,'question',10,7,4,312,'published',0,'[\"前端\", \"Vue.js\", \"React\", \"框架选择\"]','2025-12-05 11:00:00','2025-12-09 08:43:31'),(15,'行测言语理解答题技巧','备考公务员，言语理解是我的弱项，最近总结了一些技巧：\n\n**主旨概括题：**\n1. 找关键词：因此、所以、总之\n2. 注意转折：但是、然而、却\n3. 首尾句往往是重点\n\n**细节判断题：**\n1. 绝对化表述要警惕\n2. 偷换概念要识别\n3. 无中生有要排除\n\n**语句排序题：**\n1. 找首句特征\n2. 找关联词配对\n3. 注意指代词\n\n配合行测数量关系速解一起学，效果更好！',9,'sharing',15,3,2,156,'published',0,'[\"公考\", \"行测\", \"言语理解\", \"技巧\"]','2025-12-06 09:30:00','2025-12-09 08:43:32'),(16,'机器学习项目实战经验 - 房价预测','完成了机器学习算法精讲的房价预测项目，分享一下经验：\n\n**数据预处理：**\n1. 缺失值处理：数值用中位数，类别用众数\n2. 异常值处理：IQR方法识别\n3. 特征编码：One-Hot编码\n\n**特征工程：**\n- 创建新特征：房龄、总面积\n- 特征选择：相关性分析\n- 特征缩放：StandardScaler\n\n**模型选择：**\n尝试了多个模型：\n- 线性回归：R²=0.72\n- 随机森林：R²=0.85\n- XGBoost：R²=0.88\n\n最终选择XGBoost，RMSE最低。\n\n代码已上传GitHub，需要的同学私信我～',6,'sharing',11,5,3,267,'published',0,'[\"机器学习\", \"项目实战\", \"Python\", \"数据科学\"]','2025-12-07 15:00:00','2025-12-09 08:43:32'),(17,'大学物理电磁学部分太难了，求助！','学到电磁学就懵了，特别是：\n\n**不理解的地方：**\n1. 麦克斯韦方程组的物理意义\n2. 电磁感应定律的应用\n3. 交流电路的计算\n\n**已经尝试：**\n- 看了大学物理速成课程\n- 做了课后习题\n- 但还是不太懂\n\n有没有学长学姐能推荐一些学习资源或者讲解一下思路？感谢！',101,'question',12,2,2,87,'published',0,'[\"物理\", \"电磁学\", \"求助\", \"大学物理\"]','2025-12-08 10:00:00','2025-12-09 08:43:33'),(18,'Node.js后端开发学习路线','作为前端转全栈的过来人，分享一下Node.js学习路线：\n\n**第一阶段：基础（2周）**\n- Node.js核心模块\n- npm包管理\n- 异步编程\n\n**第二阶段：框架（3周）**\n- Express.js基础\n- 中间件机制\n- 路由设计\n\n**第三阶段：数据库（2周）**\n- MySQL基础操作\n- MongoDB入门\n- ORM使用（Sequelize/Mongoose）\n\n**第四阶段：实战（持续）**\n- RESTful API设计\n- 用户认证（JWT）\n- 项目部署\n\nWeb开发实战课程的Node.js部分讲得很系统，推荐！',102,'sharing',19,4,2,198,'published',0,'[\"Node.js\", \"后端\", \"学习路线\", \"全栈\"]','2025-12-08 14:30:00','2025-12-09 08:43:34'),(19,'数据库索引优化实践总结','最近在学数据库系统课程，对索引优化有了新的理解：\n\n**索引类型选择：**\n1. B+树索引：范围查询\n2. 哈希索引：等值查询\n3. 全文索引：文本搜索\n\n**索引设计原则：**\n- 选择性高的列优先\n- 经常查询的列建索引\n- 避免过多索引\n\n**常见优化场景：**\n```sql\n-- 优化前\nSELECT * FROM orders WHERE YEAR(create_time) = 2025;\n\n-- 优化后\nSELECT * FROM orders WHERE create_time >= \'2025-01-01\' AND create_time < \'2026-01-01\';\n```\n\n**EXPLAIN分析：**\n- type: ALL → range → ref → const\n- 目标是避免全表扫描\n\n欢迎讨论交流！',103,'sharing',20,3,2,145,'published',0,'[\"数据库\", \"MySQL\", \"索引优化\", \"性能\"]','2025-12-09 09:00:00','2025-12-09 08:43:34'),(20,'申论大作文写作模板分享','整理了申论大作文的万能模板：\n\n**开头模板：**\n\"随着...的深入推进，...问题日益凸显。...不仅关系到...，更影响着...。因此，...势在必行。\"\n\n**分论点结构：**\n论点一：...是...的基础\n论点二：...是...的关键  \n论点三：...是...的保障\n\n**结尾模板：**\n\"...非一日之功，需要...。只有...，才能...，最终实现...的目标。\"\n\n**注意事项：**\n1. 观点要明确\n2. 论据要充分\n3. 语言要规范\n4. 字数要达标\n\n申论系统课 - 小马哥讲得很透彻，强烈推荐！',104,'sharing',7,6,4,289,'published',0,'[\"申论\", \"公考\", \"写作模板\", \"大作文\"]','2025-12-09 11:30:00','2025-12-09 10:53:35');
/*!40000 ALTER TABLE `community_post` ENABLE KEYS */;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course` (
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
  `course_overview` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '课程概述',
  `learning_objectives` json DEFAULT NULL COMMENT '学习目标列表',
  `course_features` json DEFAULT NULL COMMENT '课程特色列表',
  PRIMARY KEY (`course_id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_teacher` (`teacher_user_id`),
  KEY `idx_difficulty` (`difficulty_level`),
  CONSTRAINT `course_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `course_category` (`category_id`),
  CONSTRAINT `course_ibfk_2` FOREIGN KEY (`teacher_user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course`
--

/*!40000 ALTER TABLE `course` DISABLE KEYS */;
INSERT INTO `course` VALUES (1,'2026版AI新课 - Java入门到大神','从零基础到高级应用，全面掌握Java编程与AI技术结合。包含AI应用开发、算法实现和实战项目。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/Java%E5%85%A5%E9%97%A8%E5%88%B0%E5%A4%A7%E7%A5%9E.jpg',3,1,'beginner',7200,1,'2025-11-30 13:52:00','2025-12-06 21:16:35',2580,4.8,215,'2025-11-29 21:52:00','2025-12-06 13:16:35','2026年最新版Java课程，结合人工智能技术，从基础语法到AI应用开发，帮助学员掌握Java编程的同时了解AI技术在实际项目中的应用。','[\"掌握Java基础语法和面向对象编程\", \"学习Java高级特性和框架应用\", \"了解AI算法在Java中的实现\", \"完成AI+Java实战项目\", \"掌握现代Java开发工具和技术栈\"]','[{\"icon\": \"fas fa-robot\", \"title\": \"AI技术融合\", \"description\": \"将人工智能技术与Java开发完美结合\"}, {\"icon\": \"fas fa-project-diagram\", \"title\": \"实战项目\", \"description\": \"通过真实AI项目提升编程能力\"}, {\"icon\": \"fas fa-rocket\", \"title\": \"2026最新版\", \"description\": \"紧跟技术发展趋势的最新课程内容\"}, {\"icon\": \"fas fa-infinity\", \"title\": \"从零到大神\", \"description\": \"完整的学习路径，适合各个水平的学员\"}]'),(2,'高等数学(上) - 3小时速成','超级通俗易懂的高等数学上册速成课程，3小时掌握核心概念，期末不挂科。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/13408799812653464.jpeg',7,2,'beginner',180,1,'2025-11-30 13:52:00','2025-12-01 15:41:53',3416,4.9,328,'2025-11-29 21:52:00','2025-12-01 07:41:53','专为大学生设计的高等数学速成课程，用最通俗易懂的方式讲解复杂的数学概念，帮助学生快速理解并通过期末考试。','[\"掌握极限的概念和计算方法\", \"理解导数的定义和应用\", \"学会积分的基本计算\", \"掌握微分方程的基础知识\", \"能够解决常见的高数题型\"]','[{\"icon\": \"fas fa-clock\", \"title\": \"3小时速成\", \"description\": \"高效学习，快速掌握核心知识点\"}, {\"icon\": \"fas fa-smile\", \"title\": \"通俗易懂\", \"description\": \"用最简单的语言解释复杂概念\"}, {\"icon\": \"fas fa-shield-alt\", \"title\": \"期末保障\", \"description\": \"针对期末考试，确保不挂科\"}, {\"icon\": \"fas fa-lightning-bolt\", \"title\": \"速成方法\", \"description\": \"独特的学习方法，事半功倍\"}]'),(3,'英语四级听力原文训练','专注于英语四级听力部分的原文训练，提高听力理解能力和应试技巧。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/%E5%B0%81%E9%9D%A2.jpeg',8,3,'intermediate',600,1,'2025-11-30 13:52:00','2025-11-30 14:49:15',2150,4.6,186,'2025-11-29 21:52:00','2025-11-30 06:49:15','针对大学英语四级考试听力部分的专项训练课程，通过大量原文练习和技巧讲解，帮助学生显著提升听力成绩。','[\"掌握四级听力考试题型和技巧\", \"提高英语听力理解能力\", \"熟悉常见听力场景和词汇\", \"学会快速抓取关键信息\", \"达到四级听力及格水平\"]','[{\"icon\": \"fas fa-headphones\", \"title\": \"专项训练\", \"description\": \"专注听力部分的深度训练\"}, {\"icon\": \"fas fa-file-alt\", \"title\": \"原文练习\", \"description\": \"大量真题原文材料练习\"}, {\"icon\": \"fas fa-bullseye\", \"title\": \"应试技巧\", \"description\": \"针对性的考试技巧指导\"}, {\"icon\": \"fas fa-chart-line\", \"title\": \"快速提升\", \"description\": \"短期内显著提高听力成绩\"}]'),(4,'高数(微积分) - 上期未速成','针对微积分部分的深度讲解，解决上期课程中未完全掌握的难点问题。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E9%AB%98%E6%95%B01.jpg',7,2,'intermediate',300,1,'2025-11-30 13:52:00','2025-11-30 14:49:17',1890,4.5,142,'2025-11-29 21:52:00','2025-11-30 06:49:17','专门针对微积分学习中的难点和易错点进行深入讲解，帮助学生彻底理解微积分的核心概念和计算方法。','[\"深入理解微积分的基本概念\", \"掌握复杂函数的求导技巧\", \"学会积分的高级计算方法\", \"解决微积分应用题\", \"提高数学思维能力\"]','[{\"icon\": \"fas fa-microscope\", \"title\": \"深度讲解\", \"description\": \"针对难点进行深入分析\"}, {\"icon\": \"fas fa-puzzle-piece\", \"title\": \"查漏补缺\", \"description\": \"解决之前学习中的遗留问题\"}, {\"icon\": \"fas fa-brain\", \"title\": \"思维训练\", \"description\": \"培养数学逻辑思维能力\"}, {\"icon\": \"fas fa-tools\", \"title\": \"实用技巧\", \"description\": \"掌握解题的实用方法和技巧\"}]'),(5,'1小时教你学会申论','公务员考试申论科目的快速入门课程，1小时掌握申论写作的核心技巧。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA.jpg',9,4,'beginner',60,1,'2025-11-30 13:52:00','2025-12-01 15:34:20',3681,4.7,295,'2025-11-29 21:52:00','2025-12-01 07:34:20','专为公务员考试申论科目设计的快速入门课程，通过系统的方法论和实用技巧，帮助考生快速掌握申论写作要领。','[\"掌握申论考试的基本题型\", \"学会材料分析和要点提取\", \"掌握申论写作的基本结构\", \"学习政府思维和表达方式\", \"提高申论答题效率\"]','[{\"icon\": \"fas fa-stopwatch\", \"title\": \"1小时速成\", \"description\": \"高效学习，快速入门申论\"}, {\"icon\": \"fas fa-pen-fancy\", \"title\": \"写作技巧\", \"description\": \"掌握申论写作的核心方法\"}, {\"icon\": \"fas fa-government\", \"title\": \"政府思维\", \"description\": \"培养公务员思维模式\"}, {\"icon\": \"fas fa-target\", \"title\": \"应试导向\", \"description\": \"针对考试要求的实用指导\"}]'),(6,'大学英语六级 - 20小时期末突击','免费优质的英语六级突击课程，20小时高效复习，通俗易懂，干货满满。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/%E8%8B%B1%E8%AF%AD%E5%85%AD%E7%BA%A7%E7%AA%81%E5%87%BB.jpg',8,3,'intermediate',1200,1,'2025-11-30 13:52:00','2025-12-06 21:16:35',4250,4.9,412,'2025-11-29 21:52:00','2025-12-06 13:16:35','专为大学英语六级考试设计的突击复习课程，涵盖听力、阅读、翻译、写作四大板块，帮助学生在短时间内显著提升成绩。','[\"掌握六级考试各题型技巧\", \"提高英语综合运用能力\", \"学会高效的复习方法\", \"掌握六级核心词汇和语法\", \"达到六级考试通过标准\"]','[{\"icon\": \"fas fa-gift\", \"title\": \"完全免费\", \"description\": \"高质量免费课程，无任何隐藏费用\"}, {\"icon\": \"fas fa-gem\", \"title\": \"干货满满\", \"description\": \"纯干货内容，没有废话\"}, {\"icon\": \"fas fa-rocket\", \"title\": \"20小时突击\", \"description\": \"高效复习计划，短期快速提升\"}, {\"icon\": \"fas fa-heart\", \"title\": \"通俗易懂\", \"description\": \"用最简单的方式讲解复杂知识\"}]'),(7,'申论系统课 - 小马哥','由知名讲师小马哥主讲的申论系统课程，全面提升申论写作和分析能力。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA2.jpg',9,4,'advanced',1800,1,'2025-11-30 13:52:00','2025-11-30 14:49:19',2940,4.8,268,'2025-11-29 21:52:00','2025-11-30 06:49:19','由资深公考专家小马哥精心打造的申论系统课程，从基础理论到高级技巧，全方位提升申论应试能力。','[\"系统掌握申论理论体系\", \"学会深层次材料分析\", \"掌握高分申论写作技巧\", \"培养政策分析思维\", \"达到申论高分水平\"]','[{\"icon\": \"fas fa-user-tie\", \"title\": \"名师授课\", \"description\": \"知名讲师小马哥亲自授课\"}, {\"icon\": \"fas fa-layer-group\", \"title\": \"系统课程\", \"description\": \"完整的申论学习体系\"}, {\"icon\": \"fas fa-medal\", \"title\": \"高分保障\", \"description\": \"针对高分的专业指导\"}, {\"icon\": \"fas fa-graduation-cap\", \"title\": \"专业权威\", \"description\": \"多年公考培训经验积累\"}]'),(8,'清华大学 - 如何逗自己一周达到《公考140+》','清华大学出品的公务员考试高分秘籍，一周内掌握140+分数的核心方法。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E8%A1%8C%E6%B5%8B1.jpg',9,5,'advanced',420,1,'2025-11-30 13:52:00','2025-11-30 14:49:20',1850,4.7,156,'2025-11-29 21:52:00','2025-11-30 06:49:20','清华大学权威出品的公务员考试高分课程，汇集顶尖学府的学习方法和应试技巧，帮助考生在短时间内实现分数的质的飞跃。','[\"掌握高效的学习方法\", \"学会时间管理和复习规划\", \"掌握各科目高分技巧\", \"培养应试心理素质\", \"实现公考140+高分目标\"]','[{\"icon\": \"fas fa-university\", \"title\": \"清华出品\", \"description\": \"清华大学权威课程品质保证\"}, {\"icon\": \"fas fa-trophy\", \"title\": \"140+高分\", \"description\": \"针对高分目标的专业指导\"}, {\"icon\": \"fas fa-calendar-week\", \"title\": \"一周速成\", \"description\": \"高效学习方法，快速提升\"}, {\"icon\": \"fas fa-star\", \"title\": \"珍贵资源\", \"description\": \"难得一见的优质学习资源\"}]'),(9,'Python数据分析实战','使用Python进行数据分析，掌握Pandas、NumPy等核心库的使用。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/Python%E5%AE%9E%E6%88%98%E8%AF%BE%E7%A8%8B.jpg',2,1,'intermediate',2400,1,'2025-11-30 14:00:00','2025-12-06 21:16:35',1580,4.6,125,'2025-11-29 22:00:00','2025-12-06 13:16:35','深入学习Python数据分析技术，从数据清洗到可视化，掌握完整的数据分析流程。','[\"掌握Pandas数据处理技巧\", \"学会NumPy数组运算\", \"掌握数据可视化方法\", \"完成真实数据分析项目\", \"学习数据清洗和预处理\"]','[{\"icon\": \"fas fa-chart-pie\", \"title\": \"实战导向\", \"description\": \"真实数据集实战练习\"}, {\"icon\": \"fas fa-database\", \"title\": \"数据处理\", \"description\": \"完整的数据分析流程\"}, {\"icon\": \"fas fa-eye\", \"title\": \"可视化\", \"description\": \"精美的数据可视化展示\"}, {\"icon\": \"fas fa-briefcase\", \"title\": \"职业技能\", \"description\": \"企业级数据分析能力\"}]'),(10,'Web前端全栈开发','HTML、CSS、JavaScript全栈开发，打造现代化Web应用。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/Web%E5%BC%80%E5%8F%91.jpg',1,2,'beginner',3600,1,'2025-11-30 14:00:00','2025-12-06 21:16:35',2350,4.8,198,'2025-11-29 22:00:00','2025-12-06 13:16:35','从零开始学习Web前端开发，掌握HTML5、CSS3、JavaScript ES6+等现代前端技术。','[\"掌握HTML5语义化标签\", \"精通CSS3布局和动画\", \"熟练使用JavaScript ES6+\", \"学习Vue.js/React框架\", \"完成完整Web项目\"]','[{\"icon\": \"fas fa-laptop-code\", \"title\": \"全栈技能\", \"description\": \"前后端技术全覆盖\"}, {\"icon\": \"fas fa-mobile-alt\", \"title\": \"响应式设计\", \"description\": \"适配各种设备屏幕\"}, {\"icon\": \"fas fa-rocket\", \"title\": \"现代技术\", \"description\": \"最新前端技术栈\"}, {\"icon\": \"fas fa-users\", \"title\": \"项目实战\", \"description\": \"真实企业级项目\"}]'),(11,'机器学习算法精讲','深入理解机器学习算法原理，从理论到实践全面掌握。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/%E6%9C%BA%E5%99%A8%E5%AD%A6%E4%B9%A0%E7%AE%97%E6%B3%95.jpg',3,1,'advanced',3000,1,'2025-11-30 14:00:00','2025-12-06 21:17:58',980,4.7,87,'2025-11-29 22:00:00','2025-12-06 13:17:58','系统学习机器学习核心算法，包括监督学习、非监督学习和强化学习等。','[\"理解机器学习基本原理\", \"掌握常用算法实现\", \"学会模型评估和优化\", \"完成机器学习项目\", \"了解深度学习基础\"]','[{\"icon\": \"fas fa-brain\", \"title\": \"算法精讲\", \"description\": \"深入讲解算法原理\"}, {\"icon\": \"fas fa-code\", \"title\": \"代码实现\", \"description\": \"手写算法代码实现\"}, {\"icon\": \"fas fa-chart-line\", \"title\": \"模型优化\", \"description\": \"模型调优技巧\"}, {\"icon\": \"fas fa-project-diagram\", \"title\": \"项目实战\", \"description\": \"真实ML项目经验\"}]'),(12,'大学物理速成','大学物理核心知识点速成，轻松应对期末考试。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/%E5%A4%A7%E5%AD%A6%E7%89%A9%E7%90%86%E9%80%9F%E6%88%90.jpg',7,2,'beginner',240,1,'2025-11-30 14:00:00','2025-12-06 21:17:58',1250,4.5,95,'2025-11-29 22:00:00','2025-12-06 13:17:58','涵盖力学、电磁学、光学等核心内容，用通俗易懂的方式讲解物理概念。','[\"掌握牛顿力学基础\", \"理解电磁学原理\", \"学习光学基本知识\", \"掌握热力学定律\", \"能够解决物理习题\"]','[{\"icon\": \"fas fa-atom\", \"title\": \"核心知识\", \"description\": \"聚焦考试重点内容\"}, {\"icon\": \"fas fa-calculator\", \"title\": \"解题技巧\", \"description\": \"快速解题方法\"}, {\"icon\": \"fas fa-clock\", \"title\": \"高效学习\", \"description\": \"短时间掌握要点\"}, {\"icon\": \"fas fa-check-circle\", \"title\": \"考试保障\", \"description\": \"针对期末考试设计\"}]'),(13,'英语六级阅读理解突破','专项训练英语六级阅读理解，掌握快速阅读和答题技巧。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/%E8%8B%B1%E8%AF%AD%E5%85%AD%E7%BA%A7%E9%98%85%E8%AF%BB%E7%90%86%E8%A7%A3.jpg',8,3,'intermediate',480,1,'2025-11-30 14:00:00','2025-12-06 21:17:58',1680,4.6,142,'2025-11-29 22:00:00','2025-12-06 13:17:58','针对六级阅读理解的专项突破课程，提高阅读速度和准确率。','[\"掌握快速阅读技巧\", \"学会定位关键信息\", \"提高词汇量\", \"理解长难句结构\", \"提升阅读准确率\"]','[{\"icon\": \"fas fa-book-open\", \"title\": \"阅读训练\", \"description\": \"大量真题阅读练习\"}, {\"icon\": \"fas fa-tachometer-alt\", \"title\": \"速度提升\", \"description\": \"提高阅读速度\"}, {\"icon\": \"fas fa-bullseye\", \"title\": \"精准定位\", \"description\": \"快速找到答案\"}, {\"icon\": \"fas fa-award\", \"title\": \"高分技巧\", \"description\": \"阅读高分秘籍\"}]'),(14,'线性代数精讲','线性代数核心概念和计算方法，为后续学习打下基础。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/%E7%BA%BF%E6%80%A7%E4%BB%A3%E6%95%B0%E7%B2%BE%E8%AE%B2.jpg',7,2,'intermediate',360,1,'2025-11-30 14:00:00','2025-12-06 21:17:58',890,4.4,76,'2025-11-29 22:00:00','2025-12-06 13:17:58','系统学习线性代数，包括矩阵运算、向量空间、特征值等核心内容。','[\"掌握矩阵基本运算\", \"理解向量空间概念\", \"学会求解线性方程组\", \"掌握特征值和特征向量\", \"了解线性代数应用\"]','[{\"icon\": \"fas fa-square-root-alt\", \"title\": \"理论扎实\", \"description\": \"深入理解数学原理\"}, {\"icon\": \"fas fa-calculator\", \"title\": \"计算技巧\", \"description\": \"快速计算方法\"}, {\"icon\": \"fas fa-project-diagram\", \"title\": \"应用实例\", \"description\": \"实际应用场景\"}, {\"icon\": \"fas fa-graduation-cap\", \"title\": \"考试导向\", \"description\": \"针对考试重点\"}]'),(15,'行测数量关系速解','公务员考试行测数量关系专项训练，快速提分技巧。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/%E8%A1%8C%E6%B5%8B.jpg',9,4,'intermediate',300,1,'2025-11-30 14:00:00','2025-12-06 21:17:58',1420,4.7,118,'2025-11-29 22:00:00','2025-12-06 13:17:58','针对公务员考试行测数量关系部分的专项突破，掌握快速解题技巧。','[\"掌握数量关系题型\", \"学会快速计算方法\", \"掌握解题技巧\", \"提高答题速度\", \"提升正确率\"]','[{\"icon\": \"fas fa-calculator\", \"title\": \"速算技巧\", \"description\": \"快速计算方法\"}, {\"icon\": \"fas fa-lightbulb\", \"title\": \"解题思路\", \"description\": \"独特解题方法\"}, {\"icon\": \"fas fa-clock\", \"title\": \"时间管理\", \"description\": \"合理分配时间\"}, {\"icon\": \"fas fa-chart-line\", \"title\": \"快速提分\", \"description\": \"短期内显著提升\"}]'),(16,'概率论与数理统计','概率论与数理统计核心知识，理论与应用并重。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E5%B0%81%E9%9D%A2/%E6%A6%82%E7%8E%87%E8%AE%BA%E4%B8%8E%E6%95%B0%E7%90%86%E7%BB%9F%E8%AE%A1.jpg',7,2,'intermediate',420,1,'2025-11-30 14:00:00','2025-12-06 21:17:58',760,4.5,68,'2025-11-29 22:00:00','2025-12-06 13:17:58','系统学习概率论与数理统计，掌握随机变量、概率分布等核心概念。','[\"理解概率基本概念\", \"掌握随机变量分布\", \"学会参数估计\", \"掌握假设检验\", \"了解统计应用\"]','[{\"icon\": \"fas fa-dice\", \"title\": \"概率思维\", \"description\": \"培养概率思维方式\"}, {\"icon\": \"fas fa-chart-bar\", \"title\": \"统计分析\", \"description\": \"数据统计分析能力\"}, {\"icon\": \"fas fa-calculator\", \"title\": \"计算方法\", \"description\": \"概率计算技巧\"}, {\"icon\": \"fas fa-flask\", \"title\": \"实际应用\", \"description\": \"统计应用实例\"}]'),(17,'数据结构与算法','深入讲解数据结构与算法，适合计算机专业学生',NULL,1,15,'intermediate',0,1,'2025-12-08 15:42:33','2025-12-11 17:21:33',3,4.5,2,'2025-12-08 07:42:33','2025-12-11 09:21:33',NULL,NULL,NULL),(18,'机器学习基础','机器学习入门课程，涵盖常用算法',NULL,3,15,'intermediate',0,1,'2025-12-08 15:42:33','2025-12-08 15:42:52',2,5.0,1,'2025-12-08 07:42:33','2025-12-08 07:42:52',NULL,NULL,NULL),(19,'Web开发实战','前端+后端全栈开发课程',NULL,1,15,'beginner',0,1,'2025-12-08 15:42:33','2025-12-08 15:42:52',2,5.0,1,'2025-12-08 07:42:33','2025-12-08 07:42:52',NULL,NULL,NULL),(20,'数据库系统','MySQL、MongoDB等数据库技术讲解',NULL,6,15,'intermediate',0,1,'2025-12-08 15:42:33','2025-12-08 15:42:52',1,4.0,1,'2025-12-08 07:42:33','2025-12-08 07:42:52',NULL,NULL,NULL),(21,'test','1111',NULL,2,15,'beginner',0,0,'2025-12-11 17:30:28','2025-12-11 17:30:28',0,0.0,0,'2025-12-11 09:30:28','2025-12-11 09:30:28',NULL,NULL,NULL);
/*!40000 ALTER TABLE `course` ENABLE KEYS */;

--
-- Table structure for table `course_category`
--

DROP TABLE IF EXISTS `course_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_category_id` int DEFAULT NULL,
  `category_icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类图标',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  KEY `idx_parent_category` (`parent_category_id`),
  CONSTRAINT `course_category_ibfk_1` FOREIGN KEY (`parent_category_id`) REFERENCES `course_category` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_category`
--

/*!40000 ALTER TABLE `course_category` DISABLE KEYS */;
INSERT INTO `course_category` VALUES (1,'编程开发',NULL,'fa-code',1,'2025-11-28 05:06:38','2025-11-28 05:06:38'),(2,'数据科学',NULL,'fa-chart-bar',2,'2025-11-28 05:06:38','2025-11-28 05:06:38'),(3,'人工智能',NULL,'fa-brain',3,'2025-11-28 05:06:38','2025-11-28 05:06:38'),(4,'移动开发',NULL,'fa-mobile-alt',4,'2025-11-28 05:06:38','2025-11-28 05:06:38'),(5,'UI/UX设计',NULL,'fa-palette',5,'2025-11-28 05:06:38','2025-11-28 05:06:38'),(6,'后端开发',NULL,'fa-server',6,'2025-11-28 05:06:38','2025-11-28 05:06:38'),(7,'数学',NULL,'fa-calculator',7,'2025-11-30 05:52:00','2025-11-30 05:52:00'),(8,'英语',NULL,'fa-language',8,'2025-11-30 05:52:00','2025-11-30 05:52:00'),(9,'公务员考试',NULL,'fa-graduation-cap',9,'2025-11-30 05:52:00','2025-11-30 05:52:00');
/*!40000 ALTER TABLE `course_category` ENABLE KEYS */;

--
-- Table structure for table `course_chapter`
--

DROP TABLE IF EXISTS `course_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_chapter` (
  `chapter_id` int NOT NULL AUTO_INCREMENT,
  `course_id` int NOT NULL,
  `chapter_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_index` int DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`chapter_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_order` (`order_index`),
  CONSTRAINT `course_chapter_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_chapter`
--

/*!40000 ALTER TABLE `course_chapter` DISABLE KEYS */;
INSERT INTO `course_chapter` VALUES (1,1,'Java基础入门',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(2,1,'面向对象编程',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(3,1,'Java高级特性',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(4,1,'AI算法实现',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(5,1,'AI+Java实战项目',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(6,2,'极限与连续',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(7,2,'导数与微分',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(8,2,'积分学',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(9,3,'短对话听力',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(10,3,'长对话听力',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(11,3,'短文听力',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(12,3,'听力技巧总结',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(13,4,'微分难点突破',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(14,4,'积分难点突破',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(15,4,'微积分应用',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(16,5,'申论基础知识',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(17,5,'材料分析技巧',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(18,5,'写作方法',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(19,6,'听力专项',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(20,6,'阅读专项',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(21,6,'翻译专项',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(22,6,'写作专项',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(23,7,'申论理论体系',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(24,7,'归纳概括题',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(25,7,'综合分析题',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(26,7,'提出对策题',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(27,7,'申发论述题',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(28,8,'学习方法论',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(29,8,'行测高分技巧',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(30,8,'申论高分技巧',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(31,8,'时间管理',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(32,9,'Python数据分析基础',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(33,9,'Pandas数据处理',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(34,9,'NumPy数组运算',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(35,9,'数据可视化',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(36,9,'实战项目',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(37,10,'HTML5基础',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(38,10,'CSS3样式与布局',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(39,10,'JavaScript核心',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(40,10,'前端框架',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(41,10,'项目实战',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(42,11,'机器学习概述',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(43,11,'监督学习算法',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(44,11,'非监督学习算法',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(45,11,'模型评估与优化',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(46,11,'深度学习入门',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(47,12,'力学基础',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(48,12,'电磁学',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(49,12,'光学与热学',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(50,13,'阅读技巧',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(51,13,'真题训练',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(52,13,'模拟测试',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(53,14,'矩阵运算',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(54,14,'向量空间',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(55,14,'特征值与特征向量',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(56,15,'数量关系题型',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(57,15,'速算技巧',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(58,15,'真题演练',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(59,16,'概率论基础',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(60,16,'随机变量',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(61,16,'数理统计',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(62,17,'数组与链表',1,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(63,17,'栈与队列',2,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(64,17,'树与图',3,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(65,17,'排序算法',4,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(66,18,'线性回归',1,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(67,18,'逻辑回归',2,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(68,18,'决策树',3,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(69,18,'聚类算法',4,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(70,19,'HTML/CSS基础',1,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(71,19,'JavaScript编程',2,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(72,19,'React框架',3,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(73,19,'Node.js后端',4,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(74,20,'SQL基础',1,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(75,20,'索引与优化',2,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(76,20,'NoSQL数据库',3,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(77,20,'数据库设计',4,'2025-12-08 15:42:35','2025-12-08 07:42:35'),(78,21,'1111',1,'2025-12-11 17:30:28','2025-12-11 09:30:28');
/*!40000 ALTER TABLE `course_chapter` ENABLE KEYS */;

--
-- Table structure for table `course_review`
--

DROP TABLE IF EXISTS `course_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_review` (
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
  CONSTRAINT `course_review_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `course_review_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程评价表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_review`
--

/*!40000 ALTER TABLE `course_review` DISABLE KEYS */;
INSERT INTO `course_review` VALUES (1,1,6,5,'课程内容非常全面，从Java基础到AI应用都讲得很清楚，老师讲解也很细致。','2025-11-29 02:30:00','2025-11-28 18:30:00'),(2,1,7,5,'2026最新版确实很新，内容紧跟技术潮流，AI部分讲得特别好。','2025-11-29 06:20:00','2025-11-28 22:20:00'),(3,1,8,4,'课程质量不错，就是内容有点多，需要花时间慢慢学。','2025-11-29 08:45:00','2025-11-29 00:45:00'),(4,2,9,5,'3小时真的学会了！讲得太通俗易懂了，期末考试有救了！','2025-11-29 03:00:00','2025-11-28 19:00:00'),(5,2,10,5,'老师讲课风趣幽默，把复杂的数学概念讲得很简单，强烈推荐！','2025-11-29 07:30:00','2025-11-28 23:30:00'),(6,2,6,4,'速成课程确实有效，但还是需要自己多练习题目。','2025-11-29 10:00:00','2025-11-29 02:00:00'),(7,3,7,5,'听力原文训练很有针对性，练习后听力水平明显提升。','2025-11-29 04:15:00','2025-11-28 20:15:00'),(8,3,8,4,'材料很丰富，就是需要坚持练习才能看到效果。','2025-11-29 09:00:00','2025-11-29 01:00:00'),(9,4,6,4,'微积分难点讲解很到位，帮助我理解了之前不懂的知识点。','2025-11-29 05:00:00','2025-11-28 21:00:00'),(10,5,9,5,'1小时真的学会了申论基础，太高效了！','2025-11-29 06:00:00','2025-11-28 22:00:00'),(11,6,9,5,'20小时突击真的有用！而且完全免费，太良心了！','2025-11-29 05:30:00','2025-11-28 21:30:00'),(12,6,10,5,'干货满满，没有废话，每一分钟都很有价值。','2025-11-29 11:00:00','2025-11-29 03:00:00'),(13,6,6,5,'通俗易懂，老师讲得特别好，六级有希望了！','2025-11-29 12:30:00','2025-11-29 04:30:00'),(14,7,7,5,'小马哥讲得太好了！申论系统课程非常专业，学到很多。','2025-11-29 06:45:00','2025-11-28 22:45:00'),(15,7,8,5,'从理论到实践都讲得很透彻，申论水平提升明显。','2025-11-29 13:00:00','2025-11-29 05:00:00'),(16,8,9,5,'清华出品，质量保证！学习方法确实很高效。','2025-11-29 07:00:00','2025-11-28 23:00:00'),(17,8,10,5,'一周达到140+不是梦，方法论很实用！','2025-11-29 14:00:00','2025-11-29 06:00:00'),(18,9,6,5,'Python数据分析讲得很实用，项目案例都是真实场景。','2025-11-29 08:00:00','2025-11-29 00:00:00'),(19,9,7,4,'内容丰富，Pandas和NumPy讲得很详细。','2025-11-29 15:00:00','2025-11-29 07:00:00'),(20,10,8,5,'Web全栈课程很全面，从前端到后端都有涉及。','2025-11-29 09:00:00','2025-11-29 01:00:00'),(21,10,9,5,'项目实战很有价值，学完就能做项目了。','2025-11-29 16:00:00','2025-11-29 08:00:00'),(22,11,6,5,'机器学习算法讲解很透彻，理论和实践结合得很好。','2025-11-29 10:00:00','2025-11-29 02:00:00'),(23,12,7,4,'物理速成课程很有效，帮我快速复习了重点内容。','2025-11-29 11:00:00','2025-11-29 03:00:00'),(24,13,8,5,'阅读理解技巧很实用，做题速度提升了很多。','2025-11-29 12:00:00','2025-11-29 04:00:00'),(25,14,9,4,'线性代数讲得很清楚，矩阵运算不再是难题。','2025-11-29 13:00:00','2025-11-29 05:00:00'),(26,15,10,5,'行测数量关系速算技巧太实用了，省了很多时间！','2025-11-29 14:00:00','2025-11-29 06:00:00'),(27,16,6,4,'概率论讲得不错，但需要多做练习才能掌握。','2025-11-29 15:00:00','2025-11-29 07:00:00'),(28,2,11,5,'甚好','2025-11-30 06:57:06','2025-11-30 06:57:06'),(29,5,11,5,'很好','2025-11-30 06:59:26','2025-11-30 06:59:26'),(30,5,13,5,'很好','2025-11-30 07:26:44','2025-11-30 07:26:44'),(31,5,12,5,'1111','2025-11-30 07:29:09','2025-11-30 07:29:09'),(32,5,12,5,'1234','2025-11-30 07:30:47','2025-11-30 07:30:47'),(33,2,12,5,'11212','2025-11-30 07:41:11','2025-11-30 07:41:11'),(34,5,13,5,'1111','2025-11-30 07:45:18','2025-11-30 07:45:18'),(35,5,13,5,'111','2025-11-30 07:54:10','2025-11-30 07:54:10'),(36,17,101,5,'课程内容很扎实，算法讲解很清晰','2025-12-08 07:42:40','2025-12-08 07:42:40'),(37,17,102,4,'练习题目有点难，但很有收获','2025-12-08 07:42:40','2025-12-08 07:42:40'),(38,18,103,5,'机器学习入门的好课程','2025-12-08 07:42:40','2025-12-08 07:42:40'),(39,19,104,5,'实战性很强，学到了很多','2025-12-08 07:42:40','2025-12-08 07:42:40'),(40,20,103,4,'数据库知识讲得很全面','2025-12-08 07:42:40','2025-12-08 07:42:40'),(41,17,101,5,'课程内容很扎实，算法讲解很清晰','2025-12-08 07:43:05','2025-12-08 07:43:05'),(42,17,102,4,'练习题目有点难，但很有收获','2025-12-08 07:43:05','2025-12-08 07:43:05'),(43,18,103,5,'机器学习入门的好课程','2025-12-08 07:43:05','2025-12-08 07:43:05'),(44,19,104,5,'实战性很强，学到了很多','2025-12-08 07:43:05','2025-12-08 07:43:05'),(45,20,103,4,'数据库知识讲得很全面','2025-12-08 07:43:05','2025-12-08 07:43:05'),(46,17,101,5,'课程内容很扎实，算法讲解很清晰','2025-12-08 07:44:12','2025-12-08 07:44:12'),(47,17,102,4,'练习题目有点难，但很有收获','2025-12-08 07:44:12','2025-12-08 07:44:12'),(48,18,103,5,'机器学习入门的好课程','2025-12-08 07:44:12','2025-12-08 07:44:12'),(49,19,104,5,'实战性很强，学到了很多','2025-12-08 07:44:12','2025-12-08 07:44:12'),(50,20,103,4,'数据库知识讲得很全面','2025-12-08 07:44:12','2025-12-08 07:44:12'),(51,17,101,5,'课程内容很扎实，算法讲解很清晰','2025-12-08 07:47:42','2025-12-08 07:47:42'),(52,17,102,4,'练习题目有点难，但很有收获','2025-12-08 07:47:42','2025-12-08 07:47:42'),(53,18,103,5,'机器学习入门的好课程','2025-12-08 07:47:42','2025-12-08 07:47:42'),(54,19,104,5,'实战性很强，学到了很多','2025-12-08 07:47:42','2025-12-08 07:47:42'),(55,20,103,4,'数据库知识讲得很全面','2025-12-08 07:47:42','2025-12-08 07:47:42');
/*!40000 ALTER TABLE `course_review` ENABLE KEYS */;

--
-- Table structure for table `course_video`
--

DROP TABLE IF EXISTS `course_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_video` (
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
  CONSTRAINT `course_video_ibfk_1` FOREIGN KEY (`chapter_id`) REFERENCES `course_chapter` (`chapter_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_video`
--

/*!40000 ALTER TABLE `course_video` DISABLE KEYS */;
INSERT INTO `course_video` VALUES (1,1,'Java开发环境搭建','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video1.mp4','安装JDK和IDE，配置开发环境',900,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(2,1,'第一个Java程序','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video2.mp4','编写Hello World程序',720,2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(3,2,'类与对象','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video3.mp4','理解面向对象的核心概念',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(4,2,'继承与多态','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video4.mp4','掌握继承和多态的使用',1080,2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(5,3,'集合框架','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video5.mp4','学习Java集合框架',1500,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(6,4,'机器学习算法基础','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video6.mp4','了解常见的机器学习算法',1800,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(7,5,'智能推荐系统实战','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video7.mp4','使用Java实现推荐系统',2400,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(8,6,'极限的概念','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/1.mp4','理解极限的定义和性质',600,1,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(9,6,'极限的计算','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/2.mp4','掌握极限的计算方法',720,2,'2025-11-30 14:00:00','2025-11-30 06:42:52'),(10,7,'导数的定义','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/3.mp4','理解导数的几何意义',540,1,'2025-11-30 14:00:00','2025-11-30 06:42:53'),(11,7,'求导法则','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/1.mp4','掌握各种求导法则',660,2,'2025-11-30 14:00:00','2025-11-30 06:42:54'),(12,8,'不定积分','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/2.mp4','学习不定积分的计算',780,1,'2025-11-30 14:00:00','2025-11-30 06:42:55'),(13,8,'定积分应用','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/3.mp4','定积分在几何中的应用',840,2,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(14,9,'短对话真题练习1','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/1.mp4','短对话听力真题训练',900,1,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(15,9,'短对话真题练习2','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/2.mp4','短对话听力技巧讲解',900,2,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(16,10,'长对话真题练习','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/3.mp4','长对话听力训练',1200,1,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(17,11,'短文听力训练','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/1.mp4','短文听力专项练习',1080,1,'2025-11-30 14:00:00','2025-11-30 06:43:01'),(18,12,'听力技巧总结','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/2.mp4','四级听力技巧汇总',600,1,'2025-11-30 14:00:00','2025-11-30 06:43:03'),(19,13,'复杂函数求导','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E9%AB%98%E6%95%B01.mp4','掌握复杂函数的求导技巧',900,1,'2025-11-30 14:00:00','2025-11-30 06:43:05'),(20,14,'积分计算技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E9%AB%98%E6%95%B02.mp4','高级积分计算方法',960,1,'2025-11-30 14:00:00','2025-11-30 06:43:05'),(21,16,'申论基础理论','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA1.mp4','申论考试基础知识',720,1,'2025-11-30 14:00:00','2025-11-30 06:30:21'),(22,17,'材料分析方法','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA2.mp4','如何分析申论材料',840,1,'2025-11-30 14:00:00','2025-11-30 06:30:21'),(23,19,'六级听力技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E5%85%AD%E7%BA%A71.mp4','六级听力答题技巧',1080,1,'2025-11-30 14:00:00','2025-11-30 06:43:09'),(24,20,'六级阅读方法','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E5%85%AD%E7%BA%A72.mp4','快速阅读理解方法',1200,1,'2025-11-30 14:00:00','2025-11-30 06:43:10'),(25,23,'申论理论框架','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA1.mp4','申论理论体系讲解',1500,1,'2025-11-30 14:00:00','2025-11-30 06:43:11'),(26,28,'高效学习法','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E8%80%83%E5%85%AC%E8%A1%8C%E6%B5%8B1.mp4','清华学习方法论',900,1,'2025-11-30 14:00:00','2025-11-30 06:43:12'),(27,32,'Python数据分析环境搭建','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video27.mp4','安装Anaconda和Jupyter',600,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(28,33,'Pandas基础操作','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video28.mp4','DataFrame和Series的使用',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(29,33,'数据清洗技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video29.mp4','处理缺失值和异常值',1080,2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(30,34,'NumPy数组运算','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video30.mp4','数组的创建和运算',900,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(31,35,'Matplotlib可视化','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video31.mp4','使用Matplotlib绘图',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(32,36,'销售数据分析项目','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video32.mp4','完整的数据分析项目实战',2400,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(33,37,'HTML5标签详解','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video33.mp4','HTML5语义化标签使用',1080,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(34,38,'CSS3布局技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video34.mp4','Flexbox和Grid布局',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(35,39,'JavaScript ES6+','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video35.mp4','ES6新特性详解',1500,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(36,40,'Vue.js入门','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video36.mp4','Vue.js框架基础',1800,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(37,42,'机器学习基础','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video37.mp4','机器学习概念介绍',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(38,43,'线性回归算法','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video38.mp4','线性回归原理和实现',1500,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(39,47,'牛顿运动定律','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video39.mp4','力学基础知识',900,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(40,50,'快速阅读技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video40.mp4','提高阅读速度的方法',1080,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(41,78,'1111','/uploads/videos/video_1765445429021_12yapl.mp4',NULL,35,1,'2025-12-11 17:30:30','2025-12-11 09:30:30');
/*!40000 ALTER TABLE `course_video` ENABLE KEYS */;

--
-- Table structure for table `learning_behaviors`
--

DROP TABLE IF EXISTS `learning_behaviors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learning_behaviors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int DEFAULT NULL,
  `chapter_id` int DEFAULT NULL,
  `behavior_type` varchar(50) NOT NULL,
  `behavior_data` json DEFAULT NULL,
  `duration` int DEFAULT '0',
  `video_position` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_course` (`user_id`,`course_id`),
  KEY `idx_behavior_type` (`behavior_type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learning_behaviors`
--

/*!40000 ALTER TABLE `learning_behaviors` DISABLE KEYS */;
INSERT INTO `learning_behaviors` VALUES (1,1,1,1,'play','{\"action\": \"start\", \"video_info\": {\"duration\": 1200}}',0,0,'2025-12-11 08:39:42'),(2,1,1,1,'pause','{\"reason\": \"user\", \"pause_position\": 120}',0,120,'2025-12-11 08:39:42'),(3,1,1,1,'seek_forward','{\"to_position\": 180, \"from_position\": 120, \"skip_duration\": 60}',0,180,'2025-12-11 08:39:42'),(4,1,1,1,'note_taking','{\"note_type\": \"text\", \"has_content\": true, \"note_length\": 50}',30,200,'2025-12-11 08:39:42'),(5,1,1,1,'speed_up','{\"new_speed\": 1.5, \"old_speed\": 1}',0,250,'2025-12-11 08:39:42'),(6,1,1,1,'bookmark','{\"bookmark_position\": 300}',0,300,'2025-12-11 08:39:42'),(7,1,1,1,'seek_backward','{\"to_position\": 350, \"from_position\": 400, \"rewind_duration\": 50}',0,350,'2025-12-11 08:39:42'),(8,1,1,1,'discussion','{\"discussion_type\": \"comment\"}',60,400,'2025-12-11 08:39:42'),(9,1,1,1,'question_ask','{\"question_type\": \"text\", \"question_length\": 80}',45,450,'2025-12-11 08:39:42'),(10,1,1,1,'replay','{\"end_position\": 400, \"start_position\": 300, \"replay_duration\": 100}',0,400,'2025-12-11 08:39:42'),(11,1,1,1,'focus_lost','{\"lost_at_position\": 500}',0,500,'2025-12-11 08:39:42'),(12,1,1,1,'focus_regain','{\"regain_at_position\": 500, \"focus_lost_duration\": 30000}',0,500,'2025-12-11 08:39:42'),(13,1,1,1,'chapter_complete','{\"total_time\": 3600000, \"completion_rate\": 100}',0,1200,'2025-12-11 08:39:42'),(14,2,1,1,'play','{\"action\": \"start\"}',0,0,'2025-12-11 08:39:42'),(15,2,1,1,'pause','{\"reason\": \"user\"}',0,90,'2025-12-11 08:39:42'),(16,2,1,1,'note_taking','{\"note_type\": \"text\"}',25,150,'2025-12-11 08:39:42'),(17,2,1,1,'speed_down','{\"new_speed\": 0.75, \"old_speed\": 1}',0,200,'2025-12-11 08:39:42'),(18,2,1,1,'quiz_attempt','{\"quiz_id\": 1, \"quiz_type\": \"multiple_choice\"}',120,300,'2025-12-11 08:39:42'),(19,3,1,2,'play','{\"action\": \"start\"}',0,0,'2025-12-11 08:39:42'),(20,3,1,2,'seek_forward','{\"skip_duration\": 30}',0,30,'2025-12-11 08:39:42'),(21,3,1,2,'bookmark','{\"bookmark_position\": 180}',0,180,'2025-12-11 08:39:42'),(22,3,1,2,'resource_download','{\"resource_name\": \"lecture_notes.pdf\", \"resource_type\": \"pdf\"}',0,200,'2025-12-11 08:39:42'),(23,1,1,1,'play','{\"action\": \"start\", \"video_info\": {\"duration\": 1200}}',0,0,'2025-12-11 09:08:54'),(24,1,1,1,'pause','{\"reason\": \"user\", \"pause_position\": 120}',0,120,'2025-12-11 09:08:54'),(25,1,1,1,'seek_forward','{\"to_position\": 180, \"from_position\": 120, \"skip_duration\": 60}',0,180,'2025-12-11 09:08:54'),(26,1,1,1,'note_taking','{\"note_type\": \"text\", \"has_content\": true, \"note_length\": 50}',30,200,'2025-12-11 09:08:54'),(27,1,1,1,'speed_up','{\"new_speed\": 1.5, \"old_speed\": 1}',0,250,'2025-12-11 09:08:54'),(28,1,1,1,'bookmark','{\"bookmark_position\": 300}',0,300,'2025-12-11 09:08:54'),(29,1,1,1,'seek_backward','{\"to_position\": 350, \"from_position\": 400, \"rewind_duration\": 50}',0,350,'2025-12-11 09:08:54'),(30,1,1,1,'discussion','{\"discussion_type\": \"comment\"}',60,400,'2025-12-11 09:08:54'),(31,1,1,1,'question_ask','{\"question_type\": \"text\", \"question_length\": 80}',45,450,'2025-12-11 09:08:54'),(32,1,1,1,'replay','{\"end_position\": 400, \"start_position\": 300, \"replay_duration\": 100}',0,400,'2025-12-11 09:08:54'),(33,1,1,1,'focus_lost','{\"lost_at_position\": 500}',0,500,'2025-12-11 09:08:54'),(34,1,1,1,'focus_regain','{\"regain_at_position\": 500, \"focus_lost_duration\": 30000}',0,500,'2025-12-11 09:08:54'),(35,1,1,1,'chapter_complete','{\"total_time\": 3600000, \"completion_rate\": 100}',0,1200,'2025-12-11 09:08:54'),(36,2,1,1,'play','{\"action\": \"start\"}',0,0,'2025-12-11 09:08:54'),(37,2,1,1,'pause','{\"reason\": \"user\"}',0,90,'2025-12-11 09:08:54'),(38,2,1,1,'note_taking','{\"note_type\": \"text\"}',25,150,'2025-12-11 09:08:54'),(39,2,1,1,'speed_down','{\"new_speed\": 0.75, \"old_speed\": 1}',0,200,'2025-12-11 09:08:54'),(40,2,1,1,'quiz_attempt','{\"quiz_id\": 1, \"quiz_type\": \"multiple_choice\"}',120,300,'2025-12-11 09:08:54'),(41,3,1,2,'play','{\"action\": \"start\"}',0,0,'2025-12-11 09:08:54'),(42,3,1,2,'seek_forward','{\"skip_duration\": 30}',0,30,'2025-12-11 09:08:54'),(43,3,1,2,'bookmark','{\"bookmark_position\": 180}',0,180,'2025-12-11 09:08:54'),(44,3,1,2,'resource_download','{\"resource_name\": \"lecture_notes.pdf\", \"resource_type\": \"pdf\"}',0,200,'2025-12-11 09:08:54'),(45,1,1,1,'play','{\"action\": \"start\", \"video_info\": {\"duration\": 1200}}',0,0,'2025-12-11 09:09:32'),(46,1,1,1,'pause','{\"reason\": \"user\", \"pause_position\": 120}',0,120,'2025-12-11 09:09:32'),(47,1,1,1,'seek_forward','{\"to_position\": 180, \"from_position\": 120, \"skip_duration\": 60}',0,180,'2025-12-11 09:09:32'),(48,1,1,1,'note_taking','{\"note_type\": \"text\", \"has_content\": true, \"note_length\": 50}',30,200,'2025-12-11 09:09:32'),(49,1,1,1,'speed_up','{\"new_speed\": 1.5, \"old_speed\": 1}',0,250,'2025-12-11 09:09:32'),(50,1,1,1,'bookmark','{\"bookmark_position\": 300}',0,300,'2025-12-11 09:09:32'),(51,1,1,1,'seek_backward','{\"to_position\": 350, \"from_position\": 400, \"rewind_duration\": 50}',0,350,'2025-12-11 09:09:32'),(52,1,1,1,'discussion','{\"discussion_type\": \"comment\"}',60,400,'2025-12-11 09:09:32'),(53,1,1,1,'question_ask','{\"question_type\": \"text\", \"question_length\": 80}',45,450,'2025-12-11 09:09:32'),(54,1,1,1,'replay','{\"end_position\": 400, \"start_position\": 300, \"replay_duration\": 100}',0,400,'2025-12-11 09:09:32'),(55,1,1,1,'focus_lost','{\"lost_at_position\": 500}',0,500,'2025-12-11 09:09:32'),(56,1,1,1,'focus_regain','{\"regain_at_position\": 500, \"focus_lost_duration\": 30000}',0,500,'2025-12-11 09:09:32'),(57,1,1,1,'chapter_complete','{\"total_time\": 3600000, \"completion_rate\": 100}',0,1200,'2025-12-11 09:09:32'),(58,2,1,1,'play','{\"action\": \"start\"}',0,0,'2025-12-11 09:09:32'),(59,2,1,1,'pause','{\"reason\": \"user\"}',0,90,'2025-12-11 09:09:32'),(60,2,1,1,'note_taking','{\"note_type\": \"text\"}',25,150,'2025-12-11 09:09:32'),(61,2,1,1,'speed_down','{\"new_speed\": 0.75, \"old_speed\": 1}',0,200,'2025-12-11 09:09:32'),(62,2,1,1,'quiz_attempt','{\"quiz_id\": 1, \"quiz_type\": \"multiple_choice\"}',120,300,'2025-12-11 09:09:32'),(63,3,1,2,'play','{\"action\": \"start\"}',0,0,'2025-12-11 09:09:32'),(64,3,1,2,'seek_forward','{\"skip_duration\": 30}',0,30,'2025-12-11 09:09:32'),(65,3,1,2,'bookmark','{\"bookmark_position\": 180}',0,180,'2025-12-11 09:09:32'),(66,3,1,2,'resource_download','{\"resource_name\": \"lecture_notes.pdf\", \"resource_type\": \"pdf\"}',0,200,'2025-12-11 09:09:32'),(67,1,1,1,'play','{\"action\": \"start\"}',0,0,'2025-12-11 09:20:23'),(68,1,1,1,'pause','{\"reason\": \"user\"}',0,120,'2025-12-11 09:20:23'),(69,1,1,1,'seek_forward','{\"skip_duration\": 60}',0,180,'2025-12-11 09:20:23'),(70,1,1,1,'note_taking','{\"note_length\": 50}',30,200,'2025-12-11 09:20:23'),(71,1,1,1,'speed_up','{\"new_speed\": 1.5, \"old_speed\": 1}',0,250,'2025-12-11 09:20:23'),(72,1,1,1,'bookmark','{\"bookmark_position\": 300}',0,300,'2025-12-11 09:20:23'),(73,1,1,1,'seek_backward','{\"rewind_duration\": 50}',0,350,'2025-12-11 09:20:23'),(74,1,1,1,'discussion','{\"discussion_type\": \"comment\"}',60,400,'2025-12-11 09:20:23'),(75,1,1,1,'question_ask','{\"question_length\": 80}',45,450,'2025-12-11 09:20:23'),(76,1,1,1,'replay','{\"replay_duration\": 100}',0,400,'2025-12-11 09:20:23'),(77,1,1,1,'focus_lost','{\"lost_at_position\": 500}',0,500,'2025-12-11 09:20:23'),(78,1,1,1,'focus_regain','{\"focus_lost_duration\": 30000}',0,500,'2025-12-11 09:20:23'),(79,1,1,1,'chapter_complete','{\"completion_rate\": 100}',0,1200,'2025-12-11 09:20:23');
/*!40000 ALTER TABLE `learning_behaviors` ENABLE KEYS */;

--
-- Table structure for table `learning_detail`
--

DROP TABLE IF EXISTS `learning_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learning_detail` (
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
  CONSTRAINT `learning_detail_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `learning_detail_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`),
  CONSTRAINT `learning_detail_ibfk_3` FOREIGN KEY (`video_id`) REFERENCES `course_video` (`video_id`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learning_detail`
--

/*!40000 ALTER TABLE `learning_detail` DISABLE KEYS */;
INSERT INTO `learning_detail` VALUES (1,6,1,1,'2025-11-29 10:00:00',900,1.00,0,100.00,900),(2,6,1,2,'2025-11-29 11:00:00',720,1.00,0,100.00,720),(3,6,1,3,'2025-11-29 12:00:00',600,1.00,1,50.00,600),(4,6,9,27,'2025-11-29 14:00:00',600,1.00,0,100.00,600),(5,7,2,8,'2025-11-29 09:00:00',600,1.00,0,100.00,600),(6,7,2,9,'2025-11-29 10:00:00',720,1.00,0,100.00,720),(7,7,4,19,'2025-11-29 13:00:00',300,1.00,2,33.33,300),(8,8,3,14,'2025-11-29 08:00:00',900,1.00,0,100.00,900),(9,8,3,15,'2025-11-29 09:30:00',900,1.00,1,100.00,900),(10,8,6,23,'2025-11-29 15:00:00',400,1.00,0,37.04,400),(11,9,7,25,'2025-11-29 10:00:00',1200,1.00,0,80.00,1200),(12,9,7,25,'2025-11-29 12:00:00',1080,1.00,1,72.00,1080),(13,9,5,21,'2025-11-29 16:00:00',300,1.00,0,41.67,300),(14,10,8,26,'2025-11-29 11:00:00',600,1.00,0,66.67,600),(15,10,8,26,'2025-11-29 13:00:00',900,1.00,0,100.00,900),(16,10,10,33,'2025-11-29 17:00:00',800,1.00,2,74.07,800),(17,14,5,22,'2025-12-01 13:14:18',395,1.00,0,47.00,395),(18,14,5,22,'2025-12-01 13:14:19',467,1.00,0,55.56,467),(19,14,2,8,'2025-12-01 21:13:56',148,1.00,0,24.72,148),(20,14,2,8,'2025-12-01 21:53:16',156,0.75,0,26.03,156),(21,14,2,8,'2025-12-02 10:28:32',164,1.00,0,27.31,164),(22,14,2,11,'2025-12-02 10:28:37',184,1.00,0,27.95,184),(23,14,2,11,'2025-12-02 10:28:47',193,1.00,0,29.25,193),(24,14,2,11,'2025-12-02 10:28:57',202,1.00,0,30.56,202),(25,14,2,11,'2025-12-02 10:29:07',210,1.00,0,31.87,210),(26,14,2,11,'2025-12-02 10:29:17',219,1.00,0,33.17,219),(27,14,2,11,'2025-12-02 10:29:27',228,1.00,0,34.48,228),(28,14,2,11,'2025-12-02 10:29:38',236,1.00,0,35.78,236),(29,14,2,8,'2025-12-04 11:17:32',285,1.00,0,47.47,285),(30,14,2,8,'2025-12-04 11:17:35',422,1.00,0,70.28,422),(31,14,1,1,'2025-11-29 13:53:28',900,1.00,0,100.00,900),(32,14,1,2,'2025-11-30 13:53:28',720,1.25,1,100.00,720),(33,14,2,8,'2025-12-01 13:53:28',600,0.75,0,100.00,600),(34,14,2,9,'2025-12-02 13:53:28',720,1.00,0,100.00,720),(35,14,3,14,'2025-12-03 13:53:28',900,1.50,0,100.00,900),(36,14,5,21,'2025-12-04 13:53:28',720,1.25,2,100.00,720),(37,14,1,3,'2025-12-04 13:53:28',1200,2.00,1,50.00,600),(38,14,2,9,'2025-12-04 14:11:17',720,1.00,0,100.00,720),(39,14,2,9,'2025-12-04 14:11:18',720,1.00,0,100.00,720),(40,14,2,9,'2025-12-04 14:11:24',5,1.00,0,0.65,5),(41,14,2,9,'2025-12-04 14:11:28',121,1.00,0,16.84,121),(42,14,2,9,'2025-12-04 14:11:35',282,1.00,0,39.23,282),(43,14,2,9,'2025-12-04 14:43:41',332,1.00,0,46.05,332),(44,14,2,9,'2025-12-04 14:43:45',412,1.00,0,57.28,412),(45,14,2,9,'2025-12-04 14:43:50',511,1.00,0,71.04,511),(46,14,2,9,'2025-12-04 14:43:52',583,1.00,0,80.95,583),(47,14,2,10,'2025-12-04 14:46:51',212,1.00,0,39.20,212),(48,14,2,10,'2025-12-04 14:46:55',414,1.00,0,76.76,414),(49,14,3,14,'2025-12-04 14:48:04',900,1.00,0,100.00,900),(50,14,3,14,'2025-12-04 14:48:05',900,1.00,0,100.00,900),(51,14,3,14,'2025-12-04 14:48:11',5,1.00,0,0.55,5),(52,14,3,14,'2025-12-04 14:48:18',231,1.00,0,25.69,231),(53,14,3,14,'2025-12-04 14:48:21',439,1.00,0,48.75,439),(54,14,5,21,'2025-12-05 23:54:54',720,1.00,0,100.00,720),(55,14,5,21,'2025-12-05 23:55:05',1,1.00,0,0.11,1),(56,14,5,21,'2025-12-05 23:55:54',8,1.00,0,1.18,8),(57,14,5,21,'2025-12-05 23:56:48',16,1.00,0,2.25,16),(58,14,3,14,'2025-12-09 08:04:09',448,0.75,0,49.77,448),(59,14,3,14,'2025-12-09 08:04:54',458,1.00,0,50.86,458),(60,14,3,14,'2025-12-09 08:04:59',467,1.25,0,51.91,467),(61,14,3,14,'2025-12-09 08:05:04',477,1.00,0,52.95,477),(62,14,2,9,'2025-12-09 09:12:53',591,1.25,0,82.13,591),(63,14,2,8,'2025-12-09 09:13:25',429,1.00,0,71.55,429),(64,14,2,8,'2025-12-09 09:13:30',437,1.00,0,72.81,437),(65,14,2,9,'2025-12-09 09:13:58',601,1.50,0,83.41,601),(66,14,2,9,'2025-12-09 09:14:08',609,1.00,0,84.62,609),(67,14,7,25,'2025-12-09 10:38:19',16,1.00,0,1.07,16),(68,14,6,23,'2025-12-09 11:27:59',88,1.00,0,8.17,88);
/*!40000 ALTER TABLE `learning_detail` ENABLE KEYS */;

--
-- Table structure for table `learning_session`
--

DROP TABLE IF EXISTS `learning_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learning_session` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int NOT NULL,
  `chapter_id` int DEFAULT NULL,
  `video_id` int DEFAULT NULL,
  `focus_duration` int NOT NULL COMMENT '专注时长(秒)',
  `focus_score` decimal(5,2) DEFAULT NULL COMMENT '专注度评分',
  `session_type` enum('video','quiz','practice','review','reading','discussion') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'video' COMMENT '学习类型',
  `start_time` timestamp NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` timestamp NULL DEFAULT NULL COMMENT '结束时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_chapter` (`chapter_id`),
  KEY `idx_video` (`video_id`),
  KEY `idx_time` (`start_time`,`end_time`),
  KEY `idx_type` (`session_type`),
  CONSTRAINT `fk_learning_session_chapter` FOREIGN KEY (`chapter_id`) REFERENCES `course_chapter` (`chapter_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_learning_session_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_learning_session_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_learning_session_video` FOREIGN KEY (`video_id`) REFERENCES `course_video` (`video_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习会话记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learning_session`
--

/*!40000 ALTER TABLE `learning_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `learning_session` ENABLE KEYS */;

--
-- Table structure for table `learning_style`
--

DROP TABLE IF EXISTS `learning_style`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learning_style` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `learning_style_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '学习风格类型',
  `style_score` json DEFAULT NULL COMMENT '各项风格得分',
  `analysis_date` date DEFAULT NULL COMMENT '分析日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`,`analysis_date`),
  KEY `idx_user_type` (`user_id`,`learning_style_type`),
  CONSTRAINT `fk_learning_style_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生学习风格表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learning_style`
--

/*!40000 ALTER TABLE `learning_style` DISABLE KEYS */;
/*!40000 ALTER TABLE `learning_style` ENABLE KEYS */;

--
-- Table structure for table `learning_trend_analysis`
--

DROP TABLE IF EXISTS `learning_trend_analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learning_trend_analysis` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `teacher_id` int NOT NULL COMMENT '教师ID',
  `analysis_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分析类型：overall/course-{id}',
  `week_number` int NOT NULL COMMENT '周数',
  `completion_rate` decimal(5,2) NOT NULL COMMENT '完成率 (%)',
  `interaction_rate` decimal(5,2) NOT NULL COMMENT '互动率 (%)',
  `mastery_rate` decimal(5,2) NOT NULL COMMENT '掌握率 (%)',
  `focus_duration` int NOT NULL COMMENT '专注时长 (小时)',
  `created_date` date NOT NULL COMMENT '创建日期',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_teacher_type_week` (`teacher_id`,`analysis_type`,`week_number`) COMMENT '教师-类型-周数唯一约束',
  KEY `idx_teacher_id` (`teacher_id`),
  KEY `idx_analysis_type` (`analysis_type`),
  KEY `idx_created_date` (`created_date`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教学数据分析表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learning_trend_analysis`
--

/*!40000 ALTER TABLE `learning_trend_analysis` DISABLE KEYS */;
INSERT INTO `learning_trend_analysis` VALUES (1,15,'overall',1,65.00,68.00,62.00,22,'2025-11-25','2025-12-08 08:07:27','2025-12-08 08:07:27'),(2,15,'overall',2,68.00,72.00,65.00,23,'2025-12-02','2025-12-08 08:07:27','2025-12-08 08:07:27'),(3,15,'overall',3,72.00,75.00,68.00,24,'2025-12-09','2025-12-08 08:07:27','2025-12-08 08:07:27'),(4,15,'overall',4,75.00,78.00,72.00,25,'2025-12-16','2025-12-08 08:07:27','2025-12-08 08:07:27'),(5,15,'overall',5,78.00,80.00,75.00,26,'2025-12-23','2025-12-08 08:07:27','2025-12-08 08:07:27'),(6,15,'overall',6,82.00,83.00,79.00,27,'2025-12-30','2025-12-08 08:07:27','2025-12-08 08:07:27'),(7,15,'course-17',1,70.00,65.00,68.00,25,'2025-11-25','2025-12-08 08:07:27','2025-12-08 08:07:27'),(8,15,'course-17',2,72.00,68.00,70.00,26,'2025-12-02','2025-12-08 08:07:27','2025-12-08 08:07:27'),(9,15,'course-17',3,75.00,72.00,73.00,27,'2025-12-09','2025-12-08 08:07:27','2025-12-08 08:07:27'),(10,15,'course-17',4,78.00,75.00,76.00,28,'2025-12-16','2025-12-08 08:07:27','2025-12-08 08:07:27'),(11,15,'course-17',5,82.00,78.00,79.00,29,'2025-12-23','2025-12-08 08:07:27','2025-12-08 08:07:27'),(12,15,'course-17',6,85.00,80.00,82.00,30,'2025-12-30','2025-12-08 08:07:27','2025-12-08 08:07:27'),(13,15,'course-18',1,60.00,65.00,58.00,20,'2025-11-25','2025-12-08 08:07:27','2025-12-08 08:07:27'),(14,15,'course-18',2,65.00,68.00,62.00,21,'2025-12-02','2025-12-08 08:07:27','2025-12-08 08:07:27'),(15,15,'course-18',3,68.00,72.00,65.00,22,'2025-12-09','2025-12-08 08:07:27','2025-12-08 08:07:27'),(16,15,'course-18',4,72.00,75.00,68.00,23,'2025-12-16','2025-12-08 08:07:27','2025-12-08 08:07:27'),(17,15,'course-18',5,75.00,78.00,72.00,24,'2025-12-23','2025-12-08 08:07:27','2025-12-08 08:07:27'),(18,15,'course-18',6,78.00,80.00,75.00,25,'2025-12-30','2025-12-08 08:07:27','2025-12-08 08:07:27'),(19,15,'course-19',1,72.00,75.00,70.00,26,'2025-11-25','2025-12-08 08:07:27','2025-12-08 08:07:27'),(20,15,'course-19',2,75.00,78.00,72.00,27,'2025-12-02','2025-12-08 08:07:27','2025-12-08 08:07:27'),(21,15,'course-19',3,78.00,80.00,75.00,28,'2025-12-09','2025-12-08 08:07:27','2025-12-08 08:07:27'),(22,15,'course-19',4,80.00,82.00,78.00,29,'2025-12-16','2025-12-08 08:07:27','2025-12-08 08:07:27'),(23,15,'course-19',5,82.00,84.00,80.00,30,'2025-12-23','2025-12-08 08:07:27','2025-12-08 08:07:27'),(24,15,'course-19',6,85.00,86.00,82.00,31,'2025-12-30','2025-12-08 08:07:27','2025-12-08 08:07:27'),(25,15,'course-20',1,68.00,70.00,65.00,24,'2025-11-25','2025-12-08 08:07:27','2025-12-08 08:07:27'),(26,15,'course-20',2,70.00,72.00,68.00,25,'2025-12-02','2025-12-08 08:07:27','2025-12-08 08:07:27'),(27,15,'course-20',3,72.00,75.00,70.00,26,'2025-12-09','2025-12-08 08:07:27','2025-12-08 08:07:27'),(28,15,'course-20',4,75.00,78.00,72.00,27,'2025-12-16','2025-12-08 08:07:27','2025-12-08 08:07:27'),(29,15,'course-20',5,78.00,80.00,75.00,28,'2025-12-23','2025-12-08 08:07:27','2025-12-08 08:07:27'),(30,15,'course-20',6,80.00,82.00,78.00,29,'2025-12-30','2025-12-08 08:07:27','2025-12-08 08:07:27');
/*!40000 ALTER TABLE `learning_trend_analysis` ENABLE KEYS */;

--
-- Table structure for table `notification`
--

DROP TABLE IF EXISTS `notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `type` enum('team_invite','team_join_request','team_join_approved','team_join_rejected','task_assigned','task_reminder','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `related_id` int DEFAULT NULL COMMENT '相关ID（如team_id, task_id等）',
  `is_read` tinyint DEFAULT '0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification`
--

/*!40000 ALTER TABLE `notification` DISABLE KEYS */;
INSERT INTO `notification` VALUES (1,1,'team_join_request','新的小组加入申请','赵六申请加入您的小组「JavaScript学习小组」',1,0,'2025-12-06 00:02:34'),(2,2,'task_assigned','新任务分配','张三在小组「JavaScript学习小组」中为您分配了任务：练习DOM操作',2,0,'2025-12-06 00:02:34'),(3,2,'task_reminder','任务提醒','张三提醒您完成任务：练习DOM操作',2,1,'2025-12-06 00:02:34'),(4,3,'system','系统通知','欢迎加入学习小组功能！',NULL,1,'2025-12-06 00:02:34');
/*!40000 ALTER TABLE `notification` ENABLE KEYS */;

--
-- Table structure for table `post_comment`
--

DROP TABLE IF EXISTS `post_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_comment` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `author_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_comment_id` int DEFAULT NULL,
  `likes_count` int DEFAULT '0',
  `status` enum('published','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'published',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `comment_type` enum('discussion','qa_answer') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'discussion' COMMENT '评论类型',
  PRIMARY KEY (`comment_id`),
  KEY `idx_post` (`post_id`),
  KEY `idx_author` (`author_id`),
  KEY `idx_parent` (`parent_comment_id`),
  CONSTRAINT `fk_parent_comment` FOREIGN KEY (`parent_comment_id`) REFERENCES `post_comment` (`comment_id`) ON DELETE CASCADE,
  CONSTRAINT `post_comment_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `community_post` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `post_comment_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `post_comment_ibfk_3` FOREIGN KEY (`parent_comment_id`) REFERENCES `post_comment` (`comment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_comment`
--

/*!40000 ALTER TABLE `post_comment` DISABLE KEYS */;
INSERT INTO `post_comment` VALUES (3,10,8,'总结得很好！特征值那部分确实是重点，我考试就考了好几道。',NULL,8,'published','2025-12-01 10:00:00','2025-12-01 10:00:00','discussion'),(4,10,9,'请问逆矩阵用伴随矩阵法还是初等变换法更好？',NULL,5,'published','2025-12-01 11:30:00','2025-12-01 11:30:00','discussion'),(5,10,7,'初等变换法更通用，计算量也相对小一些。',4,12,'published','2025-12-01 12:00:00','2025-12-01 12:00:00','discussion'),(6,11,6,'时间序列趋势建议用折线图，更直观。面积图适合展示累积效果。',NULL,15,'published','2025-12-02 11:00:00','2025-12-02 11:00:00','qa_answer'),(7,11,10,'类别对比的话，如果类别少于5个用饼图，多了就用柱状图。',NULL,11,'published','2025-12-02 12:30:00','2025-12-02 12:30:00','qa_answer'),(8,11,8,'谢谢两位！那多维度数据呢？',6,3,'published','2025-12-02 13:00:00','2025-12-02 13:00:00','discussion'),(9,11,6,'可以用子图(subplot)或者热力图(heatmap)，看具体需求。',8,9,'published','2025-12-02 14:00:00','2025-12-02 14:00:00','qa_answer'),(10,12,7,'四字成语翻译确实是难点，收藏了！',NULL,18,'published','2025-12-03 15:00:00','2025-12-03 15:00:00','discussion'),(11,12,101,'请问有没有更多高频词汇整理？',NULL,6,'published','2025-12-03 16:00:00','2025-12-03 16:00:00','discussion'),(12,12,9,'我整理了一份200词的高频词汇表，需要的话私信我。',11,22,'published','2025-12-03 17:00:00','2025-12-03 17:00:00','discussion'),(13,13,6,'全概率公式和贝叶斯公式总是搞混，有什么好的记忆方法吗？',NULL,7,'published','2025-12-04 17:00:00','2025-12-04 17:00:00','discussion'),(14,13,10,'全概率是\"由因求果\"，贝叶斯是\"由果溯因\"，这样记就不会混了。',13,25,'published','2025-12-04 18:00:00','2025-12-04 18:00:00','qa_answer'),(15,13,8,'笔记整理得很详细，期末稳了！',NULL,10,'published','2025-12-04 19:00:00','2025-12-04 19:00:00','discussion'),(16,14,7,'新手建议先学Vue，上手快，能快速做出东西，增强信心。',NULL,35,'published','2025-12-05 12:00:00','2025-12-05 12:00:00','qa_answer'),(17,14,9,'同意楼上，Vue中文生态好，遇到问题容易找到解决方案。',16,18,'published','2025-12-05 13:00:00','2025-12-05 13:00:00','discussion'),(18,14,102,'我是先学的React，虽然难一点，但学会了之后Vue也很容易上手。',NULL,22,'published','2025-12-05 14:00:00','2025-12-05 14:00:00','qa_answer'),(19,14,6,'其实两个都要学，但先学哪个看个人。想快速就业选Vue，想去大厂选React。',NULL,28,'published','2025-12-05 15:00:00','2025-12-05 15:00:00','qa_answer'),(20,15,10,'语句排序题的技巧很实用，之前总是做错。',NULL,12,'published','2025-12-06 10:00:00','2025-12-06 10:00:00','discussion'),(21,15,104,'请问有没有推荐的练习题库？',NULL,5,'published','2025-12-06 11:00:00','2025-12-06 11:00:00','discussion'),(22,16,7,'XGBoost确实强，我的项目也是用它效果最好。',NULL,14,'published','2025-12-07 16:00:00','2025-12-07 16:00:00','discussion'),(23,16,103,'请问特征工程那部分能详细讲讲吗？感觉这是提升模型的关键。',NULL,8,'published','2025-12-07 17:00:00','2025-12-07 17:00:00','discussion'),(24,16,6,'特征工程确实很重要，好的特征比好的模型更重要。',23,16,'published','2025-12-07 18:00:00','2025-12-07 18:00:00','discussion'),(25,17,8,'电磁学确实难，建议先把静电场搞懂，再学电磁感应。',NULL,6,'published','2025-12-08 11:00:00','2025-12-08 11:00:00','qa_answer'),(26,17,10,'麦克斯韦方程组可以看费曼物理学讲义，讲得很透彻。',NULL,9,'published','2025-12-08 12:00:00','2025-12-08 12:00:00','qa_answer'),(27,18,6,'路线很清晰，收藏了！请问有推荐的实战项目吗？',NULL,11,'published','2025-12-08 15:00:00','2025-12-08 15:00:00','discussion'),(28,18,102,'可以做一个博客系统或者待办事项API，涵盖CRUD操作。',27,15,'published','2025-12-08 16:00:00','2025-12-08 16:00:00','qa_answer'),(29,19,7,'EXPLAIN分析那部分讲得好，之前一直不会看执行计划。',NULL,10,'published','2025-12-09 10:00:00','2025-12-09 10:00:00','discussion'),(30,19,9,'联合索引的最左前缀原则也很重要，建议补充一下。',NULL,8,'published','2025-12-09 11:00:00','2025-12-09 11:00:00','discussion'),(31,20,6,'模板很实用，但要注意不能太套路化，阅卷老师一眼就能看出来。',NULL,20,'published','2025-12-09 12:00:00','2025-12-09 12:00:00','discussion'),(32,20,8,'同意，模板是框架，内容还是要结合材料来写。',31,12,'published','2025-12-09 13:00:00','2025-12-09 13:00:00','discussion'),(33,20,10,'小马哥的课确实不错，申论从60分提到了75分！',NULL,18,'published','2025-12-09 14:00:00','2025-12-09 14:00:00','discussion'),(34,20,14,'1',NULL,0,'published','2025-12-09 10:53:35','2025-12-09 10:53:35','discussion');
/*!40000 ALTER TABLE `post_comment` ENABLE KEYS */;

--
-- Table structure for table `post_like`
--

DROP TABLE IF EXISTS `post_like`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `post_like` (
  `like_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `unique_post_user` (`post_id`,`user_id`),
  KEY `idx_post` (`post_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `post_like_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `community_post` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `post_like_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_like`
--

/*!40000 ALTER TABLE `post_like` DISABLE KEYS */;
INSERT INTO `post_like` VALUES (3,10,6,'2025-12-01 10:30:00'),(4,10,8,'2025-12-01 11:00:00'),(5,10,9,'2025-12-01 12:00:00'),(6,10,101,'2025-12-01 13:00:00'),(7,10,102,'2025-12-01 14:00:00'),(8,11,6,'2025-12-02 11:30:00'),(9,11,7,'2025-12-02 12:00:00'),(10,11,10,'2025-12-02 13:00:00'),(11,12,6,'2025-12-03 15:30:00'),(12,12,7,'2025-12-03 16:00:00'),(13,12,8,'2025-12-03 17:00:00'),(14,12,10,'2025-12-03 18:00:00'),(15,12,101,'2025-12-03 19:00:00'),(16,12,103,'2025-12-03 20:00:00'),(17,13,6,'2025-12-04 17:30:00'),(18,13,7,'2025-12-04 18:00:00'),(19,13,8,'2025-12-04 19:00:00'),(20,13,9,'2025-12-04 20:00:00'),(21,14,7,'2025-12-05 12:30:00'),(22,14,8,'2025-12-05 13:00:00'),(23,14,9,'2025-12-05 14:00:00'),(24,14,10,'2025-12-05 15:00:00'),(25,14,101,'2025-12-05 16:00:00'),(26,14,102,'2025-12-05 17:00:00'),(27,14,103,'2025-12-05 18:00:00'),(28,15,6,'2025-12-06 10:30:00'),(29,15,10,'2025-12-06 11:00:00'),(30,15,104,'2025-12-06 12:00:00'),(31,16,7,'2025-12-07 16:30:00'),(32,16,8,'2025-12-07 17:00:00'),(33,16,9,'2025-12-07 18:00:00'),(34,16,103,'2025-12-07 19:00:00'),(35,16,104,'2025-12-07 20:00:00'),(36,17,8,'2025-12-08 11:30:00'),(37,17,10,'2025-12-08 12:30:00'),(38,18,6,'2025-12-08 15:30:00'),(39,18,7,'2025-12-08 16:00:00'),(40,18,9,'2025-12-08 17:00:00'),(41,18,103,'2025-12-08 18:00:00'),(42,19,6,'2025-12-09 10:30:00'),(43,19,7,'2025-12-09 11:00:00'),(44,19,8,'2025-12-09 12:00:00'),(45,20,6,'2025-12-09 12:30:00'),(46,20,7,'2025-12-09 13:00:00'),(47,20,8,'2025-12-09 14:00:00'),(48,20,9,'2025-12-09 15:00:00'),(49,20,10,'2025-12-09 16:00:00'),(50,20,101,'2025-12-09 17:00:00');
/*!40000 ALTER TABLE `post_like` ENABLE KEYS */;

--
-- Table structure for table `qa_answer`
--

DROP TABLE IF EXISTS `qa_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qa_answer` (
  `answer_id` int NOT NULL AUTO_INCREMENT,
  `qa_id` int NOT NULL,
  `author_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_best_answer` tinyint DEFAULT '0',
  `likes_count` int DEFAULT '0',
  `status` enum('published','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'published',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`answer_id`),
  KEY `idx_qa` (`qa_id`),
  KEY `idx_author` (`author_id`),
  CONSTRAINT `qa_answer_ibfk_1` FOREIGN KEY (`qa_id`) REFERENCES `qa_question` (`qa_id`) ON DELETE CASCADE,
  CONSTRAINT `qa_answer_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qa_answer`
--

/*!40000 ALTER TABLE `qa_answer` DISABLE KEYS */;
/*!40000 ALTER TABLE `qa_answer` ENABLE KEYS */;

--
-- Table structure for table `qa_question`
--

DROP TABLE IF EXISTS `qa_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qa_question` (
  `qa_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_id` int NOT NULL,
  `course_id` int DEFAULT NULL,
  `difficulty_level` enum('beginner','intermediate','advanced') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('open','answered','closed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'open',
  `views_count` int DEFAULT '0',
  `answers_count` int DEFAULT '0',
  `best_answer_id` int DEFAULT NULL,
  `tags` json DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`qa_id`),
  KEY `idx_author` (`author_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `qa_question_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `qa_question_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qa_question`
--

/*!40000 ALTER TABLE `qa_question` DISABLE KEYS */;
/*!40000 ALTER TABLE `qa_question` ENABLE KEYS */;

--
-- Table structure for table `room_member`
--

DROP TABLE IF EXISTS `room_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room_member` (
  `member_id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `user_id` int NOT NULL,
  `role` enum('member','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'member',
  `join_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `leave_time` datetime DEFAULT NULL,
  `status` enum('active','left') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `total_study_time` int DEFAULT '0' COMMENT '总学习时间(分钟)',
  `study_goal` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '学习目标',
  `current_task` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '当前任务',
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `unique_room_user` (`room_id`,`user_id`),
  KEY `idx_room` (`room_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `room_member_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `study_room` (`room_id`) ON DELETE CASCADE,
  CONSTRAINT `room_member_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_member`
--

/*!40000 ALTER TABLE `room_member` DISABLE KEYS */;
INSERT INTO `room_member` VALUES (1,1,11,'member','2025-11-30 15:03:15','2025-11-30 15:03:17','active',0,NULL,NULL),(4,1,13,'member','2025-11-30 18:41:04','2025-11-30 18:41:06','active',0,NULL,NULL),(5,1,14,'member','2025-12-06 00:10:06',NULL,'active',0,NULL,NULL),(15,1,105,'member','2025-12-09 08:27:06',NULL,'active',0,NULL,NULL),(16,1,106,'member','2025-12-09 08:27:49',NULL,'active',0,NULL,NULL),(17,2,7,'admin','2025-12-01 09:00:00',NULL,'active',1200,'考研数学130+','复习高数极限'),(18,2,6,'member','2025-12-01 10:30:00',NULL,'active',800,'数学不挂科','做线代习题'),(19,2,9,'member','2025-12-01 14:00:00',NULL,'active',650,'考研上岸','概率论复习'),(20,2,10,'member','2025-12-02 08:00:00',NULL,'active',450,'数学提高20分','高数积分'),(21,2,14,'member','2025-12-03 09:00:00',NULL,'active',320,'期末不挂科','复习导数'),(22,2,101,'member','2025-12-04 10:00:00',NULL,'active',280,'考研数学120+','做真题'),(23,3,8,'admin','2025-12-02 10:00:00',NULL,'active',1500,'六级600+','听力精听'),(24,3,6,'member','2025-12-02 11:00:00',NULL,'active',900,'四级过线','背单词'),(25,3,7,'member','2025-12-02 14:00:00',NULL,'active',750,'六级550+','阅读理解'),(26,3,9,'member','2025-12-03 09:00:00',NULL,'active',600,'四级500+','写作练习'),(27,3,10,'member','2025-12-03 10:00:00',NULL,'active',480,'六级过线','翻译练习'),(28,3,14,'member','2025-12-04 08:00:00',NULL,'active',350,'四级550+','听力训练'),(29,3,102,'member','2025-12-05 10:00:00',NULL,'active',200,'四级过线','做真题'),(30,3,103,'member','2025-12-05 11:00:00',NULL,'active',150,'提高听力','听力练习'),(31,4,6,'admin','2025-12-03 14:00:00',NULL,'active',1100,'掌握Java核心','Spring Boot学习'),(32,4,7,'member','2025-12-03 15:00:00',NULL,'active',800,'Java就业','MyBatis练习'),(33,4,8,'member','2025-12-04 09:00:00',NULL,'active',600,'后端开发','MySQL优化'),(34,4,14,'member','2025-12-06 14:00:00',NULL,'active',180,'Java进阶','多线程学习'),(35,4,104,'member','2025-12-05 11:00:00',NULL,'active',250,'项目实战','做小项目'),(36,5,9,'admin','2025-12-04 08:00:00',NULL,'active',1800,'行测80+申论70+','言语理解'),(37,5,7,'member','2025-12-04 09:00:00',NULL,'active',1200,'上岸','数量关系'),(38,5,8,'member','2025-12-04 10:00:00',NULL,'active',900,'进面试','申论大作文'),(39,5,10,'member','2025-12-05 08:00:00',NULL,'active',700,'行测75+','资料分析'),(40,5,6,'member','2025-12-05 09:00:00',NULL,'active',500,'申论65+','申论小题'),(41,5,14,'member','2025-12-07 08:00:00',NULL,'active',200,'行测提高','做真题'),(42,6,10,'admin','2025-12-05 11:00:00',NULL,'active',950,'前端工程师','Vue3项目'),(43,6,6,'member','2025-12-05 12:00:00',NULL,'active',600,'全栈开发','React学习'),(44,6,8,'member','2025-12-06 10:00:00',NULL,'active',400,'前端入门','CSS布局'),(45,6,14,'member','2025-12-06 11:00:00',NULL,'active',300,'Vue熟练','组件开发');
/*!40000 ALTER TABLE `room_member` ENABLE KEYS */;

--
-- Table structure for table `room_message`
--

DROP TABLE IF EXISTS `room_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room_message` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_type` enum('text','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'text',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `room_id` (`room_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `room_message_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `study_room` (`room_id`) ON DELETE CASCADE,
  CONSTRAINT `room_message_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_message`
--

/*!40000 ALTER TABLE `room_message` DISABLE KEYS */;
INSERT INTO `room_message` VALUES (45,1,14,'大家好，今天一起学习！','text','2025-12-06 09:00:00'),(46,1,105,'早上好，开始学习了','text','2025-12-06 09:05:00'),(47,1,106,'加油加油！','text','2025-12-06 09:10:00'),(48,1,14,'今天目标：完成第三章','text','2025-12-06 09:15:00'),(49,1,105,'我也是，一起加油','text','2025-12-06 09:20:00'),(50,2,7,'欢迎大家加入考研数学冲刺室！','text','2025-12-01 09:00:00'),(51,2,6,'谢谢！一起加油考研！','text','2025-12-01 10:35:00'),(52,2,9,'高数极限这块有什么好的复习方法吗？','text','2025-12-01 14:30:00'),(53,2,7,'建议先看张宇的视频，然后做660题','text','2025-12-01 14:35:00'),(54,2,10,'线代用李永乐的讲义效果不错','text','2025-12-02 08:30:00'),(55,2,14,'概率论哪本书比较好？','text','2025-12-03 09:30:00'),(56,2,7,'王式安的概率论讲义很经典','text','2025-12-03 09:35:00'),(57,2,101,'今天做了一套真题，感觉还行','text','2025-12-04 15:00:00'),(58,3,8,'四六级备考室开张啦，欢迎大家！','text','2025-12-02 10:00:00'),(59,3,6,'四级听力太难了，有什么技巧吗？','text','2025-12-02 11:30:00'),(60,3,8,'建议每天精听一篇，注意连读和弱读','text','2025-12-02 11:35:00'),(61,3,7,'六级阅读时间不够用怎么办？','text','2025-12-02 14:30:00'),(62,3,8,'先做仔细阅读，再做信息匹配，最后选词填空','text','2025-12-02 14:35:00'),(63,3,9,'背单词用什么APP比较好？','text','2025-12-03 09:30:00'),(64,3,10,'墨墨背单词不错，可以自定义词书','text','2025-12-03 10:30:00'),(65,3,14,'今天背了200个单词！','text','2025-12-04 18:00:00'),(66,3,102,'坚持就是胜利！','text','2025-12-05 10:30:00'),(67,3,103,'听力精听真的有用，推荐！','text','2025-12-05 15:00:00'),(68,4,6,'Java学习室开始运营，欢迎各位码农！','text','2025-12-03 14:00:00'),(69,4,7,'Spring Boot有什么好的入门教程吗？','text','2025-12-03 15:30:00'),(70,4,6,'推荐B站尚硅谷的教程，讲得很详细','text','2025-12-03 15:35:00'),(71,4,8,'MySQL索引优化有什么技巧？','text','2025-12-04 09:30:00'),(72,4,6,'注意最左前缀原则，避免全表扫描','text','2025-12-04 09:35:00'),(73,4,14,'多线程这块有点难理解','text','2025-12-06 14:30:00'),(74,4,6,'可以先理解线程的生命周期，再学同步机制','text','2025-12-06 14:35:00'),(75,5,9,'公考自习室开张！一起上岸！','text','2025-12-04 08:00:00'),(76,5,7,'行测数量关系太难了','text','2025-12-04 09:30:00'),(77,5,9,'数量关系可以适当放弃难题，保证正确率','text','2025-12-04 09:35:00'),(78,5,8,'申论大作文怎么写才能拿高分？','text','2025-12-04 10:30:00'),(79,5,9,'注意论点明确，论据充分，结构清晰','text','2025-12-04 10:35:00'),(80,5,10,'资料分析有什么速算技巧？','text','2025-12-05 08:30:00'),(81,5,9,'截位直除法和特殊值法很实用','text','2025-12-05 08:35:00'),(82,5,14,'今天做了一套行测真题，正确率65%','text','2025-12-07 18:00:00'),(83,5,9,'继续加油，多做多总结！','text','2025-12-07 18:05:00'),(84,6,10,'前端学习室欢迎大家！','text','2025-12-05 11:00:00'),(85,6,6,'Vue3和Vue2有什么主要区别？','text','2025-12-05 12:30:00'),(86,6,10,'Composition API是最大的变化，更灵活','text','2025-12-05 12:35:00'),(87,6,8,'CSS Flex布局和Grid布局怎么选择？','text','2025-12-06 10:30:00'),(88,6,10,'一维布局用Flex，二维布局用Grid','text','2025-12-06 10:35:00'),(89,6,14,'Vue组件通信有哪些方式？','text','2025-12-06 11:30:00'),(90,6,6,'props/emit、provide/inject、Vuex/Pinia等','text','2025-12-06 11:35:00');
/*!40000 ALTER TABLE `room_message` ENABLE KEYS */;

--
-- Temporary view structure for view `student_behavior_summary`
--

DROP TABLE IF EXISTS `student_behavior_summary`;
/*!50001 DROP VIEW IF EXISTS `student_behavior_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `student_behavior_summary` AS SELECT 
 1 AS `user_id`,
 1 AS `user_name`,
 1 AS `enrolled_courses`,
 1 AS `avg_completion_rate`,
 1 AS `avg_mastery_level`,
 1 AS `total_focus_time`,
 1 AS `active_days`,
 1 AS `last_analysis_time`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `student_course_performance`
--

DROP TABLE IF EXISTS `student_course_performance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_course_performance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int NOT NULL,
  `analysis_period` varchar(20) DEFAULT NULL COMMENT '分析周期: daily/weekly/monthly',
  `completion_rate` decimal(5,2) DEFAULT '0.00' COMMENT '课程完播率(%)',
  `mastery_level` decimal(5,2) DEFAULT '0.00' COMMENT '知识掌握度(%)',
  `efficiency_score` decimal(5,2) DEFAULT '0.00' COMMENT '学习效率指数',
  `avg_focus_duration` int DEFAULT '0' COMMENT '平均专注时长(分钟)',
  `total_study_time` int DEFAULT '0' COMMENT '总学习时间(分钟)',
  `chapter_progress` json DEFAULT NULL COMMENT '章节进度数据',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  KEY `idx_user_course` (`user_id`,`course_id`),
  CONSTRAINT `student_course_performance_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `student_course_performance_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生课程表现分析表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_course_performance`
--

/*!40000 ALTER TABLE `student_course_performance` DISABLE KEYS */;
INSERT INTO `student_course_performance` VALUES (1,14,1,'weekly',65.50,70.20,72.80,42,420,'{\"progress_rate\": 60.0, \"total_chapters\": 5, \"completed_chapters\": 3}','2025-12-01 08:53:43','2025-12-01 08:53:43'),(2,14,2,'weekly',45.30,58.70,65.40,30,210,'{\"progress_rate\": 33.3, \"total_chapters\": 3, \"completed_chapters\": 1}','2025-12-01 08:53:43','2025-12-01 08:53:43'),(3,14,3,'weekly',80.20,85.60,88.90,52,380,'{\"progress_rate\": 75.0, \"total_chapters\": 4, \"completed_chapters\": 3}','2025-12-01 08:53:43','2025-12-01 08:53:43'),(4,14,5,'weekly',30.10,45.20,60.30,28,150,'{\"progress_rate\": 33.3, \"total_chapters\": 3, \"completed_chapters\": 1}','2025-12-01 08:53:43','2025-12-01 08:53:43');
/*!40000 ALTER TABLE `student_course_performance` ENABLE KEYS */;

--
-- Table structure for table `student_focus_analysis`
--

DROP TABLE IF EXISTS `student_focus_analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_focus_analysis` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int NOT NULL,
  `session_date` date NOT NULL,
  `focus_duration` int DEFAULT '0' COMMENT '专注时长(分钟)',
  `total_duration` int DEFAULT '0' COMMENT '总学习时长(分钟)',
  `focus_rate` decimal(5,2) DEFAULT '0.00' COMMENT '专注率(%)',
  `session_count` int DEFAULT '1' COMMENT '学习次数',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  KEY `idx_user_course_date` (`user_id`,`course_id`,`session_date`),
  CONSTRAINT `student_focus_analysis_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `student_focus_analysis_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生专注度分析表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_focus_analysis`
--

/*!40000 ALTER TABLE `student_focus_analysis` DISABLE KEYS */;
INSERT INTO `student_focus_analysis` VALUES (1,14,1,'2025-11-25',45,60,75.00,2,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(2,14,1,'2025-11-26',60,80,75.00,1,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(3,14,1,'2025-11-28',35,50,70.00,1,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(4,14,1,'2025-11-30',55,70,78.60,2,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(5,14,1,'2025-12-01',40,55,72.70,1,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(6,14,2,'2025-11-27',30,45,66.70,1,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(7,14,2,'2025-11-29',25,40,62.50,1,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(8,14,2,'2025-12-01',35,50,70.00,1,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(9,14,3,'2025-11-26',50,65,76.90,1,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(10,14,3,'2025-11-29',60,75,80.00,2,'2025-12-01 08:53:41','2025-12-01 08:53:41'),(11,14,3,'2025-12-01',45,60,75.00,1,'2025-12-01 08:53:41','2025-12-01 08:53:41');
/*!40000 ALTER TABLE `student_focus_analysis` ENABLE KEYS */;

--
-- Table structure for table `student_learning_goal`
--

DROP TABLE IF EXISTS `student_learning_goal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_learning_goal` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `goal_type` varchar(50) DEFAULT NULL COMMENT '目标类型: daily/weekly/monthly/course',
  `goal_content` text NOT NULL,
  `target_value` decimal(10,2) DEFAULT NULL COMMENT '目标数值',
  `current_value` decimal(10,2) DEFAULT '0.00' COMMENT '当前数值',
  `unit` varchar(50) DEFAULT NULL COMMENT '单位',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` varchar(20) DEFAULT 'active' COMMENT '状态: active/completed/expired',
  `progress_rate` decimal(5,2) DEFAULT '0.00' COMMENT '完成进度(%)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_status` (`user_id`,`status`),
  KEY `idx_dates` (`start_date`,`end_date`),
  CONSTRAINT `student_learning_goal_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生学习目标表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_learning_goal`
--

/*!40000 ALTER TABLE `student_learning_goal` DISABLE KEYS */;
INSERT INTO `student_learning_goal` VALUES (1,14,'daily','每天学习至少2小时',120.00,85.00,'分钟','2025-12-01','2025-12-01','active',70.80,'2025-12-01 08:53:57','2025-12-01 08:53:57'),(2,14,'weekly','完成Java课程第三章',1.00,0.60,'章节','2025-11-29','2025-12-06','active',60.00,'2025-12-01 08:53:57','2025-12-01 08:53:57'),(3,14,'weekly','英语听力练习3小时',180.00,120.00,'分钟','2025-11-28','2025-12-05','active',66.70,'2025-12-01 08:53:57','2025-12-01 08:53:57'),(4,14,'course','Java课程达到80%掌握度',80.00,70.20,'百分比','2025-11-16','2025-12-16','active',87.80,'2025-12-01 08:53:57','2025-12-01 08:53:57'),(5,14,'course','高数课程达到70%掌握度',70.00,58.70,'百分比','2025-11-11','2025-12-11','active',83.90,'2025-12-01 08:53:57','2025-12-01 08:53:57'),(6,14,'monthly','通过2门课程期末测试',2.00,0.00,'门数','2025-11-21','2025-12-21','active',0.00,'2025-12-01 08:53:57','2025-12-01 08:53:57');
/*!40000 ALTER TABLE `student_learning_goal` ENABLE KEYS */;

--
-- Table structure for table `student_learning_log`
--

DROP TABLE IF EXISTS `student_learning_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_learning_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int DEFAULT NULL,
  `video_id` int DEFAULT NULL,
  `action_type` varchar(50) NOT NULL COMMENT '行为类型: play/pause/seek/complete/search/note/quiz',
  `action_detail` json DEFAULT NULL COMMENT '行为详情',
  `duration_seconds` int DEFAULT '0' COMMENT '行为时长(秒)',
  `timestamp` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `device_info` varchar(255) DEFAULT NULL COMMENT '设备信息',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `video_id` (`video_id`),
  KEY `idx_user_action` (`user_id`,`action_type`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `idx_course_video` (`course_id`,`video_id`),
  CONSTRAINT `student_learning_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `student_learning_log_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE SET NULL,
  CONSTRAINT `student_learning_log_ibfk_3` FOREIGN KEY (`video_id`) REFERENCES `course_video` (`video_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生学习行为日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_learning_log`
--

/*!40000 ALTER TABLE `student_learning_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_learning_log` ENABLE KEYS */;

--
-- Table structure for table `student_learning_style`
--

DROP TABLE IF EXISTS `student_learning_style`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_learning_style` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `analysis_date` date NOT NULL,
  `learning_style_type` varchar(50) DEFAULT NULL COMMENT '学习类型: 视觉型/听觉型/动手型/理论型等',
  `style_score` json DEFAULT NULL COMMENT '各项风格分数',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`,`analysis_date`),
  CONSTRAINT `student_learning_style_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生学习风格分析表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_learning_style`
--

/*!40000 ALTER TABLE `student_learning_style` DISABLE KEYS */;
INSERT INTO `student_learning_style` VALUES (1,14,'2025-12-01','动手实践型','{\"visual\": 75.5, \"auditory\": 65.0, \"kinesthetic\": 88.2, \"theoretical\": 62.3}','2025-12-01 08:53:40','2025-12-01 08:53:40');
/*!40000 ALTER TABLE `student_learning_style` ENABLE KEYS */;

--
-- Table structure for table `student_progress`
--

DROP TABLE IF EXISTS `student_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_progress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int NOT NULL,
  `progress` decimal(5,2) DEFAULT '0.00' COMMENT '整体进度',
  `completion_rate` decimal(5,2) DEFAULT '0.00' COMMENT '完成率(%)',
  `mastery_level` decimal(5,2) DEFAULT '0.00' COMMENT '掌握程度(%)',
  `efficiency_score` decimal(5,2) DEFAULT '0.00' COMMENT '学习效率指数',
  `avg_focus_duration` int DEFAULT '0' COMMENT '平均专注时长(分钟)',
  `total_learn_duration` int DEFAULT '0' COMMENT '总学习时长(分钟)',
  `last_learn_time` timestamp NULL DEFAULT NULL COMMENT '最后学习时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_course` (`user_id`,`course_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_progress` (`progress`),
  CONSTRAINT `fk_student_progress_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_student_progress_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生课程进度表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_progress`
--

/*!40000 ALTER TABLE `student_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_progress` ENABLE KEYS */;

--
-- Table structure for table `study_room`
--

DROP TABLE IF EXISTS `study_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_room` (
  `room_id` int NOT NULL AUTO_INCREMENT,
  `room_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `creator_id` int NOT NULL,
  `max_participants` int DEFAULT '20',
  `current_participants` int DEFAULT '0',
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `status` enum('open','closed','active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'open',
  `room_type` enum('public','private') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'public',
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tags` json DEFAULT NULL COMMENT '自习室标签',
  `rules` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '自习室规则',
  `schedule_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开放时间',
  PRIMARY KEY (`room_id`),
  KEY `idx_creator` (`creator_id`),
  KEY `idx_status` (`status`),
  KEY `idx_time` (`start_time`,`end_time`),
  CONSTRAINT `study_room_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_room`
--

/*!40000 ALTER TABLE `study_room` DISABLE KEYS */;
INSERT INTO `study_room` VALUES (1,'test','这个一个学习自习室，在这里面学习',NULL,14,50,5,NULL,NULL,'open','public',NULL,'2025-11-30 15:03:07','2025-12-09 08:29:05','[\"学习\"]','1.学习\n2.学习\n3.学习','9:00-12:00'),(2,'考研数学冲刺室','考研数学专项复习，一起攻克高数、线代、概率论',NULL,7,30,6,NULL,NULL,'open','public',NULL,'2025-12-01 09:00:00','2025-12-09 09:07:55','[\"考研\", \"数学\", \"高数\"]','1.保持安静专注\n2.每小时休息10分钟\n3.互相鼓励，共同进步','8:00-22:00'),(3,'英语四六级备考室','四六级考试冲刺，听力阅读写作全面提升',NULL,8,40,8,NULL,NULL,'open','public',NULL,'2025-12-02 10:00:00','2025-12-09 09:07:55','[\"英语\", \"四级\", \"六级\"]','1.可以小声跟读\n2.分享学习资料\n3.每日打卡','7:00-23:00'),(4,'Java编程学习室','Java从入门到精通，代码实战练习',NULL,6,25,5,NULL,NULL,'open','public',NULL,'2025-12-03 14:00:00','2025-12-09 09:07:55','[\"Java\", \"编程\", \"后端\"]','1.遇到问题可以讨论\n2.分享代码片段\n3.互相code review','9:00-21:00'),(5,'公务员考试自习室','行测申论专项训练，上岸必备',NULL,9,35,6,NULL,NULL,'open','public',NULL,'2025-12-04 08:00:00','2025-12-09 09:07:55','[\"公考\", \"行测\", \"申论\"]','1.真题模拟练习\n2.分享解题技巧\n3.互相监督学习','6:00-24:00'),(6,'前端开发学习室','HTML/CSS/JavaScript/Vue/React学习交流',NULL,10,20,4,NULL,NULL,'open','public',NULL,'2025-12-05 11:00:00','2025-12-09 09:07:55','[\"前端\", \"Vue\", \"React\"]','1.项目实战为主\n2.代码规范讨论\n3.技术分享','10:00-22:00');
/*!40000 ALTER TABLE `study_room` ENABLE KEYS */;

--
-- Table structure for table `study_task`
--

DROP TABLE IF EXISTS `study_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_task` (
  `task_id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `user_id` int NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `estimated_hours` decimal(4,1) DEFAULT '1.0',
  `start_time` timestamp NULL DEFAULT NULL,
  `completed_time` timestamp NULL DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('active','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  PRIMARY KEY (`task_id`),
  KEY `idx_room_user` (`room_id`,`user_id`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='自习室学习任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_task`
--

/*!40000 ALTER TABLE `study_task` DISABLE KEYS */;
INSERT INTO `study_task` VALUES (5,1,14,'完成Java第三章学习','学习任务','学习面向对象编程基础',2.0,'2025-12-06 01:00:00','2025-12-06 03:30:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(6,1,105,'复习数据结构','学习任务','复习链表和树的基本操作',1.5,'2025-12-06 01:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(7,1,106,'做算法练习题','练习任务','完成LeetCode 5道题',2.0,'2025-12-06 02:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(8,2,7,'高数极限专题复习','学习任务','复习极限的定义、性质和计算方法',3.0,'2025-12-01 01:00:00','2025-12-01 04:30:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(9,2,6,'线性代数矩阵运算','学习任务','复习矩阵的基本运算和性质',2.5,'2025-12-01 02:30:00','2025-12-01 05:00:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(10,2,9,'概率论随机变量','学习任务','学习离散和连续随机变量',2.0,'2025-12-01 06:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(11,2,10,'高数积分计算','练习任务','完成20道积分计算题',2.0,'2025-12-02 00:00:00','2025-12-02 02:30:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(12,2,14,'导数基础复习','学习任务','复习导数的定义和求导法则',1.5,'2025-12-03 01:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(13,2,101,'做2020年真题','练习任务','完成2020年考研数学真题',3.0,'2025-12-04 02:00:00','2025-12-04 05:30:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(14,3,8,'六级听力精听','学习任务','精听2019年6月六级听力',1.5,'2025-12-02 02:00:00','2025-12-02 03:30:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(15,3,6,'四级词汇背诵','学习任务','背诵四级核心词汇200个',2.0,'2025-12-02 03:00:00','2025-12-02 05:00:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(16,3,7,'六级阅读理解','练习任务','完成3篇六级阅读理解',1.5,'2025-12-02 06:00:00','2025-12-02 07:30:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(17,3,9,'四级写作练习','练习任务','写一篇四级作文',1.0,'2025-12-03 01:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(18,3,10,'六级翻译练习','练习任务','完成5段翻译练习',1.0,'2025-12-03 02:00:00','2025-12-03 03:00:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(19,3,14,'听力技巧学习','学习任务','学习听力答题技巧',1.0,'2025-12-04 00:00:00','2025-12-04 01:00:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(20,3,102,'四级真题模拟','练习任务','完成一套四级真题',2.5,'2025-12-05 02:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(21,4,6,'Spring Boot项目搭建','学习任务','搭建Spring Boot基础项目框架',2.0,'2025-12-03 06:00:00','2025-12-03 08:00:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(22,4,7,'MyBatis CRUD操作','练习任务','实现用户表的增删改查',1.5,'2025-12-03 07:00:00','2025-12-03 08:30:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(23,4,8,'MySQL索引优化','学习任务','学习索引原理和优化方法',2.0,'2025-12-04 01:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(24,4,14,'多线程基础','学习任务','学习线程创建和生命周期',2.0,'2025-12-06 06:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(25,4,104,'小项目实战','练习任务','完成学生管理系统',3.0,'2025-12-05 03:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(26,5,9,'言语理解专项','学习任务','学习言语理解答题技巧',2.0,'2025-12-04 00:00:00','2025-12-04 02:00:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(27,5,7,'数量关系练习','练习任务','完成30道数量关系题',2.0,'2025-12-04 01:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(28,5,8,'申论大作文','练习任务','写一篇申论大作文',1.5,'2025-12-04 02:00:00','2025-12-04 03:30:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(29,5,10,'资料分析专项','学习任务','学习资料分析速算技巧',2.0,'2025-12-05 00:00:00','2025-12-05 02:00:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(30,5,6,'申论小题练习','练习任务','完成3道申论小题',1.5,'2025-12-05 01:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(31,5,14,'行测真题模拟','练习任务','完成一套行测真题',2.0,'2025-12-07 00:00:00','2025-12-07 02:00:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(32,6,10,'Vue3项目实战','学习任务','使用Vue3开发Todo应用',3.0,'2025-12-05 03:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(33,6,6,'React Hooks学习','学习任务','学习useState和useEffect',2.0,'2025-12-05 04:00:00','2025-12-05 06:00:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(34,6,8,'CSS Flex布局','学习任务','掌握Flex布局属性',1.5,'2025-12-06 02:00:00','2025-12-06 03:30:00','2025-12-09 01:08:35','2025-12-09 01:08:35','active'),(35,6,14,'Vue组件开发','练习任务','开发3个可复用组件',2.0,'2025-12-06 03:00:00',NULL,'2025-12-09 01:08:35','2025-12-09 01:08:35','active');
/*!40000 ALTER TABLE `study_task` ENABLE KEYS */;

--
-- Table structure for table `study_team`
--

DROP TABLE IF EXISTS `study_team`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_team` (
  `team_id` int NOT NULL AUTO_INCREMENT,
  `team_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `creator_id` int NOT NULL,
  `max_members` int DEFAULT '2',
  `current_members` int DEFAULT '1',
  `status` enum('active','inactive','full','closed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `tags` json DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`team_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_creator` (`creator_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `study_team_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE SET NULL,
  CONSTRAINT `study_team_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_team`
--

/*!40000 ALTER TABLE `study_team` DISABLE KEYS */;
INSERT INTO `study_team` VALUES (4,'JavaScript学习小组','一起学习JavaScript基础知识，互相监督，共同进步！','/uploads/team-avatars/team1.jpg',1,1,2,2,'active','[\"JavaScript\", \"前端\", \"基础\"]','2025-12-11 17:09:20','2025-12-11 17:09:20'),(5,'Vue.js实战小组','通过实际项目学习Vue.js，提升前端开发技能','/uploads/team-avatars/team2.jpg',2,3,2,1,'active','[\"Vue.js\", \"前端\", \"实战\"]','2025-12-11 17:09:20','2025-12-11 17:09:20'),(6,'Node.js后端小组','专注Node.js后端开发，从基础到进阶','/uploads/team-avatars/team3.jpg',3,2,2,1,'active','[\"Node.js\", \"后端\", \"服务器\"]','2025-12-11 17:09:20','2025-12-11 17:09:20'),(9,'英语六级','一周冲击英语六级加油加油加油',NULL,13,14,2,2,'active','[]','2025-12-08 20:58:00','2025-12-09 09:20:34'),(10,'Python数据分析小组','一起学习Python数据分析，掌握pandas、numpy等工具',NULL,5,6,2,2,'active','[\"Python\", \"数据分析\", \"pandas\"]','2025-12-01 10:00:00','2025-12-08 15:30:00'),(11,'React前端进阶组','深入学习React Hooks、Redux状态管理',NULL,2,7,4,2,'active','[\"React\", \"前端\", \"Hooks\"]','2025-12-02 14:30:00','2025-12-08 16:00:00'),(12,'MySQL数据库学习组','从零开始学习MySQL，掌握SQL语法和数据库设计',NULL,3,8,2,2,'active','[\"MySQL\", \"数据库\", \"SQL\"]','2025-12-03 09:00:00','2025-12-08 18:00:00'),(13,'算法刷题小组','每日一题，LeetCode算法练习，互相讨论解题思路',NULL,NULL,9,2,2,'active','[\"算法\", \"LeetCode\", \"刷题\"]','2025-12-04 20:00:00','2025-12-08 22:00:00'),(14,'TypeScript入门组','学习TypeScript类型系统，提升代码质量',NULL,1,10,2,2,'active','[\"TypeScript\", \"前端\", \"类型\"]','2025-12-05 11:00:00','2025-12-08 12:00:00'),(15,'计算机网络学习组','系统学习计算机网络知识，TCP/IP协议栈',NULL,13,14,2,2,'active','[\"网络\", \"TCP/IP\", \"协议\"]','2025-12-06 08:00:00','2025-12-08 20:00:00');
/*!40000 ALTER TABLE `study_team` ENABLE KEYS */;

--
-- Table structure for table `team_comment`
--

DROP TABLE IF EXISTS `team_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_comment` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `team_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('active','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  PRIMARY KEY (`comment_id`),
  KEY `idx_team_id` (`team_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='小组评论表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_comment`
--

/*!40000 ALTER TABLE `team_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_comment` ENABLE KEYS */;

--
-- Table structure for table `team_join_request`
--

DROP TABLE IF EXISTS `team_join_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_join_request` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `team_id` int NOT NULL,
  `user_id` int NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `request_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `response_time` datetime DEFAULT NULL,
  `response_by` int DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `unique_team_user_request` (`team_id`,`user_id`,`status`),
  KEY `idx_team` (`team_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `team_join_request_ibfk_3` (`response_by`),
  CONSTRAINT `team_join_request_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `study_team` (`team_id`) ON DELETE CASCADE,
  CONSTRAINT `team_join_request_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `team_join_request_ibfk_3` FOREIGN KEY (`response_by`) REFERENCES `user` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_join_request`
--

/*!40000 ALTER TABLE `team_join_request` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_join_request` ENABLE KEYS */;

--
-- Table structure for table `team_learning_progress`
--

DROP TABLE IF EXISTS `team_learning_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_learning_progress` (
  `progress_id` int NOT NULL AUTO_INCREMENT,
  `team_id` int NOT NULL,
  `user_id` int NOT NULL,
  `course_id` int DEFAULT NULL,
  `study_date` date NOT NULL COMMENT '学习日期',
  `daily_study_duration` int DEFAULT '0' COMMENT '当日学习时长（分钟）',
  `daily_completed_tasks` int DEFAULT '0' COMMENT '当日完成任务数',
  `daily_progress_percentage` decimal(5,2) DEFAULT '0.00' COMMENT '当日学习进度百分比',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`progress_id`),
  UNIQUE KEY `unique_team_user_date` (`team_id`,`user_id`,`study_date`),
  KEY `idx_team` (`team_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_study_date` (`study_date`),
  CONSTRAINT `team_learning_progress_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `study_team` (`team_id`) ON DELETE CASCADE,
  CONSTRAINT `team_learning_progress_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `team_learning_progress_ibfk_3` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='小组每日学习进度表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_learning_progress`
--

/*!40000 ALTER TABLE `team_learning_progress` DISABLE KEYS */;
INSERT INTO `team_learning_progress` VALUES (1,9,14,1,'2025-12-08',60,1,70.00,'2025-12-08 14:59:12','2025-12-08 14:59:12'),(2,9,105,17,'2025-12-08',60,1,75.00,'2025-12-08 14:59:12','2025-12-08 14:59:12'),(6,10,14,5,'2025-12-07',120,2,85.00,'2025-12-07 14:00:00','2025-12-07 14:00:00'),(7,10,101,5,'2025-12-07',90,1,60.00,'2025-12-07 13:00:00','2025-12-07 13:00:00'),(8,10,14,5,'2025-12-08',150,3,90.00,'2025-12-08 14:00:00','2025-12-08 14:00:00'),(9,10,101,5,'2025-12-08',80,1,65.00,'2025-12-08 13:00:00','2025-12-08 13:00:00'),(10,11,14,2,'2025-12-07',90,1,70.00,'2025-12-07 11:00:00','2025-12-07 11:00:00'),(11,11,102,2,'2025-12-07',75,1,55.00,'2025-12-07 12:00:00','2025-12-07 12:00:00'),(12,11,14,2,'2025-12-08',120,2,80.00,'2025-12-08 11:00:00','2025-12-08 11:00:00'),(13,11,102,2,'2025-12-08',100,1,68.00,'2025-12-08 12:00:00','2025-12-08 12:00:00'),(14,12,14,3,'2025-12-07',180,2,88.00,'2025-12-07 14:00:00','2025-12-07 14:00:00'),(15,12,103,3,'2025-12-07',120,1,70.00,'2025-12-07 12:00:00','2025-12-07 12:00:00'),(16,12,14,3,'2025-12-08',200,3,95.00,'2025-12-08 14:00:00','2025-12-08 14:00:00'),(17,12,103,3,'2025-12-08',160,2,85.00,'2025-12-08 13:00:00','2025-12-08 13:00:00'),(18,13,14,NULL,'2025-12-07',240,4,92.00,'2025-12-07 15:00:00','2025-12-07 15:00:00'),(19,13,104,NULL,'2025-12-07',180,3,78.00,'2025-12-07 14:00:00','2025-12-07 14:00:00'),(20,13,14,NULL,'2025-12-08',300,5,98.00,'2025-12-08 15:00:00','2025-12-08 15:00:00'),(21,13,104,NULL,'2025-12-08',200,3,82.00,'2025-12-08 14:00:00','2025-12-08 14:00:00'),(22,14,14,1,'2025-12-07',60,1,75.00,'2025-12-07 10:00:00','2025-12-07 10:00:00'),(23,14,105,1,'2025-12-07',45,1,50.00,'2025-12-07 09:00:00','2025-12-07 09:00:00'),(24,14,14,1,'2025-12-08',90,2,88.00,'2025-12-08 10:00:00','2025-12-08 10:00:00'),(25,14,105,1,'2025-12-08',70,1,62.00,'2025-12-08 09:00:00','2025-12-08 09:00:00'),(26,15,14,13,'2025-12-07',90,1,72.00,'2025-12-07 12:00:00','2025-12-07 12:00:00'),(27,15,106,13,'2025-12-07',75,1,58.00,'2025-12-07 11:00:00','2025-12-07 11:00:00'),(28,15,14,13,'2025-12-08',120,2,85.00,'2025-12-08 12:00:00','2025-12-08 12:00:00'),(29,15,106,13,'2025-12-08',100,1,70.00,'2025-12-08 11:00:00','2025-12-08 11:00:00');
/*!40000 ALTER TABLE `team_learning_progress` ENABLE KEYS */;

--
-- Table structure for table `team_member`
--

DROP TABLE IF EXISTS `team_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_member` (
  `member_id` int NOT NULL AUTO_INCREMENT,
  `team_id` int NOT NULL,
  `user_id` int NOT NULL,
  `role` enum('leader','member') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'member',
  `join_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('active','pending','removed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `unique_team_user` (`team_id`,`user_id`),
  KEY `idx_team` (`team_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `team_member_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `study_team` (`team_id`) ON DELETE CASCADE,
  CONSTRAINT `team_member_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_member`
--

/*!40000 ALTER TABLE `team_member` DISABLE KEYS */;
INSERT INTO `team_member` VALUES (21,9,14,'leader','2025-12-08 20:58:00','active'),(22,9,105,'member','2025-12-08 20:58:23','active'),(29,10,14,'leader','2025-12-01 10:00:00','active'),(30,10,101,'member','2025-12-01 12:00:00','active'),(31,11,14,'leader','2025-12-02 14:30:00','active'),(32,11,102,'member','2025-12-02 16:00:00','active'),(33,12,14,'leader','2025-12-03 09:00:00','active'),(34,12,103,'member','2025-12-03 10:30:00','active'),(35,13,14,'leader','2025-12-04 20:00:00','active'),(36,13,104,'member','2025-12-04 21:00:00','active'),(37,14,14,'leader','2025-12-05 11:00:00','active'),(38,14,105,'member','2025-12-05 14:00:00','active'),(39,15,14,'leader','2025-12-06 08:00:00','active'),(40,15,106,'member','2025-12-06 10:00:00','active');
/*!40000 ALTER TABLE `team_member` ENABLE KEYS */;

--
-- Table structure for table `team_task`
--

DROP TABLE IF EXISTS `team_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_task` (
  `task_id` int NOT NULL AUTO_INCREMENT,
  `team_id` int NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `creator_id` int NOT NULL,
  `assignee_id` int DEFAULT NULL,
  `due_date` datetime DEFAULT NULL,
  `priority` enum('low','medium','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_completed` tinyint(1) DEFAULT '0' COMMENT '是否完成',
  `completion_time` int DEFAULT NULL COMMENT '完成耗时(分钟)',
  `completed_at` timestamp NULL DEFAULT NULL COMMENT '完成时间',
  PRIMARY KEY (`task_id`),
  KEY `idx_team` (`team_id`),
  KEY `idx_creator` (`creator_id`),
  KEY `idx_assignee` (`assignee_id`),
  CONSTRAINT `team_task_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `study_team` (`team_id`) ON DELETE CASCADE,
  CONSTRAINT `team_task_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `team_task_ibfk_3` FOREIGN KEY (`assignee_id`) REFERENCES `user` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_task`
--

/*!40000 ALTER TABLE `team_task` DISABLE KEYS */;
INSERT INTO `team_task` VALUES (1,9,'完成JavaScript基础语法学习','学习变量、函数、对象等基础概念',4,14,'2024-12-10 23:59:59','high','2025-12-06 00:01:27','2025-12-09 00:29:21',1,180,NULL),(2,9,'练习DOM操作','完成10个DOM操作练习题',4,14,'2024-12-08 23:59:59','medium','2025-12-06 00:01:27','2025-12-09 00:29:38',1,50,NULL),(3,9,'学习ES6新特性','掌握箭头函数、解构赋值等ES6特性',4,14,'2024-12-15 23:59:59','medium','2025-12-06 00:01:27','2025-12-09 11:29:13',0,NULL,NULL),(4,9,'完成小项目：计算器','使用JavaScript实现一个简单的计算器',105,105,'2024-12-20 23:59:59','high','2025-12-06 00:01:27','2025-12-08 23:44:37',1,60,NULL),(5,9,'学习Vue组件开发','掌握Vue组件的创建和使用',105,105,'2024-12-12 23:59:59','high','2025-12-06 00:01:27','2025-12-08 23:44:37',1,120,NULL),(6,9,'学习Express框架','掌握Express基础用法和路由',105,105,'2024-12-14 23:59:59','high','2025-12-06 00:01:27','2025-12-08 23:44:38',0,NULL,NULL),(14,10,'学习pandas基础','掌握DataFrame创建、数据读取和基本操作',14,14,'2025-12-15 23:59:59','high','2025-12-01 10:30:00','2025-12-08 10:00:00',1,120,'2025-12-07 07:00:00'),(15,10,'完成数据清洗练习','处理缺失值、重复值和异常值',101,101,'2025-12-18 23:59:59','medium','2025-12-02 09:00:00','2025-12-08 11:00:00',0,NULL,NULL),(16,11,'学习useState和useEffect','掌握React Hooks的基本用法',14,14,'2025-12-12 23:59:59','high','2025-12-02 15:00:00','2025-12-08 09:00:00',1,90,'2025-12-06 10:00:00'),(17,11,'实现自定义Hook','封装一个通用的数据请求Hook',102,102,'2025-12-16 23:59:59','medium','2025-12-03 10:00:00','2025-12-08 14:00:00',0,NULL,NULL),(18,12,'学习SQL基础语法','掌握SELECT、INSERT、UPDATE、DELETE语句',14,14,'2025-12-10 23:59:59','high','2025-12-03 09:30:00','2025-12-07 20:00:00',1,150,'2025-12-06 08:00:00'),(19,12,'练习多表联查','掌握JOIN、LEFT JOIN、RIGHT JOIN的使用',103,103,'2025-12-14 23:59:59','high','2025-12-04 10:00:00','2025-12-08 15:00:00',0,NULL,NULL),(20,13,'完成数组专题10道','刷完LeetCode数组相关的10道题目',14,14,'2025-12-11 23:59:59','high','2025-12-04 20:30:00','2025-12-08 21:00:00',1,240,'2025-12-08 12:00:00'),(21,13,'学习二分查找算法','掌握二分查找的模板和变体',104,104,'2025-12-13 23:59:59','high','2025-12-05 09:00:00','2025-12-08 10:00:00',0,NULL,NULL),(22,14,'学习TS基础类型','掌握string、number、boolean、array等基础类型',14,14,'2025-12-12 23:59:59','high','2025-12-05 11:30:00','2025-12-08 09:00:00',1,60,'2025-12-07 02:00:00'),(23,14,'学习接口和类型别名','掌握interface和type的使用',105,105,'2025-12-16 23:59:59','medium','2025-12-06 10:00:00','2025-12-08 14:00:00',0,NULL,NULL),(24,15,'学习OSI七层模型','理解每一层的功能和协议',14,14,'2025-12-13 23:59:59','high','2025-12-06 08:30:00','2025-12-08 18:00:00',1,90,'2025-12-08 09:00:00'),(25,15,'学习TCP三次握手','理解TCP连接建立的过程',105,105,'2025-12-15 23:59:59','high','2025-12-06 14:00:00','2025-12-08 19:00:00',0,NULL,NULL);
/*!40000 ALTER TABLE `team_task` ENABLE KEYS */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `user_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('learner','instructor','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'learner',
  `is_active` tinyint DEFAULT '1',
  `register_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login_time` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'张老师','zhang.teacher@example.com','$2a$10$examplehashteacher1','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%99%E5%B8%88/man1.jpg','instructor',1,'2025-11-28 21:06:41','2025-11-30 10:00:00','2025-11-28 05:06:41','2025-12-09 02:26:53'),(2,'李老师','li.teacher@example.com','$2a$10$examplehashteacher2','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%99%E5%B8%88/man2.png','instructor',1,'2025-11-28 21:06:41','2025-11-30 09:30:00','2025-11-28 05:06:41','2025-12-09 02:31:48'),(3,'王老师','wang.teacher@example.com','$2a$10$examplehashteacher3','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%99%E5%B8%88/woman1.png','instructor',1,'2025-11-28 21:06:41','2025-11-30 11:00:00','2025-11-28 05:06:41','2025-12-09 02:31:48'),(4,'赵老师','zhao.teacher@example.com','$2a$10$examplehashteacher4','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%99%E5%B8%88/woman2.png','instructor',1,'2025-11-28 21:06:41','2025-11-30 08:00:00','2025-11-28 05:06:41','2025-12-09 02:31:48'),(5,'刘老师','liu.teacher@example.com','$2a$10$examplehashteacher5','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%99%E5%B8%88/woman3.jpg','instructor',1,'2025-11-28 21:06:41','2025-11-30 12:00:00','2025-11-28 05:06:41','2025-12-09 02:31:48'),(6,'小明','xiaoming@example.com','$2a$10$examplehashstudent1','https://via.placeholder.com/150/845ec2/ffffff?text=S1','learner',1,'2025-11-28 21:06:41','2025-11-30 13:00:00','2025-11-28 05:06:41','2025-11-29 21:00:00'),(7,'小红','xiaohong@example.com','$2a$10$examplehashstudent2','https://via.placeholder.com/150/f093fb/ffffff?text=S2','learner',1,'2025-11-28 21:06:41','2025-11-30 14:00:00','2025-11-28 05:06:41','2025-11-29 22:00:00'),(8,'小刚','xiaogang@example.com','$2a$10$examplehashstudent3','https://via.placeholder.com/150/4facfe/ffffff?text=S3','learner',1,'2025-11-28 21:06:41','2025-11-30 15:00:00','2025-11-28 05:06:41','2025-11-29 23:00:00'),(9,'小丽','xiaoli@example.com','$2a$10$examplehashstudent4','https://via.placeholder.com/150/ff6348/ffffff?text=S4','learner',1,'2025-11-28 21:06:41','2025-11-30 16:00:00','2025-11-28 05:06:41','2025-11-30 00:00:00'),(10,'小华','xiaohua@example.com','$2a$10$examplehashstudent5','https://via.placeholder.com/150/feca57/ffffff?text=S5','learner',1,'2025-11-28 21:06:41','2025-11-30 17:00:00','2025-11-28 05:06:41','2025-11-30 01:00:00'),(11,'1111','1111_1764483685328_a4yg6h@mzcourse.local','$2b$10$URRsMC0546kXKr.77hP.AekIArlH3Jp3UrB9oeH/10a3Tr8DOx1.O',NULL,'learner',1,'2025-11-30 14:21:25',NULL,'2025-11-30 06:21:25','2025-11-30 06:21:25'),(12,'tttt','tttt_1764486655431_csyp0m@mzcourse.local','$2b$10$pc1AvNKBQirHlJS8h2Lei.hN5TpurKsEd7HpRMTPGucGwUjSnmkbK',NULL,'learner',1,'2025-11-30 15:10:55','2025-11-30 18:41:27','2025-11-30 07:10:55','2025-11-30 10:41:27'),(13,'ffff','ffff_1764487246998_fgivus@mzcourse.local','$2b$10$MVXZ7A3N58Bd5cgQwp21iOjmfhRCtwu/CFPxsysg9MaKGAf7xZexi',NULL,'instructor',1,'2025-11-30 15:20:47','2025-11-30 18:41:57','2025-11-30 07:20:47','2025-11-30 10:41:57'),(14,'student','behavior.student@mzcourse.local','$2b$10$vuZqKnT..SBS.ErxZ/ytWe.vW3M7ge53yil3MxPEPrqzG5aLHPYIy',NULL,'learner',1,'2025-12-01 13:11:25','2025-12-09 11:20:26','2025-12-01 05:11:25','2025-12-09 03:20:26'),(15,'teacher','teacher_1765179711963_h5ixn8@mzcourse.local','$2b$10$DGyCvInkk86WR.KTNGHuqOFHj2m3vNOPeDLqaolxKaDOeE/m82fpy','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%99%E5%B8%88/woman3.png','instructor',1,'2025-12-08 15:41:52','2025-12-09 11:30:47','2025-12-08 07:41:52','2025-12-09 03:30:47'),(101,'学生A','student.a@example.com','$2a$10$examplestudent1',NULL,'learner',1,'2025-12-08 15:42:37',NULL,'2025-12-08 07:42:37','2025-12-08 07:42:37'),(102,'学生B','student.b@example.com','$2a$10$examplestudent2',NULL,'learner',1,'2025-12-08 15:42:37',NULL,'2025-12-08 07:42:37','2025-12-08 07:42:37'),(103,'学生C','student.c@example.com','$2a$10$examplestudent3',NULL,'learner',1,'2025-12-08 15:42:37',NULL,'2025-12-08 07:42:37','2025-12-08 07:42:37'),(104,'学生D','student.d@example.com','$2a$10$examplestudent4',NULL,'learner',1,'2025-12-08 15:42:37',NULL,'2025-12-08 07:42:37','2025-12-08 07:42:37'),(105,'s1','s1_1765198699176_vob66r@mzcourse.local','$2b$10$soiMRYt0QNU19ijv7X5YB.MtZUgZ3APppMPhBnlKQg5JC6JaNJQCG',NULL,'learner',1,'2025-12-08 20:58:19','2025-12-09 08:26:52','2025-12-08 12:58:19','2025-12-09 00:26:52'),(106,'s2','s2_1765240066103_9xxfzs@mzcourse.local','$2b$10$cYiwyFx8e3U3Pe4szTtZ7uVkH4VyWl9H.cfwxzhhzp7qyaGykEwyi',NULL,'learner',1,'2025-12-09 08:27:46',NULL,'2025-12-09 00:27:46','2025-12-09 00:27:46');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;

--
-- Table structure for table `user_achievement`
--

DROP TABLE IF EXISTS `user_achievement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_achievement` (
  `user_achieve_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `achievement_id` int NOT NULL,
  `earned_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_achieve_id`),
  UNIQUE KEY `uk_user_achievement` (`user_id`,`achievement_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_achievement` (`achievement_id`),
  CONSTRAINT `user_achievement_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `user_achievement_ibfk_2` FOREIGN KEY (`achievement_id`) REFERENCES `achievement` (`achievement_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_achievement`
--

/*!40000 ALTER TABLE `user_achievement` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_achievement` ENABLE KEYS */;

--
-- Table structure for table `user_behavior`
--

DROP TABLE IF EXISTS `user_behavior`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_behavior` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `course_id` int NOT NULL,
  `video_id` int NOT NULL,
  `behavior_type` varchar(50) NOT NULL,
  `current_time` int DEFAULT '0',
  `play_speed` decimal(3,2) DEFAULT '1.00',
  `behavior_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_course` (`user_id`,`course_id`),
  KEY `idx_video` (`video_id`),
  KEY `idx_behavior_type` (`behavior_type`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_behavior`
--

/*!40000 ALTER TABLE `user_behavior` DISABLE KEYS */;
INSERT INTO `user_behavior` VALUES (1,14,1,1001,'speed_change',120,0.75,'2025-11-29 00:15:22'),(2,14,1,1001,'speed_change',300,1.25,'2025-11-30 00:15:22'),(3,14,1,1002,'speed_change',90,1.00,'2025-12-01 00:15:22'),(4,14,2,2001,'speed_change',180,1.50,'2025-11-30 00:15:22'),(5,14,2,2001,'speed_change',60,1.50,'2025-12-01 00:15:22'),(6,14,2,2002,'speed_change',30,1.25,'2025-12-02 00:15:22'),(7,14,3,3001,'speed_change',240,2.00,'2025-12-01 00:15:22'),(8,14,3,3001,'speed_change',45,1.25,'2025-12-02 00:15:22'),(9,14,3,3002,'speed_change',100,1.00,'2025-12-02 00:15:22');
/*!40000 ALTER TABLE `user_behavior` ENABLE KEYS */;

--
-- Table structure for table `user_course`
--

DROP TABLE IF EXISTS `user_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_course` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `course_id` int NOT NULL COMMENT '课程ID',
  `enroll_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  `progress` int DEFAULT '0' COMMENT '学习进度（0-100）',
  `last_learn_time` datetime DEFAULT NULL COMMENT '最后学习时间',
  `is_favorite` tinyint DEFAULT '0' COMMENT '是否收藏',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `total_learn_duration` int DEFAULT '0' COMMENT '总学习时长（分钟）',
  `last_chapter_id` int DEFAULT NULL COMMENT '最后学习的章节ID',
  `last_video_id` int DEFAULT NULL COMMENT '最后学习的视频ID',
  `is_completed` tinyint DEFAULT '0' COMMENT '是否已完成课程',
  `completed_time` datetime DEFAULT NULL COMMENT '完成时间',
  `rating` int DEFAULT NULL COMMENT '评分（1-5）',
  `is_enrolled` tinyint NOT NULL DEFAULT '1' COMMENT '是否已报名',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_course` (`user_id`,`course_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `fk_user_course_last_chapter` (`last_chapter_id`),
  KEY `fk_user_course_last_video` (`last_video_id`),
  KEY `idx_user_course_progress` (`progress`),
  KEY `idx_user_course_completed` (`is_completed`),
  KEY `idx_user_course_updated` (`updated_at`),
  CONSTRAINT `fk_user_course_last_chapter` FOREIGN KEY (`last_chapter_id`) REFERENCES `course_chapter` (`chapter_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_course_last_video` FOREIGN KEY (`last_video_id`) REFERENCES `course_video` (`video_id`) ON DELETE SET NULL,
  CONSTRAINT `user_course_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `user_course_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户课程关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_course`
--

/*!40000 ALTER TABLE `user_course` DISABLE KEYS */;
INSERT INTO `user_course` VALUES (1,4,1,'2025-11-28 21:06:48',35,'2025-11-28 21:06:48',0,'2025-11-28 13:06:48','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(2,4,4,'2025-11-28 21:06:48',60,'2025-11-28 21:06:48',0,'2025-11-28 13:06:48','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(3,5,1,'2025-11-28 21:06:48',80,'2025-11-28 21:06:48',0,'2025-11-28 13:06:48','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(4,5,3,'2025-11-28 21:06:48',45,'2025-11-28 21:06:48',0,'2025-11-28 13:06:48','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(6,5,5,'2025-11-28 23:12:19',85,'2025-11-28 23:12:19',0,'2025-11-28 15:12:19','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(7,6,2,'2025-11-28 23:16:26',0,NULL,0,'2025-11-28 15:16:26','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(8,6,1,'2025-11-28 23:20:13',0,NULL,0,'2025-11-28 15:20:13','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(9,6,3,'2025-11-28 23:28:59',0,NULL,0,'2025-11-28 15:28:59','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(10,8,1,'2025-11-29 14:27:31',0,NULL,0,'2025-11-29 06:27:31','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(11,11,10,'2025-11-30 14:53:40',0,NULL,0,'2025-11-30 06:53:40','2025-12-01 07:54:14',0,NULL,NULL,0,NULL,NULL,0),(16,14,5,'2025-12-01 15:34:20',45,'2025-12-01 18:00:00',1,'2025-12-01 07:34:20','2025-12-06 12:27:59',120,NULL,NULL,0,NULL,NULL,1),(21,14,2,'2025-12-01 15:51:51',45,NULL,0,'2025-12-01 07:51:51','2025-12-01 08:53:38',0,NULL,NULL,0,NULL,NULL,1),(22,14,1,'2025-12-01 16:53:38',65,NULL,0,'2025-12-01 08:53:38','2025-12-01 12:38:02',0,NULL,NULL,0,NULL,NULL,0),(23,14,3,'2025-12-01 16:53:38',80,NULL,0,'2025-12-01 08:53:38','2025-12-01 16:00:15',0,NULL,NULL,0,NULL,NULL,1),(26,14,8,'2025-12-02 00:00:07',0,NULL,0,'2025-12-01 16:00:07','2025-12-01 16:00:07',0,NULL,NULL,0,NULL,NULL,1),(27,14,7,'2025-12-02 00:00:19',0,NULL,0,'2025-12-01 16:00:19','2025-12-01 16:00:19',0,NULL,NULL,0,NULL,NULL,1),(28,14,15,'2025-12-02 00:00:25',0,NULL,0,'2025-12-01 16:00:25','2025-12-08 11:30:57',0,NULL,NULL,0,NULL,NULL,0),(31,14,6,'2025-12-06 21:47:26',0,NULL,0,'2025-12-06 13:47:26','2025-12-06 13:47:26',0,NULL,NULL,0,NULL,NULL,1),(32,101,17,'2025-12-08 15:42:38',85,NULL,0,'2025-12-08 07:42:38','2025-12-08 07:42:38',4500,NULL,NULL,0,NULL,NULL,1),(33,101,18,'2025-12-08 15:42:38',70,NULL,0,'2025-12-08 07:42:38','2025-12-08 07:42:38',3600,NULL,NULL,0,NULL,NULL,1),(34,102,17,'2025-12-08 15:42:38',90,NULL,0,'2025-12-08 07:42:38','2025-12-08 07:42:38',5000,NULL,NULL,0,NULL,NULL,1),(35,102,19,'2025-12-08 15:42:38',80,NULL,0,'2025-12-08 07:42:38','2025-12-08 07:42:38',4200,NULL,NULL,0,NULL,NULL,1),(36,103,18,'2025-12-08 15:42:38',65,NULL,0,'2025-12-08 07:42:38','2025-12-08 07:42:38',3200,NULL,NULL,0,NULL,NULL,1),(37,103,20,'2025-12-08 15:42:38',75,NULL,0,'2025-12-08 07:42:38','2025-12-08 07:42:38',3800,NULL,NULL,0,NULL,NULL,1),(38,104,17,'2025-12-08 15:42:38',95,NULL,0,'2025-12-08 07:42:38','2025-12-08 07:42:38',5200,NULL,NULL,0,NULL,NULL,1),(39,104,19,'2025-12-08 15:42:38',85,NULL,0,'2025-12-08 07:42:38','2025-12-08 07:42:38',4600,NULL,NULL,0,NULL,NULL,1),(41,6,4,'2025-11-25 10:00:00',75,'2025-12-10 15:30:00',1,'2025-12-11 09:49:29','2025-12-11 09:49:29',180,NULL,NULL,0,NULL,NULL,1),(42,6,7,'2025-11-28 14:00:00',60,'2025-12-09 20:00:00',0,'2025-12-11 09:49:29','2025-12-11 09:49:29',120,NULL,NULL,0,NULL,NULL,1),(43,6,11,'2025-12-01 09:00:00',85,'2025-12-11 10:00:00',1,'2025-12-11 09:49:29','2025-12-11 09:49:29',240,NULL,NULL,0,NULL,NULL,1),(44,7,8,'2025-11-22 11:00:00',90,'2025-12-10 18:00:00',1,'2025-12-11 09:49:29','2025-12-11 09:49:29',300,NULL,NULL,0,NULL,NULL,1),(45,7,14,'2025-11-30 16:00:00',70,'2025-12-09 14:00:00',0,'2025-12-11 09:49:29','2025-12-11 09:49:29',150,NULL,NULL,0,NULL,NULL,1),(46,7,16,'2025-12-03 13:00:00',55,'2025-12-08 16:00:00',0,'2025-12-11 09:49:29','2025-12-11 09:49:29',90,NULL,NULL,0,NULL,NULL,1),(47,8,6,'2025-11-20 08:00:00',95,'2025-12-11 08:00:00',1,'2025-12-11 09:49:29','2025-12-11 09:49:29',360,NULL,NULL,0,NULL,NULL,1),(48,8,13,'2025-11-25 12:00:00',80,'2025-12-10 19:00:00',1,'2025-12-11 09:49:29','2025-12-11 09:49:29',200,NULL,NULL,0,NULL,NULL,1),(49,8,12,'2025-12-02 10:00:00',45,'2025-12-07 15:00:00',0,'2025-12-11 09:49:29','2025-12-11 09:49:29',80,NULL,NULL,0,NULL,NULL,1),(50,9,15,'2025-11-18 14:00:00',88,'2025-12-11 11:00:00',1,'2025-12-11 09:49:29','2025-12-11 09:49:29',280,NULL,NULL,0,NULL,NULL,1),(51,9,16,'2025-11-28 09:00:00',65,'2025-12-09 13:00:00',0,'2025-12-11 09:49:29','2025-12-11 09:49:29',140,NULL,NULL,0,NULL,NULL,1),(52,10,17,'2025-11-15 16:00:00',92,'2025-12-10 20:00:00',1,'2025-12-11 09:49:29','2025-12-11 09:49:29',320,NULL,NULL,0,NULL,NULL,1),(53,10,18,'2025-11-22 11:00:00',78,'2025-12-09 17:00:00',1,'2025-12-11 09:49:29','2025-12-11 09:49:29',210,NULL,NULL,0,NULL,NULL,1),(54,105,6,'2025-11-30 10:00:00',70,'2025-12-10 16:00:00',1,'2025-12-11 09:49:29','2025-12-11 09:49:29',180,NULL,NULL,0,NULL,NULL,1),(55,105,14,'2025-12-02 14:00:00',55,'2025-12-08 12:00:00',0,'2025-12-11 09:49:29','2025-12-11 09:49:29',100,NULL,NULL,0,NULL,NULL,1),(56,106,12,'2025-12-01 09:00:00',60,'2025-12-09 15:00:00',0,'2025-12-11 09:49:29','2025-12-11 09:49:29',120,NULL,NULL,0,NULL,NULL,1),(57,106,20,'2025-12-03 11:00:00',40,'2025-12-07 18:00:00',0,'2025-12-11 09:49:29','2025-12-11 09:49:29',80,NULL,NULL,0,NULL,NULL,1);
/*!40000 ALTER TABLE `user_course` ENABLE KEYS */;

--
-- Table structure for table `user_detail`
--

DROP TABLE IF EXISTS `user_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_detail` (
  `user_detail_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `phone` char(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `occupation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `learning_goal` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `social_links` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_detail_id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `phone` (`phone`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `user_detail_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_detail`
--

/*!40000 ALTER TABLE `user_detail` DISABLE KEYS */;
INSERT INTO `user_detail` VALUES (1,13,NULL,'1111',NULL,NULL,NULL,NULL,NULL,'2025-11-30 07:53:58','2025-11-30 07:54:01'),(2,14,NULL,'今天的每一页笔记，都在为明天的自己铺路；现在的每一道难题，都在雕刻未来从容不迫的底气。',NULL,NULL,NULL,NULL,NULL,'2025-12-01 12:38:35','2025-12-09 02:52:02'),(3,1,NULL,'热爱学习的程序员',NULL,NULL,NULL,NULL,NULL,'2025-12-05 16:00:39','2025-12-05 16:00:39'),(4,2,NULL,'前端开发工程师',NULL,NULL,NULL,NULL,NULL,'2025-12-05 16:00:39','2025-12-05 16:00:39'),(5,3,NULL,'后端开发工程师',NULL,NULL,NULL,NULL,NULL,'2025-12-05 16:00:39','2025-12-05 16:00:39'),(6,4,NULL,'全栈开发工程师',NULL,NULL,NULL,NULL,NULL,'2025-12-05 16:00:39','2025-12-05 16:00:39'),(12,6,NULL,'热爱编程的大学生，专注前端开发','学生','成为全栈工程师','北京',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(13,7,NULL,'数学专业研究生，喜欢分享学习心得','研究生','考研数学130+','上海',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(14,8,NULL,'英语专业学生，四六级高分通过者','学生','英语六级600+','广州',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(15,9,NULL,'公务员考试备考者，目标上岸','待业','公务员考试上岸','深圳',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(16,10,NULL,'计算机专业学生，算法爱好者','学生','进入大厂工作','杭州',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(17,101,NULL,'数据科学专业学生','学生','掌握机器学习','成都',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(18,102,NULL,'前端开发实习生','实习生','精通React开发','武汉',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(19,103,NULL,'后端开发工程师','工程师','系统架构师','西安',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(20,104,NULL,'算法竞赛选手','学生','ACM金牌','南京',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(21,105,NULL,'英语教育专业','学生','英语教师资格证','重庆',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52'),(22,106,NULL,'网络工程专业','学生','网络安全专家','天津',NULL,NULL,'2025-12-11 09:48:52','2025-12-11 09:48:52');
/*!40000 ALTER TABLE `user_detail` ENABLE KEYS */;

--
-- Table structure for table `user_enrollment`
--

DROP TABLE IF EXISTS `user_enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_enrollment` (
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
  CONSTRAINT `user_enrollment_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `user_enrollment_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_enrollment`
--

/*!40000 ALTER TABLE `user_enrollment` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_enrollment` ENABLE KEYS */;

--
-- Table structure for table `video_ai_quiz`
--

DROP TABLE IF EXISTS `video_ai_quiz`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `video_ai_quiz` (
  `quiz_id` int NOT NULL AUTO_INCREMENT,
  `video_id` int NOT NULL,
  `question_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`quiz_id`),
  KEY `idx_video` (`video_id`),
  CONSTRAINT `video_ai_quiz_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `course_video` (`video_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_ai_quiz`
--

/*!40000 ALTER TABLE `video_ai_quiz` DISABLE KEYS */;
/*!40000 ALTER TABLE `video_ai_quiz` ENABLE KEYS */;

--
-- Table structure for table `video_ai_quiz_option`
--

DROP TABLE IF EXISTS `video_ai_quiz_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `video_ai_quiz_option` (
  `option_id` int NOT NULL AUTO_INCREMENT,
  `quiz_id` int NOT NULL,
  `option_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_correct` tinyint DEFAULT '0',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`option_id`),
  KEY `idx_quiz` (`quiz_id`),
  KEY `idx_correct` (`is_correct`),
  CONSTRAINT `video_ai_quiz_option_ibfk_1` FOREIGN KEY (`quiz_id`) REFERENCES `video_ai_quiz` (`quiz_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_ai_quiz_option`
--

/*!40000 ALTER TABLE `video_ai_quiz_option` DISABLE KEYS */;
/*!40000 ALTER TABLE `video_ai_quiz_option` ENABLE KEYS */;

--
-- Table structure for table `video_ai_summary`
--

DROP TABLE IF EXISTS `video_ai_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `video_ai_summary` (
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
  CONSTRAINT `video_ai_summary_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `course_video` (`video_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_ai_summary`
--

/*!40000 ALTER TABLE `video_ai_summary` DISABLE KEYS */;
/*!40000 ALTER TABLE `video_ai_summary` ENABLE KEYS */;

--
-- Table structure for table `video_comment`
--

DROP TABLE IF EXISTS `video_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `video_comment` (
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
  CONSTRAINT `video_comment_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `course_video` (`video_id`) ON DELETE CASCADE,
  CONSTRAINT `video_comment_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `video_comment_ibfk_3` FOREIGN KEY (`parent_comment_id`) REFERENCES `video_comment` (`comment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_comment`
--

/*!40000 ALTER TABLE `video_comment` DISABLE KEYS */;
INSERT INTO `video_comment` VALUES (1,1,4,NULL,'讲解很清晰，环境已经成功搭好了。',5,'2025-11-28 21:06:55','2025-11-28 21:06:55'),(2,1,5,1,'同感，期待后面的内容！',4,'2025-11-28 21:06:55','2025-11-29 17:12:42'),(3,2,4,NULL,'循环语句的示例非常实用。',2,'2025-11-28 21:06:55','2025-11-28 21:06:55'),(4,7,5,NULL,'机器学习部分对初学者很友好。',4,'2025-11-28 21:06:55','2025-11-28 21:06:55'),(5,3,4,NULL,'语法规则这部分需要多练习才能熟练掌握。',6,'2025-11-28 23:12:17','2025-11-28 23:12:17'),(6,11,5,NULL,'JavaScript的历史发展很有趣，了解背景有助于学习。',9,'2025-11-28 23:12:17','2025-11-28 23:12:17'),(7,12,4,NULL,'变量声明的几种方式讲得很清楚。',7,'2025-11-28 23:12:17','2025-11-28 23:12:17'),(11,3,1,5,'很好',0,'2025-11-28 23:16:41','2025-11-28 23:16:41'),(12,1,1,NULL,'很棒',0,'2025-11-28 23:16:58','2025-11-28 23:16:58'),(13,1,6,NULL,'你好',1,'2025-11-28 23:26:34','2025-11-28 23:26:51'),(14,1,6,13,'很棒',0,'2025-11-28 23:26:42','2025-11-28 23:26:42'),(15,14,11,NULL,'test',0,'2025-11-30 14:54:36','2025-11-30 14:54:36'),(16,23,14,NULL,'你好',0,'2025-12-06 23:47:43','2025-12-06 23:47:43'),(17,23,14,NULL,'你好',0,'2025-12-06 23:49:25','2025-12-06 23:49:25'),(18,23,14,NULL,'是',0,'2025-12-07 00:02:57','2025-12-07 00:02:57');
/*!40000 ALTER TABLE `video_comment` ENABLE KEYS */;

--
-- Dumping routines for database 'mzcourse'
--

--
-- Final view structure for view `student_behavior_summary`
--

/*!50001 DROP VIEW IF EXISTS `student_behavior_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `student_behavior_summary` AS select `u`.`user_id` AS `user_id`,`u`.`user_name` AS `user_name`,count(distinct `uc`.`course_id`) AS `enrolled_courses`,avg(`cp`.`completion_rate`) AS `avg_completion_rate`,avg(`cp`.`mastery_level`) AS `avg_mastery_level`,sum(`fa`.`focus_duration`) AS `total_focus_time`,count(distinct cast(`ll`.`timestamp` as date)) AS `active_days`,max(`cp`.`updated_at`) AS `last_analysis_time` from ((((`user` `u` left join `user_course` `uc` on((`u`.`user_id` = `uc`.`user_id`))) left join `student_course_performance` `cp` on(((`u`.`user_id` = `cp`.`user_id`) and (`uc`.`course_id` = `cp`.`course_id`)))) left join `student_focus_analysis` `fa` on((`u`.`user_id` = `fa`.`user_id`))) left join `student_learning_log` `ll` on(((`u`.`user_id` = `ll`.`user_id`) and (`ll`.`timestamp` >= (now() - interval 30 day))))) where (`u`.`role` = 'learner') group by `u`.`user_id`,`u`.`user_name` */;
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

-- Dump completed on 2025-12-11 17:50:29
