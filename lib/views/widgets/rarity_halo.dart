import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/theme/app_theme.dart';
import 'package:tpcg_collection_record/utils/grade_utils.dart';

/// 稀有度光环：为顶级评级卡（黑10 / 金10 / 任意满分10）在卡面外缘叠加
/// 一圈金色/全息描边，让"贵卡一眼更亮"。非顶级评级直接透传 [child]，
/// 零额外开销；为保证长列表滚动性能，光环为**静态**绘制，不跑动画。
class RarityHalo extends StatelessWidget {
  const RarityHalo({
    super.key,
    required this.grade,
    required this.borderRadius,
    required this.child,
  });

  final String grade;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!GradeUtils.isTopRarity(grade)) return child;

    final gradeColors = Theme.of(context).extension<GradeColors>()!;
    final tier = GradeUtils.tierColor(grade, gradeColors);

    // 黑10 用金描边突出（纯黑描边在暗底不可见），其余顶级档用自身档位色。
    final bool isBlackTop = grade.contains('黑10');
    final Color haloColor = isBlackTop ? gradeColors.tierGold : tier;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // 外发光层：置于卡片【下方】，模糊阴影仅在卡片边缘外侧扩散；
        // 卡片本体不透明会盖住其中心部分，故不会在图片中间形成蒙版。
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: haloColor.withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),

        // 卡片本体（不透明，遮住发光层中心，仅露出外缘光晕）
        child,

        // 描边层：只画一圈边框，中间透明，绝不蒙住图片与徽章。
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(color: haloColor, width: 2.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
