import 'package:flutter/material.dart';

/// 自绘骨架屏：用扫光动画的占位块替代转圈加载，营造"内容即将呈现"的预期感。
///
/// 提供基础 [ShimmerBox] 与两种贴合业务布局的骨架：
/// - [HomeSkeleton]：首页（统计四宫格 + 轮播位）
/// - [CardWallSkeleton]：卡片列表卡墙（2 列 5:7 网格）
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = colorScheme.surfaceContainerHigh;
    final highlight = colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.borderRadius)
                : null,
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * t, 0),
              end: Alignment(1 - 2 * t, 0),
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

/// 首页加载骨架：统计标题 + 四宫格 + 轮播大卡位。
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final statAspect = screenWidth > 400 ? 1.7 : 1.5;
    final carouselCardWidth = screenWidth * 0.64 - 16;
    final carouselCardHeight = carouselCardWidth / (5 / 7);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 140, height: 24),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: statAspect,
            children: List.generate(
              4,
              (_) => const ShimmerBox(borderRadius: 12),
            ),
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 120, height: 24),
          const SizedBox(height: 12),
          Center(
            child: ShimmerBox(
              width: carouselCardWidth,
              height: carouselCardHeight,
              borderRadius: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// 卡墙加载骨架：2 列 5:7 竖版网格占位。
class CardWallSkeleton extends StatelessWidget {
  const CardWallSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 5 / 7,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerBox(borderRadius: 14),
    );
  }
}
