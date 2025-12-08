# TPCG 收藏记录 - 应用图标设置指南

## 当前图标配置

应用图标已经成功配置并生成。图标采用了TPCG主题设计：
- 蓝色背景 (#2196F3)
- 白色卡片形状
- 中央圆形内有字母 "T"
- 现代化的圆角设计

## 图标文件位置

### 源图标
- `assets/images/app_icon.png` - 1024x1024 像素的主图标文件

### 生成的图标文件

#### iOS 图标
位置: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
包含所有iOS所需的尺寸：
- Icon-App-1024x1024@1x.png (App Store)
- Icon-App-60x60@2x.png, Icon-App-60x60@3x.png (主屏幕)
- Icon-App-40x40@2x.png, Icon-App-40x40@3x.png (Spotlight)
- Icon-App-29x29@2x.png, Icon-App-29x29@3x.png (设置)
- 其他各种尺寸...

#### macOS 图标
位置: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
包含macOS所需的尺寸：
- app_icon_1024.png (1024x1024)
- app_icon_512.png (512x512)
- app_icon_256.png (256x256)
- app_icon_128.png (128x128)
- app_icon_64.png (64x64)
- app_icon_32.png (32x32)
- app_icon_16.png (16x16)

## 配置文件

### pubspec.yaml 配置
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  ios: true
  image_path: "assets/images/app_icon.png"
  macos:
    generate: true
    image_path: "assets/images/app_icon.png"
```

## 如何更新图标

1. **替换源图标文件**
   ```bash
   # 将新的图标文件放到 assets/images/app_icon.png
   # 建议尺寸: 1024x1024 像素
   # 格式: PNG
   ```

2. **重新生成图标**
   ```bash
   cd /path/to/your/app
   flutter pub get
   dart run flutter_launcher_icons
   ```

3. **清理并重新构建**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 图标设计建议

- **尺寸**: 使用 1024x1024 像素的源图标
- **格式**: PNG 格式，支持透明背景
- **设计**: 简洁明了，在小尺寸下也要清晰可见
- **颜色**: 使用对比鲜明的颜色
- **圆角**: iOS 会自动添加圆角，不需要在源图标中添加

## 注意事项

- 图标会自动生成多种尺寸，确保在各种设备上都能正常显示
- iOS 和 macOS 平台的图标已成功配置
- 如果需要支持 Android 或 Web 平台，需要相应的平台配置

## 验证图标

构建并运行应用程序后，可以在以下位置查看图标：
- iOS 模拟器的主屏幕
- macOS 应用程序文件夹
- 应用程序切换器中

图标应该显示为蓝色背景的卡片设计，中央有白色圆形和字母 "T"。