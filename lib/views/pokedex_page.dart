import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/theme/app_theme.dart';
import 'package:tpcg_collection_record/utils/grade_utils.dart';
import 'package:tpcg_collection_record/utils/pokedex_generations.dart';
import 'package:tpcg_collection_record/viewmodels/pokedex_viewmodel.dart';
import 'package:tpcg_collection_record/views/pokedex_number_detail_page.dart';
import 'package:tpcg_collection_record/views/widgets/image_file_widget.dart';
import 'package:tpcg_collection_record/views/widgets/rarity_halo.dart';
import 'package:tpcg_collection_record/views/widgets/showcase_background.dart';

/// 图鉴收集页：全国总进度 + 九世代分段网格。
///
/// 已拥有格点亮（封面缩略图 + 评级色描边），未拥有格灰显；两者均显示
/// 「#编号 + 中文名」。点击已拥有格进入该编号详情。数据来自
/// [PokedexViewModel]（应用级 Provider），进入时刷新以反映最新卡片。
class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});

  @override
  State<PokedexPage> createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  /// 已折叠世代的索引集合（对应 [kGenerations] 的 list index）。
  /// 默认空集 = 全部展开；仅内存维护，退出页面即重置（不持久化）。
  final Set<int> _collapsedGenerations = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokedexViewModel>().load();
    });
  }

  /// 切换指定世代的折叠/展开状态。
  void _toggleGeneration(int index) {
    setState(() {
      if (!_collapsedGenerations.remove(index)) {
        _collapsedGenerations.add(index);
      }
    });
  }

  int _crossAxisCount(double width) {
    if (width >= 900) return 6;
    if (width >= 600) return 4;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图鉴收集')),
      body: Consumer<PokedexViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const ShowcaseBackground(
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final crossAxisCount =
              _crossAxisCount(MediaQuery.of(context).size.width);
          return ShowcaseBackground(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _NationalProgress(vm: vm)),
                for (var i = 0; i < kGenerations.length; i++)
                  ..._buildGenerationSlivers(
                    context,
                    vm,
                    kGenerations[i],
                    crossAxisCount,
                    index: i,
                    collapsed: _collapsedGenerations.contains(i),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildGenerationSlivers(
    BuildContext context,
    PokedexViewModel vm,
    PokedexGeneration gen,
    int crossAxisCount, {
    required int index,
    required bool collapsed,
  }) {
    final progress = vm.progressOf(gen);
    final entries = vm.entriesOf(gen);
    return [
      SliverToBoxAdapter(
        child: _GenerationHeader(
          title: gen.title,
          owned: progress.owned,
          total: progress.total,
          collapsed: collapsed,
          onToggle: () => _toggleGeneration(index),
        ),
      ),
      // 折叠时不构建该世代网格：既让后续世代标题上移，
      // 也避免大量格子进入 widget 树（滚动更轻）。
      if (!collapsed)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = entries[index];
                return _PokedexCell(
                  entry: entry,
                  onTap: entry.owned
                      ? () => _openDetail(context, entry.number)
                      : null,
                );
              },
              childCount: entries.length,
            ),
          ),
        ),
    ];
  }

  void _openDetail(BuildContext context, int number) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokedexNumberDetailPage(number: number),
      ),
    );
  }
}

/// 全国总进度卡片。
class _NationalProgress extends StatelessWidget {
  const _NationalProgress({required this.vm});

  final PokedexViewModel vm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pct = (vm.collectedRatio * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.catching_pokemon,
                    size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('全国图鉴',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$pct%',
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('${vm.collectedCount}',
                    style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 30,
                        fontWeight: FontWeight.w900)),
                Text(' / ${vm.totalCount}',
                    style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: vm.collectedRatio,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 世代分段标题：可点击折叠/展开该世代网格，右侧箭头指示当前状态。
class _GenerationHeader extends StatelessWidget {
  const _GenerationHeader({
    required this.title,
    required this.owned,
    required this.total,
    required this.collapsed,
    required this.onToggle,
  });

  final String title;
  final int owned;
  final int total;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('$owned/$total',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              // collapsed=true 时箭头指向右（收起），展开时旋转朝下。
              AnimatedRotation(
                turns: collapsed ? -0.25 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.expand_more,
                  size: 22,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 图鉴单格：已拥有点亮封面 + 评级色描边；未拥有灰显。均显「#编号 + 中文名」。
class _PokedexCell extends StatelessWidget {
  const _PokedexCell({required this.entry, this.onTap});

  final PokedexEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradeColors = Theme.of(context).extension<GradeColors>()!;
    final owned = entry.owned;

    final borderColor = owned
        ? GradeUtils.tierColor(entry.cover!.grade, gradeColors)
        : colorScheme.outlineVariant;

    final Widget content = Container(
      decoration: BoxDecoration(
        color: owned ? colorScheme.surface : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: owned ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: owned
                ? ImageFileWidget(
                    imageRef: entry.cover!.frontImage,
                    fit: BoxFit.cover,
                    placeholder: _ownedPlaceholder(colorScheme),
                  )
                : _unownedArtwork(colorScheme),
          ),
          _label(context, colorScheme, owned),
        ],
      ),
    );

    final Widget cell = owned
        ? RarityHalo(
            grade: entry.cover!.grade,
            borderRadius: BorderRadius.circular(12),
            child: content,
          )
        : content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: cell,
      ),
    );
  }

  Widget _label(BuildContext context, ColorScheme colorScheme, bool owned) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      color: owned
          ? colorScheme.surface
          : colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#${entry.number}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            entry.zhName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  owned ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: owned ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ownedPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.secondaryContainer,
      child: Center(
        child: Icon(Icons.credit_card,
            size: 28, color: colorScheme.onSecondaryContainer),
      ),
    );
  }

  Widget _unownedArtwork(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.catching_pokemon,
          size: 30,
          color: colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
