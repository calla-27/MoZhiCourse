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
  `achievement_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `condition_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `condition_value` int DEFAULT NULL,
  `icon_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment_like`
--

/*!40000 ALTER TABLE `comment_like` DISABLE KEYS */;
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
  `message_type` enum('private','team','room','system') COLLATE utf8mb4_unicode_ci DEFAULT 'private',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_message`
--

/*!40000 ALTER TABLE `community_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `community_message` ENABLE KEYS */;

--
-- Table structure for table `community_post`
--

DROP TABLE IF EXISTS `community_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_post` (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_id` int NOT NULL,
  `category` enum('discussion','question','sharing','announcement') COLLATE utf8mb4_unicode_ci DEFAULT 'discussion',
  `course_id` int DEFAULT NULL,
  `likes_count` int DEFAULT '0',
  `comments_count` int DEFAULT '0',
  `views_count` int DEFAULT '0',
  `status` enum('published','draft','deleted') COLLATE utf8mb4_unicode_ci DEFAULT 'published',
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_post`
--

/*!40000 ALTER TABLE `community_post` DISABLE KEYS */;
INSERT INTO `community_post` VALUES (1,'Java学习心得分享','经过一个月的学习，我终于完成了2026版AI新课的Java课程。这门课程真的很棒，从基础到AI应用都讲得非常清楚。\n\n特别是AI算法实现那部分，老师用很多实例来讲解，让我对机器学习有了更深的理解。推荐系统实战项目也很有意思，跟着做完之后感觉收获满满。\n\n给正在学习的同学几点建议：\n1. 一定要跟着敲代码，不要只看视频\n2. 每个章节的练习题都要做\n3. 实战项目一定要自己独立完成一遍\n\n加油！',6,'sharing',1,25,12,156,'published',0,'[\"Java\", \"AI\", \"学习心得\", \"编程\"]','2025-11-29 10:30:00','2025-11-29 10:30:00'),(2,'高数期末复习攻略 - 3小时速成真的有用！','马上就要期末考试了，分享一下我用3小时速成课程复习高数的经验。\n\n**课程优点：**\n- 讲解通俗易懂，不会让人听不懂\n- 重点突出，都是考试常考的内容\n- 例题很典型，掌握了就能应对大部分题目\n\n**我的复习计划：**\n第1小时：极限与连续（重点是求极限的方法）\n第2小时：导数与微分（各种求导法则要熟练）\n第3小时：积分学（定积分的应用很重要）\n\n**额外建议：**\n看完视频后一定要做题！我整理了一些常考题型，需要的同学可以留言。\n\n祝大家期末都能过！💪',7,'sharing',2,42,18,203,'published',1,'[\"高数\", \"期末复习\", \"学习方法\", \"考试\"]','2025-11-29 11:00:00','2025-11-29 11:00:00'),(3,'英语四级听力如何突破？求大神指点','听力一直是我的弱项，每次做题都错很多。最近在学四级听力原文训练这门课，感觉有点进步，但还是不够。\n\n**我的问题：**\n1. 短对话总是听不清关键信息\n2. 长对话容易走神，后面就跟不上了\n3. 短文听力速度太快，来不及反应\n\n**已经尝试的方法：**\n- 每天听1小时\n- 跟读练习\n- 做真题\n\n但效果不明显，有没有学长学姐分享一下经验？特别是如何提高听力速度和抓关键词的能力？\n\n谢谢大家！🙏',8,'question',3,28,15,187,'published',0,'[\"英语\", \"四级\", \"听力\", \"求助\"]','2025-11-29 12:15:00','2025-11-29 12:15:00'),(4,'申论写作模板分享 - 小马哥课程笔记整理','学完小马哥的申论系统课，整理了一些写作模板和技巧，分享给准备公考的同学。\n\n**归纳概括题模板：**\n根据材料X，主要问题有：一是...；二是...；三是...。\n\n**综合分析题思路：**\n1. 解释含义\n2. 分析原因/影响\n3. 提出对策\n4. 总结升华\n\n**申发论述题结构：**\n开头：引出话题+亮明观点\n分论点1：理论论证\n分论点2：事实论证  \n分论点3：对比论证\n结尾：总结全文+升华主题\n\n**小马哥强调的重点：**\n- 政府思维很重要\n- 材料分析要全面\n- 语言表达要规范\n\n完整笔记太长了，需要的同学可以私信我。希望大家都能考出好成绩！✊',9,'sharing',7,35,20,245,'published',0,'[\"申论\", \"公考\", \"写作模板\", \"笔记\"]','2025-11-29 13:30:00','2025-11-29 13:30:00'),(5,'Python数据分析项目实战经验分享','刚完成了销售数据分析项目，踩了不少坑，分享一些经验给大家。\n\n**项目难点：**\n1. 数据清洗：缺失值和异常值的处理\n2. 数据可视化：选择合适的图表类型\n3. 结果解读：从数据中得出有价值的结论\n\n**我的解决方案：**\n- 缺失值：根据业务逻辑选择填充或删除\n- 异常值：用箱线图识别，结合实际情况处理\n- 可视化：多尝试几种图表，选最直观的\n\n**推荐的学习资源：**\n- Pandas官方文档\n- Matplotlib画廊\n- Kaggle上的实战项目\n\n这门课程的项目设计很好，跟着做完真的能学到很多。建议大家不要只看视频，一定要自己动手做！\n\n有问题欢迎交流～',6,'sharing',9,22,10,134,'published',0,'[\"Python\", \"数据分析\", \"项目实战\", \"经验分享\"]','2025-11-29 14:30:00','2025-11-29 14:30:00'),(6,'Web前端学习路线推荐','作为一个刚入门的前端小白，分享一下我的学习路线，希望对大家有帮助。\n\n**第一阶段：基础（1-2个月）**\n- HTML5：语义化标签、表单\n- CSS3：布局（Flexbox、Grid）、动画\n- JavaScript：ES6基础语法\n\n**第二阶段：进阶（2-3个月）**\n- JavaScript深入：闭包、原型链、异步\n- 前端框架：Vue.js或React\n- 工程化：Webpack、Git\n\n**第三阶段：实战（持续）**\n- 做项目！做项目！做项目！\n- 参与开源项目\n- 写技术博客\n\n**学习建议：**\n1. 不要贪多，一个一个学\n2. 多写代码，少看视频\n3. 遇到问题先自己思考\n4. 加入学习社群，互相帮助\n\n一起加油！💪',10,'sharing',10,18,8,98,'published',0,'[\"前端\", \"学习路线\", \"Web开发\", \"新手\"]','2025-11-29 15:00:00','2025-11-29 15:00:00'),(7,'清华公考140+方法论真的有用吗？','看到清华大学的公考课程，一周达到140+，感觉有点不可思议。有学过的同学吗？效果怎么样？\n\n我现在行测大概120分左右，申论70分，想提高到140+。\n\n**我的疑问：**\n1. 一周时间真的够吗？\n2. 适合什么基础的人？\n3. 主要讲什么内容？\n\n准备报名，但有点犹豫，希望学过的同学给点建议。谢谢！',7,'question',8,15,9,76,'published',0,'[\"公考\", \"清华\", \"学习方法\", \"咨询\"]','2025-11-29 16:00:00','2025-11-29 16:00:00'),(8,'机器学习算法学习笔记 - 持续更新','开始学习机器学习算法精讲这门课，打算把学习笔记分享出来，也算是督促自己坚持学习。\n\n**第一周：机器学习概述**\n- 什么是机器学习\n- 监督学习 vs 非监督学习\n- 常见算法分类\n\n**第二周：线性回归**\n- 算法原理\n- 损失函数\n- 梯度下降\n- Python实现\n\n后续会继续更新，欢迎一起学习的同学交流！\n\n#机器学习 #学习笔记',6,'sharing',11,12,6,52,'published',0,'[\"机器学习\", \"算法\", \"学习笔记\", \"AI\"]','2025-11-29 17:00:00','2025-11-29 17:00:00');
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
  `course_overview` text COLLATE utf8mb4_unicode_ci COMMENT '课程概述',
  `learning_objectives` json DEFAULT NULL COMMENT '学习目标列表',
  `course_features` json DEFAULT NULL COMMENT '课程特色列表',
  PRIMARY KEY (`course_id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_teacher` (`teacher_user_id`),
  KEY `idx_difficulty` (`difficulty_level`),
  CONSTRAINT `course_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `course_category` (`category_id`),
  CONSTRAINT `course_ibfk_2` FOREIGN KEY (`teacher_user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course`
--

/*!40000 ALTER TABLE `course` DISABLE KEYS */;
INSERT INTO `course` VALUES (1,'2026版AI新课 - Java入门到大神','从零基础到高级应用，全面掌握Java编程与AI技术结合。包含AI应用开发、算法实现和实战项目。','',3,1,'beginner',7200,1,'2025-11-30 13:52:00','2025-11-30 15:12:48',2580,4.8,215,'2025-11-29 21:52:00','2025-11-30 07:12:48','2026年最新版Java课程，结合人工智能技术，从基础语法到AI应用开发，帮助学员掌握Java编程的同时了解AI技术在实际项目中的应用。','[\"掌握Java基础语法和面向对象编程\", \"学习Java高级特性和框架应用\", \"了解AI算法在Java中的实现\", \"完成AI+Java实战项目\", \"掌握现代Java开发工具和技术栈\"]','[{\"icon\": \"fas fa-robot\", \"title\": \"AI技术融合\", \"description\": \"将人工智能技术与Java开发完美结合\"}, {\"icon\": \"fas fa-project-diagram\", \"title\": \"实战项目\", \"description\": \"通过真实AI项目提升编程能力\"}, {\"icon\": \"fas fa-rocket\", \"title\": \"2026最新版\", \"description\": \"紧跟技术发展趋势的最新课程内容\"}, {\"icon\": \"fas fa-infinity\", \"title\": \"从零到大神\", \"description\": \"完整的学习路径，适合各个水平的学员\"}]'),(2,'高等数学(上) - 3小时速成','超级通俗易懂的高等数学上册速成课程，3小时掌握核心概念，期末不挂科。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/13408799812653464.jpeg',7,2,'beginner',180,1,'2025-11-30 13:52:00','2025-11-30 15:15:13',3420,4.9,328,'2025-11-29 21:52:00','2025-11-30 07:15:13','专为大学生设计的高等数学速成课程，用最通俗易懂的方式讲解复杂的数学概念，帮助学生快速理解并通过期末考试。','[\"掌握极限的概念和计算方法\", \"理解导数的定义和应用\", \"学会积分的基本计算\", \"掌握微分方程的基础知识\", \"能够解决常见的高数题型\"]','[{\"icon\": \"fas fa-clock\", \"title\": \"3小时速成\", \"description\": \"高效学习，快速掌握核心知识点\"}, {\"icon\": \"fas fa-smile\", \"title\": \"通俗易懂\", \"description\": \"用最简单的语言解释复杂概念\"}, {\"icon\": \"fas fa-shield-alt\", \"title\": \"期末保障\", \"description\": \"针对期末考试，确保不挂科\"}, {\"icon\": \"fas fa-lightning-bolt\", \"title\": \"速成方法\", \"description\": \"独特的学习方法，事半功倍\"}]'),(3,'英语四级听力原文训练','专注于英语四级听力部分的原文训练，提高听力理解能力和应试技巧。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/%E5%B0%81%E9%9D%A2.jpeg',8,3,'intermediate',600,1,'2025-11-30 13:52:00','2025-11-30 14:49:15',2150,4.6,186,'2025-11-29 21:52:00','2025-11-30 06:49:15','针对大学英语四级考试听力部分的专项训练课程，通过大量原文练习和技巧讲解，帮助学生显著提升听力成绩。','[\"掌握四级听力考试题型和技巧\", \"提高英语听力理解能力\", \"熟悉常见听力场景和词汇\", \"学会快速抓取关键信息\", \"达到四级听力及格水平\"]','[{\"icon\": \"fas fa-headphones\", \"title\": \"专项训练\", \"description\": \"专注听力部分的深度训练\"}, {\"icon\": \"fas fa-file-alt\", \"title\": \"原文练习\", \"description\": \"大量真题原文材料练习\"}, {\"icon\": \"fas fa-bullseye\", \"title\": \"应试技巧\", \"description\": \"针对性的考试技巧指导\"}, {\"icon\": \"fas fa-chart-line\", \"title\": \"快速提升\", \"description\": \"短期内显著提高听力成绩\"}]'),(4,'高数(微积分) - 上期未速成','针对微积分部分的深度讲解，解决上期课程中未完全掌握的难点问题。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E9%AB%98%E6%95%B01.jpg',7,2,'intermediate',300,1,'2025-11-30 13:52:00','2025-11-30 14:49:17',1890,4.5,142,'2025-11-29 21:52:00','2025-11-30 06:49:17','专门针对微积分学习中的难点和易错点进行深入讲解，帮助学生彻底理解微积分的核心概念和计算方法。','[\"深入理解微积分的基本概念\", \"掌握复杂函数的求导技巧\", \"学会积分的高级计算方法\", \"解决微积分应用题\", \"提高数学思维能力\"]','[{\"icon\": \"fas fa-microscope\", \"title\": \"深度讲解\", \"description\": \"针对难点进行深入分析\"}, {\"icon\": \"fas fa-puzzle-piece\", \"title\": \"查漏补缺\", \"description\": \"解决之前学习中的遗留问题\"}, {\"icon\": \"fas fa-brain\", \"title\": \"思维训练\", \"description\": \"培养数学逻辑思维能力\"}, {\"icon\": \"fas fa-tools\", \"title\": \"实用技巧\", \"description\": \"掌握解题的实用方法和技巧\"}]'),(5,'1小时教你学会申论','公务员考试申论科目的快速入门课程，1小时掌握申论写作的核心技巧。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA.jpg',9,4,'beginner',60,1,'2025-11-30 13:52:00','2025-11-30 14:49:18',3680,4.7,295,'2025-11-29 21:52:00','2025-11-30 06:49:18','专为公务员考试申论科目设计的快速入门课程，通过系统的方法论和实用技巧，帮助考生快速掌握申论写作要领。','[\"掌握申论考试的基本题型\", \"学会材料分析和要点提取\", \"掌握申论写作的基本结构\", \"学习政府思维和表达方式\", \"提高申论答题效率\"]','[{\"icon\": \"fas fa-stopwatch\", \"title\": \"1小时速成\", \"description\": \"高效学习，快速入门申论\"}, {\"icon\": \"fas fa-pen-fancy\", \"title\": \"写作技巧\", \"description\": \"掌握申论写作的核心方法\"}, {\"icon\": \"fas fa-government\", \"title\": \"政府思维\", \"description\": \"培养公务员思维模式\"}, {\"icon\": \"fas fa-target\", \"title\": \"应试导向\", \"description\": \"针对考试要求的实用指导\"}]'),(6,'大学英语六级 - 20小时期末突击','免费优质的英语六级突击课程，20小时高效复习，通俗易懂，干货满满。','',8,3,'intermediate',1200,1,'2025-11-30 13:52:00','2025-11-30 15:14:00',4250,4.9,412,'2025-11-29 21:52:00','2025-11-30 07:14:00','专为大学英语六级考试设计的突击复习课程，涵盖听力、阅读、翻译、写作四大板块，帮助学生在短时间内显著提升成绩。','[\"掌握六级考试各题型技巧\", \"提高英语综合运用能力\", \"学会高效的复习方法\", \"掌握六级核心词汇和语法\", \"达到六级考试通过标准\"]','[{\"icon\": \"fas fa-gift\", \"title\": \"完全免费\", \"description\": \"高质量免费课程，无任何隐藏费用\"}, {\"icon\": \"fas fa-gem\", \"title\": \"干货满满\", \"description\": \"纯干货内容，没有废话\"}, {\"icon\": \"fas fa-rocket\", \"title\": \"20小时突击\", \"description\": \"高效复习计划，短期快速提升\"}, {\"icon\": \"fas fa-heart\", \"title\": \"通俗易懂\", \"description\": \"用最简单的方式讲解复杂知识\"}]'),(7,'申论系统课 - 小马哥','由知名讲师小马哥主讲的申论系统课程，全面提升申论写作和分析能力。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA2.jpg',9,4,'advanced',1800,1,'2025-11-30 13:52:00','2025-11-30 14:49:19',2940,4.8,268,'2025-11-29 21:52:00','2025-11-30 06:49:19','由资深公考专家小马哥精心打造的申论系统课程，从基础理论到高级技巧，全方位提升申论应试能力。','[\"系统掌握申论理论体系\", \"学会深层次材料分析\", \"掌握高分申论写作技巧\", \"培养政策分析思维\", \"达到申论高分水平\"]','[{\"icon\": \"fas fa-user-tie\", \"title\": \"名师授课\", \"description\": \"知名讲师小马哥亲自授课\"}, {\"icon\": \"fas fa-layer-group\", \"title\": \"系统课程\", \"description\": \"完整的申论学习体系\"}, {\"icon\": \"fas fa-medal\", \"title\": \"高分保障\", \"description\": \"针对高分的专业指导\"}, {\"icon\": \"fas fa-graduation-cap\", \"title\": \"专业权威\", \"description\": \"多年公考培训经验积累\"}]'),(8,'清华大学 - 如何逗自己一周达到《公考140+》','清华大学出品的公务员考试高分秘籍，一周内掌握140+分数的核心方法。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E8%A1%8C%E6%B5%8B1.jpg',9,5,'advanced',420,1,'2025-11-30 13:52:00','2025-11-30 14:49:20',1850,4.7,156,'2025-11-29 21:52:00','2025-11-30 06:49:20','清华大学权威出品的公务员考试高分课程，汇集顶尖学府的学习方法和应试技巧，帮助考生在短时间内实现分数的质的飞跃。','[\"掌握高效的学习方法\", \"学会时间管理和复习规划\", \"掌握各科目高分技巧\", \"培养应试心理素质\", \"实现公考140+高分目标\"]','[{\"icon\": \"fas fa-university\", \"title\": \"清华出品\", \"description\": \"清华大学权威课程品质保证\"}, {\"icon\": \"fas fa-trophy\", \"title\": \"140+高分\", \"description\": \"针对高分目标的专业指导\"}, {\"icon\": \"fas fa-calendar-week\", \"title\": \"一周速成\", \"description\": \"高效学习方法，快速提升\"}, {\"icon\": \"fas fa-star\", \"title\": \"珍贵资源\", \"description\": \"难得一见的优质学习资源\"}]'),(9,'Python数据分析实战','使用Python进行数据分析，掌握Pandas、NumPy等核心库的使用。','',2,1,'intermediate',2400,1,'2025-11-30 14:00:00','2025-11-30 15:12:48',1580,4.6,125,'2025-11-29 22:00:00','2025-11-30 07:12:48','深入学习Python数据分析技术，从数据清洗到可视化，掌握完整的数据分析流程。','[\"掌握Pandas数据处理技巧\", \"学会NumPy数组运算\", \"掌握数据可视化方法\", \"完成真实数据分析项目\", \"学习数据清洗和预处理\"]','[{\"icon\": \"fas fa-chart-pie\", \"title\": \"实战导向\", \"description\": \"真实数据集实战练习\"}, {\"icon\": \"fas fa-database\", \"title\": \"数据处理\", \"description\": \"完整的数据分析流程\"}, {\"icon\": \"fas fa-eye\", \"title\": \"可视化\", \"description\": \"精美的数据可视化展示\"}, {\"icon\": \"fas fa-briefcase\", \"title\": \"职业技能\", \"description\": \"企业级数据分析能力\"}]'),(10,'Web前端全栈开发','HTML、CSS、JavaScript全栈开发，打造现代化Web应用。','',1,2,'beginner',3600,1,'2025-11-30 14:00:00','2025-11-30 15:13:14',2350,4.8,198,'2025-11-29 22:00:00','2025-11-30 07:13:14','从零开始学习Web前端开发，掌握HTML5、CSS3、JavaScript ES6+等现代前端技术。','[\"掌握HTML5语义化标签\", \"精通CSS3布局和动画\", \"熟练使用JavaScript ES6+\", \"学习Vue.js/React框架\", \"完成完整Web项目\"]','[{\"icon\": \"fas fa-laptop-code\", \"title\": \"全栈技能\", \"description\": \"前后端技术全覆盖\"}, {\"icon\": \"fas fa-mobile-alt\", \"title\": \"响应式设计\", \"description\": \"适配各种设备屏幕\"}, {\"icon\": \"fas fa-rocket\", \"title\": \"现代技术\", \"description\": \"最新前端技术栈\"}, {\"icon\": \"fas fa-users\", \"title\": \"项目实战\", \"description\": \"真实企业级项目\"}]'),(11,'机器学习算法精讲','深入理解机器学习算法原理，从理论到实践全面掌握。','https://via.placeholder.com/400x250/4facfe/ffffff?text=ML+Algorithms',3,1,'advanced',3000,1,'2025-11-30 14:00:00','2025-11-30 14:00:00',980,4.7,87,'2025-11-29 22:00:00','2025-11-29 22:00:00','系统学习机器学习核心算法，包括监督学习、非监督学习和强化学习等。','[\"理解机器学习基本原理\", \"掌握常用算法实现\", \"学会模型评估和优化\", \"完成机器学习项目\", \"了解深度学习基础\"]','[{\"icon\": \"fas fa-brain\", \"title\": \"算法精讲\", \"description\": \"深入讲解算法原理\"}, {\"icon\": \"fas fa-code\", \"title\": \"代码实现\", \"description\": \"手写算法代码实现\"}, {\"icon\": \"fas fa-chart-line\", \"title\": \"模型优化\", \"description\": \"模型调优技巧\"}, {\"icon\": \"fas fa-project-diagram\", \"title\": \"项目实战\", \"description\": \"真实ML项目经验\"}]'),(12,'大学物理速成','大学物理核心知识点速成，轻松应对期末考试。','https://via.placeholder.com/400x250/00d2ff/ffffff?text=Physics',7,2,'beginner',240,1,'2025-11-30 14:00:00','2025-11-30 14:00:00',1250,4.5,95,'2025-11-29 22:00:00','2025-11-29 22:00:00','涵盖力学、电磁学、光学等核心内容，用通俗易懂的方式讲解物理概念。','[\"掌握牛顿力学基础\", \"理解电磁学原理\", \"学习光学基本知识\", \"掌握热力学定律\", \"能够解决物理习题\"]','[{\"icon\": \"fas fa-atom\", \"title\": \"核心知识\", \"description\": \"聚焦考试重点内容\"}, {\"icon\": \"fas fa-calculator\", \"title\": \"解题技巧\", \"description\": \"快速解题方法\"}, {\"icon\": \"fas fa-clock\", \"title\": \"高效学习\", \"description\": \"短时间掌握要点\"}, {\"icon\": \"fas fa-check-circle\", \"title\": \"考试保障\", \"description\": \"针对期末考试设计\"}]'),(13,'英语六级阅读理解突破','专项训练英语六级阅读理解，掌握快速阅读和答题技巧。','https://via.placeholder.com/400x250/ff6348/ffffff?text=CET6+Reading',8,3,'intermediate',480,1,'2025-11-30 14:00:00','2025-11-30 14:00:00',1680,4.6,142,'2025-11-29 22:00:00','2025-11-29 22:00:00','针对六级阅读理解的专项突破课程，提高阅读速度和准确率。','[\"掌握快速阅读技巧\", \"学会定位关键信息\", \"提高词汇量\", \"理解长难句结构\", \"提升阅读准确率\"]','[{\"icon\": \"fas fa-book-open\", \"title\": \"阅读训练\", \"description\": \"大量真题阅读练习\"}, {\"icon\": \"fas fa-tachometer-alt\", \"title\": \"速度提升\", \"description\": \"提高阅读速度\"}, {\"icon\": \"fas fa-bullseye\", \"title\": \"精准定位\", \"description\": \"快速找到答案\"}, {\"icon\": \"fas fa-award\", \"title\": \"高分技巧\", \"description\": \"阅读高分秘籍\"}]'),(14,'线性代数精讲','线性代数核心概念和计算方法，为后续学习打下基础。','https://via.placeholder.com/400x250/feca57/ffffff?text=Linear+Algebra',7,2,'intermediate',360,1,'2025-11-30 14:00:00','2025-11-30 14:00:00',890,4.4,76,'2025-11-29 22:00:00','2025-11-29 22:00:00','系统学习线性代数，包括矩阵运算、向量空间、特征值等核心内容。','[\"掌握矩阵基本运算\", \"理解向量空间概念\", \"学会求解线性方程组\", \"掌握特征值和特征向量\", \"了解线性代数应用\"]','[{\"icon\": \"fas fa-square-root-alt\", \"title\": \"理论扎实\", \"description\": \"深入理解数学原理\"}, {\"icon\": \"fas fa-calculator\", \"title\": \"计算技巧\", \"description\": \"快速计算方法\"}, {\"icon\": \"fas fa-project-diagram\", \"title\": \"应用实例\", \"description\": \"实际应用场景\"}, {\"icon\": \"fas fa-graduation-cap\", \"title\": \"考试导向\", \"description\": \"针对考试重点\"}]'),(15,'行测数量关系速解','公务员考试行测数量关系专项训练，快速提分技巧。','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%AF%BE%E7%A8%8B%E5%B0%81%E9%9D%A2/%E8%80%83%E5%85%AC%E8%A1%8C%E6%B5%8B1.jpg',9,4,'intermediate',300,1,'2025-11-30 14:00:00','2025-11-30 14:49:21',1420,4.7,118,'2025-11-29 22:00:00','2025-11-30 06:49:21','针对公务员考试行测数量关系部分的专项突破，掌握快速解题技巧。','[\"掌握数量关系题型\", \"学会快速计算方法\", \"掌握解题技巧\", \"提高答题速度\", \"提升正确率\"]','[{\"icon\": \"fas fa-calculator\", \"title\": \"速算技巧\", \"description\": \"快速计算方法\"}, {\"icon\": \"fas fa-lightbulb\", \"title\": \"解题思路\", \"description\": \"独特解题方法\"}, {\"icon\": \"fas fa-clock\", \"title\": \"时间管理\", \"description\": \"合理分配时间\"}, {\"icon\": \"fas fa-chart-line\", \"title\": \"快速提分\", \"description\": \"短期内显著提升\"}]'),(16,'概率论与数理统计','概率论与数理统计核心知识，理论与应用并重。','https://via.placeholder.com/400x250/ff9ff3/ffffff?text=Probability',7,2,'intermediate',420,1,'2025-11-30 14:00:00','2025-11-30 14:00:00',760,4.5,68,'2025-11-29 22:00:00','2025-11-29 22:00:00','系统学习概率论与数理统计，掌握随机变量、概率分布等核心概念。','[\"理解概率基本概念\", \"掌握随机变量分布\", \"学会参数估计\", \"掌握假设检验\", \"了解统计应用\"]','[{\"icon\": \"fas fa-dice\", \"title\": \"概率思维\", \"description\": \"培养概率思维方式\"}, {\"icon\": \"fas fa-chart-bar\", \"title\": \"统计分析\", \"description\": \"数据统计分析能力\"}, {\"icon\": \"fas fa-calculator\", \"title\": \"计算方法\", \"description\": \"概率计算技巧\"}, {\"icon\": \"fas fa-flask\", \"title\": \"实际应用\", \"description\": \"统计应用实例\"}]');
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
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_chapter`
--

/*!40000 ALTER TABLE `course_chapter` DISABLE KEYS */;
INSERT INTO `course_chapter` VALUES (1,1,'Java基础入门',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(2,1,'面向对象编程',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(3,1,'Java高级特性',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(4,1,'AI算法实现',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(5,1,'AI+Java实战项目',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(6,2,'极限与连续',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(7,2,'导数与微分',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(8,2,'积分学',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(9,3,'短对话听力',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(10,3,'长对话听力',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(11,3,'短文听力',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(12,3,'听力技巧总结',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(13,4,'微分难点突破',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(14,4,'积分难点突破',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(15,4,'微积分应用',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(16,5,'申论基础知识',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(17,5,'材料分析技巧',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(18,5,'写作方法',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(19,6,'听力专项',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(20,6,'阅读专项',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(21,6,'翻译专项',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(22,6,'写作专项',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(23,7,'申论理论体系',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(24,7,'归纳概括题',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(25,7,'综合分析题',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(26,7,'提出对策题',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(27,7,'申发论述题',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(28,8,'学习方法论',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(29,8,'行测高分技巧',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(30,8,'申论高分技巧',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(31,8,'时间管理',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(32,9,'Python数据分析基础',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(33,9,'Pandas数据处理',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(34,9,'NumPy数组运算',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(35,9,'数据可视化',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(36,9,'实战项目',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(37,10,'HTML5基础',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(38,10,'CSS3样式与布局',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(39,10,'JavaScript核心',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(40,10,'前端框架',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(41,10,'项目实战',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(42,11,'机器学习概述',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(43,11,'监督学习算法',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(44,11,'非监督学习算法',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(45,11,'模型评估与优化',4,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(46,11,'深度学习入门',5,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(47,12,'力学基础',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(48,12,'电磁学',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(49,12,'光学与热学',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(50,13,'阅读技巧',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(51,13,'真题训练',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(52,13,'模拟测试',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(53,14,'矩阵运算',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(54,14,'向量空间',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(55,14,'特征值与特征向量',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(56,15,'数量关系题型',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(57,15,'速算技巧',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(58,15,'真题演练',3,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(59,16,'概率论基础',1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(60,16,'随机变量',2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(61,16,'数理统计',3,'2025-11-30 14:00:00','2025-11-29 22:00:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程评价表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_review`
--

/*!40000 ALTER TABLE `course_review` DISABLE KEYS */;
INSERT INTO `course_review` VALUES (1,1,6,5,'课程内容非常全面，从Java基础到AI应用都讲得很清楚，老师讲解也很细致。','2025-11-29 02:30:00','2025-11-28 18:30:00'),(2,1,7,5,'2026最新版确实很新，内容紧跟技术潮流，AI部分讲得特别好。','2025-11-29 06:20:00','2025-11-28 22:20:00'),(3,1,8,4,'课程质量不错，就是内容有点多，需要花时间慢慢学。','2025-11-29 08:45:00','2025-11-29 00:45:00'),(4,2,9,5,'3小时真的学会了！讲得太通俗易懂了，期末考试有救了！','2025-11-29 03:00:00','2025-11-28 19:00:00'),(5,2,10,5,'老师讲课风趣幽默，把复杂的数学概念讲得很简单，强烈推荐！','2025-11-29 07:30:00','2025-11-28 23:30:00'),(6,2,6,4,'速成课程确实有效，但还是需要自己多练习题目。','2025-11-29 10:00:00','2025-11-29 02:00:00'),(7,3,7,5,'听力原文训练很有针对性，练习后听力水平明显提升。','2025-11-29 04:15:00','2025-11-28 20:15:00'),(8,3,8,4,'材料很丰富，就是需要坚持练习才能看到效果。','2025-11-29 09:00:00','2025-11-29 01:00:00'),(9,4,6,4,'微积分难点讲解很到位，帮助我理解了之前不懂的知识点。','2025-11-29 05:00:00','2025-11-28 21:00:00'),(10,5,9,5,'1小时真的学会了申论基础，太高效了！','2025-11-29 06:00:00','2025-11-28 22:00:00'),(11,6,9,5,'20小时突击真的有用！而且完全免费，太良心了！','2025-11-29 05:30:00','2025-11-28 21:30:00'),(12,6,10,5,'干货满满，没有废话，每一分钟都很有价值。','2025-11-29 11:00:00','2025-11-29 03:00:00'),(13,6,6,5,'通俗易懂，老师讲得特别好，六级有希望了！','2025-11-29 12:30:00','2025-11-29 04:30:00'),(14,7,7,5,'小马哥讲得太好了！申论系统课程非常专业，学到很多。','2025-11-29 06:45:00','2025-11-28 22:45:00'),(15,7,8,5,'从理论到实践都讲得很透彻，申论水平提升明显。','2025-11-29 13:00:00','2025-11-29 05:00:00'),(16,8,9,5,'清华出品，质量保证！学习方法确实很高效。','2025-11-29 07:00:00','2025-11-28 23:00:00'),(17,8,10,5,'一周达到140+不是梦，方法论很实用！','2025-11-29 14:00:00','2025-11-29 06:00:00'),(18,9,6,5,'Python数据分析讲得很实用，项目案例都是真实场景。','2025-11-29 08:00:00','2025-11-29 00:00:00'),(19,9,7,4,'内容丰富，Pandas和NumPy讲得很详细。','2025-11-29 15:00:00','2025-11-29 07:00:00'),(20,10,8,5,'Web全栈课程很全面，从前端到后端都有涉及。','2025-11-29 09:00:00','2025-11-29 01:00:00'),(21,10,9,5,'项目实战很有价值，学完就能做项目了。','2025-11-29 16:00:00','2025-11-29 08:00:00'),(22,11,6,5,'机器学习算法讲解很透彻，理论和实践结合得很好。','2025-11-29 10:00:00','2025-11-29 02:00:00'),(23,12,7,4,'物理速成课程很有效，帮我快速复习了重点内容。','2025-11-29 11:00:00','2025-11-29 03:00:00'),(24,13,8,5,'阅读理解技巧很实用，做题速度提升了很多。','2025-11-29 12:00:00','2025-11-29 04:00:00'),(25,14,9,4,'线性代数讲得很清楚，矩阵运算不再是难题。','2025-11-29 13:00:00','2025-11-29 05:00:00'),(26,15,10,5,'行测数量关系速算技巧太实用了，省了很多时间！','2025-11-29 14:00:00','2025-11-29 06:00:00'),(27,16,6,4,'概率论讲得不错，但需要多做练习才能掌握。','2025-11-29 15:00:00','2025-11-29 07:00:00'),(28,2,11,5,'甚好','2025-11-30 06:57:06','2025-11-30 06:57:06'),(29,5,11,5,'很好','2025-11-30 06:59:26','2025-11-30 06:59:26'),(30,5,13,5,'很好','2025-11-30 07:26:44','2025-11-30 07:26:44'),(31,5,12,5,'1111','2025-11-30 07:29:09','2025-11-30 07:29:09'),(32,5,12,5,'1234','2025-11-30 07:30:47','2025-11-30 07:30:47'),(33,2,12,5,'11212','2025-11-30 07:41:11','2025-11-30 07:41:11'),(34,5,13,5,'1111','2025-11-30 07:45:18','2025-11-30 07:45:18'),(35,5,13,5,'111','2025-11-30 07:54:10','2025-11-30 07:54:10');
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
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_video`
--

/*!40000 ALTER TABLE `course_video` DISABLE KEYS */;
INSERT INTO `course_video` VALUES (1,1,'Java开发环境搭建','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video1.mp4','安装JDK和IDE，配置开发环境',900,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(2,1,'第一个Java程序','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video2.mp4','编写Hello World程序',720,2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(3,2,'类与对象','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video3.mp4','理解面向对象的核心概念',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(4,2,'继承与多态','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video4.mp4','掌握继承和多态的使用',1080,2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(5,3,'集合框架','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video5.mp4','学习Java集合框架',1500,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(6,4,'机器学习算法基础','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video6.mp4','了解常见的机器学习算法',1800,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(7,5,'智能推荐系统实战','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video7.mp4','使用Java实现推荐系统',2400,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(8,6,'极限的概念','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/1.mp4','理解极限的定义和性质',600,1,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(9,6,'极限的计算','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/2.mp4','掌握极限的计算方法',720,2,'2025-11-30 14:00:00','2025-11-30 06:42:52'),(10,7,'导数的定义','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/3.mp4','理解导数的几何意义',540,1,'2025-11-30 14:00:00','2025-11-30 06:42:53'),(11,7,'求导法则','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/1.mp4','掌握各种求导法则',660,2,'2025-11-30 14:00:00','2025-11-30 06:42:54'),(12,8,'不定积分','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/2.mp4','学习不定积分的计算',780,1,'2025-11-30 14:00:00','2025-11-30 06:42:55'),(13,8,'定积分应用','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E6%95%B0%E5%AD%A61/3.mp4','定积分在几何中的应用',840,2,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(14,9,'短对话真题练习1','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/1.mp4','短对话听力真题训练',900,1,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(15,9,'短对话真题练习2','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/2.mp4','短对话听力技巧讲解',900,2,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(16,10,'长对话真题练习','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/3.mp4','长对话听力训练',1200,1,'2025-11-30 14:00:00','2025-11-30 06:28:39'),(17,11,'短文听力训练','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/1.mp4','短文听力专项练习',1080,1,'2025-11-30 14:00:00','2025-11-30 06:43:01'),(18,12,'听力技巧总结','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%8B%B1%E8%AF%AD1/2.mp4','四级听力技巧汇总',600,1,'2025-11-30 14:00:00','2025-11-30 06:43:03'),(19,13,'复杂函数求导','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E9%AB%98%E6%95%B01.mp4','掌握复杂函数的求导技巧',900,1,'2025-11-30 14:00:00','2025-11-30 06:43:05'),(20,14,'积分计算技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E9%AB%98%E6%95%B02.mp4','高级积分计算方法',960,1,'2025-11-30 14:00:00','2025-11-30 06:43:05'),(21,16,'申论基础理论','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA1.mp4','申论考试基础知识',720,1,'2025-11-30 14:00:00','2025-11-30 06:30:21'),(22,17,'材料分析方法','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA2.mp4','如何分析申论材料',840,1,'2025-11-30 14:00:00','2025-11-30 06:30:21'),(23,19,'六级听力技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E5%85%AD%E7%BA%A71.mp4','六级听力答题技巧',1080,1,'2025-11-30 14:00:00','2025-11-30 06:43:09'),(24,20,'六级阅读方法','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E5%85%AD%E7%BA%A72.mp4','快速阅读理解方法',1200,1,'2025-11-30 14:00:00','2025-11-30 06:43:10'),(25,23,'申论理论框架','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E8%80%83%E5%85%AC%E7%94%B3%E8%AE%BA1.mp4','申论理论体系讲解',1500,1,'2025-11-30 14:00:00','2025-11-30 06:43:11'),(26,28,'高效学习法','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/mzcourse/%E8%A7%86%E9%A2%91/%E8%80%83%E5%85%AC%E8%A1%8C%E6%B5%8B1.mp4','清华学习方法论',900,1,'2025-11-30 14:00:00','2025-11-30 06:43:12'),(27,32,'Python数据分析环境搭建','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video27.mp4','安装Anaconda和Jupyter',600,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(28,33,'Pandas基础操作','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video28.mp4','DataFrame和Series的使用',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(29,33,'数据清洗技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video29.mp4','处理缺失值和异常值',1080,2,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(30,34,'NumPy数组运算','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video30.mp4','数组的创建和运算',900,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(31,35,'Matplotlib可视化','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video31.mp4','使用Matplotlib绘图',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(32,36,'销售数据分析项目','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video32.mp4','完整的数据分析项目实战',2400,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(33,37,'HTML5标签详解','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video33.mp4','HTML5语义化标签使用',1080,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(34,38,'CSS3布局技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video34.mp4','Flexbox和Grid布局',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(35,39,'JavaScript ES6+','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video35.mp4','ES6新特性详解',1500,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(36,40,'Vue.js入门','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video36.mp4','Vue.js框架基础',1800,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(37,42,'机器学习基础','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video37.mp4','机器学习概念介绍',1200,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(38,43,'线性回归算法','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video38.mp4','线性回归原理和实现',1500,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(39,47,'牛顿运动定律','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video39.mp4','力学基础知识',900,1,'2025-11-30 14:00:00','2025-11-29 22:00:00'),(40,50,'快速阅读技巧','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/video40.mp4','提高阅读速度的方法',1080,1,'2025-11-30 14:00:00','2025-11-29 22:00:00');
/*!40000 ALTER TABLE `course_video` ENABLE KEYS */;

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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learning_detail`
--

/*!40000 ALTER TABLE `learning_detail` DISABLE KEYS */;
INSERT INTO `learning_detail` VALUES (1,6,1,1,'2025-11-29 10:00:00',900,1.00,0,100.00,900),(2,6,1,2,'2025-11-29 11:00:00',720,1.00,0,100.00,720),(3,6,1,3,'2025-11-29 12:00:00',600,1.00,1,50.00,600),(4,6,9,27,'2025-11-29 14:00:00',600,1.00,0,100.00,600),(5,7,2,8,'2025-11-29 09:00:00',600,1.00,0,100.00,600),(6,7,2,9,'2025-11-29 10:00:00',720,1.00,0,100.00,720),(7,7,4,19,'2025-11-29 13:00:00',300,1.00,2,33.33,300),(8,8,3,14,'2025-11-29 08:00:00',900,1.00,0,100.00,900),(9,8,3,15,'2025-11-29 09:30:00',900,1.00,1,100.00,900),(10,8,6,23,'2025-11-29 15:00:00',400,1.00,0,37.04,400),(11,9,7,25,'2025-11-29 10:00:00',1200,1.00,0,80.00,1200),(12,9,7,25,'2025-11-29 12:00:00',1080,1.00,1,72.00,1080),(13,9,5,21,'2025-11-29 16:00:00',300,1.00,0,41.67,300),(14,10,8,26,'2025-11-29 11:00:00',600,1.00,0,66.67,600),(15,10,8,26,'2025-11-29 13:00:00',900,1.00,0,100.00,900),(16,10,10,33,'2025-11-29 17:00:00',800,1.00,2,74.07,800);
/*!40000 ALTER TABLE `learning_detail` ENABLE KEYS */;

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
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_comment_id` int DEFAULT NULL,
  `likes_count` int DEFAULT '0',
  `status` enum('published','deleted') COLLATE utf8mb4_unicode_ci DEFAULT 'published',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `comment_type` enum('discussion','qa_answer') COLLATE utf8mb4_unicode_ci DEFAULT 'discussion' COMMENT '评论类型',
  PRIMARY KEY (`comment_id`),
  KEY `idx_post` (`post_id`),
  KEY `idx_author` (`author_id`),
  KEY `idx_parent` (`parent_comment_id`),
  CONSTRAINT `fk_parent_comment` FOREIGN KEY (`parent_comment_id`) REFERENCES `post_comment` (`comment_id`) ON DELETE CASCADE,
  CONSTRAINT `post_comment_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `community_post` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `post_comment_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `post_comment_ibfk_3` FOREIGN KEY (`parent_comment_id`) REFERENCES `post_comment` (`comment_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_comment`
--

/*!40000 ALTER TABLE `post_comment` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_like`
--

/*!40000 ALTER TABLE `post_like` DISABLE KEYS */;
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
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_best_answer` tinyint DEFAULT '0',
  `likes_count` int DEFAULT '0',
  `status` enum('published','deleted') COLLATE utf8mb4_unicode_ci DEFAULT 'published',
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
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_id` int NOT NULL,
  `course_id` int DEFAULT NULL,
  `difficulty_level` enum('beginner','intermediate','advanced') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('open','answered','closed') COLLATE utf8mb4_unicode_ci DEFAULT 'open',
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
  `join_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `leave_time` datetime DEFAULT NULL,
  `status` enum('active','left') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `total_study_time` int DEFAULT '0' COMMENT '总学习时间(分钟)',
  `study_goal` text COLLATE utf8mb4_unicode_ci COMMENT '学习目标',
  `current_task` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '当前任务',
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `unique_room_user` (`room_id`,`user_id`),
  KEY `idx_room` (`room_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `room_member_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `study_room` (`room_id`) ON DELETE CASCADE,
  CONSTRAINT `room_member_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_member`
--

/*!40000 ALTER TABLE `room_member` DISABLE KEYS */;
INSERT INTO `room_member` VALUES (1,1,11,'2025-11-30 15:03:15','2025-11-30 15:03:17','active',0,NULL,NULL);
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
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_type` enum('text','system') COLLATE utf8mb4_unicode_ci DEFAULT 'text',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `room_id` (`room_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `room_message_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `study_room` (`room_id`) ON DELETE CASCADE,
  CONSTRAINT `room_message_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_message`
--

/*!40000 ALTER TABLE `room_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `room_message` ENABLE KEYS */;

--
-- Table structure for table `study_room`
--

DROP TABLE IF EXISTS `study_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_room` (
  `room_id` int NOT NULL AUTO_INCREMENT,
  `room_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `creator_id` int NOT NULL,
  `max_participants` int DEFAULT '20',
  `current_participants` int DEFAULT '0',
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `status` enum('open','closed','active','inactive') COLLATE utf8mb4_unicode_ci DEFAULT 'open',
  `room_type` enum('public','private') COLLATE utf8mb4_unicode_ci DEFAULT 'public',
  `password` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tags` json DEFAULT NULL COMMENT '自习室标签',
  `rules` text COLLATE utf8mb4_unicode_ci COMMENT '自习室规则',
  `schedule_time` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '开放时间',
  PRIMARY KEY (`room_id`),
  KEY `idx_creator` (`creator_id`),
  KEY `idx_status` (`status`),
  KEY `idx_time` (`start_time`,`end_time`),
  CONSTRAINT `study_room_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_room`
--

/*!40000 ALTER TABLE `study_room` DISABLE KEYS */;
INSERT INTO `study_room` VALUES (1,'test','这个一个学习自习室，在这里面学习',11,50,1,NULL,NULL,'open','public',NULL,'2025-11-30 15:03:07','2025-11-30 15:03:15','[\"学习\"]','1.学习\n2.学习\n3.学习','9:00-12:00');
/*!40000 ALTER TABLE `study_room` ENABLE KEYS */;

--
-- Table structure for table `study_team`
--

DROP TABLE IF EXISTS `study_team`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_team` (
  `team_id` int NOT NULL AUTO_INCREMENT,
  `team_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `course_id` int DEFAULT NULL,
  `creator_id` int NOT NULL,
  `max_members` int DEFAULT '10',
  `current_members` int DEFAULT '1',
  `status` enum('active','inactive','full','closed') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `tags` json DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`team_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_creator` (`creator_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `study_team_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE SET NULL,
  CONSTRAINT `study_team_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_team`
--

/*!40000 ALTER TABLE `study_team` DISABLE KEYS */;
INSERT INTO `study_team` VALUES (2,'test','一起学习，学习使我快乐',NULL,11,10,1,'active','[\"编程\"]','2025-11-30 15:02:12','2025-11-30 15:02:12');
/*!40000 ALTER TABLE `study_team` ENABLE KEYS */;

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
  `role` enum('leader','member') COLLATE utf8mb4_unicode_ci DEFAULT 'member',
  `join_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('active','pending','removed') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `unique_team_user` (`team_id`,`user_id`),
  KEY `idx_team` (`team_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `team_member_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `study_team` (`team_id`) ON DELETE CASCADE,
  CONSTRAINT `team_member_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_member`
--

/*!40000 ALTER TABLE `team_member` DISABLE KEYS */;
INSERT INTO `team_member` VALUES (3,2,11,'leader','2025-11-30 15:02:12','active');
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
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `creator_id` int NOT NULL,
  `assignee_id` int DEFAULT NULL,
  `due_date` datetime DEFAULT NULL,
  `priority` enum('low','medium','high') COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `status` enum('pending','in_progress','completed','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`),
  KEY `idx_team` (`team_id`),
  KEY `idx_creator` (`creator_id`),
  KEY `idx_assignee` (`assignee_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `team_task_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `study_team` (`team_id`) ON DELETE CASCADE,
  CONSTRAINT `team_task_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `team_task_ibfk_3` FOREIGN KEY (`assignee_id`) REFERENCES `user` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_task`
--

/*!40000 ALTER TABLE `team_task` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'张老师','zhang.teacher@example.com','$2a$10$examplehashteacher1','https://via.placeholder.com/150/4285f4/ffffff?text=T1','instructor',1,'2025-11-28 21:06:41','2025-11-30 10:00:00','2025-11-28 05:06:41','2025-11-29 18:00:00'),(2,'李老师','li.teacher@example.com','$2a$10$examplehashteacher2','https://via.placeholder.com/150/ff6b6b/ffffff?text=T2','instructor',1,'2025-11-28 21:06:41','2025-11-30 09:30:00','2025-11-28 05:06:41','2025-11-29 17:30:00'),(3,'王老师','wang.teacher@example.com','$2a$10$examplehashteacher3','https://via.placeholder.com/150/4ecdc4/ffffff?text=T3','instructor',1,'2025-11-28 21:06:41','2025-11-30 11:00:00','2025-11-28 05:06:41','2025-11-29 19:00:00'),(4,'赵老师','zhao.teacher@example.com','$2a$10$examplehashteacher4','https://via.placeholder.com/150/ffd93d/ffffff?text=T4','instructor',1,'2025-11-28 21:06:41','2025-11-30 08:00:00','2025-11-28 05:06:41','2025-11-29 16:00:00'),(5,'刘老师','liu.teacher@example.com','$2a$10$examplehashteacher5','https://via.placeholder.com/150/74b9ff/ffffff?text=T5','instructor',1,'2025-11-28 21:06:41','2025-11-30 12:00:00','2025-11-28 05:06:41','2025-11-29 20:00:00'),(6,'小明','xiaoming@example.com','$2a$10$examplehashstudent1','https://via.placeholder.com/150/845ec2/ffffff?text=S1','learner',1,'2025-11-28 21:06:41','2025-11-30 13:00:00','2025-11-28 05:06:41','2025-11-29 21:00:00'),(7,'小红','xiaohong@example.com','$2a$10$examplehashstudent2','https://via.placeholder.com/150/f093fb/ffffff?text=S2','learner',1,'2025-11-28 21:06:41','2025-11-30 14:00:00','2025-11-28 05:06:41','2025-11-29 22:00:00'),(8,'小刚','xiaogang@example.com','$2a$10$examplehashstudent3','https://via.placeholder.com/150/4facfe/ffffff?text=S3','learner',1,'2025-11-28 21:06:41','2025-11-30 15:00:00','2025-11-28 05:06:41','2025-11-29 23:00:00'),(9,'小丽','xiaoli@example.com','$2a$10$examplehashstudent4','https://via.placeholder.com/150/ff6348/ffffff?text=S4','learner',1,'2025-11-28 21:06:41','2025-11-30 16:00:00','2025-11-28 05:06:41','2025-11-30 00:00:00'),(10,'小华','xiaohua@example.com','$2a$10$examplehashstudent5','https://via.placeholder.com/150/feca57/ffffff?text=S5','learner',1,'2025-11-28 21:06:41','2025-11-30 17:00:00','2025-11-28 05:06:41','2025-11-30 01:00:00'),(11,'1111','1111_1764483685328_a4yg6h@mzcourse.local','$2b$10$URRsMC0546kXKr.77hP.AekIArlH3Jp3UrB9oeH/10a3Tr8DOx1.O',NULL,'learner',1,'2025-11-30 14:21:25',NULL,'2025-11-30 06:21:25','2025-11-30 06:21:25'),(12,'tttt','tttt_1764486655431_csyp0m@mzcourse.local','$2b$10$pc1AvNKBQirHlJS8h2Lei.hN5TpurKsEd7HpRMTPGucGwUjSnmkbK',NULL,'learner',1,'2025-11-30 15:10:55','2025-11-30 15:27:58','2025-11-30 07:10:55','2025-11-30 07:27:58'),(13,'ffff','ffff_1764487246998_fgivus@mzcourse.local','$2b$10$MVXZ7A3N58Bd5cgQwp21iOjmfhRCtwu/CFPxsysg9MaKGAf7xZexi',NULL,'instructor',1,'2025-11-30 15:20:47','2025-11-30 15:44:03','2025-11-30 07:20:47','2025-11-30 07:44:03');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;

--
-- Table structure for table `user_behavior`
--

DROP TABLE IF EXISTS `user_behavior`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_behavior` (
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
  CONSTRAINT `user_behavior_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `user_behavior_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`),
  CONSTRAINT `user_behavior_ibfk_3` FOREIGN KEY (`video_id`) REFERENCES `course_video` (`video_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_behavior`
--

/*!40000 ALTER TABLE `user_behavior` DISABLE KEYS */;
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
  `progress` int DEFAULT '0' COMMENT '学习进度(百分比)',
  `last_learn_time` datetime DEFAULT NULL COMMENT '最后学习时间',
  `is_favorite` tinyint DEFAULT '0' COMMENT '是否收藏',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_course` (`user_id`,`course_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  CONSTRAINT `user_course_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `user_course_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户课程关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_course`
--

/*!40000 ALTER TABLE `user_course` DISABLE KEYS */;
INSERT INTO `user_course` VALUES (1,4,1,'2025-11-28 21:06:48',35,'2025-11-28 21:06:48',1,'2025-11-28 13:06:48','2025-11-28 13:06:48'),(2,4,4,'2025-11-28 21:06:48',60,'2025-11-28 21:06:48',1,'2025-11-28 13:06:48','2025-11-28 13:06:48'),(3,5,1,'2025-11-28 21:06:48',80,'2025-11-28 21:06:48',0,'2025-11-28 13:06:48','2025-11-28 13:06:48'),(4,5,3,'2025-11-28 21:06:48',45,'2025-11-28 21:06:48',1,'2025-11-28 13:06:48','2025-11-28 13:06:48'),(6,5,5,'2025-11-28 23:12:19',85,'2025-11-28 23:12:19',0,'2025-11-28 15:12:19','2025-11-28 15:12:19'),(7,6,2,'2025-11-28 23:16:26',0,NULL,0,'2025-11-28 15:16:26','2025-11-28 15:16:27'),(8,6,1,'2025-11-28 23:20:13',0,NULL,1,'2025-11-28 15:20:13','2025-11-29 15:09:29'),(9,6,3,'2025-11-28 23:28:59',0,NULL,1,'2025-11-28 15:28:59','2025-11-28 15:28:59'),(10,8,1,'2025-11-29 14:27:31',0,NULL,1,'2025-11-29 06:27:31','2025-11-29 06:27:31'),(11,11,10,'2025-11-30 14:53:40',0,NULL,0,'2025-11-30 06:53:40','2025-11-30 06:53:42');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_detail`
--

/*!40000 ALTER TABLE `user_detail` DISABLE KEYS */;
INSERT INTO `user_detail` VALUES (1,13,NULL,'1111',NULL,NULL,NULL,NULL,NULL,'2025-11-30 07:53:58','2025-11-30 07:54:01');
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_comment`
--

/*!40000 ALTER TABLE `video_comment` DISABLE KEYS */;
INSERT INTO `video_comment` VALUES (1,1,4,NULL,'讲解很清晰，环境已经成功搭好了。',5,'2025-11-28 21:06:55','2025-11-28 21:06:55'),(2,1,5,1,'同感，期待后面的内容！',4,'2025-11-28 21:06:55','2025-11-29 17:12:42'),(3,2,4,NULL,'循环语句的示例非常实用。',2,'2025-11-28 21:06:55','2025-11-28 21:06:55'),(4,7,5,NULL,'机器学习部分对初学者很友好。',4,'2025-11-28 21:06:55','2025-11-28 21:06:55'),(5,3,4,NULL,'语法规则这部分需要多练习才能熟练掌握。',6,'2025-11-28 23:12:17','2025-11-28 23:12:17'),(6,11,5,NULL,'JavaScript的历史发展很有趣，了解背景有助于学习。',9,'2025-11-28 23:12:17','2025-11-28 23:12:17'),(7,12,4,NULL,'变量声明的几种方式讲得很清楚。',7,'2025-11-28 23:12:17','2025-11-28 23:12:17'),(11,3,1,5,'很好',0,'2025-11-28 23:16:41','2025-11-28 23:16:41'),(12,1,1,NULL,'很棒',0,'2025-11-28 23:16:58','2025-11-28 23:16:58'),(13,1,6,NULL,'你好',1,'2025-11-28 23:26:34','2025-11-28 23:26:51'),(14,1,6,13,'很棒',0,'2025-11-28 23:26:42','2025-11-28 23:26:42'),(15,14,11,NULL,'test',0,'2025-11-30 14:54:36','2025-11-30 14:54:36');
/*!40000 ALTER TABLE `video_comment` ENABLE KEYS */;

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

-- Dump completed on 2025-11-30 15:57:43
