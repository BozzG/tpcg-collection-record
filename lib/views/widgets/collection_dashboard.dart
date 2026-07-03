import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/theme/app_theme.dart';
import 'package:tpcg_collection_record/utils/grade_utils.dart';

/// 首页藏品仪表盘：总价值 Hero 区 + 收益涨跌 + 评级分布迷你条形。
///
/// 仅基于当下快照数据（不依赖历史）。深色 Hero 卡固定潮玩配色，
/// 保证明暗模式下观感一致；下方迷你指标与分布条沿用主题 token。
class CollectionDashboard extends StatelessWidget {
  const CollectionDashboard({
    super.key,
    required this.totalValue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitRate,
    required this.cardCount,
    required this.projectCount,
    required this.gradeTierCounts,
    this.onTapCards,
    this.onTapProjects,
  });

  final double totalValue;
  final double totalCost;
  final double totalProfit;
  final double profitRate;
  final int cardCount;
  final int projectCount;
  final Map<GradeTier, int> gradeTierCounts;
  final VoidCallback? onTapCards;
  final VoidCallback? onTapProjects;

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
        const SizedBox(height: 18),
        _buildGradeDistribution(context),
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
        const SizedBox(width: 10),
        _miniStat(context,
            label: '项目数',
            value: '$projectCount',
            icon: Icons.folder,
            onTap: onTapProjects),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outline, width: 1.0),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(Icons.chevron_right,
                      size: 18, color: colorScheme.onSurfaceVariant),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeDistribution(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradeColors = Theme.of(context).extension<GradeColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final total = gradeTierCounts.values.fold<int>(0, (s, v) => s + v);

    // 按稀有度从高到低排列，仅展示有数据的档位
    const order = [
      GradeTier.black10,
      GradeTier.gold10,
      GradeTier.ten,
      GradeTier.nine,
      GradeTier.eight,
      GradeTier.other,
    ];
    final tiers =
        order.where((t) => (gradeTierCounts[t] ?? 0) > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('评级分布',
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (total == 0)
          Text('暂无评级数据',
              style: TextStyle(
                  color: colorScheme.onSurfaceVariant, fontSize: 13))
        else
          ...tiers.map((tier) {
            final count = gradeTierCounts[tier] ?? 0;
            final ratio = count / total;
            final color = GradeUtils.tierColorOf(tier, gradeColors);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(GradeUtils.tierLabel(tier),
                        style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          Container(
                            height: 12,
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio.clamp(0.04, 1.0),
                            child: Container(height: 12, color: color),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 28,
                    child: Text('$count',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
