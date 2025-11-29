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
  `achievement_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `achievement_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `earned_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `icon_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_post`
--

/*!40000 ALTER TABLE `community_post` DISABLE KEYS */;
INSERT INTO `community_post` VALUES (1,'4QRWERETER','我二哥我让QWRGEWBVERB',1,'discussion',2,0,0,0,'published',0,'[\"无人过问\"]','2025-11-29 21:06:46','2025-11-29 21:06:46'),(2,'你好','念',6,'question',2,0,0,0,'published',0,'[\"提问\"]','2025-11-29 21:19:02','2025-11-29 21:19:02'),(4,'暗色发二十','韦尔股份二百',6,'sharing',2,0,0,0,'published',0,'[\"互助\"]','2025-11-29 21:20:32','2025-11-29 21:20:32'),(5,'Python Decorators Guide','Comprehensive guide to Python decorators and their practical applications.',1,'sharing',1,5,0,15,'published',0,NULL,'2025-11-29 21:21:35','2025-11-29 21:21:35'),(6,'React Performance Tips','Best practices for optimizing React application performance.',2,'sharing',2,8,0,25,'published',0,NULL,'2025-11-29 21:21:35','2025-11-29 21:21:35');
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course`
--

/*!40000 ALTER TABLE `course` DISABLE KEYS */;
INSERT INTO `course` VALUES (1,'Python编程入门','从零开始学习Python，掌握基础语法、数据类型、流程控制和函数等核心概念。','https://via.placeholder.com/400x250/667eea/ffffff?text=Python',1,1,'beginner',1800,1,'2025-11-28 21:06:43','2025-11-29 14:48:44',3200,4.7,6,'2025-11-28 13:06:43','2025-11-29 06:48:44','本课程专为编程零基础的学习者设计，通过生动有趣的案例和实践项目，带你轻松入门Python编程世界。Python作为最受欢迎的编程语言之一，以其简洁易懂的语法和强大的功能库著称，是初学者的最佳选择。','[\"掌握Python基础语法和编程概念\", \"理解变量、数据类型、运算符的使用\", \"学会使用条件语句和循环控制程序流程\", \"掌握函数的定义和使用方法\", \"学习文件操作和异常处理\", \"能够独立完成简单的Python项目\"]','[{\"icon\": \"fas fa-seedling\", \"title\": \"零基础友好\", \"description\": \"从最基础的概念开始，循序渐进\"}, {\"icon\": \"fas fa-laptop-code\", \"title\": \"实战项目\", \"description\": \"通过真实项目巩固所学知识\"}, {\"icon\": \"fas fa-gamepad\", \"title\": \"互动学习\", \"description\": \"丰富的练习题和编程挑战\"}, {\"icon\": \"fas fa-users\", \"title\": \"终身支持\", \"description\": \"学习社区答疑和资源分享\"}]'),(2,'JavaScript前端开发基础','系统学习JavaScript语法、DOM操作与事件处理，为前端开发打下坚实基础。','https://via.placeholder.com/400x250/f6d365/ffffff?text=JS',1,2,'beginner',2000,1,'2025-11-28 21:06:43','2025-11-29 14:48:46',2800,4.5,4,'2025-11-28 13:06:43','2025-11-29 06:48:46','深入学习JavaScript这门Web开发的核心语言，从基础语法到DOM操作，再到现代ES6+特性。本课程将帮助你建立扎实的前端开发基础，为后续学习React、Vue等框架做好准备。','[\"掌握JavaScript核心语法和数据类型\", \"理解函数、作用域和闭包概念\", \"学会DOM操作和事件处理\", \"掌握异步编程和Promise使用\", \"了解ES6+新特性和模块化开发\", \"能够开发交互式网页应用\"]','[{\"icon\": \"fas fa-rocket\", \"title\": \"现代JS\", \"description\": \"涵盖ES6+最新特性和最佳实践\"}, {\"icon\": \"fas fa-code\", \"title\": \"实时编码\", \"description\": \"边学边练，即时看到代码效果\"}, {\"icon\": \"fas fa-project-diagram\", \"title\": \"项目驱动\", \"description\": \"通过实际项目掌握开发技能\"}, {\"icon\": \"fas fa-globe\", \"title\": \"浏览器兼容\", \"description\": \"学习跨浏览器兼容性处理\"}]'),(3,'React全栈开发实战','基于React与Node.js，从零构建完整的前后端分离应用，掌握现代Web开发流程。','https://via.placeholder.com/400x250/4facfe/ffffff?text=React',1,3,'advanced',3200,1,'2025-11-28 21:06:43','2025-11-29 14:48:48',2100,4.5,2,'2025-11-28 13:06:43','2025-11-29 06:48:48','基于React生态系统，结合Node.js后端技术，从零构建完整的全栈Web应用。本课程涵盖现代前端开发的核心技术栈，包括React Hooks、状态管理、路由、以及RESTful API开发。','[\"掌握React组件化开发思想\", \"熟练使用React Hooks和状态管理\", \"学会React Router路由配置\", \"掌握Node.js和Express后端开发\", \"理解RESTful API设计和实现\", \"完成完整的全栈项目开发\"]','[{\"icon\": \"fas fa-layer-group\", \"title\": \"全栈技能\", \"description\": \"前后端技术一站式学习\"}, {\"icon\": \"fas fa-building\", \"title\": \"企业级项目\", \"description\": \"构建真实的商业级应用\"}, {\"icon\": \"fas fa-sync-alt\", \"title\": \"最新技术\", \"description\": \"使用最新的React和Node.js版本\"}, {\"icon\": \"fas fa-cloud-upload-alt\", \"title\": \"部署上线\", \"description\": \"学习项目部署和运维知识\"}]'),(4,'数据结构与算法解析','深入理解数组、链表、树、图等常见数据结构及经典算法，提升编程思维与面试能力。','https://via.placeholder.com/400x250/43e97b/ffffff?text=Algorithm',1,1,'intermediate',2600,1,'2025-11-28 21:06:43','2025-11-29 14:48:50',3500,5.0,2,'2025-11-28 13:06:43','2025-11-29 06:48:50','系统学习计算机科学的核心基础——数据结构与算法。通过可视化演示和代码实现，深入理解各种数据结构的特点和应用场景，掌握经典算法的设计思路，提升编程思维和解决问题的能力。','[\"理解数据结构的基本概念和分类\", \"掌握数组、链表、栈、队列的实现\", \"学会树、图等复杂数据结构\", \"掌握排序、搜索等经典算法\", \"理解算法复杂度分析方法\", \"提升编程面试和竞赛能力\"]','[{\"icon\": \"fas fa-eye\", \"title\": \"可视化学习\", \"description\": \"动画演示算法执行过程\"}, {\"icon\": \"fas fa-code-branch\", \"title\": \"多语言实现\", \"description\": \"提供Python、Java、C++代码\"}, {\"icon\": \"fas fa-briefcase\", \"title\": \"面试导向\", \"description\": \"涵盖大厂常见算法题目\"}, {\"icon\": \"fas fa-chart-line\", \"title\": \"渐进式学习\", \"description\": \"从简单到复杂，循序渐进\"}]'),(5,'机器学习入门实战','覆盖监督学习、非监督学习等核心算法，并通过项目理解模型训练与评估流程。','https://via.placeholder.com/400x250/f093fb/ffffff?text=ML',2,2,'intermediate',2400,1,'2025-11-28 21:06:43','2025-11-29 14:48:52',1900,4.5,2,'2025-11-28 13:06:43','2025-11-29 06:48:52','走进人工智能的核心领域——机器学习。本课程从数学基础开始，逐步深入监督学习、无监督学习等核心概念，结合Python和scikit-learn实现经典算法，让你具备解决实际机器学习问题的能力。','[\"理解机器学习的基本概念和分类\", \"掌握线性回归、逻辑回归等算法\", \"学会决策树、随机森林等集成方法\", \"了解聚类、降维等无监督学习\", \"掌握模型评估和参数调优\", \"完成端到端的机器学习项目\"]','[{\"icon\": \"fas fa-balance-scale\", \"title\": \"理论实践并重\", \"description\": \"数学原理与代码实现相结合\"}, {\"icon\": \"fas fa-database\", \"title\": \"真实数据集\", \"description\": \"使用工业界真实数据进行练习\"}, {\"icon\": \"fas fa-toolbox\", \"title\": \"工具链完整\", \"description\": \"涵盖pandas、numpy、sklearn等\"}, {\"icon\": \"fas fa-folder-open\", \"title\": \"项目作品集\", \"description\": \"构建个人机器学习作品集\"}]'),(6,'深度学习与神经网络','从感知机到卷积神经网络、循环神经网络，结合框架完成图像与文本任务。','https://via.placeholder.com/400x250/fa709a/ffffff?text=DL',3,2,'advanced',2800,1,'2025-11-28 21:06:43','2025-11-29 14:48:53',1600,4.9,780,'2025-11-28 13:06:43','2025-11-29 06:48:53','深入学习关系型数据库的设计原理和优化技巧。从ER模型设计到SQL查询优化，从索引策略到事务处理，全面掌握数据库开发和运维的核心技能，为大型系统开发打下坚实基础。','[\"掌握数据库设计的基本原则\", \"学会ER模型和范式化设计\", \"熟练编写复杂SQL查询语句\", \"理解索引原理和优化策略\", \"掌握事务处理和并发控制\", \"学会数据库性能监控和调优\"]','[{\"icon\": \"fas fa-drafting-compass\", \"title\": \"设计导向\", \"description\": \"从需求分析到数据库设计\"}, {\"icon\": \"fas fa-tachometer-alt\", \"title\": \"性能优化\", \"description\": \"深入学习查询优化技巧\"}, {\"icon\": \"fas fa-sitemap\", \"title\": \"实战案例\", \"description\": \"基于真实业务场景的设计\"}, {\"icon\": \"fas fa-server\", \"title\": \"多数据库\", \"description\": \"涵盖MySQL、PostgreSQL等\"}]'),(7,'移动应用开发入门','使用主流移动开发框架，完成一个从界面设计到接口联调的移动应用。','https://via.placeholder.com/400x250/30cfd0/ffffff?text=Mobile',4,3,'beginner',2100,1,'2025-11-28 21:06:43','2025-11-29 14:48:55',900,4.5,300,'2025-11-28 13:06:43','2025-11-29 06:48:55','学习跨平台移动应用开发技术，使用React Native或Flutter构建iOS和Android应用。从UI设计到原生功能调用，从状态管理到应用发布，全面掌握现代移动开发技能。','[\"理解移动应用开发的基本概念\", \"掌握跨平台开发框架使用\", \"学会移动UI设计和交互实现\", \"了解设备API和原生功能调用\", \"掌握应用状态管理和数据持久化\", \"学会应用打包和发布流程\"]','[{\"icon\": \"fas fa-mobile-alt\", \"title\": \"跨平台开发\", \"description\": \"一套代码适配iOS和Android\"}, {\"icon\": \"fas fa-bolt\", \"title\": \"原生体验\", \"description\": \"接近原生应用的性能和体验\"}, {\"icon\": \"fas fa-sync\", \"title\": \"热更新\", \"description\": \"学习应用热更新和版本管理\"}, {\"icon\": \"fas fa-store\", \"title\": \"发布指导\", \"description\": \"应用商店发布全流程指导\"}]'),(8,'后端API设计与实践','学习RESTful API设计原则、接口文档规范以及常见认证授权方案，完成一个后端服务。','https://via.placeholder.com/400x250/5ee7df/ffffff?text=Backend',6,1,'intermediate',2300,1,'2025-11-28 21:06:43','2025-11-29 14:48:57',1200,4.7,500,'2025-11-28 13:06:43','2025-11-29 06:48:57','掌握现代云计算和DevOps技术栈，学习Docker容器化、Kubernetes编排、CI/CD流水线等核心技术。通过实际项目，了解如何构建高可用、可扩展的云原生应用系统。','[\"理解云计算的基本概念和服务模式\", \"掌握Docker容器技术和镜像构建\", \"学会Kubernetes集群管理和服务编排\", \"了解CI/CD流水线设计和实现\", \"掌握监控、日志和故障排查\", \"学会云原生应用架构设计\"]','[{\"icon\": \"fas fa-cloud\", \"title\": \"实战环境\", \"description\": \"提供真实的云环境进行实践\"}, {\"icon\": \"fas fa-robot\", \"title\": \"自动化部署\", \"description\": \"从代码到生产的全自动化流程\"}, {\"icon\": \"fas fa-cubes\", \"title\": \"微服务架构\", \"description\": \"学习现代微服务设计模式\"}, {\"icon\": \"fas fa-chart-area\", \"title\": \"运维监控\", \"description\": \"掌握系统监控和性能调优\"}]');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_category`
--

/*!40000 ALTER TABLE `course_category` DISABLE KEYS */;
INSERT INTO `course_category` VALUES (1,'编程开发',NULL,'fa-code',1,'2025-11-28 13:06:38','2025-11-28 13:06:38'),(2,'数据科学',NULL,'fa-chart-bar',2,'2025-11-28 13:06:38','2025-11-28 13:06:38'),(3,'人工智能',NULL,'fa-brain',3,'2025-11-28 13:06:38','2025-11-28 13:06:38'),(4,'移动开发',NULL,'fa-mobile-alt',4,'2025-11-28 13:06:38','2025-11-28 13:06:38'),(5,'UI/UX设计',NULL,'fa-palette',5,'2025-11-28 13:06:38','2025-11-28 13:06:38'),(6,'后端开发',NULL,'fa-server',6,'2025-11-28 13:06:38','2025-11-28 13:06:38');
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
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_chapter`
--

/*!40000 ALTER TABLE `course_chapter` DISABLE KEYS */;
INSERT INTO `course_chapter` VALUES (1,1,'认识Python与开发环境',1,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(2,1,'Python基础语法与流程控制',2,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(3,2,'JavaScript基础与运行环境',1,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(4,2,'DOM编程与事件处理',2,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(5,3,'React组件与JSX基础',1,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(6,4,'线性表与链表',1,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(7,5,'监督学习概述',1,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(8,6,'神经网络基础概念',1,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(9,7,'移动开发环境搭建',1,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(10,8,'RESTful API设计原则',1,'2025-11-28 21:06:45','2025-11-28 13:06:45'),(11,3,'Node.js后端',3,'2025-11-28 23:10:31','2025-11-28 15:10:31'),(12,3,'全栈项目实战',4,'2025-11-28 23:10:31','2025-11-28 15:10:31'),(13,4,'数组与链表',1,'2025-11-28 23:10:38','2025-11-28 15:10:38'),(14,4,'栈与队列',2,'2025-11-28 23:10:38','2025-11-28 15:10:38'),(15,4,'树与图',3,'2025-11-28 23:10:38','2025-11-28 15:10:38'),(16,4,'算法分析',4,'2025-11-28 23:10:38','2025-11-28 15:10:38'),(17,5,'机器学习概述',1,'2025-11-28 23:10:45','2025-11-28 15:10:45'),(18,5,'监督学习',2,'2025-11-28 23:10:45','2025-11-28 15:10:45'),(19,5,'非监督学习',3,'2025-11-28 23:10:45','2025-11-28 15:10:45'),(20,5,'项目实战',4,'2025-11-28 23:10:45','2025-11-28 15:10:45'),(21,6,'神经网络基础',1,'2025-11-28 23:10:53','2025-11-28 15:10:53'),(22,6,'卷积神经网络',2,'2025-11-28 23:10:53','2025-11-28 15:10:53'),(23,6,'循环神经网络',3,'2025-11-28 23:10:53','2025-11-28 15:10:53'),(24,6,'深度学习框架',4,'2025-11-28 23:10:53','2025-11-28 15:10:53'),(25,7,'移动开发概述',1,'2025-11-28 23:11:02','2025-11-28 15:11:02'),(26,7,'界面设计',2,'2025-11-28 23:11:02','2025-11-28 15:11:02'),(27,7,'数据交互',3,'2025-11-28 23:11:02','2025-11-28 15:11:02'),(28,7,'应用发布',4,'2025-11-28 23:11:02','2025-11-28 15:11:02'),(29,8,'RESTful API设计',1,'2025-11-28 23:11:08','2025-11-28 15:11:08'),(30,8,'数据库设计',2,'2025-11-28 23:11:08','2025-11-28 15:11:08'),(31,8,'认证与授权',3,'2025-11-28 23:11:08','2025-11-28 15:11:08'),(32,8,'API文档与测试',4,'2025-11-28 23:11:08','2025-11-28 15:11:08');
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程评价表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_review`
--

/*!40000 ALTER TABLE `course_review` DISABLE KEYS */;
INSERT INTO `course_review` VALUES (1,1,4,5,'张老师讲得非常清楚，Python入门的最佳选择！','2025-11-28 15:12:14','2025-11-28 15:12:14'),(2,1,5,4,'课程内容很实用，练习题也很有针对性。','2025-11-28 15:12:14','2025-11-28 15:12:14'),(3,2,4,5,'李老师的JavaScript课程让我对前端开发有了全新的认识。','2025-11-28 15:12:14','2025-11-28 15:12:14'),(4,2,5,4,'DOM操作部分讲得特别详细，受益匪浅。','2025-11-28 15:12:14','2025-11-28 15:12:14'),(5,3,4,5,'王老师的全栈课程内容丰富，项目实战很有价值。','2025-11-28 15:12:14','2025-11-28 15:12:14'),(6,3,5,4,'React部分讲得很好，但Node.js部分可以再深入一些。','2025-11-28 15:12:14','2025-11-28 15:12:14'),(7,4,4,5,'算法课程逻辑清晰，对面试准备很有帮助。','2025-11-28 15:12:14','2025-11-28 15:12:14'),(8,4,5,5,'数据结构讲解得很透彻，代码示例也很好理解。','2025-11-28 15:12:14','2025-11-28 15:12:14'),(9,5,4,4,'机器学习入门课程很适合初学者，项目案例很实用。','2025-11-28 15:12:14','2025-11-28 15:12:14'),(10,5,5,5,'李老师的机器学习课程理论与实践结合得很好。','2025-11-28 15:12:14','2025-11-28 15:12:14'),(11,1,6,5,'很好','2025-11-28 15:20:33','2025-11-28 15:20:33'),(12,1,1,5,'这门课程非常棒！讲师讲解清晰，案例丰富，让我从零基础快速入门了编程。','2025-11-29 06:43:54','2025-11-29 06:43:54'),(13,1,2,4,'课程内容很实用，项目练习帮助很大，推荐给想学编程的朋友。','2025-11-29 06:43:54','2025-11-29 06:43:54'),(14,1,3,5,'老师的教学方式很好，循序渐进，即使是初学者也能跟上节奏。','2025-11-29 06:43:54','2025-11-29 06:43:54'),(15,2,1,4,'课程质量不错，内容丰富，学到了很多实用的技能。','2025-11-29 06:43:54','2025-11-29 06:43:54'),(16,2,2,5,'非常满意这门课程，老师专业，课程设计合理。','2025-11-29 06:43:54','2025-11-29 06:43:54');
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_video`
--

/*!40000 ALTER TABLE `course_video` DISABLE KEYS */;
INSERT INTO `course_video` VALUES (1,1,'Python简介与安装','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','了解Python语言特点及开发环境安装。',900,1,'2025-11-28 21:06:47','2025-11-28 15:19:17'),(2,2,'条件语句与循环','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','掌握if、for、while等流程控制语句。',1200,1,'2025-11-28 21:06:47','2025-11-28 15:19:17'),(3,3,'JavaScript运行机制','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','认识JavaScript在浏览器中的执行环境。',800,1,'2025-11-28 21:06:47','2025-11-28 15:19:17'),(4,4,'DOM选择与事件绑定','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','使用原生JS完成DOM选择与事件处理。',1100,1,'2025-11-28 21:06:47','2025-11-28 15:19:17'),(5,5,'第一个React组件','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','创建并渲染第一个React函数组件。',1000,1,'2025-11-28 21:06:47','2025-11-28 15:19:17'),(6,6,'链表的基本操作','https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/%E5%B1%8F%E5%B9%95%E5%BD%95%E5%88%B6%202025-07-03%20142851.mp4','实现单向链表的增删查改。',1300,1,'2025-11-28 21:06:47','2025-11-28 15:19:17'),(7,7,'线性回归实战','https://example.com/video/ml-linear-regression.mp4','使用线性回归完成一个房价预测案例。',1400,1,'2025-11-28 21:06:47','2025-11-28 13:06:47'),(8,8,'感知机模型与实现','https://example.com/video/dl-perceptron.mp4','理解感知机原理并实现简单分类模型。',1500,1,'2025-11-28 21:06:47','2025-11-28 13:06:47'),(9,4,'函数定义与调用','/videos/demo.mp4','学习如何定义和调用Python函数',960,1,'2025-11-28 23:11:44','2025-11-28 15:11:44'),(10,4,'模块与包','/videos/demo.mp4','了解Python模块系统和包的使用',720,2,'2025-11-28 23:11:44','2025-11-28 15:11:44'),(11,5,'JavaScript简介','/videos/demo.mp4','了解JavaScript的历史和应用场景',600,1,'2025-11-28 23:11:50','2025-11-28 15:11:50'),(12,5,'变量与数据类型','/videos/demo.mp4','学习JavaScript的变量声明和数据类型',720,2,'2025-11-28 23:11:50','2025-11-28 15:11:50'),(13,5,'函数与作用域','/videos/demo.mp4','掌握JavaScript函数的定义和作用域概念',840,3,'2025-11-28 23:11:50','2025-11-28 15:11:50'),(14,6,'DOM树结构','/videos/demo.mp4','理解DOM树的结构和节点关系',660,1,'2025-11-28 23:11:56','2025-11-28 15:11:56'),(15,6,'元素选择与操作','/videos/demo.mp4','学习如何选择和操作DOM元素',780,2,'2025-11-28 23:11:56','2025-11-28 15:11:56'),(16,7,'事件监听','/videos/demo.mp4','学习如何添加和处理事件监听器',720,1,'2025-11-28 23:12:09','2025-11-28 15:12:09'),(17,7,'事件冒泡与捕获','/videos/demo.mp4','理解事件冒泡和捕获机制',600,2,'2025-11-28 23:12:09','2025-11-28 15:12:09');
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
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learning_detail`
--

/*!40000 ALTER TABLE `learning_detail` DISABLE KEYS */;
INSERT INTO `learning_detail` VALUES (1,4,1,1,'2025-11-28 23:12:21',900,1.00,2,100.00,900),(2,4,1,2,'2025-11-28 23:12:21',720,1.00,1,100.00,720),(3,4,1,3,'2025-11-28 23:12:21',420,1.25,3,50.00,420),(4,5,1,1,'2025-11-28 23:12:21',900,1.00,0,100.00,900),(5,5,1,2,'2025-11-28 23:12:21',360,1.50,2,50.00,360),(6,5,2,11,'2025-11-28 23:12:21',600,1.00,1,100.00,600),(32,8,1,1,'2025-11-29 16:38:16',13,1.00,0,1.48,13),(33,8,1,1,'2025-11-29 17:05:53',27,1.00,0,2.96,27),(34,8,1,1,'2025-11-29 17:13:17',14,1.00,0,1.55,14),(35,8,1,1,'2025-11-29 17:13:22',27,1.00,0,2.96,27),(36,8,1,1,'2025-11-29 17:17:55',14,1.00,0,1.55,14),(37,8,1,1,'2025-11-29 17:36:06',27,1.00,0,2.96,27),(38,8,1,1,'2025-11-29 17:36:11',40,1.00,0,4.45,40),(39,8,1,1,'2025-11-29 17:36:16',54,1.00,0,5.95,54),(40,8,1,1,'2025-11-29 17:36:21',67,1.00,0,7.44,67),(41,8,1,1,'2025-11-29 17:36:26',80,1.00,0,8.93,80),(42,8,1,1,'2025-11-29 17:36:31',93,1.00,0,10.34,93),(43,8,1,1,'2025-11-29 17:36:36',106,1.00,0,11.83,106),(44,8,1,1,'2025-11-29 17:36:41',120,1.00,0,13.32,120);
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_member`
--

/*!40000 ALTER TABLE `room_member` DISABLE KEYS */;
INSERT INTO `room_member` VALUES (1,1,6,'2025-11-29 21:17:27','2025-11-29 21:17:29','active',0,NULL,NULL),(4,2,6,'2025-11-29 23:38:08','2025-11-29 23:38:11','active',0,NULL,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_room`
--

/*!40000 ALTER TABLE `study_room` DISABLE KEYS */;
INSERT INTO `study_room` VALUES (1,'112142','1213412351245是的分公司的',1,50,1,NULL,NULL,'open','public',NULL,'2025-11-29 21:06:24','2025-11-29 21:17:27','[\"学习\"]','1',NULL),(2,'你好1','241325234523453245',6,50,1,NULL,NULL,'open','public',NULL,'2025-11-29 21:20:22','2025-11-29 23:38:08','[\"学习\"]','5423452345','13523');
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_team`
--

/*!40000 ALTER TABLE `study_team` DISABLE KEYS */;
INSERT INTO `study_team` VALUES (1,'test','啦啦啦啦啦啦啦啦啦啦啦啦啦啦',NULL,1,10,2,'active','[]','2025-11-29 19:28:12','2025-11-29 19:28:12'),(2,'test1','啦啦啦啦啦啦啦啦啦啦啦啦啦啦',NULL,1,2,2,'active','[]','2025-11-29 19:28:54','2025-11-29 19:28:54'),(3,'test3','123243',NULL,1,8,2,'active','[]','2025-11-29 19:30:58','2025-11-29 19:30:58'),(4,'Python进阶学习组','专注于Python高级特性和项目实战，每周完成一个实战项目',1,1,10,1,'active','[\"Python\", \"进阶\", \"项目实战\"]','2025-11-29 21:14:40','2025-11-29 21:14:40'),(5,'Web全栈开发小队','从前端到后端，系统学习现代Web开发技术栈',2,1,8,1,'active','[\"前端\", \"后端\", \"全栈\"]','2025-11-29 21:14:40','2025-11-29 21:14:40'),(6,'数据结构与算法攻坚','每日一题，共同攻克算法难题，备战技术面试',3,1,15,1,'active','[\"算法\", \"数据结构\", \"面试\"]','2025-11-29 21:14:40','2025-11-29 21:14:40'),(7,'React深度研究','深入理解React原理和最佳实践',2,1,6,1,'active','[\"React\", \"深度\", \"原理\"]','2025-11-29 21:14:40','2025-11-29 21:14:40'),(8,'Python进阶学习组','专注于Python高级特性和项目实战，每周完成一个实战项目',1,1,10,1,'active','[\"Python\", \"进阶\", \"项目实战\"]','2025-11-29 21:14:43','2025-11-29 21:14:43'),(9,'Web全栈开发小队','从前端到后端，系统学习现代Web开发技术栈',2,1,8,1,'active','[\"前端\", \"后端\", \"全栈\"]','2025-11-29 21:14:43','2025-11-29 21:14:43'),(10,'数据结构与算法攻坚','每日一题，共同攻克算法难题，备战技术面试',3,1,15,1,'active','[\"算法\", \"数据结构\", \"面试\"]','2025-11-29 21:14:43','2025-11-29 21:14:43'),(11,'React深度研究','深入理解React原理和最佳实践',2,1,6,1,'active','[\"React\", \"深度\", \"原理\"]','2025-11-29 21:14:43','2025-11-29 21:14:43'),(12,'Python Advanced Group','Focus on Python advanced features and projects',1,1,10,1,'active',NULL,'2025-11-29 21:15:25','2025-11-29 21:15:25'),(13,'Web Fullstack Team','Learn modern web development from frontend to backend',2,1,8,1,'active',NULL,'2025-11-29 21:15:25','2025-11-29 21:15:25'),(14,'Algorithm Study Group','Daily algorithm practice and interview preparation',3,1,15,1,'active',NULL,'2025-11-29 21:15:25','2025-11-29 21:15:25'),(15,'React Deep Dive','Deep understanding of React principles and best practices',2,1,6,1,'active',NULL,'2025-11-29 21:15:25','2025-11-29 21:15:25');
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
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_member`
--

/*!40000 ALTER TABLE `team_member` DISABLE KEYS */;
INSERT INTO `team_member` VALUES (1,1,1,'leader','2025-11-29 19:28:12','active'),(2,2,1,'leader','2025-11-29 19:28:54','active'),(3,3,1,'leader','2025-11-29 19:30:58','active'),(16,12,6,'member','2025-11-29 21:17:20','active'),(17,1,6,'member','2025-11-29 21:21:35','active'),(18,2,6,'member','2025-11-29 21:21:35','active'),(19,13,6,'member','2025-11-29 23:07:19','active');
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'张老师','zhang.teacher@example.com','$2a$10$examplehashteacher1',NULL,'instructor',1,'2025-11-28 21:06:41','2025-11-28 21:06:41','2025-11-28 13:06:41','2025-11-28 13:06:41'),(2,'李老师','li.teacher@example.com','$2a$10$examplehashteacher2',NULL,'instructor',1,'2025-11-28 21:06:41','2025-11-28 21:06:41','2025-11-28 13:06:41','2025-11-28 13:06:41'),(3,'王老师','wang.teacher@example.com','$2a$10$examplehashteacher3',NULL,'instructor',1,'2025-11-28 21:06:41','2025-11-28 21:06:41','2025-11-28 13:06:41','2025-11-28 13:06:41'),(4,'测试学员A','student.a@example.com','$2a$10$examplehashstudent1',NULL,'learner',1,'2025-11-28 21:06:41','2025-11-28 21:06:41','2025-11-28 13:06:41','2025-11-28 13:06:41'),(5,'测试学员B','student.b@example.com','$2a$10$examplehashstudent2',NULL,'learner',1,'2025-11-28 21:06:41','2025-11-28 21:06:41','2025-11-28 13:06:41','2025-11-28 13:06:41'),(6,'424','test_1764339270701_2lvm10@mzcourse.local','$2b$10$xSZQ7zALK2Go1YGTkDETg.7r5FFIV/5POtID.GgbzezZ.0OeLhknS',NULL,'learner',1,'2025-11-28 22:14:30','2025-11-29 22:31:03','2025-11-28 14:14:30','2025-11-29 15:07:37'),(7,'teacher','teacher_1764396578279_d5ln5x@mzcourse.local','$2b$10$o4JWb8w3KnwkSi7S82kpv.1j4ozSAI.DadetoKKBeIEDA9OEjUGzi',NULL,'instructor',1,'2025-11-29 14:09:38','2025-11-29 19:25:17','2025-11-29 06:09:38','2025-11-29 11:25:17'),(8,'ffff','ffff_1764397594691_d82im7@mzcourse.local','$2b$10$EWtcElQ6sQJwggNBXXxX6eOG7AbmWVsvojYk/Jb/pP0TSbczgWMpO',NULL,'learner',1,'2025-11-29 14:26:34','2025-11-29 14:27:20','2025-11-29 06:26:34','2025-11-29 06:27:20'),(9,'test999','test999_1764431544927_247ifm@mzcourse.local','$2b$10$Eb9.envhRKHJAwjQXxVIX.aTPevgk1VHkGwa7mTuecMNunhrURKOu',NULL,'learner',1,'2025-11-29 23:52:25',NULL,'2025-11-29 15:52:25','2025-11-29 15:52:25'),(10,'1321','1321_1764431581380_2nws9q@mzcourse.local','$2b$10$cekZu/vSq5ndCuCHG4.XvOXdkK1e5jfb8PN9eHLKt0Gzp83zNlrYG',NULL,'instructor',1,'2025-11-29 23:53:01',NULL,'2025-11-29 15:53:01','2025-11-29 15:53:01'),(11,'stu','stu_1764431645895_szhcup@mzcourse.local','$2b$10$c2xyrxc3GB6BaxxHt1zcaOjNrQbmDG1/YBIdIMqIEqBVy.pbkOyLC',NULL,'learner',1,'2025-11-29 23:54:06','2025-11-30 00:34:41','2025-11-29 15:54:06','2025-11-29 16:34:41'),(12,'tea','tea_1764432305533_rzn85b@mzcourse.local','$2b$10$kJ64oM3OHyLRpQxjfzQAXeUZfWaPh90L.nk1b66ItjdQOvD4JjEAC',NULL,'instructor',1,'2025-11-30 00:05:05','2025-11-30 00:32:46','2025-11-29 16:05:05','2025-11-29 16:32:46'),(13,'ssss','ssss_1764434131022_dbqm4e@mzcourse.local','$2b$10$VS3eq0PlhgusMIo7Uhnko.NeJxAiJOLqtSOmu6RkWqiIKDZ1sS.Va',NULL,'learner',1,'2025-11-30 00:35:31',NULL,'2025-11-29 16:35:31','2025-11-29 16:35:31'),(14,'tttt','tttt_1764434273209_odooa9@mzcourse.local','$2b$10$L5XmOLj3z1Li0UrHWYY8M.gy3z/p7UY0tLqVCGkA9QU.7FG2PPxuC',NULL,'instructor',1,'2025-11-30 00:37:53','2025-11-30 01:01:21','2025-11-29 16:37:53','2025-11-29 17:01:21'),(15,'sss','sss_1764434868781_5qvlyy@mzcourse.local','$2b$10$wORQVnAcv/TfQpUMPr8YOu38ujXlrSnVe8G/idzCVYCmiuuO/vY5m',NULL,'learner',1,'2025-11-30 00:47:48',NULL,'2025-11-29 16:47:48','2025-11-29 16:47:48'),(16,'sssss','sssss_1764435662294_zujzdn@mzcourse.local','$2b$10$01L9ZrrBlT4zavxtuw1eGuV8FycsgTbH2sgqPrwAXBBRoc2DljlV2',NULL,'learner',1,'2025-11-30 01:01:02',NULL,'2025-11-29 17:01:02','2025-11-29 17:01:02');
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户课程关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_course`
--

/*!40000 ALTER TABLE `user_course` DISABLE KEYS */;
INSERT INTO `user_course` VALUES (1,4,1,'2025-11-28 21:06:48',35,'2025-11-28 21:06:48',1,'2025-11-28 13:06:48','2025-11-28 13:06:48'),(2,4,4,'2025-11-28 21:06:48',60,'2025-11-28 21:06:48',1,'2025-11-28 13:06:48','2025-11-28 13:06:48'),(3,5,1,'2025-11-28 21:06:48',80,'2025-11-28 21:06:48',0,'2025-11-28 13:06:48','2025-11-28 13:06:48'),(4,5,3,'2025-11-28 21:06:48',45,'2025-11-28 21:06:48',1,'2025-11-28 13:06:48','2025-11-28 13:06:48'),(6,5,5,'2025-11-28 23:12:19',85,'2025-11-28 23:12:19',0,'2025-11-28 15:12:19','2025-11-28 15:12:19'),(7,6,2,'2025-11-28 23:16:26',0,NULL,0,'2025-11-28 15:16:26','2025-11-28 15:16:27'),(8,6,1,'2025-11-28 23:20:13',0,NULL,1,'2025-11-28 15:20:13','2025-11-29 15:09:29'),(9,6,3,'2025-11-28 23:28:59',0,NULL,1,'2025-11-28 15:28:59','2025-11-28 15:28:59'),(10,8,1,'2025-11-29 14:27:31',0,NULL,1,'2025-11-29 06:27:31','2025-11-29 06:27:31');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_detail`
--

/*!40000 ALTER TABLE `user_detail` DISABLE KEYS */;
INSERT INTO `user_detail` VALUES (1,4,'13800000001','热爱编程的在校大学生。','学生','掌握Python与算法，为校招做准备。','上海',NULL,NULL,'2025-11-28 13:06:52','2025-11-28 13:06:52'),(2,5,'13800000002','转行中的测试工程师。','测试工程师','进入数据科学与机器学习领域。','北京',NULL,NULL,'2025-11-28 13:06:52','2025-11-28 13:06:52'),(3,3,'13800138003','全栈开发工程师，热爱技术分享','技术总监','帮助学员掌握全栈技能','深圳','https://wangteacher.com','{\"github\": \"wangteacher\", \"linkedin\": \"wangteacher\"}','2025-11-28 15:12:22','2025-11-28 15:12:22');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_enrollment`
--

/*!40000 ALTER TABLE `user_enrollment` DISABLE KEYS */;
INSERT INTO `user_enrollment` VALUES (1,4,1,'2025-11-28 21:06:53',35.00,'in_progress','2025-11-28 21:06:53'),(2,4,4,'2025-11-28 21:06:53',60.00,'in_progress','2025-11-28 21:06:53'),(3,5,1,'2025-11-28 21:06:53',80.00,'completed','2025-11-28 21:06:53'),(4,5,3,'2025-11-28 21:06:53',45.00,'in_progress','2025-11-28 21:06:53'),(6,5,5,'2025-11-28 23:12:23',85.00,'in_progress','2025-11-28 23:12:23');
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_comment`
--

/*!40000 ALTER TABLE `video_comment` DISABLE KEYS */;
INSERT INTO `video_comment` VALUES (1,1,4,NULL,'讲解很清晰，环境已经成功搭好了。',5,'2025-11-28 21:06:55','2025-11-28 21:06:55'),(2,1,5,1,'同感，期待后面的内容！',4,'2025-11-28 21:06:55','2025-11-29 17:12:42'),(3,2,4,NULL,'循环语句的示例非常实用。',2,'2025-11-28 21:06:55','2025-11-28 21:06:55'),(4,7,5,NULL,'机器学习部分对初学者很友好。',4,'2025-11-28 21:06:55','2025-11-28 21:06:55'),(5,3,4,NULL,'语法规则这部分需要多练习才能熟练掌握。',6,'2025-11-28 23:12:17','2025-11-28 23:12:17'),(6,11,5,NULL,'JavaScript的历史发展很有趣，了解背景有助于学习。',9,'2025-11-28 23:12:17','2025-11-28 23:12:17'),(7,12,4,NULL,'变量声明的几种方式讲得很清楚。',7,'2025-11-28 23:12:17','2025-11-28 23:12:17'),(11,3,1,5,'很好',0,'2025-11-28 23:16:41','2025-11-28 23:16:41'),(12,1,1,NULL,'很棒',0,'2025-11-28 23:16:58','2025-11-28 23:16:58'),(13,1,6,NULL,'你好',1,'2025-11-28 23:26:34','2025-11-28 23:26:51'),(14,1,6,13,'很棒',0,'2025-11-28 23:26:42','2025-11-28 23:26:42');
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

-- Dump completed on 2025-11-30  1:01:46
