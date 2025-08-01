# VS Code 插件下载链接生成器

一个用于生成 VS Code 插件下载链接的工具，支持平台无关和平台相关的下载链接生成。

## 🚀 快速开始

### 开发环境

```bash
# 启动开发环境
chmod +x dev-start.sh
./dev-start.sh
```

### Docker 部署

```bash
# 构建并运行
docker build -t vsext-link-generator .
docker run -d --name vsext-container -p 8080:80 vsext-link-generator
```

访问：http://localhost:8080

## 📁 项目结构

```
VSExtLinkGen/
├── frontend/           # Vue.js前端
│   ├── src/           # 源代码
│   └── package.json   # 前端依赖
├── backend/           # FastAPI后端
│   ├── main.py        # 主服务
│   └── requirements.txt
├── Dockerfile         # Docker配置
├── nginx.conf         # Nginx配置
└── dev-start.sh       # 开发启动脚本
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
- **部署**: Docker + Nginx
