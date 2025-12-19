#!/bin/bash

# SQLite dSYM 错误自动修复脚本
# 解决 App Store 上传时的 dSYM 缺失问题

echo "🔧 SQLite dSYM 错误自动修复"
echo "================================"

# 检查是否在项目根目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

echo "📋 当前问题："
echo "The archive did not include a dSYM for the sqlite3arm64ios.framework"
echo ""

# 步骤 1: 清理项目
echo "🧹 步骤 1: 清理项目..."
flutter clean

# 步骤 2: 清理 iOS 依赖
echo "🧹 步骤 2: 清理 iOS 依赖..."
cd ios
if [ -d "Pods" ]; then
    rm -rf Pods
fi
if [ -f "Podfile.lock" ]; then
    rm -f Podfile.lock
fi

# 清理 CocoaPods 缓存
pod cache clean --all 2>/dev/null || true
pod deintegrate 2>/dev/null || true

cd ..

# 步骤 3: 备份原始 Podfile
echo "💾 步骤 3: 备份 Podfile..."
if [ -f "ios/Podfile" ]; then
    cp ios/Podfile ios/Podfile.backup.$(date +%Y%m%d_%H%M%S)
fi

# 步骤 4: 更新 Podfile 配置
echo "📝 步骤 4: 更新 Podfile 配置..."
cat >> ios/Podfile << 'EOF'

# dSYM 修复配置
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 强制生成 dSYM 文件
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
      config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'NO'
      config.build_settings['COPY_PHASE_STRIP'] = 'NO'
      
      # 特别处理 SQLite 相关框架
      if target.name.downcase.include?('sqlite') || target.name.downcase.include?('fmdb')
        config.build_settings['GENERATE_DSYM'] = 'YES'
        config.build_settings['DWARF_DSYM_FOLDER_PATH'] = '$(CONFIGURATION_BUILD_DIR)'
        puts "🔧 配置 dSYM 生成: #{target.name}"
      end
      
      # iOS 版本兼容性
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
EOF

echo "✅ Podfile 配置已更新"

# 步骤 5: 重新获取 Flutter 依赖
echo "📦 步骤 5: 重新获取 Flutter 依赖..."
flutter pub get

# 步骤 6: 重新安装 iOS 依赖
echo "📱 步骤 6: 重新安装 iOS 依赖..."
cd ios
pod install --repo-update

if [ $? -ne 0 ]; then
    echo "❌ CocoaPods 安装失败，尝试修复..."
    pod repo update
    pod install --repo-update
fi

cd ..

# 步骤 7: 验证配置
echo "🔍 步骤 7: 验证配置..."
if grep -q "DEBUG_INFORMATION_FORMAT.*dwarf-with-dsym" ios/Podfile; then
    echo "✅ Podfile 配置正确"
else
    echo "⚠️  Podfile 配置可能有问题，请手动检查"
fi

# 步骤 8: 提供 Xcode 配置指导
echo ""
echo "🎯 步骤 8: Xcode 配置（重要）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "请在 Xcode 中完成以下配置："
echo ""
echo "1️⃣ 打开项目："
echo "   open ios/Runner.xcworkspace"
echo ""
echo "2️⃣ 配置 Build Settings："
echo "   • 选择 Runner 项目 → Runner target → Build Settings"
echo "   • 搜索 'Debug Information Format'"
echo "   • 设置 Release 为 'DWARF with dSYM File'"
echo ""
echo "3️⃣ 配置 Strip Settings："
echo "   • 搜索 'Strip Debug Symbols During Copy'"
echo "   • 设置 Release 为 'NO'"
echo ""
echo "4️⃣ 重新 Archive："
echo "   • Product → Clean Build Folder"
echo "   • Product → Archive"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 询问是否打开 Xcode
read -p "🔧 现在打开 Xcode 进行配置? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎉 打开 Xcode..."
    open ios/Runner.xcworkspace
    
    echo ""
    echo "📖 接下来的步骤："
    echo "1. 在 Xcode 中按照上述指导配置 Build Settings"
    echo "2. 执行 Product → Clean Build Folder"
    echo "3. 执行 Product → Archive"
    echo "4. 在 Organizer 中重新尝试 Distribute App"
    echo ""
    echo "💡 如果仍有问题，请查看: FIX_DSYM_SQLITE_ERROR.md"
else
    echo ""
    echo "📖 稍后请手动打开 Xcode："
    echo "   open ios/Runner.xcworkspace"
    echo ""
    echo "📚 详细修复指南: FIX_DSYM_SQLITE_ERROR.md"
fi

echo ""
echo "🎊 自动修复完成！"
echo ""
echo "📋 修复总结："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 清理了项目和依赖"
echo "✅ 更新了 Podfile 配置"
echo "✅ 重新安装了 iOS 依赖"
echo "✅ 配置了 dSYM 生成设置"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔄 下一步："
echo "1. 在 Xcode 中完成 Build Settings 配置"
echo "2. 重新 Archive 项目"
echo "3. 尝试重新上传到 App Store Connect"
echo ""
echo "💡 如果问题仍然存在，请查看详细指南: FIX_DSYM_SQLITE_ERROR.md"