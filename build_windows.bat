@echo off
chcp 65001 >nul
echo 🚀 开始构建Windows版本...
echo.

echo 📋 检查Flutter环境...
flutter doctor
echo.

echo 🧹 清理项目...
flutter clean
echo.

echo 📦 获取依赖...
flutter pub get
echo.

echo 🔨 构建Release版本...
flutter build windows --release
echo.

if exist "build\windows\x64\runner\Release\tpcg_collection_record.exe" (
    echo ✅ 构建完成！
    echo 📁 可执行文件位置: build\windows\x64\runner\Release\tpcg_collection_record.exe
    echo.
    echo 🎯 部署说明:
    echo 1. 将整个 Release 文件夹复制到目标机器
    echo 2. 双击 tpcg_collection_record.exe 运行应用
    echo 3. 确保所有DLL文件在同一目录下
) else (
    echo ❌ 构建失败！请检查错误信息
)

echo.
pause