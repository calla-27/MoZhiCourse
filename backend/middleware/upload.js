const multer = require('multer');
const path = require('path');
const fs = require('fs');

// 确保上传目录存在
const uploadDir = path.join(__dirname, '../uploads');
const avatarDir = path.join(uploadDir, 'avatars');
const roomAvatarDir = path.join(uploadDir, 'room-avatars');
const videoDir = path.join(uploadDir, 'videos');

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}
if (!fs.existsSync(avatarDir)) {
  fs.mkdirSync(avatarDir, { recursive: true });
}
if (!fs.existsSync(roomAvatarDir)) {
  fs.mkdirSync(roomAvatarDir, { recursive: true });
}
if (!fs.existsSync(videoDir)) {
  fs.mkdirSync(videoDir, { recursive: true });
}

// 用户头像上传配置
const avatarStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, avatarDir);
  },
  filename: (req, file, cb) => {
    // 生成唯一文件名：用户ID_时间戳.扩展名
    const userId = req.user.userId;
    const timestamp = Date.now();
    const ext = path.extname(file.originalname);
    cb(null, `avatar_${userId}_${timestamp}${ext}`);
  }
});

// 自习室头像上传配置
const roomAvatarStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, roomAvatarDir);
  },
  filename: (req, file, cb) => {
    const roomId = req.params.roomId || 'room';
    const timestamp = Date.now();
    const ext = path.extname(file.originalname);
    cb(null, `room_${roomId}_${timestamp}${ext}`);
  }
});

// 视频上传配置
const videoStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, videoDir);
  },
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    const ext = path.extname(file.originalname);
    const randomStr = Math.random().toString(36).substring(2, 8);
    cb(null, `video_${timestamp}_${randomStr}${ext}`);
  }
});

// 图片文件过滤器
const imageFilter = (req, file, cb) => {
  // 检查文件类型
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('只能上传图片文件'), false);
  }
};

// 视频文件过滤器
const videoFilter = (req, file, cb) => {
  // 检查文件类型
  if (file.mimetype.startsWith('video/')) {
    cb(null, true);
  } else {
    cb(new Error('只能上传视频文件'), false);
  }
};

// 用户头像上传中间件
const uploadAvatar = multer({
  storage: avatarStorage,
  fileFilter: imageFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
    files: 1
  }
}).single('avatar');

// 自习室头像上传中间件
const uploadRoomAvatarMiddleware = multer({
  storage: roomAvatarStorage,
  fileFilter: imageFilter,
  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 1
  }
}).single('avatar');

// 视频上传中间件
const uploadVideoMiddleware = multer({
  storage: videoStorage,
  fileFilter: videoFilter,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB
    files: 1
  }
}).single('video');

// 错误处理包装器
const handleUpload = (uploadMiddleware) => {
  return (req, res, next) => {
    uploadMiddleware(req, res, (err) => {
      if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({
            success: false,
            message: '文件大小不能超过5MB'
          });
        }
        if (err.code === 'LIMIT_FILE_COUNT') {
          return res.status(400).json({
            success: false,
            message: '只能上传一个文件'
          });
        }
        return res.status(400).json({
          success: false,
          message: '文件上传错误: ' + err.message
        });
      } else if (err) {
        return res.status(400).json({
          success: false,
          message: err.message
        });
      }
      next();
    });
  };
};

module.exports = {
  uploadAvatar: handleUpload(uploadAvatar),
  uploadRoomAvatar: handleUpload(uploadRoomAvatarMiddleware),
  uploadVideo: handleUpload(uploadVideoMiddleware)
};
