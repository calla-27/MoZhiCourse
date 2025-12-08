// src/routes/community/roomRoutes.js
const express = require('express');
const router = express.Router();
const roomController = require('../../controllers/community/roomController');
// 移除 authMiddleware 导入

// 移除认证中间件
// router.use(authMiddleware);

// 自习室路由
router.post('/', roomController.createRoom);
router.get('/', roomController.getRooms);
router.get('/:roomId', roomController.getRoomDetail);
router.post('/:roomId/join', roomController.joinRoom);
router.delete('/:roomId/leave', roomController.leaveRoom);
router.put('/:roomId', roomController.updateRoom);
router.delete('/:roomId', roomController.deleteRoom);

module.exports = router;