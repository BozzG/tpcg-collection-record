# Xcode签名配置完整指南

## 🎯 目标
将TPCG Collection Record应用成功安装到真实iOS设备上

## 📱 检测到的设备
✅ 郭子彦 的 iPhone (18.6.2) - 已连接

## 🚨 当前问题
```
No development certificates available to code sign app for device deployment
```
**解决方案**: 需要在Xcode中配置开发者证书和签名

## 🔧 完整解决步骤

### 步骤1：打开Xcode项目
```bash
cd /Users/bozzguo/project/tpcg_cr/app
open ios/Runner.xcworkspace
```

### 步骤2：配置Apple开发者账号

1. **添加Apple ID到Xcode**
   - Xcode → Preferences → Accounts
   - 点击 "+" 添加Apple ID
   - 输入你的Apple ID和密码
   - 选择 "Apple ID" 类型

2. **验证账号**
   - 确保账号显示在列表中
   - 点击 "Manage Certificates..."
   - 如果没有证书，点击 "+" 创建 "iOS Development" 证书

### 步骤3：配置项目签名

1. **选择项目和Target**
   - 在左侧导航栏选择 `Runner` 项目（蓝色图标）
   - 选择 `Runner` target（在TARGETS下）

2. **配置Signing & Capabilities**
   - 点击 `Signing & Capabilities` 标签
   - ✅ 勾选 "Automatically manage signing"
   - **Team**: 选择你的Apple开发者账号
   - **Bundle Identifier**: 修改为唯一值

### 步骤4：修改Bundle Identifier

**当前Bundle ID**: `com.example.tpcgCollectionRecord`

**建议修改为**:
```
com.bozzguo.tpcg-collection-record
com.yourname.pokemon-card-app
com.developer.tcg-collection
```

**修改方法**:
- 在 Bundle Identifier 字段中直接编辑
- 确保格式为: `com.yourname.appname`

### 步骤5：选择设备并运行

1. **选择设备**
   - 在Xcode顶部工具栏的设备选择器中
   - 选择 "郭子彦 的 iPhone" (而不是模拟器)

2. **构建并运行**
   - 点击播放按钮 ▶️
   - 或使用快捷键 `Cmd + R`

### 步骤6：设备端信任证书

1. **安装完成后**
   - 应用会出现在iPhone主屏幕上
   - 但可能无法直接打开

2. **信任开发者证书**
   - 设置 → 通用 → VPN与设备管理
   - 找到你的开发者账号
   - 点击 "信任 [你的开发者账号]"
   - 确认信任

## 🔍 故障排除

### 问题1: "Team"选项为空
**解决**: 
- 确保已在Xcode Preferences中添加Apple ID
- 重启Xcode后重试

### 问题2: Bundle ID已存在
**解决**: 
- 修改Bundle Identifier为更独特的值
- 例如: `com.yourname.tpcg.collection.record`

### 问题3: 证书过期
**解决**: 
- 删除过期证书
- 重新生成证书（Xcode自动管理）

### 问题4: 设备不信任
**解决**: 
- 在iPhone设置中手动信任开发者证书
- 重启设备后重试

## 📋 检查清单

在开始之前，确保：
- [ ] iPhone通过USB连接到Mac
- [ ] 在iPhone上点击了"信任此电脑"
- [ ] iPhone已解锁
- [ ] 已有Apple ID账号
- [ ] Xcode已安装最新版本

## 🚀 快速开始

```bash
# 1. 打开Xcode项目
open ios/Runner.xcworkspace

# 2. 配置签名 (按照上述步骤)

# 3. 选择设备并运行

# 4. 在iPhone上信任证书

# 5. 享受你的应用！
```

## 💡 开发者账号说明

### 免费Apple ID
- ✅ 可以在自己的设备上测试
- ⚠️ 应用7天后过期，需要重新安装
- ❌ 不能分发给其他人

### 付费开发者账号 ($99/年)
- ✅ 应用不会过期
- ✅ 可以分发给测试用户
- ✅ 可以发布到App Store

## 📞 需要帮助？

如果遇到问题：
1. 检查错误信息
2. 参考Apple官方文档
3. 重启Xcode和设备
4. 确保网络连接正常

---

## 🎊 成功标志

当看到以下情况时，说明部署成功：
- ✅ 应用图标出现在iPhone主屏幕
- ✅ 应用可以正常启动
- ✅ 所有功能正常工作
- ✅ 数据库和图片功能正常