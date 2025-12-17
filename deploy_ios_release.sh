#!/bin/bash

# iOS Release版本自动部署脚本
# 用于将TPCG Collection Record部署到真实iOS设备

echo "🚀 开始iOS Release版本部署..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查Flutter环境
echo "📋 检查Flutter环境..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装或未添加到PATH"
    exit 1
fi

flutter doctor --android-licenses > /dev/null 2>&1
FLUTTER_STATUS=$(flutter doctor | grep -E "✓|✗")
echo "$FLUTTER_STATUS"

# 检查Xcode环境
echo ""
echo "🔧 检查Xcode环境..."
if ! command -v xcode-select &> /dev/null; then
    echo "❌ Xcode未安装"
    exit 1
fi

XCODE_PATH=$(xcode-select -p)
echo "✅ Xcode路径: $XCODE_PATH"

# 检查连接的iOS设备
echo ""
echo "📱 检查连接的iOS设备..."
DEVICES_OUTPUT=$(flutter devices)
IOS_DEVICES=$(echo "$DEVICES_OUTPUT" | grep -E "iPhone|iPad" | grep -v "Simulator")

if [ -z "$IOS_DEVICES" ]; then
    echo "❌ 未检测到连接的iOS设备"
    echo ""
    echo "请确保："
    echo "1. iOS设备已通过USB连接到Mac"
    echo "2. 在设备上点击了'信任此电脑'"
    echo "3. 设备已解锁"
    echo "4. 设备已启用开发者模式 (iOS 16+)"
    echo ""
    echo "📱 当前可用设备："
    echo "$DEVICES_OUTPUT"
    exit 1
fi

echo "✅ 检测到iOS设备："
echo "$IOS_DEVICES"

# 清理项目
echo ""
echo "🧹 清理项目..."
flutter clean
if [ $? -ne 0 ]; then
    echo "❌ 清理失败"
    exit 1
fi

# 获取依赖
echo "📦 获取项目依赖..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ 依赖获取失败"
    exit 1
fi

# 生成必要代码
echo "🔧 生成必要代码..."
flutter packages pub run build_runner build --delete-conflicting-outputs > /dev/null 2>&1

# 检查Bundle Identifier
echo ""
echo "📋 检查Bundle Identifier配置..."
BUNDLE_ID=$(grep -A 1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | grep -o "com\\..*" | head -1 | sed 's/;//')\nif [ -z "$BUNDLE_ID" ]; then\n    echo "⚠️  Bundle Identifier未配置，将使用默认值"\n    BUNDLE_ID="com.example.tpcgCollectionRecord"\nelse\n    echo "✅ Bundle Identifier: $BUNDLE_ID"\nfi

# 构建Release版本
echo ""
echo "🔨 构建iOS Release版本..."
echo "这可能需要几分钟时间，请耐心等待..."

flutter build ios --release
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ Release版本构建成功！"
    echo "📍 构建产物位置: $(pwd)/build/ios/iphoneos/Runner.app"
else
    echo "❌ Release版本构建失败！"
    echo ""
    echo "💡 可能的解决方案："
    echo "1. 检查Flutter doctor输出是否有问题"
    echo "2. 确保Xcode版本兼容"
    echo "3. 检查项目依赖是否正确"
    echo "4. 尝试重新安装Flutter"
    exit 1
fi

# 询问部署方式
echo ""
echo "🎯 选择部署方式："
echo "1. 通过Flutter直接部署 (推荐，自动处理签名)"
echo "2. 通过Xcode部署 (手动配置签名，更多控制)"
echo "3. 仅构建，稍后手动部署"
read -p "请选择 (1-3): " -n 1 -r
echo

case $REPLY in
    1)
        echo "🚀 通过Flutter直接部署到设备..."
        echo ""
        echo "📝 注意事项："
        echo "- 首次部署可能需要在设备上信任开发者证书"
        echo "- 设置 → 通用 → VPN与设备管理 → 信任证书"
        echo ""
        
        # 获取设备ID
        DEVICE_ID=$(echo "$IOS_DEVICES" | head -1 | grep -o "[0-9a-f-]\\{36\\}")
        if [ -z "$DEVICE_ID" ]; then
            echo "🚀 部署到默认设备..."
            flutter run --release
        else
            echo "🚀 部署到设备: $DEVICE_ID"
            flutter run -d "$DEVICE_ID" --release\n        fi\n        \n        DEPLOY_STATUS=$?\n        if [ $DEPLOY_STATUS -eq 0 ]; then\n            echo ""\n            echo "🎉 部署成功！"\n            echo ""\n            echo "📱 应用已安装到设备上，请检查："\n            echo "✅ 应用图标是否出现在主屏幕"\n            echo "✅ 点击图标是否能正常启动"\n            echo "✅ 所有功能是否正常工作"\n        else\n            echo ""\n            echo "❌ 部署失败！"\n            echo ""\n            echo "💡 可能的原因："\n            echo "1. 签名配置问题 - 需要配置Apple开发者账号"\n            echo "2. Bundle Identifier冲突 - 需要使用唯一标识符"\n            echo "3. 设备未信任 - 需要在设备上信任开发者证书"\n            echo "4. 证书过期 - 需要重新生成开发证书"\n            echo ""\n            echo "🔧 建议使用方式2通过Xcode手动配置签名"\n        fi\n        ;;\n    2)\n        echo "🔧 准备通过Xcode部署..."\n        echo ""\n        echo "📋 接下来的步骤："\n        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"\n        echo "1️⃣  Xcode将自动打开项目"\n        echo "2️⃣  在Xcode中选择 Runner → Signing & Capabilities"\n        echo "3️⃣  配置以下设置："\n        echo "   • Team: 选择你的Apple开发者账号"\n        echo "   • Bundle Identifier: 修改为唯一值 (如: com.yourname.tpcgcollectionrecord)"\n        echo "   • ✅ 勾选 'Automatically manage signing'"\n        echo "4️⃣  在设备选择器中选择你的真实设备"\n        echo "5️⃣  点击运行按钮 (▶️) 或按 Cmd+R"\n        echo "6️⃣  在设备上信任开发者证书"\n        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"\n        echo ""\n        echo "💡 Bundle Identifier建议："\n        echo "   com.yourname.tpcgcollectionrecord"\n        echo "   com.yourdomain.pokemon-card-tracker"\n        echo "   com.company.tpcg-collection-record"\n        echo ""\n        \n        read -p "🔧 现在打开Xcode项目? (y/n): " -n 1 -r\n        echo\n        if [[ $REPLY =~ ^[Yy]$ ]]; then\n            echo "🎉 打开Xcode项目..."\n            open ios/Runner.xcworkspace\n            echo ""\n            echo "📖 详细配置指南: IOS_RELEASE_DEPLOYMENT_GUIDE.md"\n        else\n            echo "📖 稍后可以手动打开：open ios/Runner.xcworkspace"\n        fi\n        ;;\n    3)\n        echo "✅ 构建完成，应用已准备就绪！"\n        echo ""\n        echo "📍 构建产物位置："\n        echo "   $(pwd)/build/ios/iphoneos/Runner.app"\n        echo ""\n        echo "🔧 手动部署选项："\n        echo "1. 通过Xcode: open ios/Runner.xcworkspace"\n        echo "2. 通过Flutter: flutter run --release"\n        echo "3. 通过iOS App Installer (如果可用)"\n        echo ""\n        echo "📖 详细部署指南: IOS_RELEASE_DEPLOYMENT_GUIDE.md"\n        ;;\n    *)\n        echo "❌ 无效选择，退出部署"\n        exit 1\n        ;;\nesac\n\necho ""\necho "🎊 iOS Release部署流程完成！"\necho ""\necho "📋 部署信息总结："\necho "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"\necho "📱 应用名称: TPCG Collection Record"\necho "📦 版本: $(grep version pubspec.yaml | cut -d' ' -f2)"\necho "🏗️  构建模式: Release"\necho "📍 Bundle ID: $BUNDLE_ID"\necho "🎯 目标平台: iOS 12.0+"\necho "📍 构建产物: build/ios/iphoneos/Runner.app"\necho "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"\necho ""\necho "🔍 测试清单："\necho "□ 应用启动和导航"\necho "□ 数据库操作 (添加/编辑卡片)"\necho "□ 图片选择和相机功能"\necho "□ 项目管理功能"\necho "□ 搜索和排序功能"\necho "□ 数据持久化"\necho ""\necho "💡 如果遇到问题，请查看: IOS_RELEASE_DEPLOYMENT_GUIDE.md"\necho "🎉 祝你使用愉快！"