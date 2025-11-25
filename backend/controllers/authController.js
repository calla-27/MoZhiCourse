const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const {
  getUserByUserName,
  getUserByAccount,
  getUserByEmail,
  createUser,
  getUserById,
  updateLastLoginTime,
  getUserPasswordHash,
  updateUserPassword,
  updateUserProfile
} = require('../models/userModel');

// 生成JWT Token
const generateToken = (user) => {
  return jwt.sign(
    {
      userId: user.user_id,
      userName: user.user_name,
      role: user.role
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRE
    }
  );
};

// 用户注册
exports.register = async (req, res, next) => {
  try {
    const { user_name, email, password, occupation, learning_goal, role } = req.body;

    // 验证必填字段
    if (!user_name || !password) {
      return res.status(400).json({
        success: false,
        message: '用户名和密码为必填项'
      });
    }

    // 验证邮箱格式（如果提供）
    if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({
        success: false,
        message: '邮箱格式不正确'
      });
    }

    // 检查用户名是否已存在
    const existing = await getUserByUserName(user_name);

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: '该用户名已被注册'
      });
    }

    // 检查邮箱是否已存在
    if (email) {
      const existingEmail = await getUserByEmail(email);

      if (existingEmail.length > 0) {
        return res.status(400).json({
          success: false,
          message: '该邮箱已被注册'
        });
      }
    }

    // 角色校验（仅允许 learner / instructor，其他情况默认 learner）
    let finalRole = 'learner';
    if (role === 'instructor' || role === 'learner') {
      finalRole = role;
    }

    // 密码加密
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    // 插入用户数据
    const userId = await createUser({
      user_name,
      email,
      password_hash,
      occupation,
      learning_goal,
      role: finalRole,
    });

    // 获取新创建的用户信息
    const newUser = await getUserById(userId);

    // 生成token
    const token = generateToken(newUser[0]);

    res.status(201).json({
      success: true,
      message: '注册成功',
      data: {
        user: newUser[0],
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

// 用户登录
exports.login = async (req, res, next) => {
  try {
    const { username, password } = req.body;
    const account = username;

    // 验证必填字段
    if (!account || !password) {
      return res.status(400).json({
        success: false,
        message: '账号和密码为必填项'
      });
    }

    // 查询用户（支持 phone 或 user_name 作为账号）
    const users = await getUserByAccount(account);

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: '用户名或密码错误'
      });
    }

    const user = users[0];

    // 检查账户状态
    if (!user.is_active) {
      return res.status(403).json({
        success: false,
        message: '账户已被禁用'
      });
    }

    // 验证密码
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: '用户名或密码错误'
      });
    }

    // 更新最后登录时间
    await updateLastLoginTime(user.user_id);

    // 删除敏感信息
    delete user.password_hash;

    // 生成token
    const token = generateToken(user);

    res.json({
      success: true,
      message: '登录成功',
      data: {
        user,
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

// 获取当前用户信息
exports.getCurrentUser = async (req, res, next) => {
  try {
    const users = await getUserById(req.user.userId);

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }

    res.json({
      success: true,
      data: users[0]
    });
  } catch (error) {
    next(error);
  }
};

// 更新用户信息
exports.updateProfile = async (req, res, next) => {
  try {
    const { user_name, email, occupation, learning_goal, user_intro } = req.body;
    const userId = req.user.userId;

    const hasUpdates = [user_name, email, occupation, learning_goal, user_intro]
      .some((value) => value !== undefined);

    if (!hasUpdates) {
      return res.status(400).json({
        success: false,
        message: '没有要更新的字段'
      });
    }

    const updated = await updateUserProfile(userId, {
      user_name,
      email,
      occupation,
      learning_goal,
      user_intro
    });

    // 获取更新后的用户信息
    const users = await getUserById(userId);

    res.json({
      success: true,
      message: '更新成功',
      data: users[0]
    });
  } catch (error) {
    next(error);
  }
};

// 修改密码
exports.changePassword = async (req, res, next) => {
  try {
    const { old_password, new_password } = req.body;
    const userId = req.user.userId;

    if (!old_password || !new_password) {
      return res.status(400).json({
        success: false,
        message: '旧密码和新密码为必填项'
      });
    }

    // 获取当前密码
    const users = await getUserPasswordHash(userId);

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }

    // 验证旧密码
    const isMatch = await bcrypt.compare(old_password, users[0].password_hash);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: '旧密码错误'
      });
    }

    // 加密新密码
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(new_password, salt);

    // 更新密码
    await updateUserPassword(userId, password_hash);

    res.json({
      success: true,
      message: '密码修改成功'
    });
  } catch (error) {
    next(error);
  }
};
