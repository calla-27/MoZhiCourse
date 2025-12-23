-- 为用户添加头像
-- 根据READ.md中提供的头像URL

USE mzcourse;

-- 更新现有用户的头像（使用avatar_url字段）
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/1.jpg' WHERE user_id = 6;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/2.jpg' WHERE user_id = 7;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/3.jpg' WHERE user_id = 8;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/4.jpg' WHERE user_id = 9;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/5.jpg' WHERE user_id = 10;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/6.jpg' WHERE user_id = 11;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/7.jpg' WHERE user_id = 12;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/8.jpg' WHERE user_id = 14;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/9.jpg' WHERE user_id = 101;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/10.jpg' WHERE user_id = 102;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/11.png' WHERE user_id = 103;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/12.jpg' WHERE user_id = 104;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/1.jpg' WHERE user_id = 105;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/2.jpg' WHERE user_id = 106;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/3.jpg' WHERE user_id = 107;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/4.jpg' WHERE user_id = 108;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/5.jpg' WHERE user_id = 109;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/6.jpg' WHERE user_id = 110;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/7.jpg' WHERE user_id = 111;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/8.jpg' WHERE user_id = 112;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/9.jpg' WHERE user_id = 113;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/10.jpg' WHERE user_id = 114;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/11.png' WHERE user_id = 115;
UPDATE user SET avatar_url = 'https://wuyingyunshang.oss-cn-shanghai.aliyuncs.com/img/user_image/12.jpg' WHERE user_id = 116;

SELECT '✅ 用户头像更新完成！' AS message;
SELECT user_id, user_name, avatar_url FROM user WHERE role = 'learner' LIMIT 20;
