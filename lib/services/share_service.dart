import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tpcg_collection_record/utils/logger.dart';
import 'package:tpcg_collection_record/utils/temp_cleaner.dart';

/// 分享服务：把指定 [RepaintBoundary] 截图为 PNG 并调起系统分享面板。
///
/// 纯系统行为（系统分享 sheet：AirDrop / 微信 / 保存到相册等），不发起任何网络请求。
class ShareService {
  ShareService._();

  /// 将 [boundaryKey] 指向的 RepaintBoundary 渲染为高清 PNG，写入临时目录后分享。
  ///
  /// - [pixelRatio] 控制导出清晰度（默认 3.0，约等于 3x 屏）。
  /// - [shareText] 系统分享时附带的文案。
  /// - [sharePositionOrigin] iPad 上分享弹层的锚点矩形（不传 iPad 可能崩溃）。
  /// 返回是否成功调起分享。
  static Future<bool> captureAndShare({
    required GlobalKey boundaryKey,
    required String fileName,
    String? shareText,
    double pixelRatio = 3.0,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final ctx = boundaryKey.currentContext;
      if (ctx == null) {
        Log.warning('分享失败：截图边界尚未渲染');
        return false;
      }
      final renderObject = ctx.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        Log.warning('分享失败：未找到 RenderRepaintBoundary');
        return false;
      }

      final ui.Image image =
          await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        Log.warning('分享失败：图片编码为空');
        return false;
      }

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      // 先清理历史分享图，避免临时目录累积（保留本次将写入的文件）
      await cleanupTempByPrefix(['tpcg_card_', 'tpcg_project_']);
      final file = File(p.join(tempDir.path, fileName));
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
        sharePositionOrigin: sharePositionOrigin,
      );
      Log.info('分享长图已调起：${file.path}');
      return true;
    } catch (e, s) {
      Log.error('分享长图失败', e, s);
      return false;
    }
  }
}
