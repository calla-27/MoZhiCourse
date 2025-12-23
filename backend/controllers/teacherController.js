const { getTopTeachers } = require('../models/teacherModel');

/**
 * 获取明星讲师列表（按学生数量排序）
 * GET /api/teachers/top
 * Query: limit (默认4)
 */
exports.getTopTeachers = async (req, res, next) => {
  try {
    const { limit = 4 } = req.query;
    const teachers = await getTopTeachers(limit);

    res.json({
      success: true,
      data: teachers
    });
  } catch (error) {
    next(error);
  }
};
