const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3001;

// 确保上传目录存在
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 文件上传配置
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = [
      'image/jpeg', 'image/png', 'image/gif',
      'video/mp4', 'video/avi', 'video/mov',
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'application/zip',
      'application/x-rar-compressed'
    ];
    
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('不支持的文件类型'));
    }
  }
});

// 中间件
app.use(helmet());
app.use(compression());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件服务
app.use('/uploads', express.static(uploadDir));

// 限流
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

// 模拟数据库（实际项目应该用MySQL）
let mockData = {
  users: [
    { id: 1, openid: 'admin_test', nickname: '管理员', userType: 'admin' },
    { id: 2, openid: 'teacher_test', nickname: '张老师', userType: 'teacher' },
    { id: 3, openid: 'student_test', nickname: '李同学', userType: 'student' }
  ],
  camps: [
    { id: 1, name: 'Python入门营', description: '学习Python基础编程' },
    { id: 2, name: 'Web开发实战', description: '全栈开发实战课程' }
  ],
  assignments: [],
  reviews: []
};

// API路由
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// 用户认证
app.post('/api/auth/login', (req, res) => {
  const { openid, userType } = req.body;
  
  // 模拟微信登录
  const user = mockData.users.find(u => u.openid === openid);
  
  if (!user) {
    return res.status(401).json({ success: false, error: '用户不存在' });
  }
  
  if (user.userType !== userType) {
    return res.status(403).json({ success: false, error: '无权限访问' });
  }
  
  const token = `jwt-token-${user.id}-${Date.now()}`;
  
  res.json({
    success: true,
    token,
    user: {
      id: user.id,
      nickname: user.nickname,
      userType: user.userType,
      avatar: 'https://randomuser.me/api/portraits/lego/1.jpg'
    }
  });
});

// 获取学习营列表
app.get('/api/camps', (req, res) => {
  res.json({
    success: true,
    data: mockData.camps
  });
});

// 获取用户信息
app.get('/api/user/info', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) {
    return res.status(401).json({ success: false, error: '未授权' });
  }
  
  // 模拟token解析
  const userId = parseInt(token.split('-')[2]);
  const user = mockData.users.find(u => u.id === userId);
  
  if (!user) {
    return res.status(401).json({ success: false, error: '用户不存在' });
  }
  
  res.json({
    success: true,
    data: {
      id: user.id,
      nickname: user.nickname,
      userType: user.userType,
      avatar: 'https://randomuser.me/api/portraits/lego/1.jpg'
    }
  });
});

// 文件上传
app.post('/api/upload', upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ success: false, error: '没有上传文件' });
  }
  
  const fileUrl = `/uploads/${req.file.filename}`;
  
  res.json({
    success: true,
    data: {
      url: fileUrl,
      filename: req.file.originalname,
      size: req.file.size,
      mimetype: req.file.mimetype
    }
  });
});

// 错误处理
app.use((err, req, res, next) => {
  console.error(err.stack);
  
  if (err instanceof multer.MulterError) {
    return res.status(400).json({
      success: false,
      error: '文件上传错误',
      message: err.message
    });
  }
  
  res.status(err.status || 500).json({
    success: false,
    error: err.message || '服务器内部错误'
  });
});

// 404处理
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: '未找到请求的资源'
  });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`后端服务运行在端口 ${PORT}`);
  console.log(`环境: ${process.env.NODE_ENV || 'development'}`);
  console.log(`上传目录: ${uploadDir}`);
  console.log(`健康检查: http://localhost:${PORT}/api/health`);
});

module.exports = app;