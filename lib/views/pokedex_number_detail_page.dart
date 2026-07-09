import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/viewmodels/pokedex_viewmodel.dart';
import 'package:tpcg_collection_record/views/card_detail_page.dart';
import 'package:tpcg_collection_record/views/widgets/card_thumbnail.dart';
import 'package:tpcg_collection_record/views/widgets/grade_badge.dart';
import 'package:tpcg_collection_record/views/widgets/showcase_background.dart';

/// 某图鉴编号下的全部卡列表。
///
/// 顶部展示「#编号 + 中文名 + 收藏张数」，下方列出该编号所有卡（按封面
/// 优先级排序，默认封面在首位）。每张卡可「设为封面」并持久化；已是当前
/// 封面的卡标注「封面」。存在手动封面时提供「恢复默认」。
class PokedexNumberDetailPage extends StatelessWidget {
  const PokedexNumberDetailPage({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Consumer<PokedexViewModel>(
      builder: (context, vm, _) {
        final cards = vm.cardsOf(number);
        final cover = vm.coverOf(number);
        final hasManual = vm.manualCoverId(number) != null;

        return Scaffold(
          appBar: AppBar(
            title: Text('#$number ${vm.nameOf(number)}'),
            actions: [
              if (hasManual)
                TextButton(
                  onPressed: () => _restoreDefault(context, vm),
                  child: const Text('恢复默认'),
                ),
            ],
          ),
          body: ShowcaseBackground(
            child: cards.isEmpty
                ? _empty(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cards.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _header(context, cards.length);
                      }
                      final card = cards[index - 1];
                      final isCover = cover?.id == card.id;
                      return _CardRow(
                        card: card,
                        isCover: isCover,
                        onOpen: () => _openCardDetail(context, card.id!),
                        onSetCover: isCover
                            ? null
                            : () => _setCover(context, vm, card),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.style, size: 18, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text('共收藏 $count 张',
              style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.catching_pokemon, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text('该编号暂未收藏卡片',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
        ],
      ),
    );
  }

  void _openCardDetail(BuildContext context, int cardId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardDetailPage(cardId: cardId)),
    );
  }

  Future<void> _setCover(
      BuildContext context, PokedexViewModel vm, TCGCard card) async {
    await vm.setManualCover(number, card.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已将「${card.name}」设为该图鉴封面')),
      );
    }
  }

  Future<void> _restoreDefault(
      BuildContext context, PokedexViewModel vm) async {
    await vm.clearManualCover(number);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已恢复默认封面（评级最高 / 最近入手）')),
      );
    }
  }
}

/// 单张卡行：缩略图 + 信息 + 封面标记/设为封面。
class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.card,
    required this.isCover,
    required this.onOpen,
    this.onSetCover,
  });

  final TCGCard card;
  final bool isCover;
  final VoidCallback onOpen;
  final VoidCallback? onSetCover;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCover
            ? BorderSide(color: colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardThumbnail(frontImage: card.frontImage, height: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCover)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('封面',
                              style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (card.grade.isNotEmpty)
                    GradeBadge(grade: card.grade, compact: true),
                  const SizedBox(height: 6),
                  Text('入手：${card.acquiredDate}',
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  Text('现价：¥${card.currentPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('详情'),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: onSetCover,
                        icon: Icon(
                          isCover ? Icons.star : Icons.star_border,
                          size: 16,
                        ),
                        label: Text(isCover ? '当前封面' : '设为封面'),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
}
