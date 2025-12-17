#!/bin/bash

echo "=== macOS数据库初始化问题诊断脚本 ==="
echo

# 检查Flutter环境
echo "1. 检查Flutter环境:"
flutter --version
echo

# 检查macOS权限
echo "2. 检查应用权限:"
echo "应用文档目录权限检查..."
ls -la ~/Library/Containers/ | grep -i tpcg || echo "未找到应用容器目录"
echo

# 检查数据库相关依赖
echo "3. 检查pubspec.yaml中的数据库依赖:"
grep -A 5 -B 5 "sqflite\|path_provider" pubspec.yaml
echo

# 检查是否有现有的数据库文件
echo "4. 查找现有数据库文件:"
find ~/Library -name "*tpcg*" -type f 2>/dev/null | head -10
echo

# 检查系统日志中的相关错误
echo "5. 检查系统日志中的Flutter相关错误:"
log show --predicate 'process == "Runner"' --last 1h --info 2>/dev/null | tail -20 || echo "无法访问系统日志"
echo

# 运行Flutter诊断
echo "6. Flutter诊断信息:"
flutter doctor -v
echo

echo "=== 诊断完成 ==="
echo
echo "解决方案建议:"
echo "1. 如果发现权限问题，请重新安装应用"
echo "2. 如果发现数据库文件损坏，运行: dart reset_database_macos.dart"
echo "3. 如果依赖有问题，运行: flutter pub get"
echo "4. 清理构建缓存: flutter clean && flutter pub get"