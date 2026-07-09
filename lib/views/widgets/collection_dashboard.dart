import 'package:flutter/material.dart';

/// 首页藏品仪表盘：总价值 Hero 区 + 收益涨跌 + 卡片/项目迷你指标。
///
/// 仅基于当下快照数据（不依赖历史）。深色 Hero 卡固定潮玩配色，
/// 保证明暗模式下观感一致；下方迷你指标沿用主题 token。
/// 设计目标：整块高度紧凑，配合下方轮播实现首页免滚动一屏可见。
class CollectionDashboard extends StatelessWidget {
  const CollectionDashboard({
    super.key,
    required this.totalValue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitRate,
    required this.cardCount,
    required this.projectCount,
    required this.pokedexCollected,
    required this.pokedexTotal,
    this.onTapCards,
    this.onTapProjects,
    this.onTapPokedex,
  });

  final double totalValue;
  final double totalCost;
  final double totalProfit;
  final double profitRate;
  final int cardCount;
  final int projectCount;
  final int pokedexCollected;
  final int pokedexTotal;
  final VoidCallback? onTapCards;
  final VoidCallback? onTapProjects;
  final VoidCallback? onTapPokedex;

  // Hero 卡固定潮玩深色
  static const Color _heroTop = Color(0xFF14132E);
  static const Color _heroBottom = Color(0xFF1B1A57);
  static const Color _heroInk = Color(0xFFFFFFFF);
  static const Color _heroInkSoft = Color(0xFFB6B5DC);
  static const Color _up = Color(0xFF4ADE80);
  static const Color _down = Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '收藏概览',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildHeroValueCard(context),
        const SizedBox(height: 12),
        _buildMiniStatsRow(context),
      ],
    );
  }

  Widget _buildHeroValueCard(BuildContext context) {
    final bool isUp = totalProfit > 0;
    final bool isFlat = totalProfit == 0;
    final Color profitColor = isFlat
        ? _heroInkSoft
        : (isUp ? _up : _down);
    final IconData profitIcon = isFlat
        ? Icons.trending_flat
        : (isUp ? Icons.trending_up : Icons.trending_down);
    final String sign = isUp ? '+' : (isFlat ? '' : '-');
    final String ratePct =
        '${(profitRate * 100).abs().toStringAsFixed(1)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_heroTop, _heroBottom],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF060606)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet,
                  size: 16, color: _heroInkSoft),
              const SizedBox(width: 6),
              Text('藏品总价值',
                  style: TextStyle(color: _heroInkSoft, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '¥${totalValue.toStringAsFixed(2)}',
              style: const TextStyle(
                color: _heroInk,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(profitIcon, size: 18, color: profitColor),
              const SizedBox(width: 6),
              Text(
                '$sign¥${totalProfit.abs().toStringAsFixed(2)}',
                style: TextStyle(
                    color: profitColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              if (!isFlat || totalCost > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: profitColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$sign$ratePct',
                      style: TextStyle(
                          color: profitColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              const Spacer(),
              Text('成本 ¥${totalCost.toStringAsFixed(0)}',
                  style: TextStyle(color: _heroInkSoft, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatsRow(BuildContext context) {
    return Row(
      children: [
        _miniStat(context,
            label: '卡片数',
            value: '$cardCount',
            icon: Icons.credit_card,
            onTap: onTapCards),
        const SizedBox(width: 8),
        _miniStat(context,
            label: '项目数',
            value: '$projectCount',
            icon: Icons.folder,
            onTap: onTapProjects),
        const SizedBox(width: 8),
        _miniStat(context,
            label: '图鉴',
            value: '$pokedexCollected/$pokedexTotal',
            icon: Icons.catching_pokemon,
            onTap: onTapPokedex),
      ],
    );
  }

  Widget _miniStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outline, width: 1.0),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12)),
                      const SizedBox(height: 2),
                      // 三列并排时数值可能较长（如「320/1025」），
                      // 用 FittedBox 缩放避免小屏溢出。
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(value,
                            maxLines: 1,
                            style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
