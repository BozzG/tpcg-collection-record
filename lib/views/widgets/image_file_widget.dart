import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/services/image_service.dart';

/// 统一的图片文件加载组件。
///
/// 接收数据库中存储的图片引用（可能是纯文件名或历史遗留的绝对路径），
/// 通过 [ImageService.resolveAbsolutePath] 解析为当前沙箱绝对路径后加载。
/// 文件不存在时显示 [placeholder]（默认为 "图片已丢失" 占位）。
class ImageFileWidget extends StatelessWidget {
  const ImageFileWidget({
    super.key,
    required this.imageRef,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheWidth,
    this.placeholder,
    this.borderRadius,
  });

  /// 数据库中存储的图片引用（纯文件名或绝对路径）
  final String? imageRef;

  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;

  /// 图片不存在时的占位组件
  final Widget? placeholder;

  /// 可选圆角（会对图片做 ClipRRect）
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (imageRef == null || imageRef!.isEmpty) {
      return placeholder ?? _defaultPlaceholder(context);
    }

    return FutureBuilder<String?>(
      future: ImageService.resolveAbsolutePath(imageRef),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final resolvedPath = snapshot.data;
        if (resolvedPath == null) {
          return placeholder ?? _defaultPlaceholder(context);
        }

        Widget image = Image.file(
          File(resolvedPath),
          fit: fit,
          width: width,
          height: height,
          cacheWidth: cacheWidth,
          errorBuilder: (context, error, stackTrace) {
            return placeholder ?? _defaultPlaceholder(context);
          },
        );

        if (borderRadius != null) {
          image = ClipRRect(
            borderRadius: borderRadius!,
            child: image,
          );
        }

        return image;
      },
    );
  }

  Widget _defaultPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerLow,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, size: 32, color: colorScheme.outline),
            const SizedBox(height: 4),
            Text(
              '图片已丢失',
              style: TextStyle(fontSize: 11, color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
