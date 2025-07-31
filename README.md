# VS Code 插件下载链接生成器

一个用于生成VS Code插件下载链接的工具，支持平台无关和平台相关的下载链接生成。

## 项目结构

```
VSExtLinkGen/
├── backend/
│   └── main.py          # FastAPI后端服务
├── src/
│   ├── App.vue          # Vue主组件
│   ├── main.js          # Vue应用入口
│   └── style.css        # 全局样式
├── index.html           # HTML入口文件
├── package.json         # 项目依赖配置
├── vite.config.js       # Vite构建配置
└── README.md           # 项目说明
```

## 安装和运行

### 1. 安装Node.js和npm

首先确保您的系统已安装Node.js和npm。您可以从 [Node.js官网](https://nodejs.org/) 下载安装。

### 2. 安装项目依赖

```bash
npm install
```

### 3. 启动后端服务

在项目根目录下运行：

```bash
# 安装Python依赖
pip install -r requirements.txt

# 启动后端服务
cd backend
uvicorn main:app --reload --port 8000
```

### 4. 启动前端开发服务器

在项目根目录下运行：

```bash
npm run dev
```

前端服务将在 http://localhost:3000 启动，并自动代理API请求到后端服务。

## 功能特性

- 🚀 基于Vue 3 + Vite构建
- 🎨 使用Tailwind CSS进行样式设计
- 🔗 自动提取VS Code插件信息
- 📋 生成平台无关和平台相关的下载链接
- 📱 响应式设计，支持移动端
- ⚡ 实时API调用和错误处理

## API接口

### POST /extract-data

提取VS Code插件信息的接口。

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
  "unique_identifier": "volar"
}
```

## 开发说明

- 前端使用Vue 3 Composition API
- 后端使用FastAPI框架
- 使用Vite作为构建工具
- 支持热重载开发
- 配置了API代理，避免跨域问题

## 构建生产版本

```bash
npm run build
```

构建后的文件将生成在 `dist` 目录中。
