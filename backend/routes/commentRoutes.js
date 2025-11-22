const express = require('express');
const router = express.Router();
const commentController = require('../controllers/commentController');

router.get('/videos/:videoId', commentController.getComments);
router.post('/', commentController.postComment);
router.post('/:commentId/like', commentController.likeComment);

module.exports = router;