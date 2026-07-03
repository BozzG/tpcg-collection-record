import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/models/ptcg_project.dart';
import 'package:tpcg_collection_record/views/widgets/grade_badge.dart';
import 'package:tpcg_collection_record/views/widgets/rarity_halo.dart';

/// 海报内一张卡的数据（卡片 + 已解析好的正面图绝对路径）。
class PosterCardItem {
  const PosterCardItem({required this.card, this.imagePath});
  final TCGCard card;
  final String? imagePath;
}

/// 分享海报统一深色潮玩配色（不随 app 明暗变化，保证分享图观感一致）。
class _PosterPalette {
  static const Color bgTop = Color(0xFF14132E);
  static const Color bgBottom = Color(0xFF1B1A57);
  static const Color ink = Color(0xFFFFFFFF);
  static const Color inkSoft = Color(0xFFB6B5DC);
  static const Color money = Color(0xFFE67B3B);
  static const Color hair = Color(0x33FFFFFF);
}

String _today() {
  final n = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${n.year}-${two(n.month)}-${two(n.day)}';
}

Widget _posterImage(String? path, {BoxFit fit = BoxFit.cover}) {
  if (path == null) {
    return Container(
      color: const Color(0xFF24234A),
      child: const Center(
        child: Icon(Icons.credit_card, size: 40, color: _PosterPalette.inkSoft),
      ),
    );
  }
  return Image.file(File(path), fit: fit, errorBuilder: (_, __, ___) {
    return Container(
      color: const Color(0xFF24234A),
      child: const Center(
        child: Icon(Icons.broken_image,
            size: 40, color: _PosterPalette.inkSoft),
      ),
    );
  });
}

Widget _brandFooter() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          const Icon(Icons.style, size: 14, color: _PosterPalette.inkSoft),
          const SizedBox(width: 6),
          Text('TPCG 藏品记录',
              style: TextStyle(
                  color: _PosterPalette.inkSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
      Text(_today(),
          style: const TextStyle(
              color: _PosterPalette.inkSoft, fontSize: 12)),
    ],
  );
}

BoxDecoration _posterBg() => const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_PosterPalette.bgTop, _PosterPalette.bgBottom],
      ),
    );

/// 单卡展示卡海报：大卡图 + 稀有度光环 + 鉴定徽章 + 卡名/估值。
class CollectionPosterCard extends StatelessWidget {
  const CollectionPosterCard({
    super.key,
    required this.item,
    required this.width,
  });

  final PosterCardItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    final card = item.card;
    final pad = width * 0.07;
    final imgWidth = width * 0.66;

    return Container(
      width: width,
      decoration: _posterBg(),
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 品牌标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome,
                  size: 16, color: _PosterPalette.money),
              const SizedBox(width: 8),
              Text('我的珍藏',
                  style: TextStyle(
                      color: _PosterPalette.ink,
                      fontSize: width * 0.052,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2)),
            ],
          ),
          SizedBox(height: pad),

          // 大卡图 + 光环 + 评级徽章
          Center(
            child: SizedBox(
              width: imgWidth,
              child: RarityHalo(
                grade: card.grade,
                borderRadius: BorderRadius.circular(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 5 / 7,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _posterImage(item.imagePath),
                        if (card.grade.isNotEmpty)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: GradeBadge(grade: card.grade),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: pad),

          // 卡名
          Text(
            card.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: _PosterPalette.ink,
                fontSize: width * 0.062,
                fontWeight: FontWeight.w800),
          ),
          SizedBox(height: pad * 0.4),

          // 图鉴号 · 评级
          Text(
            '#${card.pokedexNumber}'
            '${card.grade.isNotEmpty ? '  ·  ${card.grade}' : ''}',
            style: TextStyle(
                color: _PosterPalette.inkSoft, fontSize: width * 0.038),
          ),
          SizedBox(height: pad * 0.7),

          // 估值
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: pad * 0.8, vertical: pad * 0.4),
            decoration: BoxDecoration(
              color: _PosterPalette.money.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _PosterPalette.money.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('当前估值  ',
                    style: TextStyle(
                        color: _PosterPalette.inkSoft,
                        fontSize: width * 0.038)),
                Text('¥${card.currentPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: _PosterPalette.money,
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          SizedBox(height: pad),

          const Divider(color: _PosterPalette.hair, height: 1),
          SizedBox(height: pad * 0.5),
          _brandFooter(),
        ],
      ),
    );
  }
}

/// 项目战绩海报：项目名 + 统计 + 卡片网格缩略。
class ProjectPosterCard extends StatelessWidget {
  const ProjectPosterCard({
    super.key,
    required this.project,
    required this.items,
    required this.width,
    this.maxThumbs = 9,
  });

  final TCGProject project;
  final List<PosterCardItem> items;
  final double width;
  final int maxThumbs;

  @override
  Widget build(BuildContext context) {
    final pad = width * 0.07;
    final totalValue =
        items.fold<double>(0, (sum, e) => sum + e.card.currentPrice);
    final thumbs = items.take(maxThumbs).toList();
    final extra = items.length - thumbs.length;

    return Container(
      width: width,
      decoration: _posterBg(),
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              const Icon(Icons.collections_bookmark,
                  size: 18, color: _PosterPalette.money),
              const SizedBox(width: 8),
              Expanded(
                child: Text(project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _PosterPalette.ink,
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          if (project.description.isNotEmpty) ...[
            SizedBox(height: pad * 0.3),
            Text(project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: _PosterPalette.inkSoft, fontSize: width * 0.036)),
          ],
          SizedBox(height: pad * 0.7),

          // 统计行
          Row(
            children: [
              _stat('藏品', '${items.length}', width),
              SizedBox(width: pad),
              _stat('总估值', '¥${totalValue.toStringAsFixed(2)}', width,
                  highlight: true),
            ],
          ),
          SizedBox(height: pad * 0.8),

          // 卡片网格缩略
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: thumbs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 5 / 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, i) {
              final isLast = i == thumbs.length - 1 && extra > 0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _posterImage(thumbs[i].imagePath),
                    if (isLast)
                      Container(
                        color: Colors.black.withValues(alpha: 0.55),
                        alignment: Alignment.center,
                        child: Text('+$extra',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: pad * 0.8),

          const Divider(color: _PosterPalette.hair, height: 1),
          SizedBox(height: pad * 0.5),
          _brandFooter(),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, double width,
      {bool highlight = false}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.04, vertical: width * 0.035),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _PosterPalette.hair),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: _PosterPalette.inkSoft, fontSize: width * 0.034)),
            SizedBox(height: width * 0.01),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: highlight
                        ? _PosterPalette.money
                        : _PosterPalette.ink,
                    fontSize: width * 0.052,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
