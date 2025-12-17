# 📱 iOS应用名称配置指南

## 🎯 应用名称的类型

iOS应用有几种不同的名称，用于不同的场景：

### 1. 显示名称 (CFBundleDisplayName)
- **用途**: 用户在主屏幕上看到的名字
- **位置**: `ios/Runner/Info.plist`
- **当前设置**: `宝可梦卡牌收藏`
- **限制**: 最多30个字符，支持中文

### 2. 内部名称 (CFBundleName)
- **用途**: 系统内部使用的名字
- **位置**: `ios/Runner/Info.plist`
- **当前设置**: `pokemon_card_collection`
- **限制**: 建议使用英文和下划线

### 3. 项目名称 (name)
- **用途**: Flutter项目标识符
- **位置**: `pubspec.yaml`
- **当前设置**: `pokemon_card_collection`
- **限制**: 必须使用小写字母和下划线

## 🔧 如何修改应用名称

### 方法1: 手动修改

1. **修改显示名称** (用户看到的名字)
   ```xml
   <!-- ios/Runner/Info.plist -->
   <key>CFBundleDisplayName</key>
   <string>你的应用名称</string>
   ```

2. **修改内部名称**
   ```xml
   <!-- ios/Runner/Info.plist -->
   <key>CFBundleName</key>
   <string>your_app_name</string>
   ```

3. **修改项目名称**
   ```yaml
   # pubspec.yaml
   name: your_app_name
   description: 你的应用描述
   ```

### 方法2: 使用配置脚本

我为你创建了一个配置脚本：

```bash
./configure_app_name.sh
```

## 📋 当前配置

```
显示名称: 宝可梦卡牌收藏
内部名称: pokemon_card_collection
项目名称: pokemon_card_collection
Bundle ID: com.bozzguo.tpcg-collection-record
```

## 🎨 名称建议

### 中文名称选项
- `宝可梦卡牌收藏` (当前)
- `口袋妖怪卡牌`
- `精灵宝可梦收藏`
- `卡牌收藏大师`
- `宝可梦图鉴`

### 英文名称选项
- `Pokemon Card Collection`
- `TCG Collection Master`
- `Pokemon Card Tracker`
- `Card Collection Pro`
- `Pokemon TCG Manager`

### 简短名称 (适合图标下方)
- `卡牌收藏`
- `宝可梦`
- `TCG收藏`
- `Card Master`

## ⚠️ 重要注意事项

### 1. 显示名称限制
- 最多30个字符
- 避免使用特殊符号
- 考虑在小屏幕上的显示效果

### 2. 修改后的操作
```bash
# 1. 清理构建缓存
flutter clean

# 2. 重新获取依赖
flutter pub get

# 3. 重新构建应用
flutter build ios --release
```

### 3. App Store发布
如果要发布到App Store，确保：
- 名称不侵犯商标
- 符合App Store审核指南
- 与应用功能相符

## 🔄 修改名称的完整流程

### 步骤1: 决定新名称
```
显示名称: [用户看到的名字]
内部名称: [系统使用的名字]
项目名称: [代码中的名字]
```

### 步骤2: 修改配置文件
1. 修改 `ios/Runner/Info.plist`
2. 修改 `pubspec.yaml`
3. 可选：修改 `android/app/src/main/AndroidManifest.xml`

### 步骤3: 清理和重建
```bash
flutter clean
flutter pub get
flutter build ios --release
```

### 步骤4: 测试验证
- 检查主屏幕图标下的名称
- 检查设置中的应用名称
- 检查App Store Connect中的名称

## 🛠️ 自动化配置脚本

使用以下脚本快速配置应用名称：

```bash
#!/bin/bash
# configure_app_name.sh

echo "📱 配置iOS应用名称"
echo "当前显示名称: 宝可梦卡牌收藏"
echo ""

read -p "输入新的显示名称 (用户看到的): " DISPLAY_NAME
read -p "输入新的内部名称 (英文): " BUNDLE_NAME
read -p "输入新的项目名称 (小写英文): " PROJECT_NAME

# 修改Info.plist
sed -i '' "s/<string>宝可梦卡牌收藏<\/string>/<string>$DISPLAY_NAME<\/string>/" ios/Runner/Info.plist
sed -i '' "s/<string>pokemon_card_collection<\/string>/<string>$BUNDLE_NAME<\/string>/" ios/Runner/Info.plist

# 修改pubspec.yaml
sed -i '' "s/name: pokemon_card_collection/name: $PROJECT_NAME/" pubspec.yaml

echo "✅ 应用名称配置完成！"
echo "🔄 请运行以下命令重新构建："
echo "   flutter clean && flutter pub get && flutter build ios --release"
```

## 📱 验证修改结果

修改完成后，你可以通过以下方式验证：

1. **构建应用**
   ```bash
   flutter build ios --release
   ```

2. **在模拟器中测试**
   ```bash
   flutter run
   ```

3. **检查应用信息**
   - 主屏幕图标下的名称
   - 设置 → 通用 → iPhone存储空间中的名称

## 💡 最佳实践

1. **保持一致性**: 确保所有平台的名称风格一致
2. **考虑本地化**: 为不同地区准备不同语言的名称
3. **简洁明了**: 名称要能清楚表达应用功能
4. **易于搜索**: 考虑App Store搜索优化

---

## 🎉 当前配置总结

```
✅ 显示名称: 宝可梦卡牌收藏
✅ 内部名称: pokemon_card_collection  
✅ 项目名称: pokemon_card_collection
✅ Bundle ID: com.bozzguo.tpcg-collection-record
```

修改完成后记得重新构建应用！