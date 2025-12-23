const { pool } = require('../config/database');

class CommentModel {
  // 根据视频ID获取所有评论和回复
  async getCommentsByVideoId(videoId, options = {}) {
    const { keyword = '', sort = 'latest' } = options;

    let sql = `
      SELECT 
        c.comment_id,
        c.video_id,
        c.user_id,
        c.parent_comment_id,
        c.comment_content,
        c.like_count,
        c.created_time,
        c.updated_time,
        u.user_name,
        LEFT(u.user_name, 1) as avatar
      FROM video_comment c
      LEFT JOIN user u ON c.user_id = u.user_id
      WHERE c.video_id = ?
    `;

    const params = [videoId];

    // 如果有关键词搜索
    if (keyword && keyword.trim()) {
      sql += ` AND (c.comment_content LIKE ? OR u.user_name LIKE ?)`;
      const searchPattern = `%${keyword.trim()}%`;
      params.push(searchPattern, searchPattern);
    }

    // 根据排序方式
    if (sort === 'popular') {
      sql += ` ORDER BY c.like_count DESC, c.created_time DESC`;
    } else {
      // 默认按最新排序
      sql += ` ORDER BY c.created_time DESC`;
    }

    const [rows] = await pool.execute(sql, params);

    return rows;
  }
  
  // 添加评论
  async addComment({ videoId, userId, content, parentId }) {

    const sql = `
      INSERT INTO video_comment 
        (video_id, user_id, parent_comment_id, comment_content, like_count) 
      VALUES (?, ?, ?, ?, 0)
    `;
    
    const [result] = await pool.execute(sql, [videoId, userId, parentId, content]);

    return result.insertId;
  }
  
  // 根据评论ID获取评论详情
  async getCommentById(commentId) {

    const sql = `
      SELECT 
        c.*,
        u.user_name,
        LEFT(u.user_name, 1) as avatar
      FROM video_comment c
      LEFT JOIN user u ON c.user_id = u.user_id
      WHERE c.comment_id = ?
    `;
    
    const [rows] = await pool.execute(sql, [commentId]);

    return rows[0] || null;
  }
  
  // 点赞评论
  async likeComment(commentId) {

    const sql = `
      UPDATE video_comment 
      SET like_count = like_count + 1 
      WHERE comment_id = ?
    `;
    
    await pool.execute(sql, [commentId]);

  }

  // 删除评论
  async deleteComment(commentId, userId) {
    // 先检查评论是否属于该用户
    const checkSql = `
      SELECT user_id FROM video_comment WHERE comment_id = ?
    `;
    
    const [rows] = await pool.execute(checkSql, [commentId]);
    
    if (rows.length === 0) {
      throw new Error('评论不存在');
    }
    
    if (rows[0].user_id !== userId) {
      throw new Error('无权删除此评论');
    }
    
    // 删除评论及其所有回复
    const deleteSql = `
      DELETE FROM video_comment 
      WHERE comment_id = ? OR parent_comment_id = ?
    `;
    
    await pool.execute(deleteSql, [commentId, commentId]);
  }
}

module.exports = new CommentModel();