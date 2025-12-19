# 📋 出口合规证明 (Export Compliance) 指南

## 🎯 什么是出口合规证明？

### 📖 定义
出口合规证明是美国政府要求的，用于确定应用是否包含加密技术或受出口管制的技术。

### 🇺🇸 法律背景
- **法规**：美国出口管理条例 (Export Administration Regulations, EAR)
- **目的**：防止敏感技术被出口到受限制的国家或地区
- **适用范围**：所有在 App Store 上发布的应用

## 🔍 为什么会出现这个提示？

### 触发条件
当您的应用满足以下条件时会出现此提示：
1. 使用了加密技术
2. 包含网络通信功能
3. 使用了 HTTPS 连接
4. 包含任何形式的数据加密

### 常见触发场景
- ✅ **HTTPS 网络请求**（最常见）
- ✅ **本地数据加密存储**
- ✅ **用户认证和登录**
- ✅ **第三方 SDK 包含加密功能**

## 🎯 您的应用情况分析

### TPCG Collection Record 应用特点
根据您的应用功能：
- 📱 **本地数据存储**：使用 SQLite 数据库
- 📷 **图片处理**：本地图片存储和处理
- 🔒 **可能的加密**：
  - iOS 系统级加密（设备存储加密）
  - SQLite 数据库可能的加密
  - 网络请求（如果有的话）

### 🔍 判断标准
您的应用**很可能需要**出口合规证明，因为：
1. iOS 应用默认使用系统加密
2. 数据库存储可能涉及加密
3. 任何网络功能都会触发要求

## 🚀 解决方案

### 方案一：声明不使用加密（推荐）

如果您的应用符合以下条件，可以声明不使用加密：
- ✅ 纯本地应用，无网络功能
- ✅ 不进行用户认证
- ✅ 不使用自定义加密算法
- ✅ 只使用标准的 iOS 系统加密

#### 操作步骤：
1. **在 App Store Connect 中**
   - 选择您的应用
   - 进入 "App 信息" 页面
   - 找到 "出口合规信息" 部分

2. **回答问题**
   ```
   问题：您的应用是否使用加密？
   答案：否
   
   问题：您的应用是否包含、使用或访问加密？
   答案：否
   ```

### 方案二：在 Info.plist 中配置（推荐）

在项目中预先配置，避免每次都要手动处理：

#### 编辑 ios/Runner/Info.plist
```xml
<!-- 在 <dict> 标签内添加以下内容 -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

#### 完整配置示例：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 现有配置... -->
    
    <!-- 出口合规配置 -->
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>
    
    <!-- 现有配置继续... -->
</dict>
</plist>
```

### 方案三：申请出口许可（如果确实使用加密）

如果您的应用确实使用了自定义加密：

1. **评估加密类型**
   - 标准加密（通常免税）
   - 自定义加密（需要许可）

2. **申请流程**
   - 在 App Store Connect 中提供详细信息
   - 可能需要向美国商务部申请许可
   - 处理时间：几天到几周

## 🔧 具体操作步骤

### 立即解决方案（推荐）

#### 步骤 1：修改 Info.plist
```bash
# 在项目根目录执行
open ios/Runner/Info.plist
```

#### 步骤 2：添加配置
在 Info.plist 文件中添加：
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

#### 步骤 3：重新构建和上传
```bash
# 重新构建
flutter build ios --release

# 重新 Archive 和上传
```

### 在 App Store Connect 中处理

如果您已经上传了构建版本：

1. **登录 App Store Connect**
2. **选择您的应用**
3. **进入构建版本页面**
4. **点击构建版本旁的警告图标**
5. **回答出口合规问题**：
   ```
   问题：您的应用是否使用加密？
   建议答案：否（对于您的应用）
   ```

## 📋 常见问题解答

### Q1: 我的应用只是本地存储，为什么需要这个？
**A**: iOS 系统默认对存储进行加密，Apple 要求所有应用都要声明是否使用加密。

### Q2: 选择"否"会有什么影响？
**A**: 没有负面影响。这只是合规声明，不会影响应用功能。

### Q3: 如果选择错了怎么办？
**A**: 可以在后续版本中修正，或联系 Apple 支持修改。

### Q4: SQLite 数据库算加密吗？
**A**: 标准 SQLite 不算自定义加密，可以选择"否"。

## 🎯 针对您的应用的建议

### TPCG Collection Record 应用
基于您的应用特点，建议：

1. **选择"否"** - 不使用加密
   - 理由：纯本地应用，无网络功能
   - 只使用标准 iOS 系统加密

2. **在 Info.plist 中添加配置**
   ```xml
   <key>ITSAppUsesNonExemptEncryption</key>
   <false/>
   ```

3. **重新构建和上传**

### 🔄 完整解决流程

```bash
# 1. 编辑 Info.plist
open ios/Runner/Info.plist
# 添加 ITSAppUsesNonExemptEncryption = false

# 2. 重新构建
flutter clean
flutter build ios --release

# 3. 在 Xcode 中重新 Archive
open ios/Runner.xcworkspace
# Product → Archive → Distribute App
```

## 💡 预防措施

### 未来版本
1. **保持 Info.plist 配置**
2. **如果添加网络功能，重新评估**
3. **定期检查依赖是否引入加密**

### 最佳实践
1. **提前配置**：在开发阶段就添加 Info.plist 配置
2. **文档记录**：记录应用的加密使用情况
3. **定期审查**：每次更新时检查是否需要修改声明

---

## 📞 需要帮助？

如果仍有疑问：
1. **Apple 开发者支持**：联系 Apple 技术支持
2. **法律咨询**：如果涉及复杂的加密技术
3. **社区资源**：查看 Apple 开发者论坛

**对于您的应用，推荐选择"否"并在 Info.plist 中添加相应配置。**