import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/viewmodels/home_viewmodel.dart';
import 'package:tpcg_collection_record/views/card_list_page.dart';
import 'package:tpcg_collection_record/views/project_list_page.dart';
import 'package:tpcg_collection_record/views/card_detail_page.dart';

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

                    // 最近添加的卡片
                    _buildRecentCardsSection(context, viewModel),
                    
                    // 添加底部安全间距
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '收藏统计',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: MediaQuery.of(context).size.width > 400 ? 1.5 : 1.3,
          children: [
            _buildStatCard(
              context,
              title: '卡片数',
              value: viewModel.cardCount.toString(),
              icon: Icons.credit_card,
              color: Colors.blue,
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
              color: Colors.green,
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
              color: Colors.orange,
              onTap: null,
            ),
            _buildStatCard(
              context,
              title: '总花费',
              value: '¥${viewModel.totalCost.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet,
              color: Colors.red,
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
                size: 28,
                color: color,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
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

  Widget _buildRecentCardsSection(
      BuildContext context, HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近添加',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (viewModel.recentCards.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.credit_card_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '还没有添加任何卡片',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.recentCards.length,
            itemBuilder: (context, index) {
              final card = viewModel.recentCards[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.credit_card,
                      color: Colors.blue[800],
                    ),
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
                    ],
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '¥${card.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            card.acquiredDate,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardDetailPage(cardId: card.id!),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
