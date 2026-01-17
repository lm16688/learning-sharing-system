# 学习分享点评系统

一个基于微信的在线学习管理系统，支持老师布置作业、学员提交作业、互评等功能。

## 🚀 功能特性

- ✅ 微信登录认证
- ✅ 学习营管理（管理员）
- ✅ 作业布置与批改（老师）
- ✅ 作业提交与查看（学员）
- ✅ 文件上传分享
- ✅ 实时消息通知
- ✅ 多角色权限管理

## 🛠 技术栈

**前端：**
- React 18
- Ant Design 5
- Axios
- React Router

**后端：**
- Node.js + Express
- MySQL 8.0
- Redis
- JWT认证

**部署：**
- Docker
- Docker Compose
- Nginx

## 🚀 快速开始

### 1. 环境要求
- Docker 20.10+
- Docker Compose 2.0+
- Git

### 2. 部署步骤

```bash
# 克隆项目
git clone https://github.com/yourusername/learning-sharing-system.git
cd learning-sharing-system

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，修改必要的配置

# 启动服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 访问系统
# 前端：http://localhost:3000
# 后端API：http://localhost:3001