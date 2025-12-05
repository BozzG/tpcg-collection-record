# TPCG Collection Record

一个用于记录宝可梦卡牌收藏的Flutter应用。

## 功能特性

### 核心功能
- **项目管理**: 创建、编辑、删除收藏项目
- **卡片管理**: 添加、编辑、删除卡片信息
- **图片上传**: 支持上传卡片正面、背面和评级图片
- **搜索功能**: 支持按名称和编号搜索卡片和项目
- **统计信息**: 显示卡片数量、项目数量、总价值和总花费

### 页面结构
1. **首页**: 显示收藏统计和最近添加的卡片
2. **卡片列表页**: 浏览所有卡片，支持搜索和操作
3. **卡片详情页**: 查看卡片的详细信息和图片
4. **卡片编辑/添加页**: 编辑或添加新卡片
5. **项目列表页**: 浏览所有项目，支持搜索和操作
6. **项目详情页**: 查看项目信息和包含的卡片
7. **项目编辑/添加页**: 编辑或添加新项目

## 技术架构

- **架构模式**: MVVM (Model-View-ViewModel)
- **状态管理**: Provider
- **数据存储**: SQLite (sqflite)
- **代码生成**: Freezed + json_serializable
- **图片处理**: file_picker + path_provider
- **日志系统**: logger (支持多级别日志输出)

## 数据模型

### PTCGCard (卡片)
- id: 系统分配的ID
- projectId: 所属项目ID
- name: 卡片名称
- issueNumber: 发行编号
- issueDate: 发行时间
- grade: 评级 (PSA/BGS/CGC/CCIC等级)
- acquiredDate: 入手时间
- acquiredPrice: 入手价格
- currentPrice: 当前成交价
- frontImage: 正面图片路径
- backImage: 背面图片路径
- gradeImage: 评级图片路径

### PTCGProject (项目)
- id: 系统分配的ID
- name: 项目名称
- description: 项目描述
- cards: 包含的卡片列表

## 评级系统

支持以下评级标准：
- **PSA**: 1-10级
- **BGS**: 1-9级, 9.5级, 10级, 黑10级
- **CGC**: 1-10级, 金10级
- **CCIC**: 1-9级, 9.5级, 银10级, 金10级

## 安装和运行

1. 确保已安装Flutter SDK
2. 克隆项目到本地
3. 运行以下命令：

```bash
# 安装依赖
flutter pub get

# 生成代码
flutter packages pub run build_runner build

# 运行应用
flutter run
```

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── ptcg_card.dart
│   └── ptcg_project.dart
├── services/                 # 服务层
│   ├── database_service.dart
│   └── image_service.dart
├── viewmodels/              # ViewModel层
│   ├── home_viewmodel.dart
│   ├── card_viewmodel.dart
│   └── project_viewmodel.dart
├── views/                   # 视图层
│   ├── home_page.dart
│   ├── card_list_page.dart
│   ├── card_detail_page.dart
│   ├── edit_card_page.dart
│   ├── add_card_page.dart
│   ├── project_list_page.dart
│   ├── project_detail_page.dart
│   ├── edit_project_page.dart
│   └── add_project_page.dart
├── utils/                   # 工具类
│   ├── grade_utils.dart
│   ├── logger.dart          # 日志工具
│   └── logger_example.dart  # 日志使用示例
```

## 使用说明

1. **创建项目**: 首先创建一个收藏项目，为您的卡片分类
2. **添加卡片**: 在项目中添加卡片，填写详细信息
3. **上传图片**: 可选择上传卡片的正面、背面和评级图片
4. **管理收藏**: 通过搜索、编辑、删除等功能管理您的收藏

## 注意事项

- 图片文件会被复制到应用目录中，确保有足够的存储空间
- 删除项目会同时删除项目中的所有卡片
- 支持的图片格式：JPG, PNG, GIF等常见格式

## 日志系统

应用集成了专业的日志组件，支持多级别日志输出：

### 日志级别
- **Debug**: 开发调试信息（仅在调试模式显示）
- **Info**: 一般业务信息
- **Warning**: 警告信息
- **Error**: 错误信息
- **Fatal**: 致命错误

### 使用方法
```dart
import 'package:tpcg_collection_record/utils/logger.dart';

// 或使用简化别名
// import 'package:tpcg_collection_record/utils/logger.dart' show Log;

// 调试日志
Log.debug('调试信息');

// 信息日志
Log.info('操作成功');

// 警告日志
Log.warning('潜在问题');

// 错误日志
Log.error('操作失败', error, stackTrace);

// 致命错误
Log.fatal('应用崩溃', error, stackTrace);
```

### 环境配置
- **Debug模式**: 显示所有级别的日志
- **Release模式**: 只显示错误级别的日志，提高性能