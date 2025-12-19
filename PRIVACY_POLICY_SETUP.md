# 隐私政策网址设置指南

## 🎯 快速解决方案

### 方案一：GitHub Pages（推荐，免费）

1. **上传隐私政策文件**
   ```bash
   # 将 privacy_policy.html 提交到您的 GitHub 仓库
   git add privacy_policy.html
   git commit -m "Add privacy policy"
   git push origin main
   ```

2. **启用 GitHub Pages**
   - 进入 GitHub 仓库设置
   - 找到 "Pages" 部分
   - Source 选择 "Deploy from a branch"
   - Branch 选择 "main"
   - 点击 "Save"

3. **获取网址**
   ```
   https://yourusername.github.io/repository-name/privacy_policy.html
   ```

### 方案二：使用免费托管服务

#### Netlify（推荐）
1. 访问 [netlify.com](https://netlify.com)
2. 拖拽 `privacy_policy.html` 文件到页面
3. 获得免费网址：`https://random-name.netlify.app/privacy_policy.html`

#### Vercel
1. 访问 [vercel.com](https://vercel.com)
2. 连接 GitHub 仓库
3. 自动部署，获得网址

### 方案三：简单的在线工具

#### GitHub Gist
1. 访问 [gist.github.com](https://gist.github.com)
2. 创建新 Gist
3. 文件名：`privacy_policy.html`
4. 粘贴隐私政策内容
5. 创建公开 Gist
6. 使用 RawGit 或 GitHack 获得可访问的网址

## 📋 App Store Connect 填写

在 App Store Connect 中：
1. 进入应用信息页面
2. 找到 "隐私政策网址 (URL)" 字段
3. 填入您的隐私政策网址
4. 保存更改

## ✅ 验证清单

- [ ] 隐私政策网址可以正常访问
- [ ] 内容符合您的应用实际情况
- [ ] 包含必要的联系信息
- [ ] 语言与应用目标市场匹配

## 🔧 自定义修改

如需修改隐私政策内容，请编辑 `privacy_policy.html` 文件中的：
- 联系邮箱
- GitHub 仓库链接
- 公司/开发者信息
- 具体的数据处理说明

## 💡 重要提醒

1. **真实性**：确保隐私政策内容与应用实际行为一致
2. **更新**：应用功能变更时及时更新隐私政策
3. **可访问性**：确保网址长期有效且可访问
4. **合规性**：根据目标市场的法规要求调整内容

## 🌐 多语言支持

如果您的应用支持多种语言，建议：
- 创建对应语言的隐私政策版本
- 使用子路径区分：`/privacy_policy_en.html`
- 在应用中提供相应的链接