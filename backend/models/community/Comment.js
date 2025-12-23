// backend/models/community/Comment.js
const { pool, execute } = require('../../config/database');

class Comment {
  /**
   * 创建评论
   */
  static async create(commentData) {
    const {
      post_id,
      user_id,
      content,
      parent_comment_id,
      comment_type = 'discussion'
    } = commentData;

    const query = `
      INSERT INTO post_comment 
      (post_id, user_id, content, parent_comment_id, comment_type)
      VALUES (?, ?, ?, ?, ?)
    `;

    const result = await execute(query, [
      post_id,
      user_id,
      content,
      parent_comment_id || null,
      comment_type
    ]);

    return result.insertId;
  }

  /**
   * 获取单个评论
   */
  static async findById(commentId) {
    const query = `
      SELECT 
        pc.*,
        u.user_name,
        u.avatar_url
      FROM post_comment pc
      LEFT JOIN user u ON pc.user_id = u.user_id
      WHERE pc.comment_id = ? AND pc.deleted_time IS NULL
    `;

    const [comments] = await pool.query(query, [commentId]);
    return comments[0] || null;
  }

  /**
   * 获取帖子的评论列表
   */
  static async findByPostId(postId, options = {}) {
    const {
      comment_type,
      parent_comment_id = null,
      page = 1,
      limit = 50,
      orderBy = 'create_time',
      order = 'ASC'
    } = options;

    const offset = (page - 1) * limit;
    let whereClause = 'pc.post_id = ? AND pc.deleted_time IS NULL';
    const params = [postId];

    if (comment_type) {
      whereClause += ' AND pc.comment_type = ?';
      params.push(comment_type);
    }

    if (parent_comment_id === null) {
      whereClause += ' AND pc.parent_comment_id IS NULL';
    } else if (parent_comment_id !== undefined) {
      whereClause += ' AND pc.parent_comment_id = ?';
      params.push(parent_comment_id);
    }

    const query = `
      SELECT 
        pc.*,
        u.user_name,
        u.avatar_url
      FROM post_comment pc
      LEFT JOIN user u ON pc.user_id = u.user_id
      WHERE ${whereClause}
      ORDER BY pc.is_accepted DESC, pc.${orderBy} ${order}
      LIMIT ? OFFSET ?
    `;

    params.push(limit, offset);
    const [comments] = await pool.query(query, params);

    // 获取总数
    const countQuery = `
      SELECT COUNT(*) as total
      FROM post_comment pc
      WHERE ${whereClause}
    `;

    const [countResult] = await pool.query(countQuery, params.slice(0, -2));
    const total = countResult[0]?.total || 0;

    return {
      data: comments,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }

  /**
   * 获取评论的子评论
   */
  static async findReplies(commentId) {
    const query = `
      SELECT 
        pc.*,
        u.user_name,
        u.avatar_url
      FROM post_comment pc
      LEFT JOIN user u ON pc.user_id = u.user_id
      WHERE pc.parent_comment_id = ? AND pc.deleted_time IS NULL
      ORDER BY pc.create_time ASC
    `;

    const [replies] = await pool.query(query, [commentId]);
    return replies;
  }

  /**
   * 更新评论
   */
  static async update(commentId, updateData) {
    const updateFields = [];
    const updateValues = [];

    // 允许更新的字段
    const allowedFields = ['content', 'is_accepted'];
    
    allowedFields.forEach(field => {
      if (updateData[field] !== undefined) {
        updateFields.push(`${field} = ?`);
        updateValues.push(updateData[field]);
      }
    });

    if (updateFields.length === 0) {
      return 0;
    }

    updateValues.push(commentId);

    const query = `
      UPDATE post_comment 
      SET ${updateFields.join(', ')}, update_time = CURRENT_TIMESTAMP
      WHERE comment_id = ? AND deleted_time IS NULL
    `;

    const result = await execute(query, updateValues);
    return result.affectedRows;
  }

  /**
   * 删除评论（软删除）
   */
  static async delete(commentId, userId) {
    const query = `
      UPDATE post_comment 
      SET deleted_time = CURRENT_TIMESTAMP 
      WHERE comment_id = ? AND user_id = ? AND deleted_time IS NULL
    `;

    const result = await execute(query, [commentId, userId]);
    return result.affectedRows;
  }

  /**
   * 更新点赞数
   */
  static async updateLikesCount(commentId, increment) {
    const query = `
      UPDATE post_comment 
      SET likes_count = likes_count ${increment > 0 ? '+' : '-'} 1 
      WHERE comment_id = ? AND deleted_time IS NULL
    `;

    await execute(query, [commentId]);
  }

  /**
   * 检查用户是否已点赞
   */
  static async hasUserLiked(commentId, userId) {
    const query = `
      SELECT like_id FROM comment_like 
      WHERE comment_id = ? AND user_id = ?
    `;

    const [result] = await pool.query(query, [commentId, userId]);
    return result.length > 0;
  }

  /**
   * 添加点赞
   */
  static async addLike(commentId, userId) {
    const query = `
      INSERT INTO comment_like (comment_id, user_id) 
      VALUES (?, ?)
    `;

    try {
      await execute(query, [commentId, userId]);
      return true;
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        return false;
      }
      throw error;
    }
  }

  /**
   * 取消点赞
   */
  static async removeLike(commentId, userId) {
    const query = `
      DELETE FROM comment_like 
      WHERE comment_id = ? AND user_id = ?
    `;

    const result = await execute(query, [commentId, userId]);
    return result.affectedRows > 0;
  }

  /**
   * 标记评论为已采纳
   */
  static async markAsAccepted(commentId) {
    const query = `
      UPDATE post_comment 
      SET is_accepted = 1, update_time = CURRENT_TIMESTAMP
      WHERE comment_id = ? AND deleted_time IS NULL
    `;

    const result = await execute(query, [commentId]);
    return result.affectedRows;
  }

  /**
   * 取消采纳评论
   */
  static async unmarkAsAccepted(commentId) {
    const query = `
      UPDATE post_comment 
      SET is_accepted = 0, update_time = CURRENT_TIMESTAMP
      WHERE comment_id = ? AND deleted_time IS NULL
    `;

    const result = await execute(query, [commentId]);
    return result.affectedRows;
  }

  /**
   * 获取帖子的采纳的评论
   */
  static async getAcceptedComment(postId) {
    const query = `
      SELECT 
        pc.*,
        u.user_name,
        u.avatar_url
      FROM post_comment pc
      LEFT JOIN user u ON pc.user_id = u.user_id
      WHERE pc.post_id = ? AND pc.is_accepted = 1 AND pc.deleted_time IS NULL
      LIMIT 1
    `;

    const [comments] = await pool.query(query, [postId]);
    return comments[0] || null;
  }

  /**
   * 获取用户的评论
   */
  static async findByUserId(userId, options = {}) {
    const { page = 1, limit = 20 } = options;
    const offset = (page - 1) * limit;

    const query = `
      SELECT 
        pc.*,
        u.user_name,
        u.avatar_url,
        p.title as post_title,
        p.category as post_category
      FROM post_comment pc
      LEFT JOIN user u ON pc.user_id = u.user_id
      LEFT JOIN community_post p ON pc.post_id = p.post_id
      WHERE pc.user_id = ? AND pc.deleted_time IS NULL AND p.deleted_time IS NULL
      ORDER BY pc.create_time DESC
      LIMIT ? OFFSET ?
    `;

    const [comments] = await pool.query(query, [userId, limit, offset]);

    const countQuery = `
      SELECT COUNT(*) as total
      FROM post_comment pc
      LEFT JOIN community_post p ON pc.post_id = p.post_id
      WHERE pc.user_id = ? AND pc.deleted_time IS NULL AND p.deleted_time IS NULL
    `;

    const [countResult] = await pool.query(countQuery, [userId]);
    const total = countResult[0]?.total || 0;

    return {
      data: comments,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    };
  }

  /**
   * 获取评论统计
   */
  static async getStats(postId = null) {
    let whereClause = 'deleted_time IS NULL';
    const params = [];

    if (postId) {
      whereClause += ' AND post_id = ?';
      params.push(postId);
    }

    const query = `
      SELECT 
        COUNT(*) as total_comments,
        SUM(CASE WHEN comment_type = 'answer' THEN 1 ELSE 0 END) as answer_count,
        SUM(CASE WHEN comment_type = 'discussion' THEN 1 ELSE 0 END) as discussion_count,
        SUM(CASE WHEN is_accepted = 1 THEN 1 ELSE 0 END) as accepted_count,
        SUM(likes_count) as total_likes
      FROM post_comment
      WHERE ${whereClause}
    `;

    const [result] = await pool.query(query, params);
    return result[0] || {};
  }
}

module.exports = Comment;