// src/routes/community/taskRoutes.js
const express = require('express');
const router = express.Router();
const taskController = require('../../controllers/community/taskController');

// 学习小组任务路由
router.post('/teams/:teamId/tasks', taskController.createTask);
router.get('/teams/:teamId/tasks', taskController.getTeamTasks);
router.put('/tasks/:taskId', taskController.updateTask);
router.delete('/tasks/:taskId', taskController.deleteTask);
router.patch('/tasks/:taskId/status', taskController.updateTaskStatus);

module.exports = router;