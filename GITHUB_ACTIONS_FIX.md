# 🔧 GitHub Actions构建错误修复

## ❌ 错误信息
```
An error occurred trying to start process 'C:\Program Files\PowerShell\7\pwsh.EXE' 
with working directory 'D:\a\tpcg-collection-record\tpcg-collection-record\app'. 
The directory name is invalid.
```

## 🔍 问题分析

这个错误是**项目配置问题**，主要原因是GitHub仓库结构与GitHub Actions配置不匹配。

### 问题根源：
1. **仓库结构不匹配**：GitHub Actions期望在 `app/` 子目录中找到Flutter项目
2. **工作目录不存在**：实际的Flutter项目可能直接在仓库根目录

### 当前项目结构分析：
```
本地结构:
/Users/bozzguo/project/tpcg_cr/
└── app/                         # Flutter项目目录
    ├── pubspec.yaml
    ├── lib/
    ├── .github/workflows/
    └── ...

GitHub期望结构:
tpcg-collection-record/          # 仓库根目录
└── app/                         # Flutter项目子目录
    ├── pubspec.yaml
    └── ...
```

## ✅ 解决方案

### 方案1：调整GitHub Actions配置（推荐）

如果Flutter项目直接在仓库根目录，移除所有 `working-directory` 配置：

```yaml
# ❌ 原配置
- name: 📦 获取项目依赖
  working-directory: app
  run: flutter pub get

# ✅ 修复后
- name: 📦 获取项目依赖
  run: flutter pub get
```

### 方案2：调整仓库结构

如果希望保持 `app/` 子目录结构，需要确保：
1. GitHub仓库根目录包含 `app/` 文件夹
2. Flutter项目的所有文件都在 `app/` 目录中

## 🔧 自动诊断

运行诊断脚本检查当前结构：

```bash
./diagnose_github_structure.sh
```

## 📝 修复步骤

### 步骤1：确认当前结构
```bash
# 检查是否在Flutter项目根目录
ls -la pubspec.yaml
ls -la .github/workflows/
```

### 步骤2：选择修复方案

**如果 pubspec.yaml 在当前目录**（推荐）：
- 使用方案1：移除所有 `working-directory: app`
- GitHub Actions直接在仓库根目录运行

**如果需要保持子目录结构**：
- 确保GitHub仓库包含完整的 `app/` 目录
- 保持 `working-directory: app` 配置

### 步骤3：推送修复
```bash
git add .
git commit -m "🔧 修复GitHub Actions仓库结构配置"
git push origin main
```

## 🎯 修复状态

- [x] 移除所有 `working-directory: app` 配置
- [x] 调整路径引用为仓库根目录相对路径
- [x] 更新构建产物上传路径
- [x] 添加结构诊断脚本

## 🚀 验证修复

1. **推送代码**后检查GitHub Actions日志
2. **确认构建成功**，无路径错误
3. **下载构建产物**验证应用正常

现在GitHub Actions应该能够正确识别项目结构并成功构建！🎉