# VS Code 插件下载链接生成器

一个用于生成 VS Code 插件下载链接的工具，支持平台无关和平台相关的下载链接生成。

## 🚀 快速开始

### 方法 1：Docker 部署（推荐）

#### 快速部署

```bash
# 给脚本执行权限
chmod +x quick-deploy.sh

# 一键部署
./quick-deploy.sh
```

#### 手动部署

```bash
# 构建前端
cd frontend && npm run build && cd ..

# 构建Docker镜像
docker build -f Dockerfile.fast -t vsext-link-generator .

# 运行容器
docker run -d --name vsext-container -p 8080:80 vsext-link-generator
```

访问：http://localhost:8080

### 方法 2：本地开发

#### 1. 安装依赖

```bash
# 前端依赖
cd frontend && npm install && cd ..

# 后端依赖
pip install -r backend/requirements.txt
```

#### 2. 启动服务

```bash
# 启动后端（端口8000）
cd backend && uvicorn main:app --reload --port 8000

# 启动前端（端口3000）
cd frontend && npm run dev
```

## 📁 项目结构

```
VSExtLinkGen/
├── frontend/           # Vue.js前端
│   ├── src/           # 源代码
│   ├── dist/          # 构建输出
│   └── package.json   # 前端依赖
├── backend/           # FastAPI后端
│   ├── main.py        # 主服务
│   └── requirements.txt
├── Dockerfile         # 完整Docker配置
├── Dockerfile.fast    # 快速Docker配置
├── nginx.conf         # Nginx配置
├── supervisord.conf   # 进程管理
└── quick-deploy.sh    # 快速部署脚本
```

## 🐳 Docker 部署说明

### 架构特点

- **前端**: Vue.js 应用，由 Nginx 托管
- **后端**: FastAPI 应用，仅在容器内运行
- **安全**: 只暴露前端端口，后端不暴露到宿主机
- **代理**: Nginx 反向代理 API 请求到后端

### 端口配置

- **宿主机**: 8080 端口（可自定义）
- **容器内**: 80 端口（Nginx）
- **后端**: 8000 端口（仅容器内）

### 容器管理

```bash
# 查看状态
docker ps

# 查看日志
docker logs vsext-container

# 停止容器
docker stop vsext-container

# 删除容器
docker rm vsext-container
```

## 🔧 开发工作流

### 修改前端代码

```bash
cd frontend
npm run build
cd ..
docker build -f Dockerfile.fast -t vsext-link-generator .
docker stop vsext-container && docker rm vsext-container
docker run -d --name vsext-container -p 8080:80 vsext-link-generator
```

### 修改后端代码

```bash
docker build -f Dockerfile.fast -t vsext-link-generator .
docker stop vsext-container && docker rm vsext-container
docker run -d --name vsext-container -p 8080:80 vsext-link-generator
```

## 📋 API 接口

### POST /extract-data

提取 VS Code 插件信息

**请求体：**

```json
{
  "url": "https://marketplace.visualstudio.com/items?itemName=Vue.volar"
}
```

**响应：**

```json
{
  "version": "1.8.27",
  "publisher": "Vue",
  "unique_identifier": "volar",
  "plugin_name": "volar"
}
```

## 🛠️ 技术栈

- **前端**: Vue 3 + Vite + Tailwind CSS
- **后端**: FastAPI + Python 3.9
- **部署**: Docker + Nginx + Supervisor
- **构建**: Vite

## 📖 详细文档

- [快速部署指南](FAST_DEPLOY_GUIDE.md) - Docker 优化部署方案
- [Docker 部署说明](DOCKER_README.md) - 完整的 Docker 部署文档
