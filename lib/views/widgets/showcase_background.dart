import 'package:flutter/material.dart';

/// 潮玩陈列氛围背景：
/// - CV1 背景肌理：淡淡的菱形网格，营造卡册/收藏柜的陈列质感
/// - CV4 暗色射灯：暗色模式下叠加顶部聚光渐变，模拟展柜射灯
///
/// 作为页面 body 的最外层 Stack 底，纯绘制、零依赖、不拦截手势。
class ShowcaseBackground extends StatelessWidget {
  const ShowcaseBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // CV1：菱形网格肌理
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _LatticePainter(
                lineColor: colorScheme.onSurface.withValues(alpha: 0.04),
              ),
            ),
          ),
        ),

        // CV4：暗色模式顶部射灯
        if (isDark)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1.1),
                    radius: 1.1,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          )
        // CV5：亮色模式「展柜玻璃」顶光，极淡白色高光，保证可读性
        else
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1.2),
                    radius: 1.2,
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),

        // 内容
        child,
      ],
    );
  }
}

class _LatticePainter extends CustomPainter {
  _LatticePainter({required this.lineColor});

  final Color lineColor;
  static const double _gap = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 正斜线
    for (double x = -size.height; x < size.width; x += _gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
    // 反斜线
    for (double x = 0; x < size.width + size.height; x += _gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LatticePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}
