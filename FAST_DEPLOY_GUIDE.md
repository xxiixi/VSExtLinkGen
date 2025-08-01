# 🚀 快速部署指南

## 为什么 Docker 构建很慢？

原来的 Dockerfile 每次都要：

1. 安装 Node.js
2. 安装 npm 依赖
3. 构建前端
4. 安装 Python 依赖

这导致每次构建都很慢！

## 🎯 优化方案：分离构建和部署

### 方案 1：使用快速 Dockerfile（推荐）

#### 1. 前端构建（本地）

```bash
cd frontend
npm install
npm run build
cd ..
```

#### 2. 使用快速 Dockerfile 构建

```bash
docker build -f Dockerfile.fast -t vsext-link-generator .
```

#### 3. 运行容器

```bash
docker run -d \
  --name vsext-container \
  -p 8080:80 \
  vsext-link-generator
```

### 方案 2：手动复制文件（最快）

#### 1. 构建前端

```bash
cd frontend
npm run build
cd ..
```

#### 2. 创建部署目录

```bash
mkdir -p deploy/nginx/html
cp -r frontend/dist/* deploy/nginx/html/
cp -r backend deploy/
cp nginx.conf deploy/
cp supervisord.conf deploy/
```

#### 3. 创建简单 Dockerfile

```dockerfile
FROM python:3.9-slim

RUN apt-get update && apt-get install -y nginx supervisor && apt-get clean

WORKDIR /app
COPY deploy/backend /app/backend
RUN pip install -r /app/backend/requirements.txt

COPY deploy/nginx/html/ /usr/share/nginx/html/
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY deploy/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80
CMD ["/usr/bin/supervisord"]
```

## 📊 性能对比

| 方案            | 构建时间 | 优点     | 缺点             |
| --------------- | -------- | -------- | ---------------- |
| 原方案          | 3-5 分钟 | 自动化   | 每次都要重新构建 |
| 快速 Dockerfile | 1-2 分钟 | 分离构建 | 需要手动构建前端 |
| 手动复制        | 30 秒    | 最快     | 需要手动管理文件 |

## 🔄 开发工作流

### 修改前端代码后：

```bash
# 1. 构建前端
cd frontend
npm run build
cd ..

# 2. 重新构建Docker（使用快速版本）
docker stop vsext-container
docker rm vsext-container
docker build -f Dockerfile.fast -t vsext-link-generator .
docker run -d --name vsext-container -p 8080:80 vsext-link-generator
```

### 修改后端代码后：

```bash
# 直接重新构建（后端不影响前端）
docker stop vsext-container
docker rm vsext-container
docker build -f Dockerfile.fast -t vsext-link-generator .
docker run -d --name vsext-container -p 8080:80 vsext-link-generator
```

## 🛠️ 一键脚本

创建 `quick-deploy.sh`：

```bash
#!/bin/bash

echo "🚀 快速部署..."

# 构建前端
echo "📦 构建前端..."
cd frontend
npm run build
cd ..

# 构建Docker镜像
echo "🐳 构建Docker镜像..."
docker build -f Dockerfile.fast -t vsext-link-generator .

# 重启容器
echo "🔄 重启容器..."
docker stop vsext-container 2>/dev/null || true
docker rm vsext-container 2>/dev/null || true
docker run -d --name vsext-container -p 8080:80 vsext-link-generator

echo "✅ 部署完成！访问 http://localhost:8080"
```

## 💡 建议

1. **开发阶段**：使用 `Dockerfile.fast`
2. **生产环境**：使用原来的 `Dockerfile`（更稳定）
3. **频繁修改**：使用手动复制方案

这样你就能享受快速的部署体验了！🎉
