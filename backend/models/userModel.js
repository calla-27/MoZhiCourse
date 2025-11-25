const { pool } = require('../config/database');

// 用户相关数据操作
const getUserByUserName = async (userName) => {
  const [rows] = await pool.query(
    `SELECT user_id, user_name, email, password_hash, role, occupation,
            learning_goal, user_intro, avatar_url, is_active, register_time, last_login_time
     FROM t_user
     WHERE user_name = ?`,
    [userName]
  );
  return rows;
};

// 按账号查询用户（现在只按 user_name）
const getUserByAccount = async (account) => {
  const [rows] = await pool.query(
    `SELECT user_id, user_name, email, password_hash, role, occupation,
            learning_goal, user_intro, avatar_url, is_active, register_time, last_login_time
     FROM t_user
     WHERE user_name = ?`,
    [account]
  );
  return rows;
};

const getUserByEmail = async (email) => {
  const [rows] = await pool.query(
    'SELECT user_id FROM t_user WHERE email = ?',
    [email]
  );
  return rows;
};

const createUser = async ({
  user_name,
  email,
  password_hash,
  occupation,
  learning_goal,
  role,
}) => {
  const [result] = await pool.query(
    `INSERT INTO t_user (user_name, email, password_hash, occupation, learning_goal, role, register_time)
     VALUES (?, ?, ?, ?, ?, COALESCE(?, 'learner'), NOW())`,
    [
      user_name,
      email || null,
      password_hash,
      occupation || null,
      learning_goal || null,
      role || null,
    ]
  );
  return result.insertId;
};

const getUserById = async (userId) => {
  const [rows] = await pool.query(
    `SELECT user_id, user_name, email, occupation, learning_goal,
            role, user_intro, avatar_url, register_time, last_login_time
     FROM t_user
     WHERE user_id = ?`,
    [userId]
  );
  return rows;
};

const updateLastLoginTime = async (userId) => {
  await pool.query(
    'UPDATE t_user SET last_login_time = NOW() WHERE user_id = ?',
    [userId]
  );
};

const getUserPasswordHash = async (userId) => {
  const [rows] = await pool.query(
    'SELECT password_hash FROM t_user WHERE user_id = ?',
    [userId]
  );
  return rows;
};

const updateUserPassword = async (userId, passwordHash) => {
  await pool.query(
    'UPDATE t_user SET password_hash = ? WHERE user_id = ?',
    [passwordHash, userId]
  );
};

const updateUserProfile = async (userId, updates) => {
  const columns = [];
  const values = [];

  Object.entries(updates).forEach(([key, value]) => {
    if (value !== undefined) {
      columns.push(`${key} = ?`);
      values.push(value);
    }
  });

  if (columns.length === 0) {
    return false;
  }

  values.push(userId);

  await pool.query(
    `UPDATE t_user SET ${columns.join(', ')} WHERE user_id = ?`,
    values
  );

  return true;
};

module.exports = {
  getUserByUserName,
  getUserByAccount,
  getUserByEmail,
  createUser,
  getUserById,
  updateLastLoginTime,
  getUserPasswordHash,
  updateUserPassword,
  updateUserProfile
};
