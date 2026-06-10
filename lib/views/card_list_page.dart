import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/models/sort_option.dart';
import 'package:tpcg_collection_record/viewmodels/card_viewmodel.dart';
import 'package:tpcg_collection_record/views/card_detail_page.dart';
import 'package:tpcg_collection_record/views/edit_card_page.dart';
import 'package:tpcg_collection_record/views/widgets/card_thumbnail.dart';
import 'package:tpcg_collection_record/views/widgets/card_wall_tile.dart';
import 'package:tpcg_collection_record/views/widgets/micro_interactions.dart';
import 'package:tpcg_collection_record/views/widgets/showcase_background.dart';

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardViewModel>().loadAllCards();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卡片列表'),
        actions: [
          Consumer<CardViewModel>(
            builder: (context, viewModel, _) {
              final isWall = viewModel.viewMode == CardViewMode.wall;
              return IconButton(
                icon: Icon(isWall ? Icons.view_agenda_outlined : Icons.grid_view),
                tooltip: isWall ? '切换为列表' : '切换为卡墙',
                onPressed: viewModel.toggleViewMode,
              );
            },
          ),
        ],
      ),
      body: Consumer<CardViewModel>(
        builder: (context, viewModel, child) {
          final colorScheme = Theme.of(context).colorScheme;
          return ShowcaseBackground(
            child: Column(
            children: [
              // 搜索栏
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索卡片名称或编号...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: viewModel.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.clearSearch();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    viewModel.searchCards(value);
                  },
                ),
              ),

              // 筛选条
              _buildFilterBar(context, viewModel),

              // 排序提示
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '按${viewModel.sortLabel}排序',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    if (viewModel.hasActiveFilters)
                      TextButton(
                        onPressed: () {
                          viewModel.clearAllFilters();
                          _searchController.clear();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('清除筛选', style: TextStyle(fontSize: 11)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 卡片展示区：卡墙 / 列表 双形态
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.cards.isEmpty
                        ? _buildEmptyState(context, viewModel, colorScheme)
                        : viewModel.viewMode == CardViewMode.wall
                            ? _buildWall(context, viewModel)
                            : _buildList(context, viewModel, colorScheme),
              ),
            ],
            ),
          );
        },
      ),
    );
  }

  /// 空态占位
  Widget _buildEmptyState(
      BuildContext context, CardViewModel viewModel, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.searchQuery.isEmpty && !viewModel.hasActiveFilters
                ? '还没有添加任何卡片'
                : '没有找到匹配的卡片',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  /// 卡墙陈列：2 列竖版大图（SF1）
  Widget _buildWall(BuildContext context, CardViewModel viewModel) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 5 / 7,
      ),
      itemCount: viewModel.cards.length,
      itemBuilder: (context, index) {
        final card = viewModel.cards[index];
        return EntranceFader(
          index: index,
          child: CardWallTile(
            card: card,
            onTap: () => _openDetail(context, card.id!),
            onEdit: () => _openEdit(context, card, viewModel),
            onDelete: () => _showDeleteDialog(context, card.id!, viewModel),
          ),
        );
      },
    );
  }

  /// 列表形态：信息密集，便于检索
  Widget _buildList(
      BuildContext context, CardViewModel viewModel, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.cards.length,
      itemBuilder: (context, index) {
        final card = viewModel.cards[index];
        return EntranceFader(
          index: index,
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Hero(
                tag: cardHeroTag(card.id),
                child: CardThumbnail(frontImage: card.frontImage),
              ),
              title: Text(
                card.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('图鉴编号: #${card.pokedexNumber}'),
                  Text('发行编号: ${card.issueNumber}'),
                  Text('评级: ${card.grade}'),
                  Text('入手时间: ${card.acquiredDate}'),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${card.currentPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openEdit(context, card, viewModel);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, card.id!, viewModel);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
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
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              onTap: () => _openDetail(context, card.id!),
            ),
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, int cardId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardDetailPage(cardId: cardId),
      ),
    );
  }

  Future<void> _openEdit(
      BuildContext context, TCGCard card, CardViewModel viewModel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCardPage(card: card),
      ),
    );
    if (result == true && context.mounted) {
      viewModel.loadAllCards();
    }
  }

  Widget _buildFilterBar(BuildContext context, CardViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          // 评级筛选
          FilterChip(
            label: Text(viewModel.selectedGrades.isEmpty
                ? '评级'
                : '评级 (${viewModel.selectedGrades.length})'),
            selected: viewModel.selectedGrades.isNotEmpty,
            onSelected: (_) => _showGradeFilterDialog(context, viewModel),
            selectedColor: colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: viewModel.selectedGrades.isNotEmpty
                  ? colorScheme.onPrimaryContainer
                  : null,
            ),
          ),
          // 项目筛选
          FilterChip(
            label: Text(viewModel.selectedProjectIds.isEmpty
                ? '项目'
                : '项目 (${viewModel.selectedProjectIds.length})'),
            selected: viewModel.selectedProjectIds.isNotEmpty,
            onSelected: (_) => _showProjectFilterDialog(context, viewModel),
            selectedColor: colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: viewModel.selectedProjectIds.isNotEmpty
                  ? colorScheme.onPrimaryContainer
                  : null,
            ),
          ),
          // 排序方式
          FilterChip(
            label: Text(viewModel.sortLabel),
            selected: viewModel.sortOption != SortOption.pokedexAsc,
            onSelected: (_) => _showSortDialog(context, viewModel),
            selectedColor: colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: viewModel.sortOption != SortOption.pokedexAsc
                  ? colorScheme.onPrimaryContainer
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showGradeFilterDialog(BuildContext context, CardViewModel viewModel) {
    final grades = viewModel.availableGrades;
    final selected = Set<String>.from(viewModel.selectedGrades);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('选择评级'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: grades.map((grade) {
                    return CheckboxListTile(
                      title: Text(grade),
                      value: selected.contains(grade),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selected.add(grade);
                          } else {
                            selected.remove(grade);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    selected.clear();
                    setState(() {});
                  },
                  child: const Text('清除'),
                ),
                TextButton(
                  onPressed: () {
                    viewModel.setGradeFilter(selected);
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProjectFilterDialog(BuildContext context, CardViewModel viewModel) {
    final projects = viewModel.availableProjects;
    final selected = Set<int>.from(viewModel.selectedProjectIds);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('选择项目'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: projects.map((entry) {
                    return CheckboxListTile(
                      title: Text(entry.value),
                      value: selected.contains(entry.key),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selected.add(entry.key);
                          } else {
                            selected.remove(entry.key);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    selected.clear();
                    setState(() {});
                  },
                  child: const Text('清除'),
                ),
                TextButton(
                  onPressed: () {
                    viewModel.setProjectFilter(selected);
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSortDialog(BuildContext context, CardViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('排序方式'),
          children: SortOption.values.map((option) {
            return SimpleDialogOption(
              onPressed: () {
                viewModel.setSortOption(option);
                Navigator.of(context).pop();
              },
              child: Row(
                children: [
                  Icon(
                    viewModel.sortOption == option
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: viewModel.sortOption == option
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(option.label),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int cardId, CardViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这张卡片吗？此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await viewModel.deleteCard(cardId);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('卡片删除成功')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除失败，请重试')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}
