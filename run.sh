#!/bin/bash

echo "TPCG Collection Record App"
echo "=========================="

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed or not in PATH"
    exit 1
fi

# 安装依赖
echo "Installing dependencies..."
flutter pub get

# 生成代码
echo "Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# 分析代码
echo "Analyzing code..."
flutter analyze --no-fatal-infos

# 运行应用
echo "Starting app..."
flutter run