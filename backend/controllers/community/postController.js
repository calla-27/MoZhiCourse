// backend/controllers/community/postController.js
const Post = require('../../models/community/Post');
const Comment = require('../../models/community/Comment');
const User = require('../../models/userModel'); // 假设有这个模型，如果没有需要创建

// 放在文件顶部，与前面的 safeParseTags 合并即可
function safeParseTags(tagsString) {
  if (!tagsString) return [];
  // 已经是数组
  if (Array.isArray(tagsString)) return tagsString;
  // 已经是 JSON 数组字符串
  if (tagsString.trim().startsWith('[')) {
    try { return JSON.parse(tagsString); } catch { return []; }
  }
  // 逗号分隔的字符串
  return tagsString.split(',').map(t => t.trim()).filter(Boolean);
}

class PostController {
  /**
   * 获取帖子列表
   */
  async getPosts(req, res) {
  try {
    console.log('📝 getPosts - req.user:', req.user);
    console.log('📝 getPosts - req.query:', req.query);
    console.log('📝 getPosts - 认证头:', req.headers.authorization);
    
    // ✅ 优先从认证中间件设置的req.user获取用户ID
    const currentUserId = req.user ? req.user.userId : 
                         (req.query.current_user_id || 0);
    
    console.log('👤 当前用户ID:', currentUserId);
    
    const { 
      category, 
      page = 1, 
      limit = 20, 
      course_id, 
      teacher_id,
      status,
      orderBy = 'create_time',
      order = 'DESC',
      keyword 
    } = req.query;
    
    console.log('🔍 查询参数:', { category, page, limit, orderBy, order, keyword });
    
    // 使用 Model 获取数据
    const result = await Post.findAll({
      category,
      course_id,
      teacher_id,
      status,
      keyword,
      page: parseInt(page),
      limit: parseInt(limit),
      orderBy,
      order
    });

    console.log('📊 查询结果:', { 
      count: result.data ? result.data.length : 0,
      total: result.pagination ? result.pagination.total : 0 
    });

    // 添加用户互动状态
    const postsArray = Array.isArray(result.data) ? result.data : [];
    const postsWithUserStatus = await Promise.all(
      postsArray.map(async post => {
        // 如果用户未登录，所有互动状态为false
        if (!currentUserId || currentUserId === 0) {
          return {
            ...post,
            user_has_liked: false,
            user_has_favorited: false,
            is_owner: false,
            tags: post.tags ? safeParseTags(post.tags) : []
          };
        }
        
        try {
          const [hasLiked, hasFavorited] = await Promise.all([
            Post.hasUserLiked(post.post_id, currentUserId),
            Post.hasUserFavorited(post.post_id, currentUserId)
          ]);

          return {
            ...post,
            user_has_liked: hasLiked,
            user_has_favorited: hasFavorited,
            is_owner: post.author_id == currentUserId,
            tags: safeParseTags(post.tags)
          };
        } catch (error) {
          console.error(`处理帖子 ${post.post_id} 互动状态失败:`, error);
          return {
            ...post,
            user_has_liked: false,
            user_has_favorited: false,
            is_owner: post.author_id == currentUserId,
            tags: safeParseTags(post.tags)
          };
        }
      })
    );

    res.json({
      success: true,
      data: postsWithUserStatus,
      pagination: result.pagination
    });
  } catch (error) {
    console.error('❌ 获取帖子列表失败:', error);
    console.error('❌ 错误堆栈:', error.stack);
    
    res.status(500).json({
      success: false,
      message: '获取帖子列表失败',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
}
  
  /**
   * 获取单个帖子详情
   */
  async getPostById(req, res) {
    try {
      const { id } = req.params;
      const currentUserId = req.query.current_user_id || req.user?.userId || 0;
      
      // 增加浏览量
      await Post.incrementViews(id);
      
      // 获取帖子详情
      const post = await Post.findById(id);
      
      if (!post) {
        return res.status(404).json({
          success: false,
          message: '帖子不存在'
        });
      }
      
      // 获取用户互动状态
      const [hasLiked, hasFavorited] = await Promise.all([
        Post.hasUserLiked(id, currentUserId),
        Post.hasUserFavorited(id, currentUserId)
      ]);
      
      // 格式化数据
      const postWithUserStatus = {
        ...post,
        user_has_liked: hasLiked,
        user_has_favorited: hasFavorited,
        is_owner: post.author_id == currentUserId,
        tags: safeParseTags(post.tags)
      };
      
      res.json({
        success: true,
        data: postWithUserStatus
      });
    } catch (error) {
      console.error('获取帖子详情失败:', error);
      res.status(500).json({
        success: false,
        message: '获取帖子详情失败'
      });
    }
  }
  
  /**
   * 创建帖子
   */
  async createPost(req, res) {
    try {
      const {
        title,
        content,
        category = 'discussion',
        course_id,
        teacher_id,
        tags = []
      } = req.body;
      
      const author_id = req.body.user_id || req.user?.userId;
      
      if (!title || !content || !author_id) {
        return res.status(400).json({
          success: false,
          message: '标题、内容和作者ID不能为空'
        });
      }
      
      // 验证category
      if (!['discussion', 'question', 'help'].includes(category)) {
        return res.status(400).json({
          success: false,
          message: '无效的帖子分类'
        });
      }
      
      // 对于名师答疑，需要验证教师存在
      if (category === 'question' && teacher_id) {
        // 这里需要验证教师是否存在，假设有User模型
        const teacher = await User.findById(teacher_id);
        if (!teacher || teacher.role !== 'instructor') {
          return res.status(400).json({
            success: false,
            message: '指定的教师不存在'
          });
        }
      }
      
      // 准备帖子数据
      const postData = {
        title,
        content,
        author_id,
        category,
        course_id: course_id || null,
        teacher_id: category === 'question' ? teacher_id : null,
        tags: Array.isArray(tags) ? tags : (tags ? tags.split(',').map(tag => tag.trim()).filter(Boolean) : [])
      };
      
      // 创建帖子
      const postId = await Post.create(postData);
      
      // 获取新创建的帖子
      const newPost = await Post.findById(postId);
      
      if (!newPost) {
        throw new Error('帖子创建后无法获取');
      }
      
      // 格式化返回数据
      const formattedPost = {
        ...newPost,
        tags: newPost.tags ? JSON.parse(newPost.tags) : [],
        is_owner: true,
        user_has_liked: false,
        user_has_favorited: false
      };
      
      res.status(201).json({
        success: true,
        message: '帖子创建成功',
        data: formattedPost
      });
    } catch (error) {
      console.error('创建帖子失败:', error);
      res.status(500).json({
        success: false,
        message: '创建帖子失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }
  
  /**
   * 更新帖子
   */
  async updatePost(req, res) {
    try {
      const { id } = req.params;
      const {
        title,
        content,
        category,
        course_id,
        teacher_id,
        tags,
        status
      } = req.body;
      
      const userId = req.body.user_id || req.user?.userId;
      
      // 检查帖子是否存在
      const post = await Post.findById(id);
      
      if (!post) {
        return res.status(404).json({
          success: false,
          message: '帖子不存在'
        });
      }
      
      // 只有作者可以更新
      if (post.author_id != userId) {
        return res.status(403).json({
          success: false,
          message: '无权修改此帖子'
        });
      }
      
      // 准备更新数据
      const updateData = {};
      if (title !== undefined) updateData.title = title;
      if (content !== undefined) updateData.content = content;
      if (category !== undefined) updateData.category = category;
      if (course_id !== undefined) updateData.course_id = course_id;
      if (teacher_id !== undefined) updateData.teacher_id = teacher_id;
      if (tags !== undefined) {
        updateData.tags = Array.isArray(tags) ? tags : (tags ? tags.split(',').map(tag => tag.trim()).filter(Boolean) : []);
      }
      if (status !== undefined) updateData.status = status;
      
      // 更新帖子
      const affectedRows = await Post.update(id, updateData);
      
      if (affectedRows === 0) {
        return res.status(400).json({
          success: false,
          message: '没有可更新的字段'
        });
      }
      
      // 获取更新后的帖子
      const updatedPost = await Post.findById(id);
      
      res.json({
        success: true,
        message: '帖子更新成功',
        data: {
          ...updatedPost,
          tags: updatedPost.tags ? JSON.parse(updatedPost.tags) : [],
          is_owner: true
        }
      });
    } catch (error) {
      console.error('更新帖子失败:', error);
      res.status(500).json({
        success: false,
        message: '更新帖子失败'
      });
    }
  }
  
  /**
   * 删除帖子（软删除）
   */
  async deletePost(req, res) {
    try {
      const { id } = req.params;
      const userId = req.body.user_id || req.user?.userId;
      
      // 检查帖子是否存在
      const post = await Post.findById(id);
      
      if (!post) {
        return res.status(404).json({
          success: false,
          message: '帖子不存在'
        });
      }
      
      // 只有作者可以删除
      if (post.author_id != userId) {
        return res.status(403).json({
          success: false,
          message: '无权删除此帖子'
        });
      }
      
      // 删除帖子
      const affectedRows = await Post.delete(id, userId);
      
      if (affectedRows === 0) {
        return res.status(400).json({
          success: false,
          message: '帖子删除失败'
        });
      }
      
      res.json({
        success: true,
        message: '帖子删除成功'
      });
    } catch (error) {
      console.error('删除帖子失败:', error);
      res.status(500).json({
        success: false,
        message: '删除帖子失败'
      });
    }
  }
  
  /**
   * 点赞/取消点赞帖子
   */
  async togglePostLike(req, res) {
    try {
      const { id } = req.params;
      const userId = req.body.user_id || req.user?.userId;
      
      // 检查帖子是否存在
      const post = await Post.findById(id);
      
      if (!post) {
        return res.status(404).json({
          success: false,
          message: '帖子不存在'
        });
      }
      
      let action;
      let likeCount;
      
      // 检查是否已点赞
      const hasLiked = await Post.hasUserLiked(id, userId);
      
      if (hasLiked) {
        // 取消点赞
        await Post.removeLike(id, userId);
        await Post.updateLikesCount(id, -1);
        action = 'unliked';
        likeCount = Math.max(0, post.likes_count - 1);
      } else {
        // 添加点赞
        await Post.addLike(id, userId);
        await Post.updateLikesCount(id, 1);
        action = 'liked';
        likeCount = post.likes_count + 1;
      }
      
      res.json({
        success: true,
        message: action === 'liked' ? '点赞成功' : '取消点赞成功',
        data: {
          liked: action === 'liked',
          like_count: likeCount
        }
      });
    } catch (error) {
      console.error('操作点赞失败:', error);
      res.status(500).json({
        success: false,
        message: '操作点赞失败'
      });
    }
  }
  
  /**
   * 收藏/取消收藏帖子
   */
  async togglePostFavorite(req, res) {
    try {
      const { id } = req.params;
      const userId = req.body.user_id || req.user?.userId;
      
      // 检查帖子是否存在
      const post = await Post.findById(id);
      
      if (!post) {
        return res.status(404).json({
          success: false,
          message: '帖子不存在'
        });
      }
      
      let action;
      let favoriteCount;
      
      // 检查是否已收藏
      const hasFavorited = await Post.hasUserFavorited(id, userId);
      
      if (hasFavorited) {
        // 取消收藏
        await Post.removeFavorite(id, userId);
        await Post.updateFavoritesCount(id, -1);
        action = 'unfavorited';
        favoriteCount = Math.max(0, post.favorites_count - 1);
      } else {
        // 添加收藏
        await Post.addFavorite(id, userId);
        await Post.updateFavoritesCount(id, 1);
        action = 'favorited';
        favoriteCount = post.favorites_count + 1;
      }
      
      res.json({
        success: true,
        message: action === 'favorited' ? '收藏成功' : '取消收藏成功',
        data: {
          favorited: action === 'favorited',
          favorite_count: favoriteCount
        }
      });
    } catch (error) {
      console.error('操作收藏失败:', error);
      res.status(500).json({
        success: false,
        message: '操作收藏失败'
      });
    }
  }
  
  /**
   * 标记帖子为已解决（用于名师答疑和互助学习）
   */
  async markPostSolved(req, res) {
    try {
      const { id } = req.params;
      const { solved_comment_id, user_id } = req.body;
      const userId = user_id || req.user?.userId;
      
      if (!solved_comment_id) {
        return res.status(400).json({
          success: false,
          message: '需要指定采纳的评论ID'
        });
      }
      
      // 检查帖子是否存在
      const post = await Post.findById(id);
      
      if (!post) {
        return res.status(404).json({
          success: false,
          message: '帖子不存在'
        });
      }
      
      // 只有作者可以标记解决
      if (post.author_id != userId) {
        return res.status(403).json({
          success: false,
          message: '无权标记此帖子为已解决'
        });
      }
      
      // 检查评论是否存在且属于此帖子
      const comment = await Comment.findById(solved_comment_id);
      
      if (!comment || comment.post_id != id) {
        return res.status(400).json({
          success: false,
          message: '评论不存在或不属于此帖子'
        });
      }
      
      // 标记评论为已采纳
      await Comment.markAsAccepted(solved_comment_id);
      
      // 更新帖子状态
      await Post.markAsSolved(id, solved_comment_id);
      
      res.json({
        success: true,
        message: '帖子已标记为已解决'
      });
    } catch (error) {
      console.error('标记帖子解决失败:', error);
      res.status(500).json({
        success: false,
        message: '标记帖子解决失败'
      });
    }
  }
  
/**
 * 获取名师列表（用于名师答疑）
 */
async getTeachers(req, res) {
  try {
    const { limit = 8, keyword } = req.query;
    
    let whereClause = 'u.role = "instructor"';
    const params = [];
    
    if (keyword) {
      whereClause += ' AND u.user_name LIKE ?';
      params.push(`%${keyword}%`);
    }
    
    const db = require('../../config/database');
    const query = `
      SELECT 
        u.user_id,
        u.user_name,
        u.avatar_url,
        ud.user_intro,
        COUNT(DISTINCT c.course_id) as course_count,
        COUNT(DISTINCT uc.user_id) as total_students,
        AVG(cr.rating) as avg_rating
      FROM user u
      LEFT JOIN user_detail ud ON u.user_id = ud.user_id
      LEFT JOIN course c ON u.user_id = c.teacher_user_id
      LEFT JOIN user_course uc ON c.course_id = uc.course_id
      LEFT JOIN course_review cr ON c.course_id = cr.course_id
      WHERE ${whereClause}
      GROUP BY u.user_id, u.user_name, u.avatar_url, ud.user_intro
      ORDER BY avg_rating DESC, course_count DESC
      LIMIT ?
    `;
    
    params.push(parseInt(limit));
    
    // 使用 pool.query 而不是 db.query
    const [teachers] = await db.pool.query(query, params);
    
    res.json({
      success: true,
      data: teachers
    });
  } catch (error) {
    console.error('获取名师列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取名师列表失败'
    });
  }
}
  
  /**
   * 获取热门帖子
   */
  async getHotPosts(req, res) {
    try {
      const { category, limit = 10 } = req.query;
      
      const hotPosts = await Post.getHotPosts(category, parseInt(limit));
      
      // 格式化数据
      const formattedPosts = hotPosts.map(post => ({
        ...post,
        tags: post.tags ? JSON.parse(post.tags) : []
      }));
      
      res.json({
        success: true,
        data: formattedPosts
      });
    } catch (error) {
      console.error('获取热门帖子失败:', error);
      res.status(500).json({
        success: false,
        message: '获取热门帖子失败'
      });
    }
  }
  
  /**
   * 获取用户收藏的帖子
   */
  async getUserFavorites(req, res) {
    try {
      const userId = req.params.userId || req.query.user_id || req.user?.userId;
      const { page = 1, limit = 20 } = req.query;
      
      if (!userId) {
        return res.status(400).json({
          success: false,
          message: '用户ID不能为空'
        });
      }
      
      const result = await Post.getUserFavorites(userId, {
        page: parseInt(page),
        limit: parseInt(limit)
      });
      
      // 格式化数据
      const formattedPosts = result.data.map(post => ({
        ...post,
        tags: post.tags ? JSON.parse(post.tags) : [],
        user_has_liked: false, // 需要在客户端重新获取
        user_has_favorited: true,
        is_owner: post.author_id == userId
      }));
      
      res.json({
        success: true,
        data: formattedPosts,
        pagination: result.pagination
      });
    } catch (error) {
      console.error('获取用户收藏失败:', error);
      res.status(500).json({
        success: false,
        message: '获取用户收藏失败'
      });
    }
  }
  
  /**
   * 获取社区统计数据
   */
  async getStats(req, res) {
    try {
      const postStats = await Post.getStats();
      const commentStats = await Comment.getStats();
      
      res.json({
        success: true,
        data: {
          posts: postStats,
          comments: commentStats
        }
      });
    } catch (error) {
      console.error('获取统计数据失败:', error);
      res.status(500).json({
        success: false,
        message: '获取统计数据失败'
      });
    }
  }
}

module.exports = new PostController();