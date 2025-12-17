# iOS Release版本部署到真实设备完整指南

## 🎯 概述

本指南将帮助你将TPCG Collection Record应用的Release版本部署到真实iOS设备上。

## 📋 前置要求

### 1. 开发环境
- ✅ macOS系统
- ✅ Xcode 15.0+ (推荐最新版本)
- ✅ Flutter SDK (已安装)
- ✅ Apple开发者账号 (免费或付费)

### 2. 设备要求
- ✅ iOS 12.0+ 的iPhone或iPad
- ✅ USB数据线连接到Mac
- ✅ 设备已启用开发者模式 (iOS 16+)

### 3. 证书配置
- ✅ Apple开发者账号登录
- ✅ 开发证书 (Xcode自动管理)
- ✅ 唯一的Bundle Identifier

## 🚀 快速部署流程

### 步骤1: 准备构建环境

```bash
# 1. 清理项目
flutter clean

# 2. 获取依赖
flutter pub get

# 3. 检查Flutter环境
flutter doctor

# 4. 检查连接的设备
flutter devices
```

### 步骤2: 构建Release版本

```bash
# 方法1: 使用构建脚本 (推荐)
./build_ios.sh
# 选择选项2: iOS设备构建

# 方法2: 手动构建
flutter build ios --release
```

### 步骤3: 配置Xcode签名

1. **打开Xcode项目**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **配置项目设置**
   - 选择左侧的 `Runner` 项目
   - 选择 `Runner` target
   - 点击 `Signing & Capabilities` 标签

3. **设置签名信息**
   ```
   Team: 选择你的Apple开发者账号
   Bundle Identifier: com.yourname.tpcgcollectionrecord
   ✅ Automatically manage signing (勾选)
   ```

### 步骤4: 设备配置

1. **连接设备**
   - 使用USB线连接iPhone到Mac
   - 在设备上点击"信任此电脑"

2. **启用开发者模式** (iOS 16+)
   - 设置 → 隐私与安全性 → 开发者模式
   - 开启并重启设备

3. **在Xcode中选择设备**
   - 在Xcode顶部选择你的真实设备
   - 确保不是模拟器

### 步骤5: 部署到设备

**方法1: 通过Xcode部署**
```bash
# 在Xcode中按 Cmd+R 或点击运行按钮
```

**方法2: 通过Flutter命令部署**
```bash
# 查看可用设备
flutter devices

# 部署到指定设备
flutter run -d [设备ID] --release

# 或者直接运行 (如果只有一个设备)
flutter run --release
```

### 步骤6: 信任开发者证书

1. **首次安装后**
   - 设置 → 通用 → VPN与设备管理
   - 找到你的开发者账号
   - 点击"信任 [你的开发者账号]"

2. **验证安装**
   - 应用图标应该出现在主屏幕
   - 点击图标启动应用

## 🛠️ 自动化部署脚本

我为你创建了一个一键部署脚本：

```bash
#!/bin/bash
# 文件名: deploy_ios_release.sh

echo "🚀 开始iOS Release版本部署..."

# 检查设备连接
echo "📱 检查连接的设备..."
DEVICES=$(flutter devices | grep "ios")
if [ -z "$DEVICES" ]; then
    echo "❌ 未检测到iOS设备，请确保设备已连接并信任此电脑"
    exit 1
fi

echo "✅ 检测到iOS设备"
flutter devices

# 清理和构建
echo "🧹 清理项目..."
flutter clean
flutter pub get

echo "🔨 构建Release版本..."
flutter build ios --release

if [ $? -eq 0 ]; then
    echo "✅ 构建成功！"
    
    # 询问部署方式
    echo ""
    echo "请选择部署方式："
    echo "1. 通过Flutter直接部署 (推荐)"
    echo "2. 通过Xcode部署 (需要手动配置签名)"
    read -p "请选择 (1-2): " choice
    
    case $choice in
        1)
            echo "🚀 通过Flutter部署到设备..."
            flutter run --release
            ;;
        2)
            echo "🔧 打开Xcode进行手动部署..."
            open ios/Runner.xcworkspace
            echo "请在Xcode中配置签名并运行应用"
            ;;
        *)
            echo "❌ 无效选择"
            exit 1
            ;;
    esac
else
    echo "❌ 构建失败！"
    exit 1
fi

echo "🎉 部署完成！"
```

## ⚠️ 常见问题解决

### 1. 签名错误
```
错误: Code signing error
解决方案:
1. 检查Bundle Identifier是否唯一
2. 确保Team选择正确
3. 删除旧证书，让Xcode重新生成
```

### 2. 设备不识别
```
错误: No devices found
解决方案:
1. 检查USB连接
2. 在设备上信任电脑
3. 重启Xcode和设备
4. 检查设备是否解锁
```

### 3. 构建失败
```
错误: Build failed
解决方案:
1. flutter clean && flutter pub get
2. 检查Flutter doctor输出
3. 更新Xcode到最新版本
4. 检查iOS版本兼容性
```

### 4. 应用无法启动
```
错误: App crashes on launch
解决方案:
1. 检查设备日志 (Xcode → Window → Devices and Simulators)
2. 确保所有权限已正确配置
3. 检查数据库初始化是否成功
```

### 5. 证书过期
```
错误: Certificate expired
解决方案:
1. 在Xcode中删除过期证书
2. 重新生成证书 (自动管理签名)
3. 重新构建和部署
```

## 📱 Bundle Identifier配置

### 推荐格式
```
com.yourname.tpcgcollectionrecord
com.yourdomain.pokemon-card-tracker
com.company.tpcg-collection-record
```

### 修改方法
1. 在Xcode中修改Bundle Identifier
2. 或在 `ios/Runner/Info.plist` 中修改
3. 确保全局唯一性

## 🔧 高级配置

### 1. 自定义应用图标
- 图标文件位置: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- 已配置多种尺寸的图标

### 2. 权限配置
- 相机权限: ✅ 已配置
- 照片库权限: ✅ 已配置
- 位置: `ios/Runner/Info.plist`

### 3. 版本管理
```yaml
# pubspec.yaml
version: 1.0.0+1
# 1.0.0 = 版本号
# +1 = 构建号
```

## 📊 测试清单

部署后请测试以下功能：

- [ ] 应用启动和导航
- [ ] 数据库操作 (添加/编辑/删除卡片)
- [ ] 图片选择功能
- [ ] 相机拍照功能
- [ ] 项目管理功能
- [ ] 搜索和排序功能
- [ ] 数据持久化
- [ ] 应用图标和启动画面

## 🎯 发布准备

如果准备发布到App Store：

1. **获取付费开发者账号** ($99/年)
2. **配置App Store Connect**
3. **创建应用记录**
4. **上传构建版本**
5. **提交审核**

## 💡 最佳实践

1. **版本管理**
   - 每次发布前增加版本号
   - 保持构建号递增

2. **测试流程**
   - 在多个设备上测试
   - 测试不同iOS版本
   - 验证所有功能正常

3. **证书管理**
   - 使用Xcode自动管理签名
   - 定期检查证书有效期
   - 备份重要证书

4. **性能优化**
   - 使用Release模式部署
   - 监控应用性能
   - 优化启动时间

## 🚀 一键部署命令

```bash
# 创建部署脚本
chmod +x deploy_ios_release.sh

# 执行部署
./deploy_ios_release.sh
```

---

## 📞 需要帮助？

如果遇到问题：
1. 检查本指南的常见问题部分
2. 查看Xcode控制台输出
3. 检查设备日志
4. 确保所有前置要求都满足

**祝你部署成功！** 🎉