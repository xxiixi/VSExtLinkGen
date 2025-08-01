FROM python:3.9-slim

# 安装Node.js和Nginx
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /app

# 复制前端代码
COPY frontend /app/frontend

# 构建前端（使用缓存优化）
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# 验证构建结果
RUN ls -la dist/

# 复制后端代码
WORKDIR /app
COPY backend /app/backend

# 安装后端依赖
RUN pip install -r /app/backend/requirements.txt

# 复制构建后的前端文件到Nginx目录
RUN cp -r /app/frontend/dist/* /usr/share/nginx/html/

# 验证Nginx目录内容
RUN ls -la /usr/share/nginx/html/

# 复制配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 只暴露前端端口（80）
EXPOSE 80

# 启动supervisor管理进程
CMD ["/usr/bin/supervisord"]
