# iOS真实设备部署指南

## 📱 通过Xcode签名并安装到真实设备

### 前置要求

1. **Apple开发者账号**
   - 免费开发者账号（个人设备测试，7天有效期）
   - 付费开发者账号（$99/年，可发布到App Store）

2. **开发环境**
   - macOS系统
   - Xcode（最新版本）
   - Flutter SDK
   - iOS设备（iPhone/iPad）

3. **设备准备**
   - iOS设备通过USB连接到Mac
   - 设备已启用"开发者模式"

### 步骤1：构建iOS应用

```bash
# 方法1：使用构建脚本
./build_ios.sh
# 选择选项2：iOS设备构建

# 方法2：手动构建
flutter clean
flutter pub get
flutter build ios --release
```

### 步骤2：在Xcode中配置签名

1. **打开Xcode项目**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **选择项目配置**
   - 在左侧导航栏选择 `Runner` 项目
   - 选择 `Runner` target
   - 点击 `Signing & Capabilities` 标签

3. **配置Team和Bundle Identifier**
   - **Team**: 选择你的Apple开发者账号
   - **Bundle Identifier**: 修改为唯一标识符
     ```
     com.yourname.tpcg-collection-record
     # 或
     com.yourdomain.tpcgcollectionrecord
     ```

4. **自动签名设置**
   - ✅ 勾选 "Automatically manage signing"
   - Xcode会自动创建和管理证书

### 步骤3：设备配置

1. **连接设备**
   - 使用USB线连接iPhone/iPad到Mac
   - 在设备上点击"信任此电脑"

2. **在Xcode中选择设备**
   - 在Xcode顶部工具栏的设备选择器中
   - 选择你的真实设备（而不是模拟器）

3. **启用开发者模式**（iOS 16+）
   - 设置 → 隐私与安全性 → 开发者模式
   - 开启开发者模式并重启设备

### 步骤4：构建并安装

1. **在Xcode中构建**
   - 快捷键：`Cmd + R`
   - 或点击播放按钮 ▶️

2. **首次安装信任**
   - 安装完成后，在设备上：
   - 设置 → 通用 → VPN与设备管理
   - 找到你的开发者账号
   - 点击"信任"

### 步骤5：验证安装

应用安装成功后，你应该能在设备主屏幕上看到：
- 应用图标：蓝色背景的卡片设计
- 应用名称：TPCG Collection Record

## 🛠️ 自动化脚本

我已经为你创建了一个增强版的构建脚本，包含设备部署功能：

```bash
#!/bin/bash
# 使用方法
./build_ios.sh
# 选择选项2进行设备构建
```

## ⚠️ 常见问题解决

### 1. 签名错误
```
错误：Code signing error
解决：检查Bundle Identifier是否唯一，Team是否正确选择
```

### 2. 设备不识别
```
错误：Device not found
解决：
1. 检查USB连接
2. 在设备上信任电脑
3. 重启Xcode和设备
```

### 3. 证书过期
```
错误：Certificate expired
解决：
1. 删除过期证书
2. 重新生成证书（Xcode自动管理）
```

### 4. Bundle ID冲突
```
错误：Bundle identifier already exists
解决：修改Bundle Identifier为唯一值
```

## 📋 Bundle Identifier建议

推荐使用以下格式：
```
com.[你的名字].tpcg-collection-record
com.[公司名].tpcgcollectionrecord
com.yourname.pokemon-card-tracker
```

## 🔄 重新部署流程

如果需要更新应用：

1. **修改代码后重新构建**
   ```bash
   flutter clean
   flutter pub get
   flutter build ios --release
   ```

2. **在Xcode中重新运行**
   - `Cmd + R` 或点击播放按钮

3. **应用会自动更新到设备**

## 📱 测试功能

部署到真实设备后，请测试以下功能：
- ✅ 应用启动和导航
- ✅ 数据库操作（添加/编辑卡片）
- ✅ 图片选择和显示
- ✅ 相机权限（拍照功能）
- ✅ 照片库权限（选择图片）

## 🚀 发布准备

如果准备发布到App Store：

1. **获取付费开发者账号**
2. **配置App Store Connect**
3. **创建App Store版本**
4. **提交审核**

## 💡 提示

- 免费开发者账号的应用有7天有效期
- 付费开发者账号可以发布到App Store
- 建议在真实设备上充分测试后再发布
- 保持Bundle Identifier的一致性

---

## 快速开始

```bash
# 1. 构建应用
./build_ios.sh

# 2. 选择选项2（iOS设备）

# 3. 在Xcode中配置签名并运行

# 4. 在设备上信任开发者证书

# 5. 开始使用应用！
```