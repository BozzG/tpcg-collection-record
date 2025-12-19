#!/bin/bash

# iOS 真机快速部署脚本
# 简化版本，专注于快速部署到真实设备

echo "📱 iOS 真机快速部署"
echo "===================="

# 检查是否在项目根目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

# 检查设备连接
echo "🔍 检查连接的 iOS 设备..."
DEVICES_OUTPUT=$(flutter devices 2>/dev/null)
IOS_DEVICES=$(echo "$DEVICES_OUTPUT" | grep -E "iPhone|iPad" | grep -v "Simulator")

if [ -z "$IOS_DEVICES" ]; then
    echo "❌ 未检测到连接的 iOS 设备"
    echo ""
    echo "请确保："
    echo "• iOS 设备已通过 USB 连接到 Mac"
    echo "• 在设备上点击了'信任此电脑'"
    echo "• 设备已解锁"
    echo ""
    echo "📱 当前可用设备："
    flutter devices
    exit 1
fi

echo "✅ 检测到 iOS 设备："
echo "$IOS_DEVICES"
echo ""

# 快速准备
echo "🚀 准备部署..."
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1

# 构建 Release 版本
echo "🔨 构建 Release 版本..."
flutter build ios --release

if [ $? -ne 0 ]; then
    echo "❌ 构建失败！"
    echo ""
    echo "💡 可能需要在 Xcode 中配置签名："
    echo "   open ios/Runner.xcworkspace"
    exit 1
fi

echo "✅ 构建成功！"
echo ""

# 部署选项
echo "🎯 选择部署方式："
echo "1. 🚀 Flutter 直接部署（快速）"
echo "2. 🔧 Xcode 手动部署（可控）"
echo "3. 📋 仅显示部署信息"

read -p "请选择 (1-3): " -n 1 -r
echo ""

case $REPLY in
    1)
        echo "🚀 正在部署到设备..."
        echo ""
        echo "📝 注意：首次部署可能需要在设备上信任开发者证书"
        echo "   设置 → 通用 → VPN与设备管理 → 信任证书"
        echo ""
        
        flutter run --release
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "🎉 部署成功！"
            echo "✅ 请检查设备上的应用是否正常工作"
        else
            echo ""
            echo "❌ 部署失败！可能需要配置签名"
            echo "💡 尝试使用选项 2 通过 Xcode 部署"
        fi
        ;;
    2)
        echo "🔧 打开 Xcode 进行手动部署..."
        echo ""
        echo "📋 在 Xcode 中的步骤："
        echo "1️⃣ 选择 Runner → Signing & Capabilities"
        echo "2️⃣ 配置 Team 和 Bundle Identifier"
        echo "3️⃣ 选择你的真实设备"
        echo "4️⃣ 点击运行按钮 ▶️"
        echo ""
        
        open ios/Runner.xcworkspace
        echo "✅ Xcode 已打开，请手动配置并运行"
        ;;
    3)
        echo "📋 部署信息："
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📱 应用: TPCG Collection Record"
        echo "🏗️ 模式: Release"
        echo "📍 构建产物: build/ios/iphoneos/Runner.app"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "🔧 手动部署命令："
        echo "   flutter run --release"
        echo ""
        echo "🔧 或通过 Xcode："
        echo "   open ios/Runner.xcworkspace"
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "🎊 部署流程完成！"
echo ""
echo "📋 测试清单："
echo "□ 应用启动正常"
echo "□ 数据库功能正常"
echo "□ 图片选择功能正常"
echo "□ 相机功能正常"
echo "□ 所有导航正常"
echo ""
echo "💡 如有问题，请查看: DEPLOY_TO_DEVICE_QUICK_GUIDE.md"