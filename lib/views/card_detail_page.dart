import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/viewmodels/card_viewmodel.dart';
import 'package:tpcg_collection_record/views/edit_card_page.dart';

class CardDetailPage extends StatefulWidget {
  final int cardId;

  const CardDetailPage({super.key, required this.cardId});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  PTCGCard? card;
  String? projectName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 推迟到下一帧执行，避免在构建过程中调用setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCard();
    });
  }

  Future<void> _loadCard() async {
    final cardViewModel = context.read<CardViewModel>();
    final loadedCard = await cardViewModel.getCardById(widget.cardId);
    final loadedProjectName =
        await cardViewModel.getProjectNameByCardId(widget.cardId);
    if (mounted) {
      setState(() {
        card = loadedCard;
        projectName = loadedProjectName;
        isLoading = false;
      });
    }
  }

  /// 显示全屏图片预览
  void _showFullScreenImage(
      BuildContext context, String imagePath, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenImageViewer(
          imagePath: imagePath,
          title: title,
          cardName: card!.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('卡片详情'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (card == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('卡片详情'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Text('卡片不存在'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(card!.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCardPage(card: card!),
                ),
              );
              if (result == true && mounted) {
                _loadCard(); // 重新加载卡片数据
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 卡片图片区域
            _buildImageSection(),

            // 卡片基本信息
            _buildBasicInfoSection(),

            // 卡片详细信息
            _buildDetailInfoSection(),

            // 价值信息
            _buildValueInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[100],
      child: PageView(
        children: [
          // 正面图片
          if (card!.frontImage != null && card!.frontImage!.isNotEmpty)
            _buildImageCard('正面', card!.frontImage!),
          if (card!.frontImage == null || card!.frontImage!.isEmpty)
            _buildPlaceholderCard('正面'),
          // 背面图片
          if (card!.backImage != null && card!.backImage!.isNotEmpty)
            _buildImageCard('背面', card!.backImage!),
          // 评级图片
          if (card!.gradeImage != null && card!.gradeImage!.isNotEmpty)
            _buildImageCard('评级', card!.gradeImage!),
        ],
      ),
    );
  }

  Widget _buildImageCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imagePath, title),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('图片加载失败', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // 添加点击提示图标
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(String title) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[100],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('暂无图片', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'CCIC 金10':
      case 'CGC 金10':
      case 'BGS 黑10':
        return Colors.black;
      case 'PSA 10':
      case 'BGS 10':
      case 'CCIC 银10':
      case 'CGC 10':
        return Colors.purple;
      case 'PSA 9':
      case 'BGS 9':
      case 'CCIC 9':
      case 'CGC 9':
        return Colors.blue;
      case 'PSA 8':
      case 'BGS 8':
      case 'CCIC 8':
      case 'CGC 8':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card!.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getGradeColor(card!.grade).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getGradeColor(card!.grade),
                    width: 1,
                  ),
                ),
                child: Text(
                  card!.grade,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getGradeColor(card!.grade),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                '¥${card!.currentPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '详细信息',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('所属项目', projectName ?? '未知项目'),
              _buildInfoRow('发行编号', card!.issueNumber),
              _buildInfoRow('发行时间', card!.issueDate),
              _buildInfoRow('评级', card!.grade),
              _buildInfoRow('入手时间', card!.acquiredDate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueCardModel(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  int _calculateHoldingDays(String acquiredDate) {
    try {
      final acquired = DateTime.parse(acquiredDate);
      final now = DateTime.now();
      return now.difference(acquired).inDays;
    } catch (e) {
      return 0;
    }
  }

  Map<String, dynamic> _calculatePriceChange() {
    if (card!.acquiredPrice <= 0) {
      return {
        'percentage': '0.00%',
        'isPositive': true,
        'icon': Icons.trending_flat,
        'color': Colors.grey,
      };
    }

    final change = card!.currentPrice - card!.acquiredPrice;
    final percentage = (change / card!.acquiredPrice) * 100;

    final isPositive = percentage >= 0;
    final sign = isPositive ? '+' : '';

    return {
      'percentage': '$sign${percentage.toStringAsFixed(2)}%',
      'isPositive': isPositive,
      'icon': isPositive
          ? (percentage > 0 ? Icons.trending_up : Icons.trending_flat)
          : Icons.trending_down,
      'color': isPositive
          ? (percentage > 0 ? Colors.green : Colors.grey)
          : Colors.red,
    };
  }

  Widget _buildValueInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '价值信息',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildValueCardModel(
                      context,
                      '入手价格',
                      '¥${card!.acquiredPrice.toStringAsFixed(2)}',
                      Icons.shopping_cart,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildValueCardModel(
                      context,
                      '当前估值',
                      '¥${card!.currentPrice.toStringAsFixed(2)}',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final priceChange = _calculatePriceChange();
                        return _buildValueCardModel(
                          context,
                          '涨幅',
                          priceChange['percentage'],
                          priceChange['icon'],
                          priceChange['color'],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildValueCardModel(
                      context,
                      '持有天数',
                      _calculateHoldingDays(card!.acquiredDate).toString(),
                      Icons.calendar_today,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 全屏图片查看器
class FullScreenImageViewer extends StatefulWidget {
  final String imagePath;
  final String title;
  final String cardName;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    required this.title,
    required this.cardName,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  bool _showAppBar = true;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showAppBar
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cardName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetZoom,
                  tooltip: '重置缩放',
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleAppBar,
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 5.0,
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[900],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '图片加载失败',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      // floatingActionButton: _showAppBar
      //     ? FloatingActionButton(
      //         onPressed: _resetZoom,
      //         backgroundColor: Colors.white.withValues(alpha: 0.9),
      //         foregroundColor: Colors.black,
      //         mini: true,
      //         child: const Icon(Icons.center_focus_strong),
      //       )
      //     : null,
    );
  }
}
