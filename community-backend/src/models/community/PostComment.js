const { execute } = require('../../config/database');

class PostComment {
    // 创建评论
    static async create(commentData) {
        const [result] = await execute(
            'INSERT INTO t_post_comment (post_id, user_id, parent_comment_id, content, comment_type) VALUES (?, ?, ?, ?, ?)',
            [commentData.post_id, commentData.user_id, commentData.parent_comment_id, commentData.content, commentData.comment_type || 'discussion']
        );
        return result.insertId;
    }

    // 获取帖子的评论
    static async findByPostId(postId, commentType = null) {
        let query = `
            SELECT pc.*, u.user_name, u.avatar_url
            FROM t_post_comment pc
            LEFT JOIN t_user u ON pc.user_id = u.user_id
            WHERE pc.post_id = ?
        `;
        const params = [postId];

        if (commentType) {
            query += ' AND pc.comment_type = ?';
            params.push(commentType);
        }

        query += ' ORDER BY pc.create_time ASC';

        const [rows] = await execute(query, params);
        return rows;
    }
}

module.exports = PostComment;