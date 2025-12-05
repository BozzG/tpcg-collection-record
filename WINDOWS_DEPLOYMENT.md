# 🪟 Windows部署快速指南

## 🎯 三种部署方式

### 方式1: 在Windows机器上直接构建 (推荐)

#### 前提条件：
- Windows 10/11
- Flutter SDK
- Visual Studio 2022 (Community版)

#### 步骤：
1. **复制项目到Windows机器**
2. **双击运行 `build_windows.bat`**
3. **在 `build\windows\x64\runner\Release\` 找到exe文件**

### 方式2: 使用GitHub Actions自动构建

#### 步骤：
1. **将代码推送到GitHub**
2. **GitHub会自动构建Windows版本**
3. **在Actions页面下载构建产物**

### 方式3: 虚拟机构建

#### 步骤：
1. **在macOS上运行Windows虚拟机**
2. **在虚拟机中安装Flutter环境**
3. **按方式1构建**

## 📦 安装到Windows机器

### 简单部署：
1. 将整个Release文件夹复制到Windows机器
2. 双击 `tpcg_collection_record.exe` 运行

### 专业部署：
1. 使用Inno Setup创建安装包
2. 分发.exe安装程序

## 🔧 环境要求

### Windows机器需要：
- Windows 10 1903或更高版本
- Visual C++ Redistributable (通常已预装)

### 开发机器需要：
- Flutter SDK 3.24+
- Visual Studio 2022
- Windows 10/11 SDK

## 📱 应用特性

✅ **完整功能**：所有iOS功能在Windows上完全可用
✅ **本地存储**：SQLite数据库，数据完全本地化
✅ **文件管理**：支持图片选择和管理
✅ **现代UI**：Material Design界面
✅ **高性能**：原生Windows应用性能

## 🚀 快速开始

1. **下载项目代码**
2. **在Windows上运行 `build_windows.bat`**
3. **双击生成的exe文件**

就这么简单！🎉