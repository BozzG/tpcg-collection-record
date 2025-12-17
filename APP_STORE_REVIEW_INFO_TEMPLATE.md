# App Store 审核信息模板

## 联系信息 / Contact Information

**姓名 / Name:** [你的姓名]
**电话 / Phone:** +86 [你的手机号]
**邮箱 / Email:** [你的邮箱地址]

## 演示账户 / Demo Account
**不需要演示账户 / No demo account required**
原因：这是一个个人收藏管理应用，不涉及用户登录系统。

## 审核备注 / Review Notes

### 应用概述 / App Overview
TPCG Collection Record 是一个专为Pokemon集换式卡牌游戏爱好者设计的个人收藏管理应用。
TPCG Collection Record is a personal collection management app designed for Pokemon Trading Card Game enthusiasts.

### 核心功能 / Core Features

1. **卡片管理 / Card Management**
   - 录入卡片基本信息（名称、编号、评级等）
   - Enter basic card information (name, number, grade, etc.)
   - 拍摄或选择卡片图片
   - Capture or select card images
   - 记录购买价格和当前估值
   - Record purchase price and current valuation

2. **项目分类 / Project Categorization**
   - 创建不同的收藏项目
   - Create different collection projects
   - 按项目整理卡片
   - Organize cards by projects
   - 项目统计和价值计算
   - Project statistics and value calculation

3. **数据统计 / Data Statistics**
   - 收藏总览和价值统计
   - Collection overview and value statistics
   - 最近添加的卡片展示
   - Recently added cards display

### 技术实现 / Technical Implementation

**数据存储 / Data Storage:**
- 使用SQLite本地数据库存储所有数据
- Uses SQLite local database to store all data
- 数据完全存储在用户设备本地，不上传到任何服务器
- Data is completely stored locally on user's device, not uploaded to any server

**权限使用 / Permission Usage:**
- 相机权限：用于拍摄卡片图片
- Camera permission: Used for capturing card images
- 相册权限：用于从相册选择卡片图片
- Photo library permission: Used for selecting card images from photo library

**隐私保护 / Privacy Protection:**
- 应用不收集任何用户个人信息
- App does not collect any personal user information
- 不涉及网络数据传输
- No network data transmission involved
- 所有功能均可离线使用
- All features work offline

### 测试说明 / Testing Instructions

**建议测试流程 / Recommended Testing Process:**
1. 打开应用，查看主页统计信息
   Open the app and view homepage statistics
2. 点击"卡片数"进入卡片列表页面
   Tap "Card Count" to enter card list page
3. 点击"+"按钮添加新卡片，测试图片选择功能
   Tap "+" button to add new card, test image selection feature
4. 点击"项目数"进入项目列表页面
   Tap "Project Count" to enter project list page
5. 创建新项目并添加卡片到项目中
   Create new project and add cards to the project

**注意事项 / Notes:**
- 首次启动可能需要几秒钟进行数据库初始化
- First launch may take a few seconds for database initialization
- 建议在真实设备上测试以获得最佳用户体验
- Recommend testing on real device for optimal user experience
- 所有功能均已完整实现，无需额外配置
- All features are fully implemented, no additional configuration required

### 合规说明 / Compliance Statement

**App Store 审核指南合规 / App Store Review Guidelines Compliance:**
- 应用功能完整且实用
- App is complete and useful
- 无违规内容或私有API使用
- No inappropriate content or private API usage
- 用户界面设计符合iOS设计规范
- User interface design follows iOS design guidelines
- 性能稳定，无崩溃问题
- Stable performance with no crash issues

**目标用户 / Target Audience:**
- Pokemon卡牌游戏爱好者和收藏家
- Pokemon card game enthusiasts and collectors
- 年龄分级：4+ (适合所有年龄)
- Age rating: 4+ (suitable for all ages)

---

**如有任何问题，请随时联系我们 / If you have any questions, please feel free to contact us**
邮箱 / Email: [你的邮箱]
电话 / Phone: [你的电话]