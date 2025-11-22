const commentModel = require('../models/Comment');

const getComments = async (req, res) => {
  const { videoId } = req.params;
  try {
    // 获取视频的所有评论（包括回复）
    const comments = await commentModel.getCommentsByVideoId(videoId);
    
    // 将评论按层级组织：主评论和回复
    const mainComments = comments.filter(comment => !comment.parent_comment_id);
    const replies = comments.filter(comment => comment.parent_comment_id);
    
    // 将回复关联到对应的主评论
    const organizedComments = mainComments.map(comment => {
      return {
        ...comment,
        replies: replies.filter(reply => reply.parent_comment_id === comment.comment_id)
      };
    });
    
    res.json({ success: true, data: organizedComments });
  } catch (err) {
    console.error('获取评论失败:', err);
    res.status(500).json({ success: false, message: '获取评论失败' });
  }
};

const postComment = async (req, res) => {
  const { videoId, userId, content, parentId } = req.body;
  
  // 验证必要参数
  if (!videoId || !userId || !content) {
    return res.status(400).json({ 
      success: false, 
      message: '缺少必要参数: videoId, userId, content' 
    });
  }
  
  try {
    const commentId = await commentModel.addComment({ 
      videoId, 
      userId, 
      content, 
      parentId: parentId || null // 如果是回复，传递 parentId
    });
    
    // 获取刚添加的评论详情返回给前端
    const newComment = await commentModel.getCommentById(commentId);
    
    return res.json({ 
      success: true, 
      commentId,
      data: newComment
    });
  } catch (err) {
    console.error('❌ 发布评论出错：', err);
    return res.status(500).json({ success: false, message: '发布评论失败' });
  }
};

const likeComment = async (req, res) => {
  const { commentId } = req.params;
  try {
    await commentModel.likeComment(commentId);
    res.json({ success: true });
  } catch (err) {
    console.error('点赞失败:', err);
    res.status(500).json({ success: false, message: '点赞失败' });
  }
};

module.exports = {
  getComments,
  postComment,
  likeComment,
};