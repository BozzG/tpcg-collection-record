import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

/// 清理临时目录下匹配指定前缀的历史文件。
///
/// 用于分享长图 / 导出备份等场景：每次生成新临时文件前先清理上一批同类产物，
/// 避免临时目录持续累积。当前要写入的新文件应在调用本方法【之后】再写入。
Future<void> cleanupTempByPrefix(List<String> prefixes) async {
  if (prefixes.isEmpty) return;
  try {
    final dir = await getTemporaryDirectory();
    if (!await dir.exists()) return;
    await for (final entity in dir.list()) {
      if (entity is File) {
        final name = p.basename(entity.path);
        if (prefixes.any(name.startsWith)) {
          try {
            await entity.delete();
          } catch (_) {
            // 单个文件删除失败忽略，不影响主流程
          }
        }
      }
    }
  } catch (e) {
    Log.warning('清理临时文件失败: $e');
  }
}
