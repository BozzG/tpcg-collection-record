# 新机器 Xcode 项目设置指南

## 🚀 在新机器上通过 Xcode 打开和构建 TPCG Collection Record 项目

### 📋 前置要求

1. **安装必要软件**
   ```bash
   # 安装 Xcode (从 App Store)
   # 安装 Flutter SDK
   # 安装 CocoaPods
   sudo gem install cocoapods
   ```

2. **验证环境**
   ```bash
   flutter doctor
   xcode-select -p
   pod --version
   ```

### 🔧 项目设置步骤

#### 第一步：准备项目
```bash
# 进入项目目录
cd /Users/ziyanguo/Project/ptcg_cr/app

# 清理并获取依赖
flutter clean
flutter pub get

# 安装 iOS 依赖
cd ios
pod install --repo-update
cd ..
```

#### 第二步：在 Xcode 中打开项目
```bash
# 打开 Xcode 工作空间（重要：必须打开 .xcworkspace 文件）
open ios/Runner.xcworkspace
```

**⚠️ 重要提醒：**
- 必须打开 `Runner.xcworkspace` 文件，不是 `Runner.xcodeproj`
- 这样才能正确加载 CocoaPods 依赖

#### 第三步：配置项目签名

1. **选择项目**
   - 在 Xcode 左侧导航栏中点击 `Runner` 项目

2. **配置 Target**
   - 选择 `Runner` target
   - 点击 `Signing & Capabilities` 标签

3. **设置开发团队**
   - 勾选 `Automatically manage signing`
   - 在 `Team` 下拉菜单中选择你的 Apple 开发者账号
   - 如果没有账号，选择 `Add Account...` 添加你的 Apple ID

4. **修改 Bundle Identifier**
   - 将 Bundle Identifier 改为唯一值，例如：
     - `com.yourname.tpcg-collection-record`
     - `com.yourdomain.tpcgcollectionrecord`

#### 第四步：解决常见问题

1. **如果遇到签名错误**
   ```bash
   # 清理 Xcode 缓存
   rm -rf ~/Library/Developer/Xcode/DerivedData
   
   # 重新安装 pods
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

2. **如果遇到依赖问题**
   ```bash
   # 更新 CocoaPods 仓库
   pod repo update
   
   # 重新安装依赖
   cd ios
   pod install --repo-update
   cd ..
   ```

### 🏗️ 构建和运行

#### 模拟器构建
1. 在 Xcode 中选择一个 iOS 模拟器（如 iPhone 15 Pro）
2. 点击运行按钮 (▶️) 或按 `Cmd+R`
3. 等待构建完成

#### 真机构建
1. 连接 iOS 设备到 Mac
2. 在设备上信任此电脑
3. 在 Xcode 中选择你的设备
4. 点击运行按钮 (▶️) 或按 `Cmd+R`
5. 如果是第一次安装，需要在设备上信任开发者证书：
   - 设置 → 通用 → VPN与设备管理 → 开发者应用 → 信任

### 📱 使用构建脚本（推荐）

你也可以使用项目提供的构建脚本：

```bash
# 使用 iOS 构建脚本
./build_ios.sh
```

脚本会自动：
- 检查环境
- 获取依赖
- 提供构建选项
- 自动打开 Xcode（如果需要）

### 🔍 故障排除

#### 常见错误及解决方案

1. **"No such module" 错误**
   ```bash
   cd ios
   pod deintegrate
   pod install
   ```

2. **签名错误**
   - 确保选择了正确的开发团队
   - 检查 Bundle Identifier 是否唯一
   - 尝试手动管理签名

3. **构建失败**
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install --repo-update
   ```

4. **设备不识别**
   - 检查 USB 连接
   - 在设备上信任此电脑
   - 重启 Xcode 和设备

### 📂 重要文件位置

- **Xcode 工作空间**: `ios/Runner.xcworkspace`
- **项目配置**: `ios/Runner.xcodeproj/project.pbxproj`
- **应用信息**: `ios/Runner/Info.plist`
- **CocoaPods 配置**: `ios/Podfile`

### 🎯 快速开始命令

```bash
# 一键设置和打开项目
cd /Users/ziyanguo/Project/ptcg_cr/app
flutter clean && flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
```

### 📖 相关文档

- `IOS_RELEASE_DEPLOYMENT_GUIDE.md` - 发布部署指南
- `build_ios.sh` - 自动化构建脚本
- `XCODE_SIGNING_GUIDE.md` - 签名配置详细指南

---

**💡 提示**: 如果这是你第一次在新机器上开发 iOS 应用，建议先用模拟器测试，确保一切正常后再配置真机部署。