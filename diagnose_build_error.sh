#!/bin/bash

# iOS构建错误自动诊断脚本
# 用于快速排查Build Failed问题

echo "🔍 TPCG Collection Record - 构建错误诊断"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查当前目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：请在Flutter项目根目录运行此脚本"
    exit 1
fi

echo "📍 项目路径: $(pwd)"
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查Flutter环境
echo "1️⃣  检查Flutter环境..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter --version
echo ""
flutter doctor -v
echo ""

# 2. 检查Xcode环境
echo "2️⃣  检查Xcode环境..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Xcode路径: $(xcode-select --print-path)"
echo "iOS SDK版本: $(xcrun --show-sdk-version)"
echo "可用设备:"
xcrun xctrace list devices | grep -E "iPhone|iPad"
echo ""

# 3. 检查CocoaPods
echo "3️⃣  检查CocoaPods..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CocoaPods版本: $(pod --version)"
if [ -f "ios/Podfile.lock" ]; then
    echo "✅ Podfile.lock 存在"
    echo "已安装的Pods:"
    cd ios
    pod list 2>/dev/null | head -10
    cd ..
else
    echo "⚠️  Podfile.lock 不存在，需要运行 pod install"
fi
echo ""

# 4. 检查项目配置
echo "4️⃣  检查项目配置..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查Bundle ID
BUNDLE_ID=$(grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/ | head -1 | cut -d'=' -f2 | tr -d ' ;')
echo "Bundle Identifier: $BUNDLE_ID"

# 检查Team ID
TEAM_ID=$(grep -r "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/ | head -1 | cut -d'=' -f2 | tr -d ' ;')
if [ -n "$TEAM_ID" ]; then
    echo "Development Team: $TEAM_ID"
else
    echo "⚠️  Development Team 未设置"
fi

# 检查关键文件
echo ""
echo "关键文件检查:"
if [ -f "ios/Runner.xcworkspace/contents.xcworkspacedata" ]; then
    echo "✅ Runner.xcworkspace 存在"
else
    echo "❌ Runner.xcworkspace 不存在"
fi

if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    echo "✅ project.pbxproj 存在"
else
    echo "❌ project.pbxproj 不存在"
fi

if [ -f "ios/Runner/Info.plist" ]; then
    echo "✅ Info.plist 存在"
else
    echo "❌ Info.plist 不存在"
fi
echo ""

# 5. 尝试构建并捕获错误
echo "5️⃣  尝试构建项目..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "正在执行: flutter build ios --release --verbose"
echo "构建日志将保存到: build_error.log"
echo ""

# 执行构建并保存日志
flutter build ios --release --verbose > build_error.log 2>&1
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ 构建成功！"
    echo "📍 应用位置: build/ios/iphoneos/Runner.app"
else
    echo "❌ 构建失败！退出码: $BUILD_EXIT_CODE"
    echo ""
    echo "🔍 错误分析:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 分析常见错误
    if grep -q "Code signing" build_error.log; then
        echo "🚨 检测到签名错误"
        echo "   解决方案: 在Xcode中配置开发者账号和Bundle ID"
    fi
    
    if grep -q "No such module" build_error.log; then
        echo "🚨 检测到模块缺失错误"
        echo "   解决方案: 运行 cd ios && pod install"
    fi
    
    if grep -q "Provisioning profile" build_error.log; then
        echo "🚨 检测到配置文件错误"
        echo "   解决方案: 检查Bundle ID和开发者账号配置"
    fi
    
    if grep -q "Certificate" build_error.log; then
        echo "🚨 检测到证书错误"
        echo "   解决方案: 在Xcode中重新生成开发证书"
    fi
    
    echo ""
    echo "📋 最后10行错误信息:"
    tail -10 build_error.log
fi

echo ""
echo "6️⃣  诊断建议..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "🔧 建议的修复步骤:"
    echo ""
    echo "1. 基础修复:"
    echo "   ./fix_xcode.sh"
    echo ""
    echo "2. 在Xcode中配置签名:"
    echo "   open ios/Runner.xcworkspace"
    echo "   - 选择Runner项目 → Runner target"
    echo "   - Signing & Capabilities → 选择Team"
    echo "   - 修改Bundle Identifier为唯一值"
    echo ""
    echo "3. 如果是CocoaPods问题:"
    echo "   cd ios && pod deintegrate && pod install && cd .."
    echo ""
    echo "4. 如果是Flutter问题:"
    echo "   flutter clean && flutter pub get"
    echo ""
    echo "📖 详细排查指南: BUILD_ERROR_TROUBLESHOOTING.md"
else
    echo "🎉 构建成功！可以在Xcode中运行应用了"
    echo ""
    echo "📱 下一步:"
    echo "1. 打开Xcode: open ios/Runner.xcworkspace"
    echo "2. 选择你的iPhone设备"
    echo "3. 点击运行按钮 ▶️"
fi

echo ""
echo "📊 诊断完成！"
echo "📄 完整构建日志: build_error.log"
echo "📖 排查指南: BUILD_ERROR_TROUBLESHOOTING.md"