#!/bin/bash

echo "🔧 测试 iOS 闪退修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 检查语法错误
echo "1️⃣ 检查语法错误..."
flutter analyze lib/main.dart
if [ $? -ne 0 ]; then
    echo "❌ 语法检查失败，请修复错误后重试"
    exit 1
fi
echo "✅ 语法检查通过"
echo ""

# 2. 清理并重新构建
echo "2️⃣ 清理并重新构建..."
flutter clean
flutter pub get
echo ""

# 3. 构建 iOS debug 版本
echo "3️⃣ 构建 iOS debug 版本..."
flutter build ios --debug
if [ $? -ne 0 ]; then
    echo "❌ iOS 构建失败"
    exit 1
fi
echo "✅ iOS 构建成功"
echo ""

# 4. 检查设备连接
echo "4️⃣ 检查设备连接..."
DEVICES=$(xcrun xctrace list devices | grep -E "iPhone|iPad" | grep -v "Simulator")
if [ -z "$DEVICES" ]; then
    echo "⚠️ 未检测到连接的 iOS 设备"
    echo "请连接 iPhone 后重试"
else
    echo "✅ 检测到设备："
    echo "$DEVICES"
fi
echo ""

# 5. 提供下一步指导
echo "5️⃣ 下一步操作："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 通过 Xcode 测试修复效果："
echo "   1. 运行: open ios/Runner.xcworkspace"
echo "   2. 选择你的 iPhone 设备"
echo "   3. 点击运行按钮 ▶️"
echo "   4. 观察应用是否正常启动"
echo ""
echo "📱 或者通过 Flutter 命令运行："
echo "   flutter run -d [设备ID]"
echo ""
echo "🔍 如果仍然闪退，请查看："
echo "   - Xcode 控制台的错误信息"
echo "   - iPhone 设置 → 隐私与安全性 → 分析与改进 → 分析数据"
echo ""

# 6. 询问是否打开 Xcode
read -p "🚀 是否现在打开 Xcode 进行测试? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎉 正在打开 Xcode..."
    open ios/Runner.xcworkspace
    echo ""
    echo "💡 在 Xcode 中："
    echo "   1. 选择你的 iPhone 设备"
    echo "   2. 点击运行按钮 ▶️"
    echo "   3. 观察底部控制台输出"
    echo "   4. 应用应该显示'正在初始化应用...'而不是直接闪退"
fi

echo ""
echo "🎊 修复测试准备完成！"