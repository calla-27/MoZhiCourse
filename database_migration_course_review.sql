-- 创建课程评价表
CREATE TABLE IF NOT EXISTS `t_course_review` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `course_id` int NOT NULL COMMENT '课程ID',
  `user_id` int NOT NULL COMMENT '用户ID',
  `rating` int NOT NULL COMMENT '评分(1-5星)',
  `review_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '评价内容',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  `updated_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`review_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `fk_course_review_course` FOREIGN KEY (`course_id`) REFERENCES `t_course` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_course_review_user` FOREIGN KEY (`user_id`) REFERENCES `t_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程评价表';
