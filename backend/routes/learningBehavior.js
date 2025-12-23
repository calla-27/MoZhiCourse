const express = require('express');
const router = express.Router();
const {
  recordBehavior,
  recordBehaviors,
  getWordCloudData,
  getBehaviorStatistics,
  getBehaviorTrend,
  updateStatistics
} = require('../controllers/learningBehaviorController');
const { authMiddleware } = require('../middleware/auth');

// 记录单个学习行为
router.post('/record', authMiddleware, recordBehavior);

// 批量记录学习行为
router.post('/record-batch', authMiddleware, recordBehaviors);

// 获取词云数据
router.get('/wordcloud', authMiddleware, getWordCloudData);

// 获取行为统计
router.get('/statistics', authMiddleware, getBehaviorStatistics);

// 获取行为趋势
router.get('/trend', authMiddleware, getBehaviorTrend);

// 更新行为统计
router.post('/update-statistics', authMiddleware, updateStatistics);

module.exports = router;