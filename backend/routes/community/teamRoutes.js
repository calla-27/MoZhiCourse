// src/routes/community/teamRoutes.js
const express = require('express');
const router = express.Router();
const teamController = require('../../controllers/community/teamController');
// 移除 authMiddleware 导入

// 移除认证中间件
// router.use(authMiddleware);

// 学习小组路由
router.get('/available-data', teamController.getAvailableData); 
router.post('/', teamController.createTeam);
router.get('/', teamController.getTeams);
router.get('/user/:userId', teamController.getUserTeams);
router.get('/:teamId', teamController.getTeamDetail);
router.post('/:teamId/join', teamController.joinTeam);
router.delete('/:teamId/leave', teamController.leaveTeam);
router.put('/:teamId', teamController.updateTeam);
router.delete('/:teamId', teamController.deleteTeam);

module.exports = router;