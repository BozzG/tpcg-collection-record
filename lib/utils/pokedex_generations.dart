/// 宝可梦世代边界常量与「编号 → 世代」归类工具。
///
/// 全国图鉴范围固定为 1..1025（截至帕底亚地区）。世代边界为固定知识，
/// 硬编码为常量表，零外部数据依赖。pokedexNumber 为 0 或 >1025 的卡不属于
/// 任何世代（[generationOf] 返回 null），因此不会在图鉴中显示。
library;

/// 全国图鉴最小编号。
const int kPokedexMin = 1;

/// 全国图鉴最大编号（帕底亚地区末尾）。
const int kPokedexMax = 1025;

/// 单个世代的图鉴区段定义。
class PokedexGeneration {
  const PokedexGeneration({
    required this.name,
    required this.region,
    required this.start,
    required this.end,
  });

  /// 世代名，如「第一世代」。
  final String name;

  /// 地区名，如「关都」。
  final String region;

  /// 起始编号（含）。
  final int start;

  /// 结束编号（含）。
  final int end;

  /// 该世代包含的编号总数。
  int get total => end - start + 1;

  /// 标题展示文案，如「第一世代 · 关都」。
  String get title => '$name · $region';
}

/// 九个世代的固定边界表。
const List<PokedexGeneration> kGenerations = [
  PokedexGeneration(name: '第一世代', region: '关都', start: 1, end: 151),
  PokedexGeneration(name: '第二世代', region: '城都', start: 152, end: 251),
  PokedexGeneration(name: '第三世代', region: '丰缘', start: 252, end: 386),
  PokedexGeneration(name: '第四世代', region: '神奥', start: 387, end: 493),
  PokedexGeneration(name: '第五世代', region: '合众', start: 494, end: 649),
  PokedexGeneration(name: '第六世代', region: '卡洛斯', start: 650, end: 721),
  PokedexGeneration(name: '第七世代', region: '阿罗拉', start: 722, end: 809),
  PokedexGeneration(name: '第八世代', region: '伽勒尔', start: 810, end: 905),
  PokedexGeneration(name: '第九世代', region: '帕底亚', start: 906, end: 1025),
];

/// 判断编号是否为有效全国图鉴号（1..1025）。
bool isValidPokedexNumber(int number) =>
    number >= kPokedexMin && number <= kPokedexMax;

/// 返回编号所属世代；越界（0 或 >1025）返回 null。
PokedexGeneration? generationOf(int number) {
  for (final g in kGenerations) {
    if (number >= g.start && number <= g.end) return g;
  }
  return null;
}
