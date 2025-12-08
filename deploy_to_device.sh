#!/bin/bash

# iOS设备部署脚本
# 用于快速部署TPCG Collection Record到真实iOS设备

echo "📱 TPCG Collection Record - iOS设备部署"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查是否连接了iOS设备
echo "🔍 检查连接的iOS设备..."
DEVICES=$(xcrun xctrace list devices | grep -E "iPhone|iPad" | grep -v "Simulator")

if [ -z "$DEVICES" ]; then
    echo "❌ 未检测到连接的iOS设备"
    echo ""
    echo "📋 请确保："
    echo "   1. iOS设备通过USB连接到Mac"
    echo "   2. 在设备上点击'信任此电脑'"
    echo "   3. 设备已解锁"
    echo ""
    exit 1
else
    echo "✅ 检测到连接的设备："
    echo "$DEVICES"
fi

echo ""

# 清理并构建
echo "🧹 清理项目..."
flutter clean > /dev/null 2>&1

echo "📦 获取依赖..."
flutter pub get > /dev/null 2>&1

echo "🏗️  构建iOS Release版本..."
flutter build ios --release

if [ $? -ne 0 ]; then
    echo "❌ 构建失败！请检查错误信息"
    exit 1
fi

echo "✅ 构建成功！"
echo ""

# 提供详细的Xcode配置指导
echo "📝 接下来需要在Xcode中配置签名："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔧 Xcode配置步骤："
echo "1️⃣  选择 Runner 项目 → Runner target"
echo "2️⃣  点击 'Signing & Capabilities' 标签"
echo "3️⃣  选择你的Apple开发者账号作为 Team"
echo "4️⃣  修改 Bundle Identifier 为唯一值，例如："
echo "    com.yourname.tpcg-collection-record"
echo "5️⃣  确保 'Automatically manage signing' 已勾选"
echo "6️⃣  在设备选择器中选择你的真实设备"
echo "7️⃣  点击运行按钮 ▶️ 或按 Cmd+R"
echo ""
echo "📱 设备端操作："
echo "8️⃣  应用安装后，在设备上："
echo "    设置 → 通用 → VPN与设备管理"
echo "9️⃣  找到你的开发者账号并点击'信任'"
echo ""

# 打开Xcode
read -p "🚀 是否现在打开Xcode? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎉 正在打开Xcode..."
    open ios/Runner.xcworkspace
    
    # 等待Xcode启动
    sleep 3
    
    echo ""
    echo "💡 提示："
    echo "   - 如果这是第一次部署，需要配置签名"
    echo "   - 免费开发者账号的应用有效期为7天"
    echo "   - 付费开发者账号可以发布到App Store"
    echo ""
    echo "📖 详细指南请查看: IOS_DEVICE_DEPLOYMENT.md"
else
    echo ""
    echo "📖 稍后可以手动打开Xcode："
    echo "   open ios/Runner.xcworkspace"
    echo ""
    echo "📖 详细部署指南: IOS_DEVICE_DEPLOYMENT.md"
fi

echo ""
echo "🎊 准备完成！在Xcode中完成签名后即可在设备上运行应用。"