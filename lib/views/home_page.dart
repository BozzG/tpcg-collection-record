import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/viewmodels/home_viewmodel.dart';
import 'package:tpcg_collection_record/viewmodels/theme_notifier.dart';
import 'package:tpcg_collection_record/views/backup_page.dart';
import 'package:tpcg_collection_record/views/card_list_page.dart';
import 'package:tpcg_collection_record/views/project_list_page.dart';
import 'package:tpcg_collection_record/views/widgets/collection_dashboard.dart';
import 'package:tpcg_collection_record/views/widgets/showcase_background.dart';
import 'package:tpcg_collection_record/views/widgets/skeleton_loader.dart';
import 'package:tpcg_collection_record/views/widgets/value_card_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TPCG 收藏记录'),
        leading: Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, _) {
            final isDark = themeNotifier.isDark;
            return IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: isDark ? '切换到浅色模式' : '切换到深色模式',
              onPressed: () => themeNotifier.toggle(),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup_outlined),
            tooltip: '数据备份',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackupPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '联系我',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('联系我'),
                    content: const Text(
                      '如果对这个APP有任何建议，请联系bozzguo@qq.com。',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const ShowcaseBackground(child: HomeSkeleton());
            }

            return RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: ShowcaseBackground(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 统计卡片区域
                      _buildStatisticsSection(context, viewModel),
                      const SizedBox(height: 24),

                      // 高价值卡片
                      _buildTopValueCardsSection(context, viewModel),

                      // 添加底部安全间距
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(
      BuildContext context, HomeViewModel viewModel) {
    return CollectionDashboard(
      totalValue: viewModel.totalValue,
      totalCost: viewModel.totalCost,
      totalProfit: viewModel.totalProfit,
      profitRate: viewModel.profitRate,
      cardCount: viewModel.cardCount,
      projectCount: viewModel.projectCount,
      gradeTierCounts: viewModel.gradeTierCounts,
      onTapCards: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CardListPage()),
        );
      },
      onTapProjects: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProjectListPage()),
        );
      },
    );
  }

  Widget _buildTopValueCardsSection(
      BuildContext context, HomeViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final cards = viewModel.carouselCards;
    // 下一种模式（仅二选一时简单切换；未来扩展可改为按枚举顺序循环）
    final nextMode = viewModel.carouselMode == CarouselMode.topValue
        ? CarouselMode.recentAcquired
        : CarouselMode.topValue;
    final nextLabel = nextMode == CarouselMode.topValue ? '最高价值' : '最新入手';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题即开关：整个标题区域可点击切换排序模式，与「收藏统计」标题视觉对齐
        InkWell(
          onTap: () => viewModel.setCarouselMode(nextMode),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Tooltip(
              message: '点击切换为「$nextLabel」',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      viewModel.carouselTitle,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.swap_vert,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (cards.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.credit_card_off,
                      size: 48,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '还没有添加任何卡片',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ValueCardCarousel(cards: cards),
      ],
    );
  }
}
