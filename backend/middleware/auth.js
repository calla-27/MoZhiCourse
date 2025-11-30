const jwt = require('jsonwebtoken');

// 认证中间件
const authMiddleware = (req, res, next) => {
  try {
    // 从请求头获取token
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    console.log('🔐 认证中间件 - Authorization头:', req.headers.authorization);
    console.log('🎫 提取的token:', token ? `${token.substring(0, 20)}...` : 'null');

    if (!token) {
      console.log('❌ 未提供认证令牌');
      return res.status(401).json({
        success: false,
        message: '未提供认证令牌'
      });
    }

    // 验证token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'mozhicourse-secret-key-2024');
    console.log('✅ JWT解析成功:', decoded);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: '认证令牌无效或已过期'
    });
  }
};

// 角色检查中间件
const checkRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: '未认证'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: '权限不足'
      });
    }

    next();
  };
};

module.exports = { authMiddleware, checkRole };
