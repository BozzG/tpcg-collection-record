# 📱 Xcode 上传时的 dSYM 选项设置指南

## 🎯 "Include app symbols for your app" 选项位置

### 📍 完整操作流程

#### 第一步：Archive 项目
1. 在 Xcode 中打开项目
   ```bash
   open ios/Runner.xcworkspace
   ```

2. 选择目标设备
   - 在设备选择器中选择 "Any iOS Device (arm64)"
   - 不要选择模拟器

3. 执行 Archive
   - 菜单栏：Product → Archive
   - 或快捷键：Cmd + Shift + B

#### 第二步：在 Organizer 中操作
Archive 完成后，Xcode 会自动打开 Organizer 窗口：

1. **Organizer 窗口**
   - 左侧会显示您的应用名称 "tpcg_collection_record"
   - 右侧显示 Archive 列表
   - 选择最新的 Archive

2. **点击 "Distribute App"**
   - 在右侧面板点击蓝色的 "Distribute App" 按钮

#### 第三步：选择分发方式
会出现分发选项对话框：

1. **选择 "App Store Connect"**
   - 选择第一个选项 "App Store Connect"
   - 点击 "Next"

#### 第四步：选择分发方法
1. **选择 "Upload"**
   - 选择 "Upload" 选项
   - 点击 "Next"

#### 第五步：App Store Connect 选项
这里会显示几个选项：

1. **"Include bitcode for iOS content"** - 通常勾选
2. **"Upload your app's symbols to receive symbolicated reports from Apple"** - 通常勾选
3. **⭐ "Include app symbols for your app"** - 这就是您要找的选项！

### 🔧 关键选项说明

#### "Include app symbols for your app" 选项
- **位置**：在 App Store Connect 选项页面
- **默认状态**：通常是勾选的
- **作用**：上传应用的调试符号文件 (dSYM)

#### 如果遇到 dSYM 错误时的操作
1. **取消勾选** "Include app symbols for your app"
2. 点击 "Next" 继续
3. 这样会跳过 dSYM 文件的验证和上传

### 📸 界面截图说明

```
┌─────────────────────────────────────────────────────────────┐
│                    App Store Connect Options                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ☑️ Include bitcode for iOS content                          │
│                                                             │
│ ☑️ Upload your app's symbols to receive symbolicated       │
│    reports from Apple                                       │
│                                                             │
│ ☑️ Include app symbols for your app  ← 这个选项！           │
│                                                             │
│                                                             │
│                    [Previous]  [Next]                      │
└─────────────────────────────────────────────────────────────┘
```

### 🚨 重要提醒

#### 取消勾选的影响
- ✅ **优点**：可以绕过 dSYM 错误，成功上传应用
- ❌ **缺点**：无法获得详细的崩溃日志符号化信息

#### 什么是 dSYM？
- **dSYM**：Debug Symbol 文件
- **作用**：将崩溃日志中的内存地址转换为可读的代码位置
- **重要性**：帮助开发者调试应用崩溃问题

### 🔄 完整上传流程

#### 方案 A：正常上传（推荐尝试）
1. Archive → Distribute App
2. App Store Connect → Upload
3. **保持所有选项勾选**
4. 如果成功，最好！

#### 方案 B：跳过 dSYM（如果方案 A 失败）
1. Archive → Distribute App
2. App Store Connect → Upload
3. **取消勾选** "Include app symbols for your app"
4. 继续上传

### 🛠️ 如果找不到 Organizer

#### 手动打开 Organizer
1. **菜单方式**：Window → Organizer
2. **快捷键**：Cmd + Shift + 9

#### 如果 Archive 不在列表中
1. 确保 Archive 成功完成
2. 检查是否选择了正确的设备（Any iOS Device）
3. 重新执行 Archive

### 💡 最佳实践建议

#### 首次上传
1. **先尝试完整上传**（包含 dSYM）
2. 如果失败，再取消 dSYM 选项
3. 记录问题，后续版本修复

#### 后续版本
1. 修复 dSYM 生成问题
2. 恢复完整的符号文件上传
3. 获得更好的崩溃日志支持

### 🔍 故障排除

#### 如果选项页面不同
- Xcode 版本不同可能界面略有差异
- 但 "Include app symbols" 选项应该都存在
- 寻找包含 "symbols" 或"符号"的选项

#### 如果仍然失败
1. 检查网络连接
2. 确认 Apple ID 权限
3. 尝试使用 Application Loader
4. 联系苹果技术支持

---

## 📋 快速操作清单

- [ ] 在 Xcode 中 Archive 项目
- [ ] 打开 Organizer（自动或手动）
- [ ] 选择最新的 Archive
- [ ] 点击 "Distribute App"
- [ ] 选择 "App Store Connect"
- [ ] 选择 "Upload"
- [ ] 找到 "Include app symbols for your app" 选项
- [ ] 根据需要勾选或取消勾选
- [ ] 继续上传流程

现在您知道在哪里找到这个选项了！