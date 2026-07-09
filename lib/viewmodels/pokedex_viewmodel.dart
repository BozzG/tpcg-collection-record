import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/services/pokedex_cover_store.dart';
import 'package:tpcg_collection_record/services/pokedex_name_service.dart';
import 'package:tpcg_collection_record/utils/grade_utils.dart';
import 'package:tpcg_collection_record/utils/logger.dart';
import 'package:tpcg_collection_record/utils/pokedex_generations.dart';

/// 图鉴单格模型（供 UI 无脑渲染）。
class PokedexEntry {
  const PokedexEntry({
    required this.number,
    required this.zhName,
    required this.owned,
    this.cover,
  });

  /// 图鉴号（1..1025）。
  final int number;

  /// 中文名（离线名录）。
  final String zhName;

  /// 是否已拥有（该编号下至少 1 张卡）。
  final bool owned;

  /// 封面卡（默认算法或手动覆盖）；未拥有为 null。
  final TCGCard? cover;
}

/// 某世代的收集进度快照。
class GenerationProgress {
  const GenerationProgress({required this.generation, required this.owned});

  final PokedexGeneration generation;

  /// 该世代已拥有的编号数。
  final int owned;

  int get total => generation.total;
}

/// 图鉴收集 ViewModel。
///
/// 聚合「按编号分组的卡片 + 中文名录 + 手动封面覆盖」，对外暴露世代进度、
/// 全国进度、单格模型与某编号卡列表。复用 [DatabaseService.getAllCards]
/// 在内存分组，不新增 SQL；仅统计 1..1025 的有效编号，0 或越界的卡被忽略。
class PokedexViewModel extends ChangeNotifier {
  PokedexViewModel(this._databaseService) {
    load();
  }

  final DatabaseService _databaseService;
  final PokedexNameService _nameService = PokedexNameService.instance;
  final PokedexCoverStore _coverStore = PokedexCoverStore.instance;

  /// 编号 → 该编号下所有卡（已按封面优先级排序，首个即默认封面）。
  final Map<int, List<TCGCard>> _cardsByNumber = {};

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// 全国已收集编号数（有效 1..1025）。
  int get collectedCount => _cardsByNumber.length;

  /// 全国图鉴总数。
  int get totalCount => kPokedexMax;

  /// 全国收集比例 0..1。
  double get collectedRatio =>
      totalCount == 0 ? 0 : collectedCount / totalCount;

  /// 加载/刷新图鉴数据。名录与封面覆盖幂等加载，仅首次真正 I/O。
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        _nameService.ensureLoaded(),
        _coverStore.ensureLoaded(),
      ]);

      final cards = await _databaseService.getAllCards();
      _cardsByNumber.clear();
      for (final card in cards) {
        if (!isValidPokedexNumber(card.pokedexNumber)) continue;
        _cardsByNumber.putIfAbsent(card.pokedexNumber, () => []).add(card);
      }
      // 每个编号内按封面优先级排序：评级高 → 最近入手 → id 大。
      for (final list in _cardsByNumber.values) {
        list.sort(_coverPriority);
      }
      Log.info('图鉴数据加载成功，已收集 $collectedCount/$totalCount');
    } catch (e, st) {
      Log.error('图鉴数据加载失败', e, st);
      _cardsByNumber.clear();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// 封面优先级比较：评级档位升序（index 越小越高）→ 入手时间降序 → id 降序。
  int _coverPriority(TCGCard a, TCGCard b) {
    final ta = GradeUtils.tierOf(a.grade).index;
    final tb = GradeUtils.tierOf(b.grade).index;
    if (ta != tb) return ta - tb;
    final byDate = b.acquiredDate.compareTo(a.acquiredDate);
    if (byDate != 0) return byDate;
    return (b.id ?? 0) - (a.id ?? 0);
  }

  /// 某世代的进度。
  GenerationProgress progressOf(PokedexGeneration g) {
    var owned = 0;
    for (final number in _cardsByNumber.keys) {
      if (number >= g.start && number <= g.end) owned++;
    }
    return GenerationProgress(generation: g, owned: owned);
  }

  /// 生成某世代的全部单格模型（含未拥有格）。
  List<PokedexEntry> entriesOf(PokedexGeneration g) {
    final list = <PokedexEntry>[];
    for (int n = g.start; n <= g.end; n++) {
      list.add(_entry(n));
    }
    return list;
  }

  PokedexEntry _entry(int number) {
    final cover = coverOf(number);
    return PokedexEntry(
      number: number,
      zhName: _nameService.nameOf(number),
      owned: cover != null,
      cover: cover,
    );
  }

  /// 某编号的封面卡：有手动覆盖且该卡仍存在则用之，否则回退默认（排序首个）。
  TCGCard? coverOf(int number) {
    final cards = _cardsByNumber[number];
    if (cards == null || cards.isEmpty) return null;
    final overrideId = _coverStore.overrideFor(number);
    if (overrideId != null) {
      for (final c in cards) {
        if (c.id == overrideId) return c;
      }
      // 手动选的卡已被删除 → 回退默认。
    }
    return cards.first;
  }

  /// 某编号下的全部卡（已按封面优先级排序）。
  List<TCGCard> cardsOf(int number) =>
      List.unmodifiable(_cardsByNumber[number] ?? const []);

  /// 中文名查询。
  String nameOf(int number) => _nameService.nameOf(number);

  /// 某编号当前的手动封面 cardId（无则 null）。
  int? manualCoverId(int number) => _coverStore.overrideFor(number);

  /// 手动设置某编号封面并持久化，刷新 UI。
  Future<void> setManualCover(int number, int cardId) async {
    await _coverStore.setCover(number, cardId);
    notifyListeners();
  }

  /// 清除某编号手动封面（回退默认）并持久化，刷新 UI。
  Future<void> clearManualCover(int number) async {
    await _coverStore.clearCover(number);
    notifyListeners();
  }
}
