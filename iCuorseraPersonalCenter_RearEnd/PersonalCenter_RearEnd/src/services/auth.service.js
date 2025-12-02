import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import UserModel from '../models/user.model.js';
import { pool } from '../config/database.js';

class AuthService {
  // 用户注册
  static async register(userData) {
    const { user_name, phone, email, password, role = 'learner' } = userData;

    // 检查手机号是否已存在
    const existingPhone = await UserModel.findByPhone(phone);
    if (existingPhone) {
      throw new Error('手机号已被注册');
    }

    // 检查邮箱是否已存在
    const existingEmail = await UserModel.findByEmail(email);
    if (existingEmail) {
      throw new Error('邮箱已被注册');
    }

    // 加密密码
    const password_hash = await bcrypt.hash(password, 10);

    // 创建用户
    const userId = await UserModel.create({
      user_name,
      phone,
      email,
      password_hash,
      role
    });

    return { userId, user_name, phone, email, role };
  }

  // 用户登录
  static async login(loginData) {
    const { phone, password } = loginData;

    /* 开发调试：直接返回永不过期假 token（仅本地用） */
    if (phone === '13900139001' && password === '123456') {
      const fakeToken = jwt.sign(
        { userId: 5, role: 'instructor' },
        process.env.JWT_SECRET,
        { expiresIn: '10y' }
      );
      return { token: fakeToken, user: { user_id: 5, role: 'instructor' } };
    }

   /* 正式流程 */

    // 查找用户
    const user = await UserModel.findByPhone(phone);
    if (!user) {
      throw new Error('手机号或密码错误');
    }

    // 验证密码
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      throw new Error('手机号或密码错误');
    }

    // 更新最后登录时间
    await UserModel.updateLastLogin(user.user_id);

    // 生成 JWT Token
    const token = jwt.sign(
      { userId: user.user_id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );


    return {
      token,
      user: {
        user_id: user.user_id,
        user_name: user.user_name,
        phone: user.phone,
        email: user.email,
        role: user.role
      }
    };
  }
}

export default AuthService;