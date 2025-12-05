#!/bin/bash

echo "🚀 开始iOS部署流程..."

# 检查Flutter环境
echo "📋 检查Flutter环境..."
flutter doctor

# 清理构建缓存
echo "🧹 清理构建缓存..."
flutter clean
flutter pub get

# 检查连接的设备
echo "📱 检查连接的设备..."
flutter devices

# 构建iOS应用
echo "🔨 构建iOS应用..."
flutter build ios --release

echo "✅ 构建完成！"
echo ""
echo "📋 下一步操作："
echo "1. 确保iPhone已连接并信任此电脑"
echo "2. 在Xcode中配置签名（如果还没有）"
echo "3. 运行: flutter run --release"
echo ""
echo "🎯 或者直接运行以下命令部署到设备："
echo "flutter run -d [设备ID] --release"