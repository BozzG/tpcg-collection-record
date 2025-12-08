#!/bin/bash

# iOS应用闪退调试脚本
# 用于快速排查和收集调试信息

echo "🔍 TPCG Collection Record - iOS闪退调试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查当前目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：请在Flutter项目根目录运行此脚本"
    exit 1
fi

echo "📍 项目路径: $(pwd)"
echo "📅 调试时间: $(date)"
echo ""

# 1. 检查设备连接
echo "1️⃣  检查设备连接..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
DEVICES=$(xcrun xctrace list devices | grep -E "iPhone|iPad" | grep -v "Simulator")
if [ -z "$DEVICES" ]; then
    echo "❌ 未检测到连接的iOS设备"
    echo "   请确保iPhone通过USB连接到Mac"
    exit 1
else
    echo "✅ 检测到设备："
    echo "$DEVICES"
fi
echo ""

# 2. 检查关键配置文件
echo "2️⃣  检查关键配置..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查Info.plist权限配置
echo "📱 Info.plist权限配置："
if grep -q "NSPhotoLibraryUsageDescription" ios/Runner/Info.plist; then
    echo "✅ 照片库权限已配置"
else
    echo "⚠️  照片库权限未配置"
fi

if grep -q "NSCameraUsageDescription" ios/Runner/Info.plist; then
    echo "✅ 相机权限已配置"
else
    echo "⚠️  相机权限未配置"
fi

# 检查Bundle ID
BUNDLE_ID=$(grep -A1 "CFBundleIdentifier" ios/Runner/Info.plist | grep -o "com\.[^<]*")
echo "📦 Bundle ID: $BUNDLE_ID"
echo ""

# 3. 检查数据库服务
echo "3️⃣  检查数据库服务..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "lib/services/database_service.dart" ]; then
    echo "✅ 数据库服务文件存在"
    
    # 检查数据库初始化方法
    if grep -q "initDatabase" lib/services/database_service.dart; then
        echo "✅ 找到数据库初始化方法"
    else
        echo "⚠️  未找到数据库初始化方法"
    fi
    
    # 检查数据库路径配置
    if grep -q "getDatabasesPath\|path_provider" lib/services/database_service.dart; then
        echo "✅ 数据库路径配置正常"
    else
        echo "⚠️  数据库路径配置可能有问题"
    fi
else
    echo "❌ 数据库服务文件不存在"
fi
echo ""

# 4. 检查图片服务
echo "4️⃣  检查图片服务..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "lib/services/image_service.dart" ]; then
    echo "✅ 图片服务文件存在"
    
    # 检查文件选择器
    if grep -q "file_picker\|FilePicker" lib/services/image_service.dart; then
        echo "✅ 文件选择器配置正常"
    else
        echo "⚠️  文件选择器配置可能有问题"
    fi
else
    echo "❌ 图片服务文件不存在"
fi
echo ""

# 5. 检查应用启动代码
echo "5️⃣  检查应用启动代码..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "lib/main.dart" ]; then
    echo "✅ main.dart文件存在"
    
    # 检查数据库初始化调用
    if grep -q "DatabaseService.*init" lib/main.dart; then
        echo "⚠️  在main.dart中发现数据库初始化调用"
        echo "   这可能导致启动时崩溃"
    else
        echo "✅ main.dart中没有直接的数据库初始化"
    fi
    
    # 检查异步初始化
    if grep -q "WidgetsFlutterBinding.ensureInitialized" lib/main.dart; then
        echo "✅ Flutter绑定初始化正常"
    else
        echo "⚠️  可能缺少Flutter绑定初始化"
    fi
else
    echo "❌ main.dart文件不存在"
fi
echo ""

# 6. 构建debug版本
echo "6️⃣  构建debug版本..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "正在构建debug版本（包含调试信息）..."

flutter build ios --debug > debug_build.log 2>&1
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ Debug版本构建成功"
else
    echo "❌ Debug版本构建失败"
    echo "📄 构建日志已保存到: debug_build.log"
    echo ""
    echo "🔍 构建错误分析："
    tail -10 debug_build.log
fi
echo ""

# 7. 生成调试建议
echo "7️⃣  生成调试建议..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🎯 基于检查结果的调试建议："
echo ""

# 基于检查结果给出建议
if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "🚨 优先级1: 修复构建错误"
    echo "   - 查看 debug_build.log 了解构建失败原因"
    echo "   - 运行 ./fix_signing.sh 修复签名问题"
    echo ""
fi

if ! grep -q "NSPhotoLibraryUsageDescription" ios/Runner/Info.plist; then
    echo "🚨 优先级2: 添加权限配置"
    echo "   - 在 ios/Runner/Info.plist 中添加照片库权限"
    echo ""
fi

if grep -q "DatabaseService.*init" lib/main.dart; then
    echo "🚨 优先级3: 检查数据库初始化"
    echo "   - 数据库初始化可能导致启动崩溃"
    echo "   - 考虑延迟初始化或添加错误处理"
    echo ""
fi

echo "📋 推荐的调试步骤："
echo "1. 通过Xcode实时调试（最有效）"
echo "   open ios/Runner.xcworkspace"
echo "   选择设备并运行，观察控制台输出"
echo ""
echo "2. 查看设备崩溃报告"
echo "   iPhone设置 → 隐私与安全性 → 分析与改进 → 分析数据"
echo ""
echo "3. 使用Flutter日志"
echo "   flutter logs"
echo ""

# 8. 询问是否打开Xcode进行实时调试
read -p "🚀 是否现在打开Xcode进行实时调试? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎉 正在打开Xcode..."
    open ios/Runner.xcworkspace
    
    echo ""
    echo "💡 在Xcode中调试的步骤："
    echo "1. 选择你的iPhone设备"
    echo "2. 点击运行按钮 ▶️"
    echo "3. 观察底部控制台的输出"
    echo "4. 如果崩溃，查看红色错误信息"
    echo "5. 记录崩溃时的堆栈跟踪"
    echo ""
    echo "📖 详细调试指南: IOS_CRASH_DEBUG.md"
else
    echo ""
    echo "📖 稍后可以手动调试："
    echo "   open ios/Runner.xcworkspace"
    echo ""
    echo "📄 调试日志文件："
    echo "   - debug_build.log (构建日志)"
    echo "   - IOS_CRASH_DEBUG.md (详细调试指南)"
fi

echo ""
echo "🎊 调试信息收集完成！"
echo ""
echo "📋 如果问题仍然存在，请提供："
echo "   1. Xcode控制台的完整错误信息"
echo "   2. iPhone崩溃报告的详细内容"
echo "   3. 应用崩溃的具体时机"
echo "   4. debug_build.log 文件内容"