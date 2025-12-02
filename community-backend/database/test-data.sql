USE community;

-- 清空现有数据（可选，用于重置）
-- DELETE FROM t_post_comment;
-- DELETE FROM t_community_post;
-- DELETE FROM t_room_member;
-- DELETE FROM t_study_room;
-- DELETE FROM t_team_member;
-- DELETE FROM t_study_team;
-- DELETE FROM t_achievement;
-- DELETE FROM t_learning_detail;
-- DELETE FROM t_user_behavior;
-- DELETE FROM t_course;
-- DELETE FROM t_user;

-- 插入测试用户
INSERT INTO t_user (user_name, email, password_hash, role, user_intro, learning_goal) VALUES 
('张三', 'zhangsan@test.com', '$2a$10$examplehash', 'learner', '热爱编程的大学生，喜欢学习新技术', '掌握全栈开发技能'),
('李老师', 'lilaoshi@test.com', '$2a$10$examplehash', 'instructor', '资深全栈开发工程师，8年开发经验', '培养更多优秀的开发者'),
('王工程师', 'wang@test.com', '$2a$10$examplehash', 'instructor', '前端架构师，React专家', '分享前端最佳实践'),
('赵同学', 'zhao@test.com', '$2a$10$examplehash', 'learner', '计算机专业学生，正在准备面试', '提升算法和项目能力'),
('刘学姐', 'liu@test.com', '$2a$10$examplehash', 'learner', '已工作2年的前端开发者', '深入学习后端技术');

-- 插入测试课程
INSERT INTO t_course (course_name, course_desc, teacher_user_id, difficulty_level, course_duration, tags) VALUES 
('Python全栈开发', '从零开始学习Python Web开发，涵盖Django、Flask等框架', 2, 'beginner', 1800, '["Python", "Web开发", "后端"]'),
('React高级实战', '深入学习React和现代前端技术，包括Hooks、状态管理等', 3, 'intermediate', 1200, '["React", "前端", "JavaScript"]'),
('Node.js后端开发', '掌握Node.js和服务端开发，构建高性能API', 2, 'intermediate', 1500, '["Node.js", "后端", "JavaScript"]'),
('数据结构与算法','系统学习数据结构和算法，提升编程能力', 3, 'advanced', 2000, '["算法", "数据结构", "面试"]');

-- 插入测试学习小组
INSERT INTO t_study_team (team_name, description, course_id, creator_id, max_members, tags) VALUES 
('Python进阶学习组', '专注于Python高级特性和项目实战，每周完成一个实战项目', 1, 1, 10, '["Python", "进阶", "项目实战"]'),
('Web全栈开发小队', '从前端到后端，系统学习现代Web开发技术栈', 2, 1, 8, '["前端", "后端", "全栈"]'),
('数据结构与算法攻坚', '每日一题，共同攻克算法难题，备战技术面试', 4, 4, 15, '["算法", "数据结构", "面试"]'),
('React深度研究', '深入理解React原理和最佳实践', 2, 5, 6, '["React", "深度", "原理"]');

-- 添加测试小组任务
INSERT INTO t_team_task (team_id, creator_id, task_title, task_content, deadline, status) VALUES 
(1, 1, '完成Python装饰器学习', '学习并实践Python装饰器的使用，完成相关练习', '2024-12-31 23:59:59', 'pending'),
(1, 4, '项目实战：Web爬虫', '使用requests和BeautifulSoup完成一个简单的网页爬虫', '2024-12-28 23:59:59', 'in_progress'),
(2, 1, 'React组件开发', '完成用户管理组件的开发', '2024-12-25 23:59:59', 'completed');

-- 插入测试自习室
INSERT INTO t_study_room (room_name, description, creator_id, max_participants, schedule_time, tags, rules) VALUES 
('清晨专注自习室', '早起的鸟儿有虫吃，清晨高效学习', 1, 50, '06:00-09:00', '["清晨", "高效", "专注"]', '保持安静，专注学习，互相鼓励'),
('深夜学习小组', '夜猫子专属，深夜学习不孤单', 4, 30, '22:00-02:00', '["深夜", "专注", "夜猫"]', '互相监督，共同进步，保持活跃'),
('Python专项练习室', 'Python学习者专属自习空间', 1, 100, '全天开放', '["Python", "编程", "练习"]', '专注Python学习，可以讨论技术问题'),
('算法刷题专用', '专注算法刷题和面试准备', 4, 40, '19:00-23:00', '["算法", "刷题", "面试"]', '每日完成指定题目，分享解题思路');

-- 添加测试自习室留言
INSERT INTO t_room_message (room_id, user_id, content, message_type) VALUES 
(1, 1, '大家早上好！今天准备学习Python装饰器', 'text'),
(1, 4, '有人一起刷算法题吗？', 'text'),
(2, 4, '深夜学习小组开始啦！', 'text'),
(2, 5, '今晚目标：完成React Hooks学习', 'text');

-- 添加成就类型
INSERT INTO t_achievement_type (achievement_name, description, condition_type, condition_value, icon_url) VALUES 
('学习达人', '连续学习7天', 'continuous_days', 7, '/icons/study_master.png'),
('活跃分子', '发表5个帖子', 'post_count', 5, '/icons/active_member.png'),
('算法高手', '完成50道算法题', 'algorithm_solved', 50, '/icons/algorithm_master.png'),
('热心助人', '帮助10个同学', 'help_count', 10, '/icons/helpful.png');

-- 插入测试帖子 - 现在包含 qa_teacher 类型
INSERT INTO t_community_post (user_id, post_type, title, content, course_id, tags) VALUES 
(1, 'discussion', 'Python中的装饰器有什么实际应用场景？', '在学习装饰器的时候感觉理解起来有点抽象，想知道在实际项目中装饰器一般用在哪些地方？有没有具体的例子可以参考？我在写Flask项目时看到很多装饰器，但不太理解其原理。', 1, '["Python", "装饰器", "Flask"]'),
(4, 'discussion', 'React Hooks使用疑问', '在使用useEffect时，依赖数组应该怎么设置？有时候会出现无限循环的问题，特别是在处理异步操作时。有没有最佳实践可以分享？', 2, '["React", "Hooks", "useEffect"]'),
(1, 'qa_help', '求助：Django模型关联查询问题', '在Django中如何实现多表关联查询？我在使用ForeignKey时遇到了问题，查询结果总是为空。具体的模型定义如下...', 1, '["Django", "数据库", "ForeignKey"]'),
(5, 'discussion', '分享一个前端性能优化技巧', '最近在项目中发现了使用React.memo和useCallback可以显著减少不必要的重渲染，特别是在大型列表中效果明显。具体实现方法如下...', 2, '["React", "性能优化", "前端"]'),
(4, 'qa_help', '算法题：二叉树路径求和', '在做LeetCode第113题时遇到了困难，求二叉树中路径和等于目标值的所有路径，我的递归实现总是漏掉一些情况。求大神指导！', 4, '["算法", "二叉树", "LeetCode"]'),
(2, 'qa_teacher', 'Python装饰器详解与实战应用', '很多同学对Python装饰器的理解不够深入，这里我详细讲解装饰器的原理和实际应用场景，包括权限验证、日志记录、性能监控等。', 1, '["Python", "装饰器", "高级特性"]'),
(3, 'qa_teacher', 'React性能优化最佳实践', '针对React应用性能优化，我总结了几个关键点：组件懒加载、Memoization、代码分割等，结合实际案例讲解。', 2, '["React", "性能优化", "最佳实践"]'),
(2, 'qa_teacher', 'Node.js异步编程核心原理', '深入讲解Node.js事件循环、Promise、async/await等异步编程机制，帮助大家理解Node.js的高并发原理。', 3, '["Node.js", "异步编程", "事件循环"]');

-- 插入测试评论
INSERT INTO t_post_comment (post_id, user_id, content) VALUES 
(1, 2, '装饰器在实际项目中常用于：1. 权限验证 2. 日志记录 3. 性能监控 4. 缓存实现。比如在Web框架中，可以用装饰器来检查用户登录状态。'),
(1, 3, '举个例子：@login_required 就是一个典型的装饰器，用来保护需要登录才能访问的视图函数。'),
(2, 2, 'useEffect的依赖数组要根据实际使用的变量来设置。如果出现无限循环，检查是否在effect内部修改了依赖项的状态。'),
(3, 2, 'Django的关联查询可以使用双下划线语法，比如：ModelA.objects.filter(modelb__name="xxx")。'),
(6, 1, '李老师讲得太好了！终于理解装饰器的应用场景了。'),
(7, 4, '王老师的性能优化技巧很实用，我们的项目正好用上了！');

-- 插入小组成员
INSERT INTO t_team_member (team_id, user_id, role, status) VALUES 
(1, 1, 'leader', 'active'),
(1, 4, 'member', 'active'),
(1, 5, 'member', 'active'),
(2, 1, 'leader', 'active'),
(2, 3, 'member', 'active'),
(3, 4, 'leader', 'active'),
(3, 1, 'member', 'active');

-- 插入自习室成员
INSERT INTO t_room_member (room_id, user_id, study_goal, current_task) VALUES 
(1, 1, '完成Python项目', 'Django模型设计'),
(1, 4, '算法刷题', '二叉树相关题目'),
(2, 4, '准备面试', '复习数据结构'),
(2, 5, '学习React', 'Hooks深入理解'),
(3, 1, 'Python学习', '装饰器掌握'),
(3, 3, '教学准备', '课程内容整理');

-- 插入成就
INSERT INTO t_achievement (user_id, achievement_type, achievement_name, description) VALUES 
(1, 'learning', '学习达人', '连续学习7天'),
(1, 'community', '活跃分子', '发表5个帖子'),
(4, 'learning', '算法高手', '完成50道算法题'),
(5, 'community', '热心助人', '帮助10个同学');

-- 插入学习行为数据
INSERT INTO t_user_behavior (user_id, course_id, behavior_type, keyword, stay_duration) VALUES 
(1, 1, 'search', 'Python装饰器', 120),
(1, 1, 'view_course', NULL, 300),
(4, 4, 'search', '二叉树遍历', 180),
(5, 2, 'view_course', NULL, 240);

-- 插入学习详情
INSERT INTO t_learning_detail (user_id, course_id, learn_duration, play_speed, pause_count, complete_rate) VALUES 
(1, 1, 3600, 1.0, 3, 85.50),
(4, 4, 2800, 1.0, 8, 72.00),
(5, 2, 4200, 1.2, 2, 95.00),
(1, 1, 1800, 1.0, 1, 45.00);

-- 在插入测试评论后，更新帖子的评论数
UPDATE t_community_post 
SET comment_count = (
    SELECT COUNT(*) 
    FROM t_post_comment 
    WHERE post_id = t_community_post.post_id
);