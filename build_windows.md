# 🪟 Windows版本构建和部署指南

## 📋 前提条件

### 在Windows机器上需要安装：
1. **Flutter SDK** (最新稳定版)
2. **Visual Studio 2022** (Community版本即可)
   - 安装时选择"使用C++的桌面开发"工作负载
   - 包含Windows 10/11 SDK
3. **Git** (用于克隆项目)

## 🚀 构建步骤

### 1. 环境准备
```bash
# 检查Flutter环境
flutter doctor

# 启用Windows桌面支持
flutter config --enable-windows-desktop

# 验证Windows支持
flutter devices
```

### 2. 获取项目代码
```bash
# 克隆项目到Windows机器
git clone [你的项目仓库地址]
cd tpcg_collection_record/app

# 或者直接复制整个项目文件夹到Windows机器
```

### 3. 安装依赖
```bash
# 清理并获取依赖
flutter clean
flutter pub get
```

### 4. 构建Windows应用
```bash
# 构建Release版本
flutter build windows --release

# 构建Debug版本（用于测试）
flutter build windows --debug
```

### 5. 找到构建产物
构建完成后，可执行文件位于：
```
build/windows/x64/runner/Release/
├── tpcg_collection_record.exe  # 主程序
├── flutter_windows.dll         # Flutter运行时
├── data/                       # 资源文件
└── [其他依赖文件]
```

## 📦 打包和分发

### 方案1: 直接复制文件夹
1. 将整个 `build/windows/x64/runner/Release/` 文件夹复制到目标机器
2. 双击 `tpcg_collection_record.exe` 运行

### 方案2: 创建安装包
使用以下工具之一创建安装包：
- **Inno Setup** (免费)
- **NSIS** (免费)
- **Advanced Installer** (付费)

### 方案3: 便携版
1. 将Release文件夹重命名为应用名称
2. 压缩成ZIP文件
3. 用户解压后即可运行

## 🔧 自动化构建脚本

### Windows批处理脚本 (build_windows.bat)
```batch
@echo off
echo 🚀 开始构建Windows版本...

echo 📋 检查Flutter环境...
flutter doctor

echo 🧹 清理项目...
flutter clean

echo 📦 获取依赖...
flutter pub get

echo 🔨 构建Release版本...
flutter build windows --release

echo ✅ 构建完成！
echo 📁 可执行文件位置: build\windows\x64\runner\Release\tpcg_collection_record.exe

pause
```

### PowerShell脚本 (build_windows.ps1)
```powershell
Write-Host "🚀 开始构建Windows版本..." -ForegroundColor Green

Write-Host "📋 检查Flutter环境..." -ForegroundColor Yellow
flutter doctor

Write-Host "🧹 清理项目..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 获取依赖..." -ForegroundColor Yellow
flutter pub get

Write-Host "🔨 构建Release版本..." -ForegroundColor Yellow
flutter build windows --release

Write-Host "✅ 构建完成！" -ForegroundColor Green
Write-Host "📁 可执行文件位置: build\windows\x64\runner\Release\tpcg_collection_record.exe" -ForegroundColor Cyan

Read-Host "按任意键继续..."
```

## 🎯 部署到Windows机器

### 方法1: 本地构建
1. 在Windows机器上安装Flutter开发环境
2. 克隆/复制项目代码
3. 运行构建脚本
4. 直接运行生成的exe文件

### 方法2: 跨平台构建 (推荐)
1. 使用GitHub Actions或其他CI/CD服务
2. 自动构建Windows版本
3. 下载构建产物到Windows机器

### 方法3: 虚拟机构建
1. 在macOS上运行Windows虚拟机
2. 在虚拟机中安装Flutter环境
3. 构建Windows版本

## 📱 应用功能
Windows版本将包含所有功能：
- ✅ 卡片管理 (添加、编辑、删除)
- ✅ 项目管理
- ✅ 图片预览和缩放
- ✅ 统计功能
- ✅ 本地数据库存储
- ✅ 文件选择器支持

## 🔍 故障排除

### 常见问题：
1. **Visual Studio未安装**: 安装VS2022并包含C++工作负载
2. **Windows SDK缺失**: 在VS安装程序中添加Windows SDK
3. **Flutter路径问题**: 确保Flutter在系统PATH中
4. **依赖冲突**: 运行 `flutter clean && flutter pub get`

### 运行时问题：
1. **缺少DLL**: 确保所有依赖文件在同一目录
2. **权限问题**: 以管理员身份运行
3. **防火墙阻止**: 添加应用到防火墙白名单

## 📞 技术支持
如果遇到问题，请提供：
- Flutter版本 (`flutter --version`)
- 错误日志
- Windows版本信息
- Visual Studio版本