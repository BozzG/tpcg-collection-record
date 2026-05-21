import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/views/card_detail_page.dart';
import 'package:tpcg_collection_record/theme/app_theme.dart';

/// 高价值卡片横向轮播组件
///
/// 接收 [cards] 列表渲染 PageView 大卡轮播。
/// - 卡片图区 1:1 正方形
/// - ≤1 张时降级为单卡居中显示
/// - 空列表由调用方处理（不会传入空列表）
class ValueCardCarousel extends StatelessWidget {
  final List<TCGCard> cards;

  /// 轮播可视占比（单张卡片占屏幕宽度比例）
  static const double _viewportFraction = 0.72;

  /// 信息栏高度
  static const double _infoBarHeight = 76.0;

  const ValueCardCarousel({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradeColors = Theme.of(context).extension<GradeColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    // 卡片实际宽度（减去水平 padding）
    final cardWidth = screenWidth * _viewportFraction - 8;
    // 1:1 正方形图片区
    final imageHeight = cardWidth / 1.2;
    // 轮播总高度 = 图片 + 信息栏 + Card 内边距余量
    final carouselHeight = imageHeight + _infoBarHeight + 28;

    if (cards.length <= 1) {
      return Center(
        child: SizedBox(
          width: cardWidth,
          height: carouselHeight,
          child: _buildCarouselCard(
              context, cards.first, colorScheme, gradeColors, imageHeight),
        ),
      );
    }

    return SizedBox(
      height: carouselHeight,
      child: PageView.builder(
        controller: PageController(viewportFraction: _viewportFraction),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCarouselCard(
                context, cards[index], colorScheme, gradeColors, imageHeight),
          );
        },
      ),
    );
  }

  Widget _buildCarouselCard(
    BuildContext context,
    TCGCard card,
    ColorScheme colorScheme,
    GradeColors gradeColors,
    double imageHeight,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardDetailPage(cardId: card.id!),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 上部：卡面图区 1:1 + 浮层徽章
            SizedBox(
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 卡面图（contain 全貌展示）
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: _buildCardImage(card.frontImage, colorScheme),
                  ),
                  // 评级徽章
                  if (card.grade.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildGradeBadge(
                          card.grade, colorScheme, gradeColors),
                    ),
                ],
              ),
            ),
            // 下部：信息栏
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 卡名
                  Text(
                    card.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // 副信息行：图鉴编号 · 发行编号
                  Text(
                    '#${card.pokedexNumber} · ${card.issueNumber}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // 价签 + 入手时间
                  Row(
                    children: [
                      Text(
                        '¥${card.currentPrice.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.secondary,
                                ),
                      ),
                      const Spacer(),
                      Text(
                        card.acquiredDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(String? frontImage, ColorScheme colorScheme) {
    if (frontImage != null && frontImage.isNotEmpty) {
      final file = File(frontImage);
      return Container(
        color: colorScheme.surfaceContainerLow,
        child: Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(colorScheme);
          },
        ),
      );
    }
    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.secondaryContainer,
      child: Center(
        child: Icon(
          Icons.credit_card,
          size: 40,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildGradeBadge(
    String grade,
    ColorScheme colorScheme,
    GradeColors gradeColors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _resolveGradeColor(grade, gradeColors),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Text(
        grade,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _resolveGradeColor(String grade, GradeColors gradeColors) {
    if (grade.contains('10')) return gradeColors.tier1;
    if (grade.contains('9')) return gradeColors.tier2;
    if (grade.contains('8')) return gradeColors.tier3;
    if (grade.contains('7')) return gradeColors.tier4;
    return gradeColors.tierDefault;
  }
}
