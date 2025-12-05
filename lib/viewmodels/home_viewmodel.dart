import 'package:flutter/foundation.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

class HomeViewModel extends ChangeNotifier {
  final DatabaseService _databaseService;
  
  HomeViewModel(this._databaseService) {
    Log.info('初始化首页ViewModel');
    loadStatistics();
    loadRecentCards();
  }
  
  int _cardCount = 0;
  int _projectCount = 0;
  double _totalValue = 0.0;
  double _totalCost = 0.0;
  List<PTCGCard> _recentCards = [];
  bool _isLoading = false;
  
  int get cardCount => _cardCount;
  int get projectCount => _projectCount;
  double get totalValue => _totalValue;
  double get totalCost => _totalCost;
  List<PTCGCard> get recentCards => _recentCards;
  bool get isLoading => _isLoading;
  
  Future<void> loadStatistics() async {
    Log.debug('开始加载统计数据');
    _isLoading = true;
    notifyListeners();
    
    try {
      _cardCount = await _databaseService.getTotalCardCount();
      _projectCount = await _databaseService.getTotalProjectCount();
      _totalValue = await _databaseService.getTotalValue();
      _totalCost = await _databaseService.getTotalCost();
      
      Log.info('统计数据加载成功 - 卡片数: $_cardCount, 项目数: $_projectCount, 总价值: $_totalValue, 总花费: $_totalCost');
    } catch (e, stackTrace) {
      Log.error('加载统计数据时发生错误', e, stackTrace);
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadRecentCards() async {
    try {
      Log.debug('开始加载最近添加的卡片');
      _recentCards = await _databaseService.getRecentCards(limit: 5);
      Log.info('最近卡片加载成功，数量: ${_recentCards.length}');
      notifyListeners();
    } catch (e, stackTrace) {
      Log.error('加载最近卡片时发生错误', e, stackTrace);
    }
  }
  
  Future<void> refresh() async {
    Log.info('刷新首页数据');
    await Future.wait([
      loadStatistics(),
      loadRecentCards(),
    ]);
  }
}