import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/viewmodels/home_viewmodel.dart';
import 'package:tpcg_collection_record/viewmodels/theme_notifier.dart';
import 'package:tpcg_collection_record/views/card_list_page.dart';
import 'package:tpcg_collection_record/views/project_list_page.dart';
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
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: viewModel.refresh,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(
      BuildContext context, HomeViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '收藏统计',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: MediaQuery.of(context).size.width > 400 ? 1.7 : 1.5,
          children: [
            _buildStatCard(
              context,
              title: '卡片数',
              value: viewModel.cardCount.toString(),
              icon: Icons.credit_card,
              color: colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardListPage()),
                );
              },
            ),
            _buildStatCard(
              context,
              title: '项目数',
              value: viewModel.projectCount.toString(),
              icon: Icons.folder,
              color: colorScheme.tertiary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProjectListPage()),
                );
              },
            ),
            _buildStatCard(
              context,
              title: '总价值',
              value: '¥${viewModel.totalValue.toStringAsFixed(2)}',
              icon: Icons.trending_up,
              color: colorScheme.secondary,
              onTap: null,
            ),
            _buildStatCard(
              context,
              title: '总花费',
              value: '¥${viewModel.totalCost.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet,
              color: colorScheme.onSurface,
              onTap: null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14,
                      ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopValueCardsSection(
      BuildContext context, HomeViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最高价值',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (viewModel.topValueCards.isEmpty)
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
          ValueCardCarousel(cards: viewModel.topValueCards),
      ],
    );
  }
}
