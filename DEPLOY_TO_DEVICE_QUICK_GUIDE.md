# 📱 iOS 真机部署快速指南

## 🎯 将 Release 版本同步到 iOS 真实设备

### 🚀 方法一：一键自动部署（推荐）

```bash
# 使用现有的部署脚本
./deploy_ios_release.sh
```

这个脚本会自动：
- ✅ 检查环境和设备连接
- ✅ 清理项目并获取依赖
- ✅ 构建 Release 版本
- ✅ 提供多种部署选项

### 🔧 方法二：手动步骤部署

#### 第一步：准备环境
```bash
cd /Users/ziyanguo/Project/ptcg_cr/app

# 检查设备连接
flutter devices

# 清理并准备项目
flutter clean
flutter pub get
```

#### 第二步：构建 Release 版本
```bash
# 构建 iOS Release 版本
flutter build ios --release
```

#### 第三步：选择部署方式

**选项 A：通过 Flutter 直接部署**
```bash
# 直接运行到连接的设备
flutter run --release

# 或指定设备 ID
flutter run -d [设备ID] --release
```

**选项 B：通过 Xcode 部署**
```bash
# 打开 Xcode 项目
open ios/Runner.xcworkspace
```

然后在 Xcode 中：
1. 选择你的真实设备（不是模拟器）
2. 点击运行按钮 ▶️ 或按 `Cmd+R`

### 📋 必要的签名配置

如果是第一次部署，需要在 Xcode 中配置签名：

1. **打开项目设置**
   - 选择左侧的 `Runner` 项目
   - 选择 `Runner` target
   - 点击 `Signing & Capabilities` 标签

2. **配置签名信息**
   ```
   ✅ Automatically manage signing (勾选)
   Team: 选择你的 Apple 开发者账号
   Bundle Identifier: 修改为唯一值
   ```

3. **推荐的 Bundle Identifier 格式**
   ```
   com.yourname.tpcgcollectionrecord
   com.yourdomain.pokemon-card-tracker
   com.company.tpcg-collection-record
   ```

### 📱 设备准备

1. **连接设备**
   - 用 USB 线连接 iPhone/iPad 到 Mac
   - 在设备上点击"信任此电脑"
   - 确保设备已解锁

2. **启用开发者模式**（iOS 16+ 需要）
   - 设置 → 隐私与安全性 → 开发者模式
   - 开启并重启设备

3. **信任开发者证书**（首次安装后）
   - 设置 → 通用 → VPN与设备管理
   - 找到你的开发者账号并信任

### ⚡ 快速命令组合

```bash
# 一条命令完成所有步骤
cd /Users/ziyanguo/Project/ptcg_cr/app && \
flutter clean && \
flutter pub get && \
flutter build ios --release && \
flutter run --release
```

### 🔍 常见问题快速解决

**问题：设备未识别**
```bash
# 检查连接
flutter devices
# 重启设备和 Xcode
```

**问题：签名错误**
- 在 Xcode 中重新选择 Team
- 修改 Bundle Identifier 为唯一值
- 删除旧证书让 Xcode 重新生成

**问题：构建失败**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

**问题：应用无法启动**
- 检查设备上是否信任了开发者证书
- 查看 Xcode 控制台的错误信息

### 📊 部署成功验证

部署完成后，检查：
- ✅ 应用图标出现在设备主屏幕
- ✅ 点击图标能正常启动应用
- ✅ 数据库功能正常（添加/编辑卡片）
- ✅ 图片选择和相机功能正常
- ✅ 所有导航和功能正常工作

### 💡 小贴士

1. **首次部署**：建议使用 Xcode 方式，可以更好地处理签名问题
2. **后续部署**：可以直接使用 `flutter run --release` 快速部署
3. **多设备测试**：在不同 iOS 版本的设备上测试兼容性
4. **性能监控**：Release 版本性能比 Debug 版本更好

---

## 🎉 现在就开始部署吧！

选择最适合你的方法：
- 🚀 **新手推荐**：使用 `./deploy_ios_release.sh` 脚本
- 🔧 **有经验**：直接使用 `flutter run --release`
- 🎯 **需要控制**：通过 Xcode 手动部署