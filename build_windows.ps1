# PowerShell脚本用于构建Windows版本
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🚀 开始构建Windows版本..." -ForegroundColor Green
Write-Host ""

Write-Host "📋 检查Flutter环境..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

Write-Host "🧹 清理项目..." -ForegroundColor Yellow
flutter clean
Write-Host ""

Write-Host "📦 获取依赖..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

Write-Host "🔨 构建Release版本..." -ForegroundColor Yellow
flutter build windows --release
Write-Host ""

$exePath = "build\windows\x64\runner\Release\tpcg_collection_record.exe"
if (Test-Path $exePath) {
    Write-Host "✅ 构建完成！" -ForegroundColor Green
    Write-Host "📁 可执行文件位置: $exePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🎯 部署说明:" -ForegroundColor Yellow
    Write-Host "1. 将整个 Release 文件夹复制到目标机器" -ForegroundColor White
    Write-Host "2. 双击 tpcg_collection_record.exe 运行应用" -ForegroundColor White
    Write-Host "3. 确保所有DLL文件在同一目录下" -ForegroundColor White
    
    # 获取文件大小
    $fileSize = (Get-Item $exePath).Length
    $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
    Write-Host "📊 应用大小: $fileSizeMB MB" -ForegroundColor Cyan
} else {
    Write-Host "❌ 构建失败！请检查错误信息" -ForegroundColor Red
}

Write-Host ""
Read-Host "按任意键继续..."