#!/bin/bash

# iOS签名问题快速修复脚本

echo "🔧 TPCG Collection Record - 签名问题修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查当前目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：请在Flutter项目根目录运行此脚本"
    exit 1
fi

echo "📍 项目路径: $(pwd)"
echo ""

# 1. 关闭Xcode
echo "1️⃣  关闭Xcode（如果正在运行）..."
osascript -e 'quit app "Xcode"' 2>/dev/null || true
sleep 2

# 2. 清理项目
echo "2️⃣  清理Flutter项目..."
flutter clean > /dev/null 2>&1

# 3. 重新获取依赖
echo "3️⃣  重新获取依赖..."
flutter pub get > /dev/null 2>&1

# 4. 重新安装CocoaPods
echo "4️⃣  重新安装CocoaPods..."
cd ios
pod deintegrate > /dev/null 2>&1
pod install > /dev/null 2>&1
cd ..

# 5. 检查Bundle ID配置
echo "5️⃣  检查Bundle ID配置..."
CURRENT_BUNDLE_ID=$(grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/ | head -1 | cut -d'=' -f2 | tr -d ' ;')
echo "当前Bundle ID: $CURRENT_BUNDLE_ID"

if [[ "$CURRENT_BUNDLE_ID" == *"example"* ]]; then
    echo "⚠️  检测到默认Bundle ID，需要修改为唯一值"
    echo ""
    echo "建议的Bundle ID:"
    echo "  com.bozzguo.tpcg-collection-record"
    echo "  com.yourname.pokemon-card-app"
    echo "  com.developer.tcg-collection"
fi

# 6. 检查开发者账号配置
echo ""
echo "6️⃣  检查开发者账号配置..."
TEAM_ID=$(grep -r "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/ | head -1 | cut -d'=' -f2 | tr -d ' ;')

if [ -z "$TEAM_ID" ] || [ "$TEAM_ID" = '""' ]; then
    echo "⚠️  未配置开发者账号Team ID"
    echo "   需要在Xcode中配置Apple开发者账号"
else
    echo "✅ Team ID已配置: $TEAM_ID"
fi

echo ""
echo "🎯 接下来需要在Xcode中完成签名配置："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 必须完成的步骤："
echo "1. 添加Apple ID到Xcode"
echo "   Xcode → Preferences → Accounts → 添加Apple ID"
echo ""
echo "2. 配置项目签名"
echo "   选择Runner项目 → Runner target → Signing & Capabilities"
echo "   - Team: 选择你的Apple开发者账号"
echo "   - Bundle Identifier: 修改为唯一值"
echo "   - ✅ 勾选 'Automatically manage signing'"
echo ""
echo "3. 选择设备并运行"
echo "   - 设备选择器中选择 '郭子彦 的 iPhone'"
echo "   - 点击运行按钮 ▶️"
echo ""

# 7. 询问是否打开Xcode
read -p "🚀 是否现在打开Xcode进行签名配置? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎉 正在打开Xcode..."
    open ios/Runner.xcworkspace
    
    echo ""
    echo "💡 在Xcode中配置签名的详细步骤："
    echo ""
    echo "🔧 步骤1: 添加Apple ID"
    echo "   - Xcode菜单 → Preferences (或Settings)"
    echo "   - 点击Accounts标签"
    echo "   - 点击 '+' 添加Apple ID"
    echo ""
    echo "🔧 步骤2: 配置项目签名"
    echo "   - 左侧点击蓝色的'Runner'项目图标"
    echo "   - 选择'Runner' target"
    echo "   - 点击'Signing & Capabilities'标签"
    echo "   - Team: 选择你的Apple开发者账号"
    echo "   - Bundle Identifier: 改为 com.bozzguo.tpcg-collection-record"
    echo ""
    echo "🔧 步骤3: 运行应用"
    echo "   - 选择'郭子彦 的 iPhone'"
    echo "   - 点击运行按钮 ▶️"
    echo ""
    echo "📖 详细指南: SIGNING_ERROR_FIX.md"
else
    echo ""
    echo "📖 稍后可以手动打开Xcode:"
    echo "   open ios/Runner.xcworkspace"
    echo ""
    echo "📖 详细签名配置指南: SIGNING_ERROR_FIX.md"
fi

echo ""
echo "🎊 项目已准备就绪！"
echo ""
echo "⚠️  重要提醒："
echo "   - 必须配置Apple开发者账号才能在真实设备上运行"
echo "   - Bundle ID必须是全球唯一的"
echo "   - 首次安装需要在iPhone上信任开发者证书"
echo "   - 免费Apple ID的应用有效期为7天"