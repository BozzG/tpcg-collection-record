#!/bin/bash

# iOS配置检查脚本
# 用于验证iOS部署前的配置是否正确

echo "🔍 iOS配置检查工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 检查Flutter环境
echo "📋 1. Flutter环境检查"
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -1)
    echo "✅ Flutter: $FLUTTER_VERSION"
else
    echo "❌ Flutter未安装"
    exit 1
fi

# 2. 检查Xcode环境
echo ""
echo "🔧 2. Xcode环境检查"
if command -v xcode-select &> /dev/null; then
    XCODE_PATH=$(xcode-select -p)
    echo "✅ Xcode路径: $XCODE_PATH"
    
    # 检查Xcode版本
    if command -v xcodebuild &> /dev/null; then
        XCODE_VERSION=$(xcodebuild -version | head -1)
        echo "✅ Xcode版本: $XCODE_VERSION"
    fi
else
    echo "❌ Xcode未安装"
    exit 1
fi

# 3. 检查Bundle Identifier
echo ""
echo "📦 3. Bundle Identifier检查"
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    BUNDLE_ID=$(grep -o 'PRODUCT_BUNDLE_IDENTIFIER = "[^"]*"' ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/PRODUCT_BUNDLE_IDENTIFIER = "//; s/"//')
    if [ -n "$BUNDLE_ID" ]; then
        echo "✅ Bundle Identifier: $BUNDLE_ID"
        
        # 检查是否使用默认值
        if [[ "$BUNDLE_ID" == *"example"* ]]; then
            echo "⚠️  警告: 使用默认Bundle ID，建议修改为唯一值"
        fi
    else
        echo "❌ Bundle Identifier未配置"
    fi
else
    echo "❌ 项目配置文件不存在"
fi

# 4. 检查应用信息
echo ""
echo "📱 4. 应用信息检查"
if [ -f "ios/Runner/Info.plist" ]; then
    APP_NAME=$(grep -A 1 "CFBundleDisplayName" ios/Runner/Info.plist | tail -1 | sed 's/.*<string>//; s/<\/string>.*//')
    if [ -n "$APP_NAME" ]; then
        echo "✅ 应用名称: $APP_NAME"
    fi
    
    # 检查权限配置
    if grep -q "NSCameraUsageDescription" ios/Runner/Info.plist; then
        echo "✅ 相机权限: 已配置"
    else
        echo "⚠️  相机权限: 未配置"
    fi
    
    if grep -q "NSPhotoLibraryUsageDescription" ios/Runner/Info.plist; then
        echo "✅ 照片库权限: 已配置"
    else
        echo "⚠️  照片库权限: 未配置"
    fi
else
    echo "❌ Info.plist文件不存在"
fi

# 5. 检查版本信息
echo ""
echo "📊 5. 版本信息检查"
if [ -f "pubspec.yaml" ]; then
    VERSION=$(grep "version:" pubspec.yaml | cut -d' ' -f2)
    if [ -n "$VERSION" ]; then
        echo "✅ 应用版本: $VERSION"
    fi
else
    echo "❌ pubspec.yaml文件不存在"
fi

# 6. 检查连接的设备
echo ""
echo "📱 6. 设备连接检查"
DEVICES_OUTPUT=$(flutter devices 2>/dev/null)
IOS_DEVICES=$(echo "$DEVICES_OUTPUT" | grep -E "iPhone|iPad" | grep -v "Simulator")

if [ -n "$IOS_DEVICES" ]; then
    echo "✅ 检测到iOS设备:"
    echo "$IOS_DEVICES" | while read -r line; do
        echo "   📱 $line"
    done
else
    echo "⚠️  未检测到连接的iOS设备"
    echo "   请确保设备已连接并信任此电脑"
fi

# 7. 检查依赖
echo ""
echo "📦 7. 项目依赖检查"
if [ -f "pubspec.lock" ]; then
    echo "✅ 依赖锁定文件存在"
    
    # 检查关键依赖
    if grep -q "sqflite" pubspec.lock; then
        echo "✅ 数据库依赖: sqflite"
    fi
    
    if grep -q "file_picker" pubspec.lock; then
        echo "✅ 文件选择依赖: file_picker"
    fi
    
    if grep -q "provider" pubspec.lock; then
        echo "✅ 状态管理依赖: provider"
    fi
else
    echo "⚠️  依赖锁定文件不存在，请运行 flutter pub get"
fi

# 8. 检查构建配置
echo ""
echo "🏗️  8. 构建配置检查"
if [ -d "build" ]; then
    echo "✅ 构建目录存在"
    
    if [ -d "build/ios" ]; then
        echo "✅ iOS构建目录存在"
        
        # 检查最近的构建
        if [ -d "build/ios/iphoneos" ]; then
            echo "✅ 设备构建产物存在"
        fi
        
        if [ -d "build/ios/iphonesimulator" ]; then
            echo "✅ 模拟器构建产物存在"
        fi
    fi
else
    echo "⚠️  构建目录不存在，需要先构建项目"
fi

# 9. 检查证书配置 (简单检查)
echo ""
echo "🔐 9. 开发者证书检查"
KEYCHAIN_CERTS=$(security find-identity -v -p codesigning 2>/dev/null | grep "iPhone Developer\\|Apple Development" | wc -l)
if [ "$KEYCHAIN_CERTS" -gt 0 ]; then
    echo "✅ 检测到 $KEYCHAIN_CERTS 个开发者证书"
else
    echo "⚠️  未检测到开发者证书，可能需要在Xcode中配置"
fi

# 总结
echo ""
echo "📋 配置检查总结"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 计算配置完整度
TOTAL_CHECKS=9
PASSED_CHECKS=0

# 这里可以根据上面的检查结果计算通过的检查项数量
# 简化版本，假设基本配置都正确
if command -v flutter &> /dev/null; then ((PASSED_CHECKS++)); fi
if command -v xcode-select &> /dev/null; then ((PASSED_CHECKS++)); fi
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then ((PASSED_CHECKS++)); fi
if [ -f "ios/Runner/Info.plist" ]; then ((PASSED_CHECKS++)); fi
if [ -f "pubspec.yaml" ]; then ((PASSED_CHECKS++)); fi
if [ -f "pubspec.lock" ]; then ((PASSED_CHECKS++)); fi
if [ -n "$IOS_DEVICES" ]; then ((PASSED_CHECKS++)); fi
if [ "$KEYCHAIN_CERTS" -gt 0 ]; then ((PASSED_CHECKS++)); fi
if [ -d "ios" ]; then ((PASSED_CHECKS++)); fi

COMPLETION_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo "✅ 配置完整度: $PASSED_CHECKS/$TOTAL_CHECKS ($COMPLETION_RATE%)"

if [ $COMPLETION_RATE -ge 80 ]; then
    echo "🎉 配置良好，可以开始部署！"
    echo ""
    echo "🚀 推荐部署命令:"
    echo "   ./deploy_ios_release.sh"
elif [ $COMPLETION_RATE -ge 60 ]; then
    echo "⚠️  配置基本完整，但有一些问题需要解决"
    echo ""
    echo "💡 建议先解决上述警告，然后再部署"
else
    echo "❌ 配置不完整，需要解决多个问题后再部署"
    echo ""
    echo "📖 请参考: IOS_RELEASE_DEPLOYMENT_GUIDE.md"
fi

echo ""
echo "📚 相关文档:"
echo "   📖 IOS_RELEASE_DEPLOYMENT_GUIDE.md - 完整部署指南"
echo "   📖 IOS_DEVICE_DEPLOYMENT.md - 设备部署说明"
echo "   🚀 deploy_ios_release.sh - 自动部署脚本"