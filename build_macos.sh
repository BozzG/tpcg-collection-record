#!/bin/bash

# macOS应用程序构建脚本
# 用于构建 TPCG Collection Record macOS应用程序

echo "🚀 开始构建 TPCG Collection Record macOS应用程序..."

# 检查Flutter环境
echo "📋 检查Flutter环境..."
flutter doctor

# 获取依赖
echo "📦 获取项目依赖..."
flutter pub get

# 生成代码
echo "🔧 生成必要的代码文件..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# 清理之前的构建
echo "🧹 清理之前的构建..."
flutter clean

# 重新获取依赖
flutter pub get

# 构建macOS应用程序
echo "🏗️  构建macOS应用程序..."
flutter build macos --release

# 检查构建结果
if [ -d "build/macos/Build/Products/Release/tpcg_collection_record.app" ]; then
    echo "✅ 构建成功！"
    echo "📍 应用程序位置: $(pwd)/build/macos/Build/Products/Release/tpcg_collection_record.app"
    echo "📊 应用程序大小: $(du -sh build/macos/Build/Products/Release/tpcg_collection_record.app | cut -f1)"
    
    echo ""
    echo "🎯 可用操作:"
    echo "1. 运行应用程序: open build/macos/Build/Products/Release/tpcg_collection_record.app"
    echo "2. 在Finder中显示: open build/macos/Build/Products/Release/"
    echo "3. 复制到应用程序文件夹: cp -R build/macos/Build/Products/Release/tpcg_collection_record.app /Applications/"
    
    # 询问是否立即运行
    read -p "🚀 是否立即运行应用程序? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🎉 启动应用程序..."
        open build/macos/Build/Products/Release/tpcg_collection_record.app
    fi
    
else
    echo "❌ 构建失败！请检查上面的错误信息。"
    exit 1
fi