import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/utils/logger.dart';
import 'package:tpcg_collection_record/utils/temp_cleaner.dart';

/// 备份结果：恢复的项目数与卡片数。
typedef BackupCounts = ({int projects, int cards});

/// 数据备份服务：导出全量数据为 JSON 并分享；从 JSON 文件导入恢复。
///
/// 纯本地：导出走系统分享 sheet，导入走系统文件选择，不发起任何网络请求。
class BackupService {
  BackupService._();

  static const String _appTag = 'tpcg_collection_record';
  static const int _backupVersion = 1;

  /// 导出全量数据为 JSON 文件并调起系统分享。返回是否成功。
  ///
  /// [sharePositionOrigin] iPad 上分享弹层的锚点矩形（不传 iPad 可能崩溃）。
  static Future<bool> exportAndShare(
    DatabaseService db, {
    Rect? sharePositionOrigin,
  }) async {
    try {
      final data = await db.exportBackup();
      final payload = <String, dynamic>{
        'app': _appTag,
        'backupVersion': _backupVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        ...data,
      };
      final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);

      final now = DateTime.now();
      String two(int v) => v.toString().padLeft(2, '0');
      final stamp =
          '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}';
      final tempDir = await getTemporaryDirectory();
      // 先清理历史导出文件，避免临时目录累积（保留本次将写入的文件）
      await cleanupTempByPrefix(['tpcg_backup_']);
      final file = File(p.join(tempDir.path, 'tpcg_backup_$stamp.json'));
      await file.writeAsString(jsonStr, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'TPCG 藏品数据备份',
        sharePositionOrigin: sharePositionOrigin,
      );
      Log.info('备份导出已调起：${file.path}');
      return true;
    } catch (e, s) {
      Log.error('导出备份失败', e, s);
      return false;
    }
  }

  /// 选择 JSON 备份文件并整体恢复。
  ///
  /// 返回恢复计数；用户取消选择时返回 null；格式错误时抛出 [FormatException]。
  static Future<BackupCounts?> pickAndImport(DatabaseService db) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final f = result.files.single;
    String content;
    if (f.bytes != null) {
      content = utf8.decode(f.bytes!);
    } else if (f.path != null) {
      content = await File(f.path!).readAsString();
    } else {
      return null;
    }

    final decoded = jsonDecode(content);
    if (decoded is! Map ||
        decoded['projects'] is! List ||
        decoded['cards'] is! List) {
      throw const FormatException('备份文件格式不正确');
    }

    final projects = (decoded['projects'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final cards = (decoded['cards'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return db.importBackup(projects: projects, cards: cards);
  }
}
