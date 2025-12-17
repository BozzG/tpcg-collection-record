#!/bin/bash

echo "🔧 修复 SQLite3 框架签名问题"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 清理构建缓存
echo "1️⃣ 清理构建缓存..."
flutter clean
rm -rf ios/build
rm -rf build

# 2. 重新获取依赖
echo "2️⃣ 重新获取依赖..."
flutter pub get

# 3. 重新安装 CocoaPods
echo "3️⃣ 重新安装 CocoaPods..."
cd ios
pod deintegrate
pod cache clean --all
pod install
cd ..

# 4. 检查 Podfile 配置
echo "4️⃣ 检查 Podfile 配置..."
if ! grep -q "config.build_settings\['CODE_SIGNING_ALLOWED'\]" ios/Podfile; then
    echo "添加代码签名配置到 Podfile..."
    
    # 备份原 Podfile
    cp ios/Podfile ios/Podfile.backup
    
    # 添加签名配置
    cat >> ios/Podfile << 'EOF'

# 修复框架签名问题
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
EOF

    echo "✅ 已添加签名配置到 Podfile"
else
    echo "✅ Podfile 签名配置已存在"
fi

# 5. 重新安装 pods
echo "5️⃣ 重新安装 pods..."
cd ios
pod install
cd ..

echo ""
echo "🎯 接下来在 Xcode 中："
echo "1. 确保选择了正确的 Team"
echo "2. Bundle ID 设置为: com.bozzguo.tpcg-collection-record"
echo "3. 选择你的 iPhone 设备"
echo "4. 点击运行按钮"

echo ""
echo "✅ SQLite3 签名问题修复完成！"