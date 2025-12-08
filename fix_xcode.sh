#!/bin/bash

# Xcode项目修复脚本
# 解决找不到Runner target和Signing & Capabilities的问题

echo "🔧 TPCG Collection Record - Xcode项目修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查当前目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：请在Flutter项目根目录运行此脚本"
    exit 1
fi

echo "📍 当前目录: $(pwd)"
echo ""

# 1. 关闭Xcode（如果正在运行）
echo "1️⃣  关闭Xcode（如果正在运行）..."
osascript -e 'quit app "Xcode"' 2>/dev/null || true
sleep 2

# 2. 清理项目
echo "2️⃣  清理Flutter项目..."
flutter clean > /dev/null 2>&1

echo "3️⃣  清理iOS构建文件..."
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -f ios/Podfile.lock
rm -rf ios/Flutter/Generated.xcconfig

# 3. 重新生成Flutter配置
echo "4️⃣  重新获取Flutter依赖..."
flutter pub get

# 4. 重新安装CocoaPods
echo "5️⃣  重新安装CocoaPods依赖..."
cd ios
pod install
if [ $? -ne 0 ]; then
    echo "⚠️  CocoaPods安装失败，尝试更新..."
    pod repo update
    pod install
fi
cd ..

# 5. 验证文件结构
echo "6️⃣  验证项目结构..."
if [ ! -f "ios/Runner.xcworkspace/contents.xcworkspacedata" ]; then
    echo "❌ workspace文件未正确生成"
    exit 1
fi

if [ ! -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    echo "❌ xcodeproj文件未找到"
    exit 1
fi

echo "✅ 项目结构验证通过"
echo ""

# 6. 显示正确的打开方式
echo "📋 重要提醒："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 正确打开方式: open ios/Runner.xcworkspace"
echo "❌ 错误打开方式: open ios/Runner.xcodeproj"
echo ""
echo "🎯 在Xcode中查找Runner target的步骤："
echo "1. 点击左侧的蓝色 'Runner' 项目图标"
echo "2. 在TARGETS部分选择 'Runner'"
echo "3. 点击 'Signing & Capabilities' 标签"
echo ""

# 7. 询问是否打开Xcode
read -p "🚀 是否现在打开Xcode? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎉 正在打开Xcode workspace..."
    open ios/Runner.xcworkspace
    
    # 等待Xcode启动
    sleep 3
    
    echo ""
    echo "💡 如果仍然看不到Runner target，请尝试："
    echo "   1. 按 Cmd+1 显示项目导航器"
    echo "   2. 确保左侧面板已展开"
    echo "   3. 点击蓝色的 'Runner' 项目图标"
    echo ""
    echo "📖 详细故障排除指南: XCODE_TROUBLESHOOTING.md"
else
    echo ""
    echo "📖 稍后可以手动打开Xcode："
    echo "   open ios/Runner.xcworkspace"
    echo ""
    echo "📖 故障排除指南: XCODE_TROUBLESHOOTING.md"
fi

echo ""
echo "🎊 修复完成！"
echo ""
echo "📋 下一步操作："
echo "1. 在Xcode中找到 Runner target"
echo "2. 配置 Signing & Capabilities"
echo "3. 选择开发者账号和修改Bundle ID"
echo "4. 选择设备并运行应用"