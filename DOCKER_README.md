# Docker 部署说明

这个项目使用 Docker 容器化部署，**只暴露前端页面到宿主机，后端 API 仅在容器内可访问**。

## 架构说明

- **前端**: Vue.js 应用，构建后由 Nginx 托管
- **后端**: FastAPI 应用，在容器内运行，不暴露到宿主机
- **反向代理**: Nginx 将前端 API 请求代理到后端
- **进程管理**: Supervisor 管理 Nginx 和后端进程

## 快速开始

### 方法 1: 使用脚本（推荐）

```bash
# 给脚本执行权限
chmod +x build-and-run.sh

# 构建并运行容器
./build-and-run.sh
```

### 方法 2: 手动执行

```bash
# 构建镜像
docker build -t vsext-link-generator .

# 运行容器
docker run -d \
  --name vsext-container \
  -p 8080:80 \
  vsext-link-generator
```

## 访问应用

- **前端页面**: http://localhost:8080
- **后端 API**: 仅在容器内可访问，通过前端页面调用

## 容器管理

```bash
# 查看容器状态
docker ps

# 查看容器日志
docker logs vsext-container

# 进入容器（调试用）
docker exec -it vsext-container bash

# 停止容器
docker stop vsext-container

# 删除容器
docker rm vsext-container

# 删除镜像
docker rmi vsext-link-generator
```

## 端口说明

- **宿主机端口**: 8080（可自定义）
- **容器内端口**: 80（Nginx）
- **后端端口**: 8000（仅在容器内，不暴露）

## 安全特性

1. **后端不暴露**: FastAPI 后端只在容器内运行，不映射到宿主机端口
2. **反向代理**: 所有 API 请求通过 Nginx 代理，增加安全性
3. **单一容器**: 使用 Supervisor 管理多个进程，简化部署

## 故障排除

### 查看日志

```bash
# 查看所有日志
docker logs vsext-container

# 实时查看日志
docker logs -f vsext-container
```

### 检查容器状态

```bash
# 查看容器详细信息
docker inspect vsext-container

# 查看容器资源使用情况
docker stats vsext-container
```

### 重新构建

如果修改了代码，需要重新构建：

```bash
# 停止并删除容器
docker stop vsext-container
docker rm vsext-container

# 重新构建并运行
./build-and-run.sh
```
