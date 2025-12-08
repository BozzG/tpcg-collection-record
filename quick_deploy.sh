#!/bin/bash

# 快速iOS设备部署脚本
# 直接打开Xcode进行签名和部署

echo "🚀 TPCG Collection Record - 快速设备部署"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查设备连接
echo "📱 检查连接的iOS设备..."
DEVICES=$(xcrun xctrace list devices | grep -E "iPhone|iPad" | grep -v "Simulator")

if [ -z "$DEVICES" ]; then
    echo "⚠️  未检测到连接的iOS设备"
    echo "   请确保设备已通过USB连接并信任此电脑"
else
    echo "✅ 检测到设备："
    echo "$DEVICES"
fi

echo ""
echo "🔧 即将打开Xcode进行签名配置..."
echo ""
echo "📋 在Xcode中需要完成的步骤："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  选择 Runner 项目 → Runner target"
echo "2️⃣  点击 'Signing & Capabilities' 标签"
echo "3️⃣  Team: 选择你的Apple开发者账号"
echo "4️⃣  Bundle Identifier: 修改为唯一值"
echo "    建议: com.yourname.tpcg-collection-record"
echo "5️⃣  确保 'Automatically manage signing' 已勾选"
echo "6️⃣  在设备选择器中选择你的iPhone"
echo "7️⃣  点击运行按钮 ▶️ 或按 Cmd+R"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "按Enter键打开Xcode..."

echo "🎉 正在打开Xcode项目..."
open ios/Runner.xcworkspace

echo ""
echo "📖 详细配置指南:"
echo "   - XCODE_SIGNING_GUIDE.md (完整签名指南)"
echo "   - BUNDLE_ID_SETUP.md (Bundle ID配置)"
echo "   - IOS_DEVICE_DEPLOYMENT.md (设备部署指南)"
echo ""
echo "💡 提示:"
echo "   - 首次部署需要配置Apple开发者账号"
echo "   - 免费账号的应用有效期为7天"
echo "   - 安装后需要在设备上信任开发者证书"
echo ""
echo "🎊 配置完成后，应用将自动安装到你的iPhone上！"