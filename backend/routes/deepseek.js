const express = require('express');
const router  = express.Router();
const { askDeepSeek } = require('../services/deepseekService');

// POST /api/deepseek/chat
router.post('/chat', async (req, res) => {
  try {
    let { messages, message, temperature } = req.body;
    
    console.log('🤖 收到 AI 请求:', { message: message?.substring(0, 50) });
    
    // 兼容两种格式：messages数组 或 message字符串
    if (message && !messages) {
      messages = [{ role: 'user', content: message }];
    }
    
    if (!Array.isArray(messages)) {
      return res.status(400).json({ 
        success: false,
        data: { answer: 'messages 必须为数组或提供 message 字符串' }
      });
    }
    
    const answer = await askDeepSeek(messages, temperature);
    
    console.log('✅ AI 响应成功');
    res.json({ success: true, data: { answer } });
  } catch (e) {
    console.error('❌ DeepSeek API错误:', e.message);
    
    // 检查是否是余额不足
    if (e.message.includes('Insufficient Balance')) {
      return res.json({ 
        success: true, 
        data: { 
          answer: '💡 DeepSeek API 账户余额不足。\n\n作为替代，这里有一些学习建议：\n\n✓ 认真观看课程视频，做好笔记\n✓ 遇到问题先尝试回看相关章节\n✓ 在评论区与同学和老师交流\n✓ 多动手实践，加深理解\n\n如需使用AI功能，请前往 DeepSeek 官网充值：https://platform.deepseek.com/' 
        }
      });
    }
    
    res.json({ 
      success: true, 
      data: { answer: `抱歉，AI服务暂时不可用: ${e.message}` }
    });
  }
});

module.exports = router;

