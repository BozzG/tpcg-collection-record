#!/bin/bash

# 新机器 Xcode 项目快速设置脚本
# 用于在新机器上快速配置和打开 TPCG Collection Record 项目

echo "🚀 新机器 Xcode 项目设置脚本"
echo "=================================="
echo ""

# 检查当前目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 检查必要工具
echo "🔍 检查开发环境..."

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter SDK"
    echo "   下载地址: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 检查 Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode 未安装，请从 App Store 安装 Xcode"
    exit 1
fi

# 检查 CocoaPods
if ! command -v pod &> /dev/null; then
    echo "⚠️  CocoaPods 未安装，正在安装..."
    sudo gem install cocoapods
    if [ $? -ne 0 ]; then
        echo "❌ CocoaPods 安装失败"
        exit 1
    fi
fi

echo "✅ 开发环境检查完成"
echo ""

# 显示环境信息
echo "📋 环境信息："
echo "Flutter: $(flutter --version | head -1)"
echo "Xcode: $(xcodebuild -version | head -1)"
echo "CocoaPods: $(pod --version)"
echo ""

# 运行 Flutter Doctor
echo "🏥 运行 Flutter Doctor..."
flutter doctor
echo ""

# 清理项目
echo "🧹 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取 Flutter 依赖..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Flutter 依赖获取失败"
    exit 1
fi

# 进入 iOS 目录
cd ios

# 检查 Podfile 是否存在
if [ ! -f "Podfile" ]; then
    echo "❌ Podfile 不存在，项目可能未正确配置"
    exit 1
fi

# 清理 CocoaPods 缓存（如果存在）
if [ -d "Pods" ]; then
    echo "🧹 清理旧的 CocoaPods 安装..."
    pod deintegrate
fi

# 安装 iOS 依赖
echo "📱 安装 iOS 依赖..."
pod install --repo-update

if [ $? -ne 0 ]; then
    echo "❌ CocoaPods 安装失败"
    echo "💡 尝试解决方案："
    echo "   1. 更新 CocoaPods: sudo gem update cocoapods"
    echo "   2. 清理缓存: pod cache clean --all"
    echo "   3. 重新运行: pod install --repo-update"
    exit 1
fi

# 返回项目根目录
cd ..

echo ""
echo "✅ 项目设置完成！"
echo ""

# 询问是否打开 Xcode
read -p "🔧 是否现在打开 Xcode 项目? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎉 打开 Xcode 项目..."
    open ios/Runner.xcworkspace
    
    echo ""
    echo "📖 接下来的步骤："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1️⃣  在 Xcode 中选择 Runner 项目"
    echo "2️⃣  点击 'Signing & Capabilities' 标签"
    echo "3️⃣  勾选 'Automatically manage signing'"
    echo "4️⃣  选择你的 Apple 开发者账号作为 Team"
    echo "5️⃣  修改 Bundle Identifier 为唯一值，例如："
    echo "    com.yourname.tpcg-collection-record"
    echo "6️⃣  选择模拟器或连接的设备"
    echo "7️⃣  点击运行按钮 (▶️) 或按 Cmd+R"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📚 详细指南请查看: XCODE_NEW_MACHINE_SETUP.md"
else
    echo ""
    echo "📖 稍后可以手动打开 Xcode 项目："
    echo "   open ios/Runner.xcworkspace"
    echo ""
    echo "📚 详细设置指南请查看: XCODE_NEW_MACHINE_SETUP.md"
fi

echo ""
echo "🎊 设置完成！祝您开发愉快！"