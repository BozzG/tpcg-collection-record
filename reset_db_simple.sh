#!/bin/bash

echo "=== 简单数据库重置脚本 ==="

# 查找可能的数据库文件位置
echo "1. 查找现有数据库文件..."

# 常见的macOS应用数据目录
POSSIBLE_PATHS=(
    "$HOME/Library/Containers/com.example.tpcgCollectionRecord/Data/Documents"
    "$HOME/Library/Application Support/tpcg_collection_record"
    "$HOME/Documents"
    "$HOME/Library/Caches/tpcg_collection_record"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "检查目录: $path"
        find "$path" -name "*tpcg*.db*" -type f 2>/dev/null | while read -r file; do
            echo "发现数据库文件: $file"
            
            # 创建备份
            backup_file="${file}.backup.$(date +%s)"
            cp "$file" "$backup_file" 2>/dev/null && echo "已备份到: $backup_file"
            
            # 删除原文件
            rm "$file" 2>/dev/null && echo "已删除: $file"
        done
    fi
done

# 查找并删除可能的锁文件
echo "2. 清理锁文件..."
find "$HOME/Library" -name "*tpcg*.db-wal" -o -name "*tpcg*.db-shm" -o -name "*tpcg*.db.lock" 2>/dev/null | while read -r file; do
    echo "删除锁文件: $file"
    rm "$file" 2>/dev/null
done

echo "3. 清理Flutter构建缓存..."
flutter clean

echo "4. 重新获取依赖..."
flutter pub get

echo "=== 重置完成 ==="
echo "现在可以重新运行应用进行测试。"