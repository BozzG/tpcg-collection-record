# 🔧 修复 SQLite 下载超时错误

## 错误描述
```
HttpException: Operation timed out, uri = https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.1.1/libsqlite3.arm64.ios.dylib
Building assets for package:sqlite3 failed.
```

## 🎯 问题原因
这个错误是由于网络连接问题导致的，SQLite3 库无法从 GitHub 下载所需的二进制文件。

## 🚀 解决方案

### 方案一：使用代理或 VPN（推荐）

如果您有可用的代理或 VPN：

```bash
# 设置代理环境变量（根据您的代理配置调整）
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# 然后重新构建
flutter build ios --release
```

### 方案二：切换到系统 SQLite（推荐）

修改 `pubspec.yaml`，使用系统内置的 SQLite：

```yaml
dependencies:
  # 注释掉或删除 sqlite3 相关依赖
  # sqlite3: ^2.4.6
  
  # 使用这些替代方案
  sqflite: ^2.3.3+1
  # 如果需要桌面支持，保留这个
  sqflite_common_ffi: ^2.3.3+1
```

### 方案三：手动下载并配置

1. **手动下载 SQLite 库**
   ```bash
   # 创建缓存目录
   mkdir -p ~/.pub-cache/hosted/pub.flutter-io.cn/sqlite3-3.1.1/lib/src/ffi/
   
   # 手动下载（需要能访问 GitHub）
   curl -L -o ~/.pub-cache/hosted/pub.flutter-io.cn/sqlite3-3.1.1/lib/src/ffi/libsqlite3.arm64.ios.dylib \
     https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.1.1/libsqlite3.arm64.ios.dylib
   ```

### 方案四：使用本地网络配置

配置 Git 和 Dart 使用本地网络设置：

```bash
# 配置 Git 代理（如果有）
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 配置 Dart pub 镜像
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 重新构建
flutter clean
flutter pub get
flutter build ios --release
```

### 方案五：修改项目配置（最简单）

如果您的应用主要用于 iOS，可以简化 SQLite 配置：

1. **更新 pubspec.yaml**
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     
     # State management
     provider: ^6.1.1
     
     # JSON serialization
     json_annotation: ^4.8.1
     freezed_annotation: ^2.4.1
     
     # Database - 简化配置
     sqflite: ^2.3.3+1
     path: ^1.8.3
     
     # 其他依赖保持不变...
   ```

2. **更新数据库服务**
   在 `lib/services/database_service.dart` 中，确保只使用 sqflite：
   
   ```dart
   import 'package:sqflite/sqflite.dart';
   // 移除 sqflite_common_ffi 相关导入
   ```

3. **更新 main.dart**
   简化桌面平台初始化：
   
   ```dart
   // 在 main.dart 中，简化桌面平台配置
   if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
     // 暂时注释掉 sqflite_common_ffi 相关代码
     // sqfliteFfiInit();
     // databaseFactory = databaseFactoryFfi;
   }
   ```

## 🔨 完整修复流程

### 步骤 1：选择解决方案
推荐使用**方案五**（修改项目配置），这是最简单且稳定的方法。

### 步骤 2：清理项目
```bash
cd /Users/ziyanguo/Project/ptcg_cr/app
flutter clean
rm -rf ~/.pub-cache/hosted/pub.flutter-io.cn/sqlite3*
```

### 步骤 3：更新依赖
```bash
flutter pub get
```

### 步骤 4：重新构建
```bash
flutter build ios --release
```

## 🎯 自动修复脚本

创建一个自动修复脚本：

```bash
#!/bin/bash
# 文件名: fix_sqlite_download.sh

echo "🔧 修复 SQLite 下载超时问题..."

# 清理缓存
echo "🧹 清理缓存..."
flutter clean
rm -rf ~/.pub-cache/hosted/pub.flutter-io.cn/sqlite3*

# 设置网络环境
echo "🌐 配置网络环境..."
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 重新获取依赖
echo "📦 重新获取依赖..."
flutter pub get

# 尝试构建
echo "🔨 尝试构建..."
flutter build ios --release

if [ $? -eq 0 ]; then
    echo "✅ 构建成功！"
else
    echo "❌ 构建仍然失败，建议使用方案五修改项目配置"
fi
```

## 💡 预防措施

1. **网络配置**
   - 确保网络连接稳定
   - 配置合适的代理设置
   - 使用国内镜像源

2. **依赖管理**
   - 选择稳定版本的依赖
   - 避免使用需要外部下载的依赖
   - 定期更新依赖版本

3. **项目配置**
   - 简化不必要的依赖
   - 使用平台原生的解决方案
   - 保持项目配置的简洁性

## 🚨 如果问题仍然存在

1. **检查网络连接**
   ```bash
   curl -I https://github.com/simolus3/sqlite3.dart/releases/
   ```

2. **使用移动热点**
   - 尝试使用手机热点网络
   - 有时运营商网络对 GitHub 访问更好

3. **联系网络管理员**
   - 如果在公司网络环境
   - 请求开放对 GitHub 的访问

4. **使用离线构建**
   - 在有网络的环境下完成首次构建
   - 将 `.pub-cache` 目录备份
   - 在离线环境使用备份的缓存

---

## 📋 快速修复检查清单

- [ ] 检查网络连接
- [ ] 清理项目缓存
- [ ] 配置网络环境变量
- [ ] 简化项目依赖
- [ ] 重新构建项目
- [ ] 验证构建成功

选择最适合您环境的解决方案，通常**方案五**（简化项目配置）是最可靠的选择。