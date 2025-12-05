#!/bin/bash

echo "🚀 开始部署到iPhone..."

# 设备ID
DEVICE_ID="00008101-000A04163ED2001E"

# 检查设备连接
echo "📱 检查设备连接..."
flutter devices

# 清理并获取依赖
echo "🧹 清理项目..."
flutter clean
flutter pub get

# 构建iOS应用
echo "🔨 构建iOS Release版本..."
flutter build ios --release

# 部署到设备
echo "📲 部署到iPhone..."
flutter install -d $DEVICE_ID

echo "✅ 部署完成！"
echo ""
echo "📋 如果遇到问题："
echo "1. 确保iPhone已启用开发者模式"
echo "2. 确保在iPhone上信任了这台电脑"
echo "3. 检查Xcode中的签名配置"