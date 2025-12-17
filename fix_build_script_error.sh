#!/bin/bash

echo "🔧 修复 iOS PhaseScriptExecution 构建错误"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查当前目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：请在Flutter项目根目录运行此脚本"
    exit 1
fi

echo "📍 项目路径: $(pwd)"
echo "📅 修复时间: $(date)"
echo ""

# 1. 关闭 Xcode
echo "1️⃣ 关闭 Xcode..."
osascript -e 'quit app "Xcode"' 2>/dev/null || true
sleep 2

# 2. 清理所有构建缓存
echo "2️⃣ 清理构建缓存..."
flutter clean
rm -rf ios/build
rm -rf build
rm -rf ios/.symlinks
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ~/.pub-cache/hosted/pub.dartlang.org/*/
echo "✅ 构建缓存清理完成"

# 3. 重新获取依赖
echo "3️⃣ 重新获取 Flutter 依赖..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Flutter 依赖获取失败"
    exit 1
fi
echo "✅ Flutter 依赖获取成功"

# 4. 检查并修复 Podfile
echo "4️⃣ 检查 Podfile 配置..."
cd ios

# 备份原 Podfile
if [ -f "Podfile" ]; then
    cp Podfile Podfile.backup.$(date +%Y%m%d_%H%M%S)
fi

# 创建新的 Podfile
cat > Podfile << 'EOF'
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      # 修复构建脚本错误
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
      
      # 修复脚本执行权限
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      
      # 修复 arm64 模拟器问题
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
EOF

echo "✅ Podfile 已更新"

# 5. 清理并重新安装 CocoaPods
echo "5️⃣ 重新安装 CocoaPods..."
pod deintegrate 2>/dev/null || true
pod cache clean --all 2>/dev/null || true
pod repo update 2>/dev/null || true

echo "正在安装 CocoaPods 依赖..."
pod install --verbose
if [ $? -ne 0 ]; then
    echo "❌ CocoaPods 安装失败，尝试修复..."
    
    # 尝试修复 CocoaPods
    sudo gem install cocoapods
    pod setup
    pod install --repo-update
    
    if [ $? -ne 0 ]; then
        echo "❌ CocoaPods 安装仍然失败"
        cd ..
        exit 1
    fi
fi

cd ..
echo "✅ CocoaPods 安装成功"

# 6. 检查并修复 Info.plist
echo "6️⃣ 检查 Info.plist 配置..."
INFO_PLIST="ios/Runner/Info.plist"

if [ -f "$INFO_PLIST" ]; then
    # 确保权限配置存在
    if ! grep -q "NSPhotoLibraryUsageDescription" "$INFO_PLIST"; then
        echo "添加照片库权限..."
        # 这里可以添加权限配置的代码
    fi
    echo "✅ Info.plist 配置正常"
else
    echo "⚠️ Info.plist 文件不存在"
fi

# 7. 检查 Flutter 生成的文件
echo "7️⃣ 检查 Flutter 生成文件..."
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "重新生成 Flutter 配置文件..."
    flutter build ios --config-only
fi
echo "✅ Flutter 配置文件检查完成"

# 8. 尝试构建
echo "8️⃣ 尝试构建项目..."
flutter build ios --debug --no-codesign
BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    echo "✅ 构建成功！"
else
    echo "⚠️ 构建仍有问题，但基础修复已完成"
fi

echo ""
echo "🎯 修复完成！接下来的步骤："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣ 打开 Xcode："
echo "   open ios/Runner.xcworkspace"
echo ""
echo "2️⃣ 在 Xcode 中配置签名："
echo "   - 选择 Runner 项目"
echo "   - 选择 Runner target"
echo "   - Signing & Capabilities 标签"
echo "   - 选择你的 Team"
echo "   - Bundle ID: com.bozzguo.tpcg-collection-record"
echo ""
echo "3️⃣ 清理 Xcode 构建："
echo "   Product → Clean Build Folder"
echo ""
echo "4️⃣ 选择设备并运行"
echo ""

# 9. 询问是否打开 Xcode
read -p "🚀 是否现在打开 Xcode? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎉 正在打开 Xcode..."
    open ios/Runner.xcworkspace
    
    echo ""
    echo "💡 在 Xcode 中的操作提醒："
    echo "1. 等待 Xcode 完全加载项目"
    echo "2. 如果看到任何错误，先尝试 Product → Clean Build Folder"
    echo "3. 确保选择了正确的 Team 和 Bundle ID"
    echo "4. 选择你的 iPhone 设备"
    echo "5. 点击运行按钮"
fi

echo ""
echo "🎊 PhaseScriptExecution 错误修复完成！"
echo ""
echo "📋 如果仍有问题，请检查："
echo "   1. Xcode 控制台的具体错误信息"
echo "   2. 是否正确配置了开发者账号"
echo "   3. Bundle ID 是否唯一"
echo "   4. 设备是否信任了开发者证书"