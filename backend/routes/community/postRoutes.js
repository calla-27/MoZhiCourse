// backend/routes/community/postRoutes.js
const express = require('express');
const router = express.Router();
const postController = require('../../controllers/community/postController');
const postCommentController = require('../../controllers/community/postCommentController');
// const { authMiddleware } = require('../../middleware/auth'); // 暂时注释掉

// 🔓 暂时移除认证中间件，先让接口能工作
// router.use(authMiddleware);

// 帖子相关路由
router.get('/', postController.getPosts);
router.get('/:id', postController.getPostById);
router.post('/', postController.createPost);
router.put('/:id', postController.updatePost);
router.delete('/:id', postController.deletePost);
router.post('/:id/like', postController.togglePostLike);
router.delete('/:id/like', postController.togglePostLike);
router.post('/:id/favorite', postController.togglePostFavorite);
router.delete('/:id/favorite', postController.togglePostFavorite);
router.patch('/:id/solve', postController.markPostSolved);

// 名师相关路由
router.get('/teachers/list', postController.getTeachers);

// 获取特定分类的帖子（快捷路由）
router.get('/category/:category', (req, res) => {
  req.query.category = req.params.category;
  return postController.getPosts(req, res);
});

// 获取答疑帖子（名师答疑）
router.get('/questions', (req, res) => {
  req.query.category = 'question';
  return postController.getPosts(req, res);
});

// 获取互助帖子
router.get('/help', (req, res) => {
  req.query.category = 'help';
  return postController.getPosts(req, res);
});

// 获取讨论帖子
router.get('/discussions', (req, res) => {
  req.query.category = 'discussion';
  return postController.getPosts(req, res);
});

// 评论相关路由
router.get('/:id/comments', postCommentController.getComments);
router.post('/:id/comments', postCommentController.addComment);
router.delete('/comments/:commentId', postCommentController.deleteComment);
router.post('/comments/:commentId/like', postCommentController.toggleCommentLike);

module.exports = router;