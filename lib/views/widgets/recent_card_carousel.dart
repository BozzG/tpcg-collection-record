import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/views/card_detail_page.dart';
import 'package:tpcg_collection_record/theme/app_theme.dart';

/// 最近添加卡片横向轮播组件
///
/// 接收 [cards] 列表渲染 PageView 大卡轮播。
/// - ≤1 张时降级为单卡居中显示
/// - 空列表由调用方处理（不会传入空列表）
class RecentCardCarousel extends StatelessWidget {
  final List<TCGCard> cards;

  const RecentCardCarousel({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradeColors = Theme.of(context).extension<GradeColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    if (cards.length <= 1) {
      return _buildSingleCard(
          context, cards.first, colorScheme, gradeColors, screenWidth);
    }

    return SizedBox(
      height: 256,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.82),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCarouselCard(
                context, cards[index], colorScheme, gradeColors),
          );
        },
      ),
    );
  }

  Widget _buildSingleCard(
    BuildContext context,
    TCGCard card,
    ColorScheme colorScheme,
    GradeColors gradeColors,
    double screenWidth,
  ) {
    return Center(
      child: SizedBox(
        width: screenWidth * 0.82,
        height: 256,
        child: _buildCarouselCard(context, card, colorScheme, gradeColors),
      ),
    );
  }

  Widget _buildCarouselCard(
    BuildContext context,
    TCGCard card,
    ColorScheme colorScheme,
    GradeColors gradeColors,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardDetailPage(cardId: card.id!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 上部：卡面图区 + 浮层徽章
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 卡面图
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
            // 下部：信息区
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    // 副信息行
                    Text(
                      '#${card.pokedexNumber} · ${card.issueNumber}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // 价签 + 日期
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(String? frontImage, ColorScheme colorScheme) {
    if (frontImage != null && frontImage.isNotEmpty) {
      final file = File(frontImage);
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(colorScheme);
        },
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
          width: 1.5,
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
