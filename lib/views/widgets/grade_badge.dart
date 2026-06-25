import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/theme/app_theme.dart';
import 'package:tpcg_collection_record/utils/grade_utils.dart';

/// 鉴定标签徽章（PSA / BGS / CGC / CCIC / PCG 风格）。
///
/// 两段式排版：左侧机构名，右侧分数，中间细分隔线；底色取评级档位色，
/// 黑描边强化"鉴定标牌"质感。无法识别机构时退化为单段纯文本徽章，
/// 兼容「其他 / 未评级」等自由文案。
class GradeBadge extends StatelessWidget {
  const GradeBadge({
    super.key,
    required this.grade,
    this.compact = false,
  });

  final String grade;

  /// 紧凑模式：用于卡墙等小尺寸场景，字号与内边距更小。
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradeColors = Theme.of(context).extension<GradeColors>()!;
    final tier = GradeUtils.tierColor(grade, gradeColors);
    final institution = GradeUtils.institutionOf(grade);
    final score = GradeUtils.scoreOf(grade);

    final double instSize = compact ? 8.5 : 10;
    final double scoreSize = compact ? 11 : 13;
    final EdgeInsets pad = compact
        ? const EdgeInsets.symmetric(horizontal: 5, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 7, vertical: 3);

    // 无机构前缀（其他/未评级）→ 单段徽章
    if (institution.isEmpty) {
      return _wrapper(
        colorScheme: colorScheme,
        tier: tier,
        child: Text(
          grade,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: scoreSize,
            letterSpacing: 0.2,
          ),
        ),
        padding: pad,
      );
    }

    return _wrapper(
      colorScheme: colorScheme,
      tier: tier,
      padding: pad,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            institution,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: instSize,
              letterSpacing: 0.5,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 5),
            child: Container(
              width: 1,
              height: scoreSize + 2,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          Text(
            score,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: scoreSize,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapper({
    required ColorScheme colorScheme,
    required Color tier,
    required Widget child,
    required EdgeInsets padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tier,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: colorScheme.outline, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: child,
    );
  }
}
