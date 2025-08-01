#!/bin/bash

echo "🚀 启动本地开发环境..."

# 检查后端是否已运行
if ! pgrep -f "uvicorn main:app" > /dev/null; then
    echo "🔧 启动后端服务..."
    cd backend
    uvicorn main:app --reload --port 8000 &
    cd ..
else
    echo "✅ 后端服务已在运行"
fi

# 检查前端是否已运行
if ! pgrep -f "vite" > /dev/null; then
    echo "🎨 启动前端服务..."
    cd frontend
    npm run dev &
    cd ..
else
    echo "✅ 前端服务已在运行"
fi

echo ""
echo "🌐 服务已启动："
echo "   前端: http://localhost:3000"
echo "   后端: http://localhost:8000"
echo ""
echo "💡 提示："
echo "   - 修改前端代码会自动热重载"
echo "   - 修改后端代码会自动重启"
echo "   - 按 Ctrl+C 停止所有服务" 