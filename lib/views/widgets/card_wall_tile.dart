import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/views/widgets/grade_badge.dart';
import 'package:tpcg_collection_record/views/widgets/image_file_widget.dart';
import 'package:tpcg_collection_record/views/widgets/micro_interactions.dart';
import 'package:tpcg_collection_record/views/widgets/rarity_halo.dart';

/// 全局统一的卡面 Hero 过渡标签，保证列表/卡墙 → 详情的飞入动画连贯。
String cardHeroTag(int? id) => 'cardHero_${id ?? 'unknown'}';

/// 卡墙陈列单元：竖版大图（5:7 仿实体卡）+ 评级徽章 + 底部渐变信息条，
/// 整体可点进入详情（Hero 飞入），右上角提供编辑/删除菜单。
class CardWallTile extends StatelessWidget {
  const CardWallTile({
    super.key,
    required this.card,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final TCGCard card;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PressableScale(
      onTap: onTap,
      child: RarityHalo(
        grade: card.grade,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outline, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                offset: const Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 5 / 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 卡面图（Hero 飞入详情）
                Hero(
                  tag: cardHeroTag(card.id),
                  child: _buildImage(context, colorScheme),
                ),

                // 卡套反光高光（实体感）
                const Positioned.fill(child: _CardGloss()),

                // 底部渐变 + 信息条
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildInfoBar(context, colorScheme),
                ),

                // 评级鉴定标签
                if (card.grade.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GradeBadge(grade: card.grade, compact: true),
                  ),

                // 编辑/删除菜单
                Positioned(
                  top: 2,
                  right: 2,
                  child: _buildMenu(context, colorScheme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, ColorScheme colorScheme) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return Container(
      color: colorScheme.surfaceContainerLow,
      child: ImageFileWidget(
        imageRef: card.frontImage,
        fit: BoxFit.cover,
        // 2 列大图按屏宽一半解码，控制内存占用
        cacheWidth: (MediaQuery.of(context).size.width / 2 * dpr).toInt(),
        placeholder: Container(
          color: colorScheme.secondaryContainer,
          child: Center(
            child: Icon(
              Icons.credit_card,
              size: 40,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            card.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                '#${card.pokedexNumber}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                '¥${card.currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context, ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      tooltip: '更多操作',
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('编辑'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: colorScheme.error),
              const SizedBox(width: 8),
              Text('删除', style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}

/// 卡套反光高光：左上→中心的极轻线性高光，模拟卡进卡砖的反光质感。
class _CardGloss extends StatelessWidget {
  const _CardGloss();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.14),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
