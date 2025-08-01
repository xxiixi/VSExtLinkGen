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