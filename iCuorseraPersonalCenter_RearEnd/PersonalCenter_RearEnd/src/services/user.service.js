import { pool } from '../config/database.js';
import UserModel from '../models/user.model.js';

class UserService {
  // 获取用户完整信息
  static async getUserProfile(userId) {
    const user = await UserModel.findById(userId);
    if (!user) {
      throw new Error('用户不存在');
    }

    return user;
  }

  // 更新用户基本信息
  static async updateProfile(userId, updateData) {
    const allowedFields = ['user_name', 'user_intro', 'occupation', 'learning_goal'];
    const filteredData = {};

    allowedFields.forEach(field => {
      if (updateData[field] !== undefined) {
        filteredData[field] = updateData[field];
      }
    });

    if (Object.keys(filteredData).length === 0) {
      throw new Error('没有可更新的字段');
    }

    const success = await UserModel.update(userId, filteredData);
    if (!success) {
      throw new Error('更新失败');
    }

    return await this.getUserProfile(userId);
  }

  // 上传头像
  static async updateAvatar(userId, avatarPath) {
    // 这里暂时不存储到数据库，因为t_user表没有avatar字段
    // 如果需要，可以添加avatar字段到t_user表
    // 目前返回上传成功的路径
    return {
      avatar_url: `/uploads/avatars/${avatarPath}`
    };
  }
}

export default UserService;