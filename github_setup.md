# 🐙 GitHub仓库设置指南

## 1. 创建GitHub仓库

### 在GitHub网站上：
1. 登录GitHub账号
2. 点击右上角 "+" → "New repository"
3. 填写仓库信息：
   - Repository name: `tpcg-collection-record`
   - Description: `Pokemon Trading Card Game Collection Record App`
   - 选择 Public（免费使用Actions）
   - 勾选 "Add a README file"
4. 点击 "Create repository"

## 2. 本地代码推送到GitHub

### 在项目目录执行：
```bash
# 初始化Git仓库（如果还没有）
git init

# 添加GitHub远程仓库
git remote add origin https://github.com/你的用户名/tpcg-collection-record.git

# 添加所有文件
git add .

# 提交代码
git commit -m "Initial commit: Flutter card collection app"

# 推送到GitHub
git push -u origin main
```

## 3. 验证仓库结构

推送后，GitHub仓库应该包含：
```
tpcg-collection-record/
├── .github/
│   └── workflows/
│       └── build-windows.yml  # 自动构建配置
├── app/                       # Flutter应用代码
│   ├── lib/
│   ├── pubspec.yaml
│   ├── build_windows.bat
│   └── ...
├── README.md
└── ...
```