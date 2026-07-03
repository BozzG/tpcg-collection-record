import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/utils/grade_utils.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

/// 首页轮播排序模式
enum CarouselMode {
  /// 按当前价值从高到低
  topValue,

  /// 按入手时间从新到旧
  recentAcquired,
}

class HomeViewModel extends ChangeNotifier {
  final DatabaseService _databaseService;
  
  HomeViewModel(this._databaseService) {
    Log.info('初始化首页ViewModel');
    loadStatistics();
    loadTopValueCards();
  }
  
  int _cardCount = 0;
  int _projectCount = 0;
  double _totalValue = 0.0;
  double _totalCost = 0.0;
  Map<GradeTier, int> _gradeTierCounts = const {};
  List<TCGCard> _topValueCards = [];
  List<TCGCard> _recentAcquiredCards = [];
  bool _recentLoaded = false;
  CarouselMode _carouselMode = CarouselMode.topValue;
  bool _isLoading = false;
  
  int get cardCount => _cardCount;
  int get projectCount => _projectCount;
  double get totalValue => _totalValue;
  double get totalCost => _totalCost;

  /// 总收益（当前总价值 − 总花费），可为负。
  double get totalProfit => _totalValue - _totalCost;

  /// 总收益率（相对总花费）；无花费时返回 0。
  double get profitRate => _totalCost > 0 ? totalProfit / _totalCost : 0.0;

  /// 评级档位分布（档位 → 卡片数），按全量卡片统计。
  Map<GradeTier, int> get gradeTierCounts => _gradeTierCounts;

  List<TCGCard> get topValueCards => _topValueCards;
  bool get isLoading => _isLoading;

  /// 当前轮播排序模式
  CarouselMode get carouselMode => _carouselMode;

  /// 当前模式下要展示的轮播卡片列表
  List<TCGCard> get carouselCards => _carouselMode == CarouselMode.topValue
      ? _topValueCards
      : _recentAcquiredCards;

  /// 当前模式下的轮播标题
  String get carouselTitle =>
      _carouselMode == CarouselMode.topValue ? '最高价值' : '最新入手';

  /// 切换轮播排序模式。首次切到「最新入手」时懒加载并缓存数据。
  Future<void> setCarouselMode(CarouselMode mode) async {
    if (_carouselMode == mode) return;
    _carouselMode = mode;
    notifyListeners();

    if (mode == CarouselMode.recentAcquired && !_recentLoaded) {
      await loadRecentAcquiredCards();
    }
  }
  
  Future<void> loadStatistics() async {
    Log.debug('开始加载统计数据');
    _isLoading = true;
    notifyListeners();
    
    try {
      _cardCount = await _databaseService.getTotalCardCount();
      _projectCount = await _databaseService.getTotalProjectCount();
      _totalValue = await _databaseService.getTotalValue();
      _totalCost = await _databaseService.getTotalCost();
      _gradeTierCounts = await _loadGradeTierCounts();

      Log.info('统计数据加载成功 - 卡片数: $_cardCount, 项目数: $_projectCount, 总价值: $_totalValue, 总花费: $_totalCost');
    } catch (e, stackTrace) {
      Log.error('加载统计数据时发生错误', e, stackTrace);
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// 读取全量评级分布并按档位归并（黑10/金10/满分10/9/8/其他）。
  Future<Map<GradeTier, int>> _loadGradeTierCounts() async {
    final dist = await _databaseService.getGradeDistribution();
    final counts = <GradeTier, int>{};
    dist.forEach((grade, count) {
      final tier = GradeUtils.tierOf(grade);
      counts[tier] = (counts[tier] ?? 0) + count;
    });
    return counts;
  }

  Future<void> loadTopValueCards() async {
    try {
      Log.debug('开始加载高价值卡片');
      _topValueCards = await _databaseService.getTopValueCards(limit: 50);
      Log.info('高价值卡片加载成功，数量: ${_topValueCards.length}');
      notifyListeners();
    } catch (e, stackTrace) {
      Log.error('加载高价值卡片时发生错误', e, stackTrace);
    }
  }

  Future<void> loadRecentAcquiredCards() async {
    try {
      Log.debug('开始加载最新入手卡片');
      _recentAcquiredCards =
          await _databaseService.getRecentAcquiredCards(limit: 50);
      _recentLoaded = true;
      Log.info('最新入手卡片加载成功，数量: ${_recentAcquiredCards.length}');
      notifyListeners();
    } catch (e, stackTrace) {
      Log.error('加载最新入手卡片时发生错误', e, stackTrace);
    }
  }
  
  Future<void> refresh() async {
    Log.info('刷新首页数据');
    await Future.wait([
      loadStatistics(),
      loadTopValueCards(),
      // 仅当「最新入手」已加载过才刷新其缓存，避免无谓查询
      if (_recentLoaded) loadRecentAcquiredCards(),
    ]);
  }
}