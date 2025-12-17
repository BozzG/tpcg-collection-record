#!/bin/bash

echo "🔍 调试项目列表错误 - $(date)"
echo "=================================="

# 1. 检查 Flutter 设备连接
echo "📱 检查设备连接状态："
flutter devices

echo ""
echo "📋 检查应用日志（最近10行）："
flutter logs --device-id="郭子彦 的 iPhone" | tail -10 &
LOGS_PID=$!

# 等待3秒获取日志
sleep 3
kill $LOGS_PID 2>/dev/null

echo ""
echo "🔧 检查数据库相关代码："
echo "- 检查 DatabaseService.getAllProjects() 方法"
echo "- 检查 ProjectViewModel.loadAllProjects() 方法"

echo ""
echo "💡 常见问题排查："
echo "1. 数据库初始化是否完成"
echo "2. 权限问题（文件读写）"
echo "3. 数据库文件路径问题"
echo "4. 异步操作超时"

echo ""
echo "🚀 建议的调试步骤："
echo "1. 在 Xcode 中查看详细错误日志"
echo "2. 检查 Console.app 中的崩溃报告"
echo "3. 添加更多日志输出"
echo "4. 使用断点调试"

echo ""
echo "调试脚本执行完成"