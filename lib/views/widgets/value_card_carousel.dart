import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/views/card_detail_page.dart';
import 'package:tpcg_collection_record/views/widgets/card_wall_tile.dart';
import 'package:tpcg_collection_record/views/widgets/grade_badge.dart';
import 'package:tpcg_collection_record/views/widgets/image_file_widget.dart';
import 'package:tpcg_collection_record/views/widgets/rarity_halo.dart';

/// 高价值卡片横向轮播组件（陈列馆画廊）。
///
/// 与卡墙 [CardWallTile] 统一视觉语言：5:7 竖版大图 + 底部渐变信息条 +
/// Hero 飞入详情 + 鉴定标签徽章 + 顶级评级稀有度光环。
/// 翻页时中心卡放大、两侧缩小形成纵深，底部自绘页面指示器。
/// - ≤1 张时降级为单卡居中显示
/// - 空列表由调用方处理（不会传入空列表）
class ValueCardCarousel extends StatefulWidget {
  final List<TCGCard> cards;

  const ValueCardCarousel({super.key, required this.cards});

  @override
  State<ValueCardCarousel> createState() => _ValueCardCarouselState();
}

class _ValueCardCarouselState extends State<ValueCardCarousel> {
  /// 轮播可视占比（中心卡占屏幕宽度比例，留出两侧露边）
  static const double _viewportFraction = 0.64;

  /// 卡面宽高比（仿实体卡 5:7）
  static const double _cardAspect = 5 / 7;

  /// 两侧卡缩放下限
  static const double _minScale = 0.84;

  late final PageController _controller;

  /// 激活页索引。仅在「四舍五入后的当前页」变化时更新，驱动指示器局部重建，
  /// 避免指示器随滚动每帧重建整行 dots。
  final ValueNotifier<int> _activeIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
    _controller.addListener(_syncActiveIndex);
  }

  /// 当前页位置（含滚动中的小数）。布局未就绪时回落到初始页，避免读取 page 抛异常。
  double get _currentPage {
    if (_controller.hasClients && _controller.position.haveDimensions) {
      return _controller.page ?? _controller.initialPage.toDouble();
    }
    return _controller.initialPage.toDouble();
  }

  /// 只更新 ValueNotifier（不 setState），索引未变则不通知，指示器随之零重建。
  void _syncActiveIndex() {
    final idx = _currentPage.round();
    if (idx != _activeIndex.value) {
      _activeIndex.value = idx;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_syncActiveIndex);
    _controller.dispose();
    _activeIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    final screenWidth = MediaQuery.of(context).size.width;

    final cardWidth = screenWidth * _viewportFraction - 16;
    final cardHeight = cardWidth / _cardAspect;
    const indicatorHeight = 28.0;
    final carouselHeight = cardHeight + indicatorHeight;

    // 单卡降级：居中静态展示，无需 PageView / 指示器
    if (cards.length <= 1) {
      return SizedBox(
        height: carouselHeight,
        child: Center(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: _buildCard(context, cards.first),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return Center(
                // 只让缩放变换随滚动重建；卡片本体通过 child 缓存，构建一次。
                child: AnimatedBuilder(
                  animation: _controller,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildCard(context, cards[index]),
                    ),
                  ),
                  builder: (context, child) {
                    final delta = (_currentPage - index).abs().clamp(0.0, 1.0);
                    final scale = 1 - (1 - _minScale) * delta;
                    return Transform.scale(scale: scale, child: child);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // 指示器仅在激活页索引变化时重建一次，滚动期间零重建。
        ValueListenableBuilder<int>(
          valueListenable: _activeIndex,
          builder: (context, current, _) =>
              _buildIndicator(context, cards.length, current),
        ),
      ],
    );
  }

  /// 5:7 竖版卡：复用卡墙视觉语言。
  Widget _buildCard(BuildContext context, TCGCard card) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailPage(cardId: card.id!),
          ),
        );
      },
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
                color: colorScheme.shadow.withValues(alpha: 0.18),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 卡面图（Hero 飞入详情）
              Hero(
                tag: cardHeroTag(card.id),
                child: _buildImage(context, card, colorScheme),
              ),

              // 卡套反光高光（实体感）
              const Positioned.fill(child: _CardGloss()),

              // 底部渐变 + 信息条
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildInfoBar(context, card, colorScheme),
              ),

              // 评级鉴定标签
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
    );
  }

  Widget _buildImage(
      BuildContext context, TCGCard card, ColorScheme colorScheme) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: colorScheme.surfaceContainerLow,
      child: ImageFileWidget(
        imageRef: card.frontImage,
        fit: BoxFit.cover,
        cacheWidth: (screenWidth * _viewportFraction * dpr).toInt(),
        placeholder: Container(
          color: colorScheme.secondaryContainer,
          child: Center(
            child: Icon(
              Icons.credit_card,
              size: 48,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBar(
      BuildContext context, TCGCard card, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 12),
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
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                '#${card.pokedexNumber}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '¥${card.currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, int count, int current) {
    final colorScheme = Theme.of(context).colorScheme;
    final safeCurrent = current.clamp(0, count - 1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == safeCurrent;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? colorScheme.secondary
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

/// 卡套反光高光：左上→右下的极轻线性高光，模拟卡进卡砖的反光。
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
              Colors.white.withValues(alpha: 0.16),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
