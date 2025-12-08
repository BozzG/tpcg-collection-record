#!/bin/bash

# iOS应用程序构建脚本
# 用于构建 TPCG Collection Record iOS应用程序

echo "📱 开始构建 TPCG Collection Record iOS应用程序..."

# 检查Flutter环境
echo "📋 检查Flutter环境..."
flutter doctor

# 检查Xcode环境
echo "🔧 检查Xcode环境..."
xcode-select -p
xcrun --show-sdk-path --sdk iphoneos

# 获取依赖
echo "📦 获取项目依赖..."
flutter pub get

# 生成代码
echo "🔧 生成必要的代码文件..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# 清理之前的构建
echo "🧹 清理之前的构建..."
flutter clean
flutter pub get

# 检查可用的iOS设备和模拟器
echo "📱 检查可用设备..."
flutter devices
echo ""
echo "📱 可用模拟器："
flutter emulators

# 询问构建类型
echo ""
echo "请选择构建类型："
echo "1. iOS模拟器 (推荐用于测试)"
echo "2. iOS设备 (需要开发者证书)"
echo "3. 仅构建不运行"
read -p "请输入选择 (1-3): " choice

case $choice in
    1)
        echo "🏗️  构建iOS模拟器应用..."
        flutter build ios --simulator
        
        if [ $? -eq 0 ]; then
            echo "✅ 模拟器构建成功！"
            echo "📍 应用程序位置: $(pwd)/build/ios/iphonesimulator/Runner.app"
            
            # 检查是否有模拟器在运行
            BOOTED_SIM=$(xcrun simctl list devices | grep "Booted" | head -1)
            if [ -z "$BOOTED_SIM" ]; then
                echo "🚀 启动iOS模拟器..."
                xcrun simctl boot "iPhone 17 Pro" 2>/dev/null || xcrun simctl boot "iPhone 15 Pro" 2>/dev/null
                open -a Simulator
                sleep 5
            fi
            
            # 询问是否运行应用
            read -p "🚀 是否在模拟器上运行应用? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "🎉 在模拟器上启动应用..."
                flutter run -d "iPhone 17 Pro" || flutter run
            fi
        else
            echo "❌ 模拟器构建失败！"
            exit 1
        fi
        ;;
    2)
        echo "🏗️  构建iOS设备应用..."
        flutter build ios --release
        
        if [ $? -eq 0 ]; then
            echo "✅ 设备构建成功！"
            echo "📍 应用程序位置: $(pwd)/build/ios/iphoneos/Runner.app"
            echo ""
            echo "📝 下一步：通过Xcode签名并安装到设备"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "1️⃣  打开Xcode项目"
            echo "2️⃣  配置签名（Signing & Capabilities）"
            echo "3️⃣  选择你的Apple开发者账号作为Team"
            echo "4️⃣  修改Bundle Identifier为唯一值"
            echo "5️⃣  连接iOS设备到Mac"
            echo "6️⃣  在Xcode中选择你的设备"
            echo "7️⃣  点击运行按钮 (▶️) 或按 Cmd+R"
            echo "8️⃣  在设备上信任开发者证书"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "💡 Bundle Identifier建议："
            echo "   com.yourname.tpcg-collection-record"
            echo "   com.yourdomain.tpcgcollectionrecord"
            echo ""
            
            # 检查是否有连接的iOS设备
            echo "📱 检查连接的iOS设备..."
            CONNECTED_DEVICES=$(xcrun simctl list devices | grep -E "iPhone|iPad" | grep -v "Simulator" | grep "Booted\|Shutdown")
            if [ -z "$CONNECTED_DEVICES" ]; then
                echo "⚠️  未检测到连接的iOS设备"
                echo "   请确保设备已通过USB连接并信任此电脑"
            else
                echo "✅ 检测到连接的设备"
            fi
            echo ""
            
            # 询问是否打开Xcode
            read -p "🔧 是否现在打开Xcode进行签名和安装? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "🎉 打开Xcode项目..."
                open ios/Runner.xcworkspace
                echo ""
                echo "📖 详细部署指南请查看: IOS_DEVICE_DEPLOYMENT.md"
            else
                echo "📖 稍后可以手动打开Xcode项目："
                echo "   open ios/Runner.xcworkspace"
                echo ""
                echo "📖 详细部署指南请查看: IOS_DEVICE_DEPLOYMENT.md"
            fi
        else
            echo "❌ 设备构建失败！"
            echo "💡 请检查以下问题："
            echo "   1. Flutter环境是否正确配置"
            echo "   2. iOS开发工具是否安装完整"
            echo "   3. 项目依赖是否正确安装"
            exit 1
        fi
        ;;
    3)
        echo "🏗️  仅构建iOS应用..."
        flutter build ios --simulator
        
        if [ $? -eq 0 ]; then
            echo "✅ 构建成功！"
            echo "📍 模拟器应用: $(pwd)/build/ios/iphonesimulator/Runner.app"
            
            # 同时构建设备版本
            echo "🏗️  构建设备版本..."
            flutter build ios --release
            
            if [ $? -eq 0 ]; then
                echo "✅ 设备版本构建成功！"
                echo "📍 设备应用: $(pwd)/build/ios/iphoneos/Runner.app"
            fi
        else
            echo "❌ 构建失败！"
            exit 1
        fi
        ;;
    *)
        echo "❌ 无效选择，退出构建"
        exit 1
        ;;
esac

echo ""
echo "🎊 iOS构建完成！"
echo ""
echo "📋 构建信息："
echo "- 应用名称: TPCG Collection Record"
echo "- 版本: 1.0.0+1"
echo "- 平台: iOS"
echo "- 最低系统要求: iOS 12.0+"
echo ""
echo "🔧 下一步操作："
echo "1. 模拟器测试: 使用构建的.app文件在模拟器中测试"
echo "2. 设备安装: 通过Xcode签名后安装到真实设备"
echo "3. App Store发布: 配置发布证书后提交到App Store"