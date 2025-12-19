我来详细介绍 App Store 发布的完整流程，这是一个相对复杂但重要的过程。

## App Store 发布完整流程

### 第一步：准备工作

#### 1. Apple Developer 账号
```bash
# 确保你有有效的 Apple Developer Program 账号
# 年费：$99 USD
# 网址：https://developer.apple.com/programs/
```

#### 2. 检查应用配置
### 第二步：配置应用信息

#### 1. 更新版本信息
```yaml
# pubspec.yaml
version: 1.0.0+1  # 版本号+构建号
```

#### 2. 配置应用图标
你已经配置了 `flutter_launcher_icons`，确保图标文件存在：
### 第三步：Xcode 配置

#### 1. 打开 Xcode 项目
```bash
# 在项目根目录执行
open ios/Runner.xcworkspace
```

#### 2. 配置 Bundle Identifier
- 在 Xcode 中选择 `Runner` 项目
- 在 `Signing & Capabilities` 标签页
- 设置唯一的 Bundle Identifier（如：`com.yourcompany.tpcgcollectionrecord`）

#### 3. 配置团队和证书
- 选择你的 Apple Developer 团队
- 确保 "Automatically manage signing" 已启用
- 或手动选择 Distribution 证书

### 第四步：App Store Connect 配置

#### 1. 创建应用记录
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 点击 "我的 App" → "+" → "新建 App"
3. 填写应用信息：
   - **名称**：PTCG Collection Record
   - **Bundle ID**：选择在 Xcode 中配置的 Bundle Identifier
   - **SKU**：唯一标识符（如：ptcg-collection-record-2025）
   - **用户访问权限**：完全访问权限

#### 2. 配置应用元数据
- **应用信息**：
  - 类别：工具类/娱乐
  - 内容分级：适合所有年龄
- **定价与销售范围**：
  - 价格：免费或付费
  - 销售地区：选择要发布的国家/地区

#### 3. 准备应用截图
需要为不同设备尺寸准备截图：
- **iPhone 6.7"**：1290 x 2796 像素
- **iPhone 6.5"**：1242 x 2688 像素  
- **iPhone 5.5"**：1242 x 2208 像素
- **iPad Pro (6th Gen)**：2048 x 2732 像素

### 第五步：构建和上传

#### 1. 构建 Release 版本
```bash
# 清理之前的构建
flutter clean

# 获取依赖
flutter pub get

# 构建 iOS Release 版本
flutter build ios --release --no-codesign

# 或者直接构建并上传
flutter build ipa --release
```

#### 2. 使用 Xcode Archive
```bash
# 在 Xcode 中
# 1. 选择 "Any iOS Device" 作为目标
# 2. Product → Archive
# 3. 等待构建完成
# 4. 在 Organizer 中选择 "Distribute App"
# 5. 选择 "App Store Connect"
# 6. 上传到 App Store Connect
```

#### 3. 或使用命令行上传
```bash
# 使用 xcrun altool 上传
xcrun altool --upload-app --type ios --file "path/to/your.ipa" \
  --username "your-apple-id@email.com" \
  --password "app-specific-password"
```

### 第六步：提交审核

#### 1. 在 App Store Connect 中配置版本
1. 选择刚上传的构建版本
2. 填写 **版本发布说明**
3. 配置 **App 审核信息**：
   - 联系信息
   - 演示账户（如果需要）
   - 备注（给审核团队的说明）

#### 2. 内容审核
确保应用符合 [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)：
- 功能完整性
- 用户界面设计
- 隐私政策（如果收集用户数据）
- 内容适宜性

#### 3. 提交审核
- 点击 "提交以供审核"
- 等待苹果审核（通常 1-7 天）

### 第七步：发布管理

#### 1. 审核状态跟踪
- **等待审核**：已提交，排队中
- **正在审核**：苹果正在审核
- **被拒绝**：需要修复问题并重新提交
- **准备销售**：审核通过，可以发布
- **在 App Store 上**：已发布

#### 2. 发布选项
- **自动发布**：审核通过后立即发布
- **手动发布**：审核通过后手动选择发布时间

### 常见问题和解决方案

#### 1. 证书问题
```bash
# 如果遇到证书问题，重新生成
# 在 Xcode 中：Preferences → Accounts → Manage Certificates
# 或在开发者中心手动创建证书
```

#### 2. 构建失败
```bash
# 清理并重新构建
flutter clean
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

#### 3. 上传失败
- 检查网络连接
- 确认 Apple ID 和密码正确
- 使用应用专用密码而不是 Apple ID 密码

### 自动化脚本

创建一个发布脚本来简化流程：
### 检查清单

在提交前确保完成以下检查：
## 总结

App Store 发布是一个多步骤的过程，主要包括：

1. **准备阶段**：开发者账号、应用配置、图标截图
2. **构建阶段**：Release 构建、代码签名、Archive
3. **上传阶段**：通过 Xcode 或命令行上传到 App Store Connect
4. **配置阶段**：应用元数据、审核信息、发布设置
5. **审核阶段**：提交审核、等待结果、处理反馈
6. **发布阶段**：审核通过后发布到 App Store

关键是要确保应用质量、遵循苹果的审核指南，并准备好所有必需的资料。建议先在 TestFlight 进行内测，确保应用稳定后再提交正式审核。

现在你可以使用提供的脚本 `./scripts/build_and_upload_ios.sh` 来开始构建流程，并参考检查清单确保所有步骤都已完成。


关于 App Store Connect 中审核信息的语言要求，让我详细说明：

## 语言要求

### **可以使用中文的部分：**
- ✅ **联系信息** - 可以使用中文
- ✅ **备注给审核团队** - 可以使用中文
- ✅ **演示账户说明** - 可以使用中文

### **建议使用英文的部分：**
- 🔄 **技术性说明** - 建议英文，但中文也可以
- 🔄 **复杂功能解释** - 建议英文，便于审核团队理解

## 实际填写建议

### 1. **联系信息**
```
姓名：张三 (Zhang San)
电话：+86 138-0013-8000
邮箱：developer@example.com
```

### 2. **演示账户（如果需要）**
对于你的 TPCG 收藏记录应用，通常**不需要**演示账户，因为：
- 这是个人收藏管理应用
- 不涉及登录系统
- 功能相对简单直观

如果确实需要，可以这样写：
```
用户名：demo_user
密码：Demo123456
说明：这是一个演示账户，包含一些示例数据用于展示应用功能。
```

### 3. **备注（给审核团队的说明）**
这是最重要的部分，建议**中英文对照**：

```
应用说明 / App Description:
这是一个Pokemon集换式卡牌游戏(TPCG)的个人收藏管理应用。
This is a personal collection management app for Pokemon Trading Card Game (TPCG).

主要功能 / Main Features:
1. 卡片信息录入和管理 / Card information entry and management
2. 项目分类整理 / Project categorization
3. 价值统计和追踪 / Value statistics and tracking
4. 图片上传和存储 / Image upload and storage

技术说明 / Technical Notes:
- 使用本地SQLite数据库存储数据 / Uses local SQLite database for data storage
- 所有数据仅存储在用户设备本地 / All data is stored locally on user's device only
- 不涉及网络数据传输 / No network data transmission involved
- 相机和相册权限仅用于卡片图片拍摄和选择 / Camera and photo library permissions are only used for card image capture and selection

审核注意事项 / Review Notes:
- 应用功能完整，可直接使用 / App is fully functional and ready to use
- 无需特殊配置或外部依赖 / No special configuration or external dependencies required
- 建议在真实设备上测试以获得最佳体验 / Recommend testing on real device for best experience
```

## 为什么建议中英文对照？

### **优势：**
1. **确保理解准确** - 避免翻译误解
2. **加快审核速度** - 审核团队可以快速理解应用功能
3. **减少被拒风险** - 清晰的说明降低误解可能性
4. **专业印象** - 体现开发者的专业性

### **苹果官方立场：**
- 苹果审核团队是**多语言团队**
- **中文审核员**会处理中国区应用
- 但英文说明可以作为**备用参考**

## 实用模板

让我为你的应用创建一个完整的审核信息模板：
## 最佳实践建议

### 1. **语言选择策略**
- **主要内容**：中文（因为你可能主要面向中文用户）
- **技术术语**：中英文对照
- **关键功能**：提供英文说明作为补充

### 2. **内容重点**
- **突出应用价值**：解释为什么用户需要这个应用
- **说明技术实现**：特别是数据存储和隐私保护
- **强调合规性**：证明应用符合审核指南

### 3. **常见误区避免**
- ❌ 不要只写"这是一个管理应用"
- ❌ 不要忽略权限使用说明
- ❌ 不要遗漏隐私保护声明
- ✅ 要详细说明每个功能的用途
- ✅ 要解释为什么需要特定权限
- ✅ 要强调数据安全和用户隐私

## 总结

**答案：不需要全部用英文**，但建议：
1. **中文为主** - 审核团队有中文审核员
2. **关键信息中英对照** - 确保理解准确
3. **技术术语用英文** - 避免翻译歧义
4. **详细说明功能** - 帮助审核团队快速理解应用

使用上面提供的模板，根据你的实际情况填写相应信息即可。这样既能确保审核团队准确理解你的应用，又能体现专业性。