#!/bin/bash

echo "🔍 GitHub仓库结构诊断"
echo "======================"

# 检查当前目录
echo "📁 当前目录: $(pwd)"
echo ""

# 检查是否是Flutter项目根目录
if [ -f "pubspec.yaml" ]; then
    echo "✅ 发现 pubspec.yaml - 这是Flutter项目根目录"
    echo "📋 项目名称: $(grep '^name:' pubspec.yaml | cut -d' ' -f2)"
else
    echo "❌ 未发现 pubspec.yaml - 这不是Flutter项目根目录"
fi
echo ""

# 检查GitHub Actions配置
if [ -d ".github/workflows" ]; then
    echo "✅ 发现 .github/workflows 目录"
    echo "📄 工作流文件:"
    ls -la .github/workflows/
else
    echo "❌ 未发现 .github/workflows 目录"
fi
echo ""

# 检查关键Flutter目录
echo "📂 Flutter项目结构检查:"
for dir in "lib" "android" "ios" "windows" "web"; do
    if [ -d "$dir" ]; then
        echo "  ✅ $dir/ 存在"
    else
        echo "  ❌ $dir/ 不存在"
    fi
done
echo ""

# 检查是否在子目录中
if [ -d "../pubspec.yaml" ] || [ -f "../pubspec.yaml" ]; then
    echo "⚠️  警告: 上级目录中发现Flutter项目"
    echo "   当前可能在子目录中，需要调整仓库结构"
fi

# 生成建议的仓库结构
echo "💡 建议的GitHub仓库结构:"
echo "your-repo/"
echo "├── .github/"
echo "│   └── workflows/"
echo "│       └── build-windows.yml"
echo "├── lib/"
echo "├── android/"
echo "├── ios/"
echo "├── windows/"
echo "├── pubspec.yaml"
echo "└── README.md"
echo ""

echo "🚀 修复建议:"
echo "1. 确保Flutter项目文件直接在仓库根目录"
echo "2. GitHub Actions配置不需要 working-directory"
echo "3. 所有路径都相对于仓库根目录"