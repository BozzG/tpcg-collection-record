# 🔧 GitHub Actions构建错误修复

## ❌ 错误信息
```
An error occurred trying to start process 'C:\Program Files\PowerShell\7\pwsh.EXE' 
with working directory 'D:\a\tpcg-collection-record\tpcg-collection-record\./app'. 
The directory name is invalid.
```

## 🔍 问题分析

这个错误是**项目配置问题**，不是GitHub的问题。

### 问题原因：
1. **路径格式错误**：`./app` 在Windows PowerShell中不是有效的路径格式
2. **工作目录设置**：GitHub Actions中的 `working-directory` 应该使用相对路径 `app` 而不是 `./app`

### 项目结构：
```
tpcg-collection-record/          # GitHub仓库根目录
└── app/                         # Flutter项目目录
    ├── pubspec.yaml
    ├── lib/
    ├── .github/workflows/
    └── ...
```

## ✅ 解决方案

### 1. 修复GitHub Actions配置

将所有的 `working-directory: ./app` 改为 `working-directory: app`：

```yaml
# ❌ 错误写法
working-directory: ./app

# ✅ 正确写法  
working-directory: app
```

### 2. 确保仓库结构正确

确保GitHub仓库的根目录包含 `app/` 文件夹：

```
your-repo/
├── app/                    # Flutter项目
│   ├── pubspec.yaml
│   ├── lib/
│   ├── .github/
│   └── ...
└── README.md              # 可选的根目录README
```

### 3. 推送修复后的代码

```bash
git add .
git commit -m "🔧 修复GitHub Actions路径配置"
git push origin main
```

## 🚀 验证修复

1. **推送代码后**，GitHub Actions会自动触发
2. **检查Actions页面**，确认构建成功
3. **下载构建产物**，验证Windows应用正常

## 📝 其他注意事项

### Windows路径规则：
- ✅ 使用 `app` 或 `app\subfolder`
- ✅ 使用 `app/subfolder` (跨平台)
- ❌ 避免 `./app` (在PowerShell中可能无效)
- ❌ 避免 `.\app` (仅Windows格式)

### GitHub Actions最佳实践：
- 使用相对路径而不是绝对路径
- 保持路径格式的跨平台兼容性
- 在 `working-directory` 中使用简洁的路径格式

## 🎯 修复状态

- [x] 修复 `working-directory` 路径格式
- [x] 更新所有相关的路径引用
- [x] 保持跨平台兼容性
- [x] 添加详细的错误说明文档

现在GitHub Actions应该能够正常构建Windows应用了！🎉