// backend/models/community/Post.js
const { pool, execute } = require('../../config/database');

class Post {
  /**
   * 创建帖子
   */
  static async create(postData) {
    const {
      title,
      content,
      author_id,
      category,
      course_id,
      teacher_id,
      tags,
      status = 'open'
    } = postData;

    const query = `
      INSERT INTO community_post 
      (title, content, author_id, category, course_id, teacher_id, tags, status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const result = await execute(query, [
      title,
      content,
      author_id,
      category,
      course_id || null,
      category === 'question' ? teacher_id : null,
      JSON.stringify(tags || []),
      status
    ]);

    return result.insertId;
  }

  /**
   * 获取单个帖子
   */
  static async findById(postId) {
    const query = `
      SELECT 
        p.*,
        u.user_name as author_name,
        u.avatar_url as author_avatar,
        c.course_name,
        tu.user_name as teacher_name,
        tu.avatar_url as teacher_avatar
      FROM community_post p
      LEFT JOIN user u ON p.author_id = u.user_id
      LEFT JOIN course c ON p.course_id = c.course_id
      LEFT JOIN user tu ON p.teacher_id = tu.user_id
      WHERE p.post_id = ? AND p.deleted_time IS NULL
    `;

    const [posts] = await pool.query(query, [postId]);
    return posts[0] || null;
  }

  /**
   * 获取帖子列表
   */
  static async findAll(options = {}) {
    try {
      const {
        category,
        course_id,
        teacher_id,
        status,
        author_id,
        keyword,
        page = 1,
        limit = 20,
        orderBy = 'create_time',
        order = 'DESC'
      } = options;

      console.log('📋 Post.findAll 参数:', options);

      const offset = (page - 1) * limit;
      let whereClause = 'p.deleted_time IS NULL';
      const params = [];

      if (category) {
        whereClause += ' AND p.category = ?';
        params.push(category);
      }

      if (course_id) {
        whereClause += ' AND p.course_id = ?';
        params.push(course_id);
      }

      if (teacher_id) {
        whereClause += ' AND p.teacher_id = ?';
        params.push(teacher_id);
      }

      if (status) {
        whereClause += ' AND p.status = ?';
        params.push(status);
      }

      if (author_id) {
        whereClause += ' AND p.author_id = ?';
        params.push(author_id);
      }

      if (keyword) {
        whereClause += ' AND (p.title LIKE ? OR p.content LIKE ?)';
        params.push(`%${keyword}%`, `%${keyword}%`);
      }

      const query = `
        SELECT 
          p.*,
          u.user_name as author_name,
          u.avatar_url as author_avatar,
          c.course_name,
          tu.user_name as teacher_name
        FROM community_post p
        LEFT JOIN user u ON p.author_id = u.user_id
        LEFT JOIN course c ON p.course_id = c.course_id
        LEFT JOIN user tu ON p.teacher_id = tu.user_id
        WHERE ${whereClause}
        ORDER BY p.${orderBy} ${order}
        LIMIT ? OFFSET ?
      `;

      console.log('📝 SQL查询:', query);
      console.log('📝 参数:', params.concat([limit, offset]));

      params.push(limit, offset);
      const [posts] = await pool.query(query, params);

      console.log('✅ 查询成功，获取到', posts.length, '条记录');

      // 获取总数
      const countQuery = `
        SELECT COUNT(*) as total
        FROM community_post p
        WHERE ${whereClause}
      `;
      
      const [countResult] = await pool.query(countQuery, params.slice(0, -2));
      const total = countResult[0]?.total || 0;

      return {
        data: posts,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      console.error('❌ Post.findAll 错误:', error);
      console.error('❌ 错误堆栈:', error.stack);
      throw error;
    }
  }

  /**
   * 更新帖子
   */
  static async update(postId, updateData) {
    const updateFields = [];
    const updateValues = [];

    // 允许更新的字段
    const allowedFields = ['title', 'content', 'category', 'course_id', 'teacher_id', 'tags', 'status'];
    
    allowedFields.forEach(field => {
      if (updateData[field] !== undefined) {
        if (field === 'tags') {
          updateFields.push(`${field} = ?`);
          updateValues.push(JSON.stringify(updateData[field]));
        } else {
          updateFields.push(`${field} = ?`);
          updateValues.push(updateData[field]);
        }
      }
    });

    if (updateFields.length === 0) {
      return 0;
    }

    updateValues.push(postId);

    const query = `
      UPDATE community_post 
      SET ${updateFields.join(', ')}, update_time = CURRENT_TIMESTAMP
      WHERE post_id = ? AND deleted_time IS NULL
    `;

    const result = await execute(query, updateValues);
    return result.affectedRows;
  }

  /**
   * 删除帖子（软删除）
   */
  static async delete(postId, userId) {
    const query = `
      UPDATE community_post 
      SET deleted_time = CURRENT_TIMESTAMP 
      WHERE post_id = ? AND author_id = ? AND deleted_time IS NULL
    `;

    const result = await execute(query, [postId, userId]);
    return result.affectedRows;
  }

  /**
   * 增加浏览量
   */
  static async incrementViews(postId) {
    const query = `
      UPDATE community_post 
      SET views_count = views_count + 1 
      WHERE post_id = ? AND deleted_time IS NULL
    `;

    await execute(query, [postId]);
  }

  /**
   * 更新点赞数
   */
  static async updateLikesCount(postId, increment) {
    const query = `
      UPDATE community_post 
      SET likes_count = likes_count ${increment > 0 ? '+' : '-'} 1 
      WHERE post_id = ? AND deleted_time IS NULL
    `;

    await execute(query, [postId]);
  }

  /**
   * 更新收藏数
   */
  static async updateFavoritesCount(postId, increment) {
    const query = `
      UPDATE community_post 
      SET favorites_count = favorites_count ${increment > 0 ? '+' : '-'} 1 
      WHERE post_id = ? AND deleted_time IS NULL
    `;

    await execute(query, [postId]);
  }

  /**
   * 更新评论数
   */
  static async updateCommentsCount(postId, increment) {
    const query = `
      UPDATE community_post 
      SET comments_count = comments_count ${increment > 0 ? '+' : '-'} 1 
      WHERE post_id = ? AND deleted_time IS NULL
    `;

    await execute(query, [postId]);
  }

  /**
   * 标记帖子为已解决
   */
  static async markAsSolved(postId, solvedCommentId) {
    const query = `
      UPDATE community_post 
      SET status = 'solved', solved_comment_id = ?, update_time = CURRENT_TIMESTAMP
      WHERE post_id = ? AND deleted_time IS NULL
    `;

    const result = await execute(query, [solvedCommentId, postId]);
    return result.affectedRows;
  }

  /**
   * 检查用户是否已点赞
   */
  static async hasUserLiked(postId, userId) {
    const query = `
      SELECT like_id FROM post_like 
      WHERE post_id = ? AND user_id = ?
    `;

    const [result] = await pool.query(query, [postId, userId]);
    return result.length > 0;
  }

  /**
   * 检查用户是否已收藏
   */
  static async hasUserFavorited(postId, userId) {
    const query = `
      SELECT favorite_id FROM post_favorite 
      WHERE post_id = ? AND user_id = ?
    `;

    const [result] = await pool.query(query, [postId, userId]);
    return result.length > 0;
  }

  /**
   * 添加点赞
   */
  static async addLike(postId, userId) {
    const query = `
      INSERT INTO post_like (post_id, user_id) 
      VALUES (?, ?)
    `;

    try {
      await execute(query, [postId, userId]);
      return true;
    } catch (error) {
      // 如果是唯一约束冲突，说明已经点赞过了
      if (error.code === 'ER_DUP_ENTRY') {
        return false;
      }
      throw error;
    }
  }

  /**
   * 取消点赞
   */
  static async removeLike(postId, userId) {
    const query = `
      DELETE FROM post_like 
      WHERE post_id = ? AND user_id = ?
    `;

    const result = await execute(query, [postId, userId]);
    return result.affectedRows > 0;
  }

  /**
   * 添加收藏
   */
  static async addFavorite(postId, userId) {
    const query = `
      INSERT INTO post_favorite (post_id, user_id) 
      VALUES (?, ?)
    `;

    try {
      await execute(query, [postId, userId]);
      return true;
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        return false;
      }
      throw error;
    }
  }

  /**
   * 取消收藏
   */
  static async removeFavorite(postId, userId) {
    const query = `
      DELETE FROM post_favorite 
      WHERE post_id = ? AND user_id = ?
    `;

    const result = await execute(query, [postId, userId]);
    return result.affectedRows > 0;
  }

  /**
   * 获取用户收藏的帖子
   */
  static async getUserFavorites(userId, options = {}) {
    const { page = 1, limit = 20 } = options;
    const offset = (page - 1) * limit;

    const query = `
      SELECT 
        p.*,
        u.user_name as author_name,
        u.avatar_url as author_avatar,
        c.course_name,
        tu.user_name as teacher_name
      FROM community_post p
      INNER JOIN post_favorite pf ON p.post_id = pf.post_id
      LEFT JOIN user u ON p.author_id = u.user_id
      LEFT JOIN course c ON p.course_id = c.course_id
      LEFT JOIN user tu ON p.teacher_id = tu.user_id
      WHERE pf.user_id = ? AND p.deleted_time IS NULL
      ORDER BY pf.create_time DESC
      LIMIT ? OFFSET ?
    `;

    const [posts] = await pool.query(query, [userId, limit, offset]);

    const countQuery = `
      SELECT COUNT(*) as total
      FROM community_post p
      INNER JOIN post_favorite pf ON p.post_id = pf.post_id
      WHERE pf.user_id = ? AND p.deleted_time IS NULL
    `;

    const [countResult] = await pool.query(countQuery, [userId]);
    const total = countResult[0]?.total || 0;

    return {
      data: posts,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }

  /**
   * 获取热门帖子
   */
  static async getHotPosts(category = null, limit = 10) {
    let whereClause = 'p.deleted_time IS NULL';
    const params = [];

    if (category) {
      whereClause += ' AND p.category = ?';
      params.push(category);
    }

    const query = `
      SELECT 
        p.*,
        u.user_name as author_name,
        u.avatar_url as author_avatar,
        c.course_name
      FROM community_post p
      LEFT JOIN user u ON p.author_id = u.user_id
      LEFT JOIN course c ON p.course_id = c.course_id
      WHERE ${whereClause}
      ORDER BY (p.likes_count * 0.4 + p.comments_count * 0.3 + p.views_count * 0.2 + p.favorites_count * 0.1) DESC
      LIMIT ?
    `;

    params.push(limit);
    const [posts] = await pool.query(query, params);
    return posts;
  }

  /**
   * 获取统计数据
   */
  static async getStats() {
    const query = `
      SELECT 
        COUNT(*) as total_posts,
        SUM(CASE WHEN category = 'discussion' THEN 1 ELSE 0 END) as discussion_count,
        SUM(CASE WHEN category = 'question' THEN 1 ELSE 0 END) as question_count,
        SUM(CASE WHEN category = 'help' THEN 1 ELSE 0 END) as help_count,
        SUM(likes_count) as total_likes,
        SUM(comments_count) as total_comments,
        SUM(views_count) as total_views
      FROM community_post
      WHERE deleted_time IS NULL
    `;

    const [result] = await pool.query(query);
    return result[0] || {};
  }
}

module.exports = Post;