const axios = require('axios');
const { baseURL, chatCompletion, timeout } = require('../config/deepseek');

// 延迟创建 client，确保 dotenv 已加载
let client = null;
function getClient() {
  if (!client) {
    const apiKey = process.env.DEEPSEEK_API_KEY;
    
    // 调试日志
    console.log('🔑 DeepSeek API Key 状态:', apiKey ? `已配置 (${apiKey.substring(0, 10)}...)` : '❌ 未配置');
    
    if (!apiKey) {
      throw new Error('DEEPSEEK_API_KEY 环境变量未配置');
    }
    
    client = axios.create({
      baseURL,
      timeout,
      headers: { 
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      }
    });
  }
  return client;
}

/**
 * 调用 DeepSeek ChatCompletion
 * @param {Array} messages  格式 [{role:'user',content:'你好'}]
 * @param {Number} temperature 0~2
 */
async function askDeepSeek(messages, temperature = 0.7) {
  try {
    console.log('📤 发送请求到 DeepSeek:', { 
      url: `${baseURL}${chatCompletion}`,
      messagesCount: messages.length 
    });
    
    const { data } = await getClient().post(chatCompletion, {
      model: 'deepseek-chat',
      messages,
      temperature
    });
    
    console.log('✅ DeepSeek 响应成功');
    return data.choices[0].message.content;
  } catch (err) {
    console.error('❌ DeepSeek API 错误:', {
      status: err.response?.status,
      statusText: err.response?.statusText,
      error: err.response?.data?.error,
      message: err.message
    });
    
    // 统一包装，前端永远收到 200，错误信息在 msg
    const errorMessage = err.response?.data?.error?.message || err.message || 'DeepSeek 调用失败';
    throw new Error(errorMessage);
  }
}

module.exports = { askDeepSeek };