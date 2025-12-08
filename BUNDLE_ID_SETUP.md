# Bundle Identifier 配置指南

## 📱 什么是Bundle Identifier

Bundle Identifier是iOS应用的唯一标识符，类似于Android的包名。每个应用都必须有一个全球唯一的Bundle ID。

## 🔧 如何修改Bundle Identifier

### 方法1：在Xcode中修改（推荐）

1. **打开Xcode项目**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **导航到项目设置**
   - 选择左侧的 `Runner` 项目
   - 选择 `Runner` target
   - 点击 `Signing & Capabilities` 标签

3. **修改Bundle Identifier**
   - 在 `Bundle Identifier` 字段中输入新的ID
   - 格式：`com.yourname.appname`

### 方法2：修改配置文件

编辑文件：`ios/Runner.xcodeproj/project.pbxproj`

查找并修改：
```
PRODUCT_BUNDLE_IDENTIFIER = com.yourname.tpcgcollectionrecord;
```

## 📋 Bundle ID命名建议

### 推荐格式
```
com.[你的名字].tpcg-collection-record
com.[公司名].tpcgcollectionrecord
com.[域名].pokemon-card-tracker
```

### 具体示例
```
com.johnsmith.tpcg-collection-record
com.mycompany.tpcgcollectionrecord
com.pokemonfan.cardtracker
com.developer.pokemon-tcg-app
```

### 命名规则
- ✅ 使用反向域名格式
- ✅ 只能包含字母、数字、连字符(-)和点(.)
- ✅ 必须全球唯一
- ❌ 不能以数字开头
- ❌ 不能包含下划线(_)
- ❌ 不能包含空格

## 🚨 常见问题

### 1. Bundle ID已存在
```
错误：An App ID with Identifier 'com.example.app' is not available
解决：修改为更独特的Bundle ID
```

### 2. 格式错误
```
错误：Invalid Bundle Identifier
解决：检查格式是否符合规范
```

### 3. 权限问题
```
错误：You don't have permission to register this Bundle ID
解决：使用你自己的开发者账号域名
```

## 🔄 当前项目配置

### 默认Bundle ID
```
com.example.tpcgCollectionRecord
```

### 建议修改为
```
com.[你的名字].tpcg-collection-record
```

例如：
```
com.bozzguo.tpcg-collection-record
com.developer.pokemon-card-app
com.myname.tcg-collection
```

## 📱 完整配置流程

1. **打开Xcode项目**
   ```bash
   ./deploy_to_device.sh
   # 或
   open ios/Runner.xcworkspace
   ```

2. **配置签名**
   - 选择 Runner → Signing & Capabilities
   - Team: 选择你的Apple开发者账号
   - Bundle Identifier: 输入唯一ID

3. **自动管理签名**
   - ✅ 勾选 "Automatically manage signing"
   - Xcode会自动处理证书和配置文件

4. **选择设备并运行**
   - 在设备选择器中选择你的iPhone/iPad
   - 点击运行按钮 ▶️

## 💡 开发者账号类型

### 免费开发者账号
- ✅ 可以在自己的设备上测试
- ⚠️ 应用有效期7天
- ❌ 不能发布到App Store

### 付费开发者账号 ($99/年)
- ✅ 可以在任何设备上测试
- ✅ 应用永久有效
- ✅ 可以发布到App Store
- ✅ 可以使用高级功能

## 🔍 验证Bundle ID

在Xcode中构建时，如果Bundle ID有问题，会显示相应的错误信息。常见的验证方法：

1. **构建测试**
   ```bash
   flutter build ios --release
   ```

2. **Xcode验证**
   - 在Xcode中选择设备
   - 尝试运行应用
   - 查看错误信息

## 📖 相关文档

- [Apple Developer Documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleidentifier)
- [iOS App Distribution Guide](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/AppDistributionGuide/)

---

## 快速配置

```bash
# 1. 运行部署脚本
./deploy_to_device.sh

# 2. 在Xcode中修改Bundle ID为：
com.yourname.tpcg-collection-record

# 3. 选择开发者账号作为Team

# 4. 连接设备并运行
```