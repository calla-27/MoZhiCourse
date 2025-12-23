-- 创建视频评论点赞表
-- 用于实现评论点赞的toggle功能（点一次添加，再点一次删除）

USE mzcourse;

-- 删除旧表（如果存在）
DROP TABLE IF EXISTS `video_comment_like`;

-- 创建视频评论点赞表
CREATE TABLE `video_comment_like` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` INT NOT NULL COMMENT '用户ID',
  `comment_id` INT NOT NULL COMMENT '评论ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_comment_like` (`user_id`, `comment_id`) COMMENT '同一用户对同一评论只能点赞一次',
  KEY `idx_user_id` (`user_id`),
  KEY `idx_comment_id` (`comment_id`),
  CONSTRAINT `fk_video_comment_like_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_video_comment_like_comment` FOREIGN KEY (`comment_id`) REFERENCES `video_comment` (`comment_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='视频评论点赞表';

-- 验证表创建成功
SELECT 'video_comment_like 表创建成功！' AS message;
DESCRIBE video_comment_like;
