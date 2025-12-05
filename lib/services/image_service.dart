import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:tpcg_collection_record/utils/logger.dart';

class ImageService {
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
        
        // 获取应用文档目录
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        
        // 创建images子目录
        Directory imagesDir = Directory(path.join(appDocPath, 'images'));
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
          Log.debug('创建图片目录: ${imagesDir.path}');
        }
        
        // 生成唯一文件名
        String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';
        String newPath = path.join(imagesDir.path, fileName);
        
        // 复制文件到应用目录
        File originalFile = File(filePath);
        await originalFile.copy(newPath);
        
        Log.info('图片保存成功: $newPath');
        return newPath;
      } else {
        Log.info('用户取消选择图片');
      }
    } catch (e, stackTrace) {
      Log.error('选择图片时发生错误', e, stackTrace);
    }
    
    return null;
  }
  
  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        Log.debug('尝试删除图片: $imagePath');
        
        File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
          Log.info('图片删除成功: $imagePath');
        } else {
          Log.warning('要删除的图片不存在: $imagePath');
        }
      } catch (e, stackTrace) {
        Log.error('删除图片时发生错误: $imagePath', e, stackTrace);
      }
    } else {
      Log.debug('图片路径为空，跳过删除操作');
    }
  }
}