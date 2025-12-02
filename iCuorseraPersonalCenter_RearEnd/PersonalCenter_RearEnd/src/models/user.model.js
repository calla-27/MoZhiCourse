import { pool } from '../config/database.js';

class UserModel {
  // 根据手机号查找用户
  static async findByPhone(phone) {
    const [rows] = await pool.query(
      'SELECT * FROM t_user WHERE phone = ?',
      [phone]
    );
    return rows[0];
  }

  // 根据邮箱查找用户
  static async findByEmail(email) {
    const [rows] = await pool.query(
      'SELECT * FROM t_user WHERE email = ?',
      [email]
    );
    return rows[0];
  }

  // 根据用户ID查找用户
  static async findById(userId) {
    const [rows] = await pool.query(
      'SELECT user_id, user_name, phone, email, user_intro, occupation, learning_goal, role, register_time, last_login_time FROM t_user WHERE user_id = ?',
      [userId]
    );
    return rows[0];
  }

  // 创建新用户
  static async create(userData) {
    const { user_name, phone, email, password_hash, role = 'learner' } = userData;
    const [result] = await pool.query(
      'INSERT INTO t_user (user_name, phone, email, password_hash, role) VALUES (?, ?, ?, ?, ?)',
      [user_name, phone, email, password_hash, role]
    );
    return result.insertId;
  }

  // 更新用户信息
  static async update(userId, userData) {
    const fields = [];
    const values = [];

    Object.keys(userData).forEach(key => {
      if (userData[key] !== undefined && key !== 'user_id') {
        fields.push(`${key} = ?`);
        values.push(userData[key]);
      }
    });

    if (fields.length === 0) return false;

    values.push(userId);
    const [result] = await pool.query(
      `UPDATE t_user SET ${fields.join(', ')} WHERE user_id = ?`,
      values
    );
    return result.affectedRows > 0;
  }

  // 更新最后登录时间
  static async updateLastLogin(userId) {
    await pool.query(
      'UPDATE t_user SET last_login_time = NOW() WHERE user_id = ?',
      [userId]
    );
  }
}

export default UserModel;