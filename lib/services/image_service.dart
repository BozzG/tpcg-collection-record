import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:tpcg_collection_record/utils/logger.dart';

class ImageService {
  /// 缓存的沙箱 images 目录路径（避免反复 await）
  static String? _cachedImagesDir;

  /// 获取沙箱 images 目录的绝对路径
  static Future<String> getImagesDirectory() async {
    if (_cachedImagesDir != null) return _cachedImagesDir!;
    final appDocDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDocDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    _cachedImagesDir = imagesDir.path;
    return _cachedImagesDir!;
  }

  /// 将纯文件名（或兼容的绝对路径）解析为当前沙箱的绝对路径。
  ///
  /// - 如果 [fileRef] 已经是绝对路径且文件存在，直接返回。
  /// - 如果 [fileRef] 是纯文件名，拼接当前沙箱 images 目录返回。
  /// - 如果 [fileRef] 是旧的绝对路径（UUID 漂移后失效），取 basename 重拼。
  static Future<String?> resolveAbsolutePath(String? fileRef) async {
    if (fileRef == null || fileRef.isEmpty) return null;

    // 已经是绝对路径且文件存在 → 直接返回
    if (fileRef.startsWith('/')) {
      if (await File(fileRef).exists()) return fileRef;
      // 绝对路径但文件不存在（UUID 漂移）→ 取文件名重拼
      final fileName = path.basename(fileRef);
      final imagesDir = await getImagesDirectory();
      final resolved = path.join(imagesDir, fileName);
      if (await File(resolved).exists()) return resolved;
      // 文件确实不存在
      Log.warning('图片文件不存在: $fileRef (尝试 $resolved 也不存在)');
      return null;
    }

    // 纯文件名 → 拼接沙箱路径
    final imagesDir = await getImagesDirectory();
    final resolved = path.join(imagesDir, fileRef);
    if (await File(resolved).exists()) return resolved;
    Log.warning('图片文件不存在: $resolved');
    return null;
  }

  /// 同步版本的路径解析（需要先调用过 getImagesDirectory 初始化缓存）。
  /// 仅做路径拼接，不检查文件是否存在。用于不方便 await 的场景。
  static String? resolveAbsolutePathSync(String? fileRef) {
    if (fileRef == null || fileRef.isEmpty) return null;
    if (_cachedImagesDir == null) {
      // 缓存未初始化，返回原始值（兼容旧逻辑）
      return fileRef;
    }
    if (fileRef.startsWith('/')) {
      // 绝对路径 → 取 basename 重拼（兼容 UUID 漂移）
      final fileName = path.basename(fileRef);
      return path.join(_cachedImagesDir!, fileName);
    }
    return path.join(_cachedImagesDir!, fileRef);
  }

  /// 选择图片并保存到沙箱，**返回纯文件名**（不含目录路径）。
  static Future<String?> pickAndSaveImage() async {
    try {
      Log.info('开始选择图片');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        Log.debug('选择的图片路径: $filePath');

        final imagesDir = await getImagesDirectory();

        // 生成唯一文件名
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';
        String newPath = path.join(imagesDir, fileName);

        // 复制文件到应用目录
        File originalFile = File(filePath);
        await originalFile.copy(newPath);

        Log.info('图片保存成功: $newPath');
        // 返回纯文件名，数据库只存文件名
        return fileName;
      } else {
        Log.info('用户取消选择图片');
      }
    } catch (e, stackTrace) {
      Log.error('选择图片时发生错误', e, stackTrace);
    }

    return null;
  }

  static Future<void> deleteImage(String? imageRef) async {
    if (imageRef != null && imageRef.isNotEmpty) {
      try {
        // 兼容纯文件名和绝对路径
        final absolutePath = await resolveAbsolutePath(imageRef);
        if (absolutePath == null) {
          Log.warning('要删除的图片不存在: $imageRef');
          return;
        }

        Log.debug('尝试删除图片: $absolutePath');
        File imageFile = File(absolutePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
          Log.info('图片删除成功: $absolutePath');
        }
      } catch (e, stackTrace) {
        Log.error('删除图片时发生错误: $imageRef', e, stackTrace);
      }
    } else {
      Log.debug('图片路径为空，跳过删除操作');
    }
  }
}
