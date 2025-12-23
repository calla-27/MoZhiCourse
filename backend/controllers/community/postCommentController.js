// backend/controllers/community/postCommentController.js
const Comment = require('../../models/community/Comment');
const Post = require('../../models/community/Post');

class PostCommentController {
  /**
   * 获取帖子评论列表
   */
  async getComments(req, res) {
    try {
      const { id } = req.params;
      const { 
        page = 1, 
        limit = 50,
        comment_type,
        orderBy = 'create_time',
        order = 'ASC'
      } = req.query;
      
      const currentUserId = req.query.current_user_id || req.user?.userId || 0;
      
      // 检查帖子是否存在
      const post = await Post.findById(id);
      
      if (!post) {
        return res.status(404).json({
          success: false,
          message: '帖子不存在'
        });
      }
      
      // 使用 Model 获取评论
      const result = await Comment.findByPostId(id, {
        comment_type,
        page: parseInt(page),
        limit: parseInt(limit),
        orderBy,
        order
      });
      
      // 添加用户互动状态
      const commentsWithUserStatus = await Promise.all(
        result.data.map(async comment => {
          const hasLiked = await Comment.hasUserLiked(comment.comment_id, currentUserId);
          
          return {
            ...comment,
            user_has_liked: hasLiked,
            is_owner: comment.user_id == currentUserId
          };
        })
      );
      
      // 如果需要，可以获取子评论
      const commentsWithReplies = await Promise.all(
        commentsWithUserStatus.map(async comment => {
          if (!comment.parent_comment_id) {
            const replies = await Comment.findReplies(comment.comment_id);
            const repliesWithStatus = await Promise.all(
              replies.map(async reply => {
                const hasLiked = await Comment.hasUserLiked(reply.comment_id, currentUserId);
                return {
                  ...reply,
                  user_has_liked: hasLiked,
                  is_owner: reply.user_id == currentUserId
                };
              })
            );
            return {
              ...comment,
              replies: repliesWithStatus
            };
          }
          return comment;
        })
      );
      
      res.json({
        success: true,
        data: commentsWithReplies,
        pagination: result.pagination
      });
    } catch (error) {
      console.error('获取评论列表失败:', error);
      res.status(500).json({
        success: false,
        message: '获取评论列表失败'
      });
    }
  }
  
  /**
   * 添加评论
   */
  async addComment(req, res) {
    try {
      const { id } = req.params;
      const {
        content,
        parent_comment_id,
        comment_type = 'discussion'
      } = req.body;
      
      const userId = req.body.user_id || req.user?.userId;
      
      if (!content || !userId) {
        return res.status(400).json({
          success: false,
          message: '评论内容和用户ID不能为空'
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
      
      // 如果指定了父评论，检查父评论是否存在
      if (parent_comment_id) {
        const parentComment = await Comment.findById(parent_comment_id);
        if (!parentComment || parentComment.post_id != id) {
          return res.status(400).json({
            success: false,
            message: '父评论不存在'
          });
        }
      }
      
      // 创建评论
      const commentData = {
        post_id: id,
        user_id: userId,
        content: content.trim(),
        parent_comment_id: parent_comment_id || null,
        comment_type: comment_type
      };
      
      const commentId = await Comment.create(commentData);
      
      // 更新帖子评论数
      await Post.updateCommentsCount(id, 1);
      
      // 获取新创建的评论
      const newComment = await Comment.findById(commentId);
      
      if (!newComment) {
        throw new Error('评论创建后无法获取');
      }
      
      res.status(201).json({
        success: true,
        message: '评论添加成功',
        data: {
          ...newComment,
          is_owner: true,
          user_has_liked: false
        }
      });
    } catch (error) {
      console.error('添加评论失败:', error);
      res.status(500).json({
        success: false,
        message: '添加评论失败'
      });
    }
  }
  
  /**
   * 删除评论
   */
  async deleteComment(req, res) {
    try {
      const { commentId } = req.params;
      const userId = req.body.user_id || req.user?.userId;
      
      // 检查评论是否存在
      const comment = await Comment.findById(commentId);
      
      if (!comment) {
        return res.status(404).json({
          success: false,
          message: '评论不存在'
        });
      }
      
      // 只有评论作者可以删除
      if (comment.user_id != userId) {
        return res.status(403).json({
          success: false,
          message: '无权删除此评论'
        });
      }
      
      // 删除评论
      const affectedRows = await Comment.delete(commentId, userId);
      
      if (affectedRows === 0) {
        return res.status(400).json({
          success: false,
          message: '评论删除失败'
        });
      }
      
      // 更新帖子评论数
      await Post.updateCommentsCount(comment.post_id, -1);
      
      res.json({
        success: true,
        message: '评论删除成功'
      });
    } catch (error) {
      console.error('删除评论失败:', error);
      res.status(500).json({
        success: false,
        message: '删除评论失败'
      });
    }
  }
  
  /**
   * 点赞/取消点赞评论
   */
  async toggleCommentLike(req, res) {
    try {
      const { commentId } = req.params;
      const userId = req.body.user_id || req.user?.userId;
      
      // 检查评论是否存在
      const comment = await Comment.findById(commentId);
      
      if (!comment) {
        return res.status(404).json({
          success: false,
          message: '评论不存在'
        });
      }
      
      let action;
      let likeCount;
      
      // 检查是否已点赞
      const hasLiked = await Comment.hasUserLiked(commentId, userId);
      
      if (hasLiked) {
        // 取消点赞
        await Comment.removeLike(commentId, userId);
        await Comment.updateLikesCount(commentId, -1);
        action = 'unliked';
        likeCount = Math.max(0, comment.likes_count - 1);
      } else {
        // 添加点赞
        await Comment.addLike(commentId, userId);
        await Comment.updateLikesCount(commentId, 1);
        action = 'liked';
        likeCount = comment.likes_count + 1;
      }
      
      res.json({
        success: true,
        message: action === 'liked' ? '点赞成功' : '取消点赞成功',
        data: {
          comment_id: parseInt(commentId),
          liked: action === 'liked',
          like_count: likeCount,
          user_has_liked: action === 'liked',
          post_id: comment.post_id
        }
      });
    } catch (error) {
      console.error('操作评论点赞失败:', error);
      res.status(500).json({
        success: false,
        message: '操作评论点赞失败'
      });
    }
  }
  
  /**
   * 获取评论详情
   */
  async getCommentDetail(req, res) {
    try {
      const { commentId } = req.params;
      const currentUserId = req.query.current_user_id || req.user?.userId || 0;
      
      // 获取评论详情
      const comment = await Comment.findById(commentId);
      
      if (!comment) {
        return res.status(404).json({
          success: false,
          message: '评论不存在'
        });
      }
      
      // 获取用户互动状态
      const hasLiked = await Comment.hasUserLiked(commentId, currentUserId);
      
      // 获取子评论
      const replies = await Comment.findReplies(commentId);
      const repliesWithStatus = await Promise.all(
        replies.map(async reply => {
          const hasLikedReply = await Comment.hasUserLiked(reply.comment_id, currentUserId);
          return {
            ...reply,
            user_has_liked: hasLikedReply,
            is_owner: reply.user_id == currentUserId
          };
        })
      );
      
      res.json({
        success: true,
        data: {
          ...comment,
          user_has_liked: hasLiked,
          is_owner: comment.user_id == currentUserId,
          replies: repliesWithStatus
        }
      });
    } catch (error) {
      console.error('获取评论详情失败:', error);
      res.status(500).json({
        success: false,
        message: '获取评论详情失败'
      });
    }
  }
  
  /**
   * 更新评论
   */
  async updateComment(req, res) {
    try {
      const { commentId } = req.params;
      const { content } = req.body;
      const userId = req.body.user_id || req.user?.userId;
      
      if (!content) {
        return res.status(400).json({
          success: false,
          message: '评论内容不能为空'
        });
      }
      
      // 检查评论是否存在
      const comment = await Comment.findById(commentId);
      
      if (!comment) {
        return res.status(404).json({
          success: false,
          message: '评论不存在'
        });
      }
      
      // 只有评论作者可以更新
      if (comment.user_id != userId) {
        return res.status(403).json({
          success: false,
          message: '无权修改此评论'
        });
      }
      
      // 更新评论
      const affectedRows = await Comment.update(commentId, { content });
      
      if (affectedRows === 0) {
        return res.status(400).json({
          success: false,
          message: '评论更新失败'
        });
      }
      
      // 获取更新后的评论
      const updatedComment = await Comment.findById(commentId);
      
      res.json({
        success: true,
        message: '评论更新成功',
        data: {
          ...updatedComment,
          is_owner: true
        }
      });
    } catch (error) {
      console.error('更新评论失败:', error);
      res.status(500).json({
        success: false,
        message: '更新评论失败'
      });
    }
  }
  
  /**
   * 获取用户的评论
   */
  async getUserComments(req, res) {
    try {
      const userId = req.params.userId || req.query.user_id || req.user?.userId;
      const { page = 1, limit = 20 } = req.query;
      
      if (!userId) {
        return res.status(400).json({
          success: false,
          message: '用户ID不能为空'
        });
      }
      
      const result = await Comment.findByUserId(userId, {
        page: parseInt(page),
        limit: parseInt(limit)
      });
      
      res.json({
        success: true,
        data: result.data,
        pagination: result.pagination
      });
    } catch (error) {
      console.error('获取用户评论失败:', error);
      res.status(500).json({
        success: false,
        message: '获取用户评论失败'
      });
    }
  }
  
  /**
   * 获取评论统计
   */
  async getCommentStats(req, res) {
    try {
      const { postId } = req.query;
      
      const stats = await Comment.getStats(postId);
      
      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('获取评论统计失败:', error);
      res.status(500).json({
        success: false,
        message: '获取评论统计失败'
      });
    }
  }
}

module.exports = new PostCommentController();