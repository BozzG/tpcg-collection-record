import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/theme/app_theme.dart';

/// 评级档位（用于配色与分布统计的统一归类）。
enum GradeTier { black10, gold10, ten, nine, eight, other }

class GradeUtils {
  static const List<String> grades = [
    'PSA 1',
    'PSA 2',
    'PSA 3',
    'PSA 4',
    'PSA 5',
    'PSA 6',
    'PSA 7',
    'PSA 8',
    'PSA 9',
    'PSA 10',
    'BGS 1',
    'BGS 2',
    'BGS 3',
    'BGS 4',
    'BGS 5',
    'BGS 6',
    'BGS 7',
    'BGS 8',
    'BGS 9',
    'BGS 9.5',
    'BGS 10',
    'BGS 黑10',
    'CGC 1',
    'CGC 2',
    'CGC 3',
    'CGC 4',
    'CGC 5',
    'CGC 6',
    'CGC 7',
    'CGC 8',
    'CGC 9',
    'CGC 10',
    'CGC 金10',
    'CCIC 1',
    'CCIC 2',
    'CCIC 3',
    'CCIC 4',
    'CCIC 5',
    'CCIC 6',
    'CCIC 7',
    'CCIC 8',
    'CCIC 9',
    'CCIC 9.5',
    'CCIC 银10',
    'CCIC 金10',
    'PCG 1',
    'PCG 2',
    'PCG 3',
    'PCG 4',
    'PCG 5',
    'PCG 6',
    'PCG 7',
    'PCG 8',
    'PCG 9',
    'PCG 10',
    'PCG 金10',
    'PCG 黑10',
    '其他',
    '未评级',
  ];

  static bool isValidGrade(String grade) {
    return grades.contains(grade);
  }

  /// 全局唯一的评级配色解析。
  ///
  /// 优先级（先特后泛，避免 `contains('10')` 抢先命中金/黑10）：
  /// 黑10 → tier1（最高）、金10 / PSA 10 → tierGold、银10/其余普通10 → tier2、
  /// 9 → tier3、8 → tier4，其余 → tierDefault。
  /// 适用于所有评级机构（PSA/BGS/CGC/CCIC/PCG…）。
  /// 注：PSA 10 视为金10 级别，单独走金色档。
  static GradeTier tierOf(String grade) {
    if (grade.contains('黑10')) return GradeTier.black10;
    if (grade.contains('金10')) return GradeTier.gold10;
    if (grade.contains('PSA 10')) return GradeTier.gold10; // PSA 10 当作金10
    if (grade.contains('10')) return GradeTier.ten; // 含银10与其余普通10
    if (grade.contains('9')) return GradeTier.nine;
    if (grade.contains('8')) return GradeTier.eight;
    return GradeTier.other;
  }

  /// 档位 → 颜色（取自当前主题的 GradeColors）。
  static Color tierColorOf(GradeTier tier, GradeColors c) {
    switch (tier) {
      case GradeTier.black10:
        return c.tier1;
      case GradeTier.gold10:
        return c.tierGold;
      case GradeTier.ten:
        return c.tier2;
      case GradeTier.nine:
        return c.tier3;
      case GradeTier.eight:
        return c.tier4;
      case GradeTier.other:
        return c.tierDefault;
    }
  }

  /// 档位 → 简短中文标签（用于分布图例）。
  static String tierLabel(GradeTier tier) {
    switch (tier) {
      case GradeTier.black10:
        return '黑10';
      case GradeTier.gold10:
        return '金10';
      case GradeTier.ten:
        return '满分10';
      case GradeTier.nine:
        return '9 分';
      case GradeTier.eight:
        return '8 分';
      case GradeTier.other:
        return '其他';
    }
  }

  /// 评级字符串 → 颜色（先归档再取色）。
  static Color tierColor(String grade, GradeColors c) =>
      tierColorOf(tierOf(grade), c);

  /// 是否为顶级稀有评级（用于稀有度光环）：黑10 / 金10 / 任意满分10。
  static bool isTopRarity(String grade) {
    return grade.contains('黑10') ||
        grade.contains('金10') ||
        grade.contains('银10') ||
        grade.contains('10');
  }

  /// 评级机构前缀（PSA/BGS/CGC/CCIC/PCG…），用于鉴定标签的两段式排版。
  /// 无法识别时返回空串。
  static String institutionOf(String grade) {
    final trimmed = grade.trim();
    final spaceIndex = trimmed.indexOf(' ');
    if (spaceIndex <= 0) return '';
    final prefix = trimmed.substring(0, spaceIndex);
    const known = {'PSA', 'BGS', 'CGC', 'CCIC', 'PCG'};
    return known.contains(prefix) ? prefix : '';
  }

  /// 评级分数部分（去掉机构前缀），如 `PSA 10` → `10`、`PCG 黑10` → `黑10`。
  static String scoreOf(String grade) {
    final inst = institutionOf(grade);
    if (inst.isEmpty) return grade.trim();
    return grade.trim().substring(inst.length).trim();
  }
}
