import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 翻卡 + 全息光泽卡面。
///
/// - SF3 翻卡 3D：点击卡面绕 Y 轴翻转，正面 [front] ↔ 背面 [back]
/// - SF4 全息光泽（仅触摸版）：手指/指针在卡面移动时，叠加随触点流动的
///   全息渐变光泽。通过 [Listener] 读取原始指针位置，不参与手势竞争，
///   因此不会与外层 PageView 的横向滑动冲突，也不依赖陀螺仪（无 sensors_plus）。
///
/// 全息彩虹为「效果色」而非品牌色，固定 RGBA，不走主题 token（与卡面材质属性一致）。
class HoloFlipCard extends StatefulWidget {
  const HoloFlipCard({
    super.key,
    required this.front,
    required this.back,
    this.borderRadius = 14,
  });

  final Widget front;
  final Widget back;
  final double borderRadius;

  @override
  State<HoloFlipCard> createState() => _HoloFlipCardState();
}

class _HoloFlipCardState extends State<HoloFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );

  // 触点归一化坐标（-1..1），驱动全息光泽朝向
  Alignment _shine = Alignment.center;
  bool _touching = false;

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flip.isAnimating) return;
    if (_flip.value < 0.5) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

  void _updateShine(Offset local, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final dx = ((local.dx / size.width).clamp(0.0, 1.0)) * 2 - 1;
    final dy = ((local.dy / size.height).clamp(0.0, 1.0)) * 2 - 1;
    setState(() {
      _shine = Alignment(dx, dy);
      _touching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flip,
      builder: (context, _) {
        final angle = _flip.value * math.pi;
        final isFront = angle <= math.pi / 2;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0015) // 透视
          ..rotateY(angle);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: isFront
              ? _buildFront(context)
              : Transform(
                  // 翻到背面后镜像修正，使背面文字正向
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _buildBack(context),
                ),
        );
      },
    );
  }

  Widget _buildFront(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          onPointerMove: (e) => _updateShine(e.localPosition, size),
          onPointerHover: (e) => _updateShine(e.localPosition, size),
          onPointerUp: (_) => setState(() => _touching = false),
          onPointerCancel: (_) => setState(() => _touching = false),
          child: GestureDetector(
            onTap: _toggleFlip,
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.front,
                // 全息光泽叠层（不拦截手势）
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: _touching ? 0.55 : 0.16,
                      child: _HoloSheen(
                        shine: _shine,
                        borderRadius: widget.borderRadius,
                      ),
                    ),
                  ),
                ),
                // 翻面提示
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flip, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text(
                            '点击翻面',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBack(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: widget.back,
    );
  }
}

/// 全息光泽叠层：随 [shine] 朝向流动的彩虹渐变 + 高光斑。
class _HoloSheen extends StatelessWidget {
  const _HoloSheen({required this.shine, required this.borderRadius});

  final Alignment shine;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 彩虹斜带，方向随触点反向流动
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-shine.x, -shine.y),
                end: Alignment(shine.x, shine.y),
                colors: const [
                  Color(0x66FF3D81), // 品红
                  Color(0x6600E0FF), // 青
                  Color(0x66FFE53D), // 黄
                  Color(0x668A5BFF), // 紫
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          // 高光斑跟随触点
          Align(
            alignment: shine,
            child: FractionallySizedBox(
              widthFactor: 0.6,
              heightFactor: 0.6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
