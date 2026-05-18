import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

/// 卡片正面缩略图组件
///
/// 矩形圆角缩略图，5:7 比例（贴近真实卡牌形态），用于列表项 leading。
/// 三态渲染：
/// - 有图：Image.file + BoxFit.cover + cacheWidth 内存优化
/// - 无图（null/空串）：primaryContainer 背景 + Icons.credit_card
/// - 加载失败：视觉同无图 + Log.warning 静默回退
class CardThumbnail extends StatelessWidget {
  const CardThumbnail({
    super.key,
    required this.frontImage,
    this.height = 56,
    this.aspectRatio = 5 / 7,
    this.borderRadius = 8,
  });

  final String? frontImage;
  final double height;
  final double aspectRatio;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = frontImage != null && frontImage!.isNotEmpty;

    Widget child;
    if (hasImage) {
      child = Image.file(
        File(frontImage!),
        fit: BoxFit.cover,
        cacheWidth: (height * MediaQuery.of(context).devicePixelRatio).toInt(),
        errorBuilder: (context, error, stackTrace) {
          Log.warning('卡片缩略图加载失败: $frontImage');
          return _buildPlaceholder(colorScheme);
        },
      );
    } else {
      child = _buildPlaceholder(colorScheme);
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: child,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.secondaryContainer,
      child: Center(
        child: Icon(
          Icons.credit_card,
          color: colorScheme.onSecondaryContainer,
          size: 24,
        ),
      ),
    );
  }
}
