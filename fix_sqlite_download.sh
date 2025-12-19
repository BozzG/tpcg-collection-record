#!/bin/bash

# SQLite 下载超时问题快速修复脚本

echo "🔧 修复 SQLite 下载超时问题"
echo "================================"

# 检查是否在项目根目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

echo "📋 当前问题："
echo "SQLite3 库下载超时，无法从 GitHub 获取二进制文件"
echo ""

# 步骤 1: 清理缓存
echo "🧹 步骤 1: 清理项目缓存..."
flutter clean

# 清理 SQLite 相关缓存
echo "🗑️  清理 SQLite 缓存..."
rm -rf ~/.pub-cache/hosted/pub.flutter-io.cn/sqlite3* 2>/dev/null || true
rm -rf ~/.pub-cache/hosted/pub.dev/sqlite3* 2>/dev/null || true

# 步骤 2: 配置网络环境
echo "🌐 步骤 2: 配置网络环境..."
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 步骤 3: 检查当前依赖
echo "📋 步骤 3: 检查当前依赖..."
if grep -q "sqlite3:" pubspec.yaml; then
    echo "⚠️  检测到 sqlite3 依赖，这可能导致下载问题"
    echo ""
    echo "🎯 建议解决方案："
    echo "1. 简化依赖配置（推荐）"
    echo "2. 配置网络代理"
    echo "3. 手动下载文件"
    echo ""
    
    read -p "是否要自动简化依赖配置? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📝 备份原始 pubspec.yaml..."
        cp pubspec.yaml pubspec.yaml.backup.$(date +%Y%m%d_%H%M%S)
        
        echo "🔧 简化依赖配置..."
        # 注释掉 sqlite3 依赖
        sed -i.bak 's/^  sqlite3:/  # sqlite3:/' pubspec.yaml
        sed -i.bak 's/^  sqlite3_flutter_libs:/  # sqlite3_flutter_libs:/' pubspec.yaml
        
        echo "✅ 依赖配置已简化"
    fi
fi

# 步骤 4: 重新获取依赖
echo "📦 步骤 4: 重新获取依赖..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ 依赖获取失败"
    exit 1
fi

# 步骤 5: 尝试构建
echo "🔨 步骤 5: 尝试构建..."
echo "这可能需要几分钟时间..."

# 首先尝试不带网络下载的构建
flutter build ios --release --no-pub

BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ 构建成功！"
    echo ""
    echo "🎉 问题已解决！"
    echo "📍 构建产物位置: build/ios/iphoneos/Runner.app"
else
    echo "⚠️  构建仍有问题，尝试其他解决方案..."
    echo ""
    echo "🔧 尝试网络配置方案..."
    
    # 询问是否有代理
    read -p "您是否有可用的网络代理? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "请输入代理地址 (例如: http://127.0.0.1:7890):"
        read -r PROXY_URL
        
        if [ -n "$PROXY_URL" ]; then
            echo "🌐 配置代理: $PROXY_URL"
            export http_proxy="$PROXY_URL"
            export https_proxy="$PROXY_URL"
            
            echo "🔨 使用代理重新构建..."
            flutter build ios --release
            
            if [ $? -eq 0 ]; then
                echo "✅ 使用代理构建成功！"
            else
                echo "❌ 代理构建也失败了"
            fi
        fi
    else
        echo ""
        echo "💡 其他解决方案："
        echo "1. 使用手机热点网络重试"
        echo "2. 在有更好网络的环境下构建"
        echo "3. 联系网络管理员开放 GitHub 访问"
        echo "4. 查看详细指南: FIX_SQLITE_DOWNLOAD_ERROR.md"
    fi
fi

echo ""
echo "📋 修复总结："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ 问题已解决"
    echo "✅ 项目可以正常构建"
    echo "✅ 可以继续进行 App Store 上传"
else
    echo "⚠️  问题仍然存在"
    echo "💡 建议查看详细指南: FIX_SQLITE_DOWNLOAD_ERROR.md"
    echo "🔧 或尝试在更好的网络环境下重新运行此脚本"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "🔄 下一步："
if [ $BUILD_STATUS -eq 0 ]; then
    echo "1. 在 Xcode 中打开项目: open ios/Runner.xcworkspace"
    echo "2. 配置签名并 Archive"
    echo "3. 上传到 App Store Connect"
else
    echo "1. 检查网络连接"
    echo "2. 尝试使用代理或 VPN"
    echo "3. 查看详细修复指南"
fi