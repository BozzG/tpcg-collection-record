#!/bin/bash

# iOS App Store 发布脚本
# 使用方法: ./scripts/build_and_upload_ios.sh

set -e

echo "🚀 开始 iOS App Store 发布流程..."

# 1. 清理项目
echo "📦 清理项目..."
flutter clean

# 2. 获取依赖
echo "📥 获取依赖..."
flutter pub get

# 3. 生成应用图标
echo "🎨 生成应用图标..."
flutter pub run flutter_launcher_icons:main

# 4. 构建 Release 版本
echo "🔨 构建 Release 版本..."
flutter build ios --release --no-codesign

# 5. 打开 Xcode 进行 Archive
echo "📱 打开 Xcode 进行 Archive..."
echo "请在 Xcode 中执行以下步骤："
echo "1. 选择 'Any iOS Device' 作为目标"
echo "2. Product → Archive"
echo "3. 在 Organizer 中选择 'Distribute App'"
echo "4. 选择 'App Store Connect'"
echo "5. 上传到 App Store Connect"

open ios/Runner.xcworkspace

echo "✅ 构建完成！请在 Xcode 中完成上传步骤。"