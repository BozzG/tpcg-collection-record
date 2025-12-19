# 🔧 修复 SQLite dSYM 错误指南

## 错误描述
```
The archive did not include a dSYM for the sqlite3arm64ios.framework with the UUIDs [34B79724-9196-3AB9-B1FB-75926D22713A]. 
Ensure that the archive's dSYM folder includes a DWARF file for sqlite3arm64ios.framework with the expected UUIDs.
```

## 🎯 问题原因
这个错误是由于 SQLite 框架缺少调试符号文件（dSYM）导致的，通常发生在：
- 使用 `sqflite` 或 `sqflite_common_ffi` 依赖
- 上传到 App Store Connect 时
- Archive 过程中 dSYM 生成不完整

## 🚀 解决方案

### 方案一：修改构建设置（推荐）

1. **在 Xcode 中配置 dSYM 生成**
   ```bash
   # 打开项目
   open ios/Runner.xcworkspace
   ```

2. **配置 Build Settings**
   - 选择 `Runner` 项目
   - 选择 `Runner` target
   - 点击 `Build Settings` 标签
   - 搜索 "Debug Information Format"
   - 将 **Release** 模式设置为 `DWARF with dSYM File`

3. **配置 Strip Debug Symbols**
   - 在 Build Settings 中搜索 "Strip Debug Symbols During Copy"
   - 确保 **Release** 模式设置为 `NO`

### 方案二：使用脚本自动修复

创建修复脚本：

```bash
#!/bin/bash
# 文件名: fix_dsym_sqlite.sh

echo "🔧 修复 SQLite dSYM 问题..."

# 进入 iOS 目录
cd ios

# 清理 Pods
echo "🧹 清理 CocoaPods..."
rm -rf Pods Podfile.lock
pod deintegrate 2>/dev/null || true

# 更新 Podfile 配置
echo "📝 更新 Podfile 配置..."
cat >> Podfile << 'EOF'

# 添加 dSYM 配置
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 确保生成 dSYM 文件
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
      config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'NO'
      config.build_settings['COPY_PHASE_STRIP'] = 'NO'
      
      # 特别处理 SQLite 相关框架
      if target.name.include?('sqlite') || target.name.include?('FMDB')
        config.build_settings['GENERATE_DSYM'] = 'YES'
      end
    end
  end
end
EOF

# 重新安装依赖
echo "📦 重新安装依赖..."
pod install --repo-update

echo "✅ 修复完成！"
```

### 方案三：手动修改 Podfile

编辑 `ios/Podfile` 文件，添加以下配置：

```ruby
# 在 Podfile 末尾添加
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 强制生成 dSYM 文件
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
      config.build_settings['STRIP_INSTALLED_PRODUCT'] = 'NO'
      config.build_settings['COPY_PHASE_STRIP'] = 'NO'
      
      # 特别处理 SQLite
      if target.name.downcase.include?('sqlite')
        config.build_settings['GENERATE_DSYM'] = 'YES'
        config.build_settings['DWARF_DSYM_FOLDER_PATH'] = '$(CONFIGURATION_BUILD_DIR)'
      end
    end
  end
end
```

### 方案四：更新依赖版本

更新 `pubspec.yaml` 中的 SQLite 依赖：

```yaml
dependencies:
  # 更新到最新版本
  sqflite: ^2.3.3+1
  sqflite_common_ffi: ^2.3.3+1
```

然后重新构建：
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

## 🔨 完整修复流程

### 步骤 1：应用修复
```bash
# 1. 进入项目目录
cd /Users/ziyanguo/Project/ptcg_cr/app

# 2. 清理项目
flutter clean
cd ios
rm -rf Pods Podfile.lock
cd ..

# 3. 更新依赖
flutter pub get
```

### 步骤 2：修改 Podfile
```bash
# 编辑 ios/Podfile，添加 post_install 配置
# （使用上面提供的配置）
```

### 步骤 3：重新安装
```bash
cd ios
pod install --repo-update
cd ..
```

### 步骤 4：在 Xcode 中配置
```bash
# 打开项目
open ios/Runner.xcworkspace
```

在 Xcode 中：
1. 选择 `Runner` 项目 → `Build Settings`
2. 搜索 "Debug Information Format"
3. 设置 Release 为 `DWARF with dSYM File`
4. 搜索 "Strip Debug Symbols"
5. 设置 Release 为 `NO`

### 步骤 5：重新构建和上传
```bash
# 构建 Release 版本
flutter build ios --release

# 在 Xcode 中 Archive
# Product → Archive
# 然后在 Organizer 中 Distribute App
```

## 🎯 替代方案：使用 IPA 构建

如果上述方法仍有问题，可以尝试直接构建 IPA：

```bash
# 方法 1: 使用 Flutter 构建 IPA
flutter build ipa --release

# 方法 2: 手动构建并跳过 dSYM 检查
flutter build ios --release --no-codesign
# 然后在 Xcode 中手动 Archive
```

## 🔍 验证修复

构建完成后，检查 dSYM 文件是否生成：

```bash
# 检查 Archive 中的 dSYM 文件
find ~/Library/Developer/Xcode/Archives -name "*.dSYM" -type d | grep -i sqlite

# 或者检查构建目录
find build/ios -name "*.dSYM" -type d
```

## 💡 预防措施

为避免将来出现此问题：

1. **保持依赖更新**
   ```bash
   flutter pub outdated
   flutter pub upgrade
   ```

2. **定期清理构建缓存**
   ```bash
   flutter clean
   cd ios && pod cache clean --all && cd ..
   ```

3. **使用稳定版本的依赖**
   - 避免使用 beta 或 dev 版本
   - 选择经过验证的版本组合

## 🚨 如果问题仍然存在

如果上述方法都无效，可以考虑：

1. **临时禁用 dSYM 上传**
   - 在 Organizer 中选择 "Include app symbols for your app" 时取消勾选
   - 这会跳过 dSYM 检查，但会影响崩溃日志的符号化

2. **联系苹果技术支持**
   - 如果是苹果服务器端问题
   - 提供详细的错误信息和 UUID

3. **使用 Application Loader**
   - 作为 Xcode Organizer 的替代方案
   - 下载独立的 Application Loader 工具

---

## 📋 快速修复检查清单

- [ ] 清理项目和 Pods
- [ ] 更新 Podfile 配置
- [ ] 重新安装依赖
- [ ] 配置 Xcode Build Settings
- [ ] 重新 Archive
- [ ] 验证 dSYM 文件生成
- [ ] 重新上传到 App Store Connect

按照这个顺序执行，应该能解决 SQLite dSYM 错误问题。