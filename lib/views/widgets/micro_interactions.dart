import 'package:flutter/material.dart';

/// 交错入场动画：子组件以「淡入 + 轻微上移」的方式进入，
/// 按 [index] 递增延迟形成瀑布式错落感（延迟封顶，避免长列表尾部等待过久）。
///
/// 纯本地动画、零依赖，适用于卡墙 / 列表项首帧入场。
class EntranceFader extends StatefulWidget {
  const EntranceFader({
    super.key,
    required this.child,
    this.index = 0,
    this.perItemDelay = const Duration(milliseconds: 45),
    this.maxDelay = const Duration(milliseconds: 360),
    this.duration = const Duration(milliseconds: 360),
    this.offsetY = 16,
  });

  final Widget child;
  final int index;
  final Duration perItemDelay;
  final Duration maxDelay;
  final Duration duration;
  final double offsetY;

  @override
  State<EntranceFader> createState() => _EntranceFaderState();
}

class _EntranceFaderState extends State<EntranceFader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    final delayMs =
        (widget.perItemDelay.inMilliseconds * widget.index).clamp(
      0,
      widget.maxDelay.inMilliseconds,
    );
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _curve.value) * widget.offsetY),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 按压回弹：按下时轻微缩小，松开回弹，配合点击反馈营造「实体卡」触感。
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 110),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
