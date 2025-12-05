# ⚡ GitHub Actions快速开始

## 🎯 5分钟完成Windows版本自动构建

### 📝 操作清单

#### ✅ 第1步：创建GitHub仓库（2分钟）
1. 登录 [GitHub.com](https://github.com)
2. 点击右上角 "+" → "New repository"
3. 仓库名：`tpcg-collection-record`
4. 设为Public（免费使用Actions）
5. 点击 "Create repository"

#### ✅ 第2步：推送代码（1分钟）
```bash
cd /Users/bozzguo/project/tpcg_collection_record
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/你的用户名/tpcg-collection-record.git
git push -u origin main
```

#### ✅ 第3步：触发构建（1分钟）
1. 打开GitHub仓库页面
2. 点击 "Actions" 标签
3. 选择 "🪟 Build Windows App"
4. 点击 "Run workflow" → "Run workflow"

#### ✅ 第4步：下载应用（1分钟）
1. 等待构建完成（约5-10分钟）
2. 在Actions页面底部下载zip文件
3. 解压后双击exe文件运行

## 🎉 完成！

现在你有了：
- ✅ 自动化的Windows构建流程
- ✅ 可直接运行的Windows应用
- ✅ 版本管理和发布系统
- ✅ 完全免费的云端构建

## 🔄 后续使用

每次修改代码后：
```bash
git add .
git commit -m "更新描述"
git push
```

GitHub会自动构建新版本！

## 📞 需要帮助？

- 构建失败：查看Actions页面的错误日志
- 下载问题：检查网络连接
- 运行问题：确保Windows 10+系统