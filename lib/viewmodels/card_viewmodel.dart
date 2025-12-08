import 'package:flutter/foundation.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

class CardViewModel extends ChangeNotifier {
  final DatabaseService _databaseService;
  
  CardViewModel(this._databaseService) {
    Log.info('初始化卡片ViewModel');
  }
  
  List<PTCGCard> _cards = [];
  List<PTCGCard> _filteredCards = [];
  bool _isLoading = false;
  String _searchQuery = '';
  
  List<PTCGCard> get cards => _filteredCards;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  
  Future<void> loadAllCards() async {
    Log.debug('开始加载所有卡片');
    _isLoading = true;
    notifyListeners();
    
    try {
      _cards = await _databaseService.getAllCards();
      _filteredCards = List.from(_cards);
      Log.info('卡片加载成功，总数: ${_cards.length}');
    } catch (e, stackTrace) {
      Log.error('加载卡片时发生错误', e, stackTrace);
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> searchCards(String query) async {
    Log.debug('搜索卡片: "$query"');
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredCards = List.from(_cards);
      Log.debug('清空搜索，显示所有卡片: ${_filteredCards.length}');
    } else {
      try {
        _filteredCards = await _databaseService.searchCards(query);
        Log.info('搜索完成，找到 ${_filteredCards.length} 张卡片');
      } catch (e, stackTrace) {
        Log.error('搜索卡片时发生错误: "$query"', e, stackTrace);
        _filteredCards = [];
      }
    }
    
    notifyListeners();
  }
  
  Future<PTCGCard?> getCardById(int id) async {
    try {
      Log.debug('获取卡片详情: ID=$id');
      final card = await _databaseService.getCardById(id);
      if (card != null) {
        Log.info('卡片详情获取成功: ${card.name}');
      } else {
        Log.warning('未找到指定ID的卡片: $id');
      }
      return card;
    } catch (e, stackTrace) {
      Log.error('获取卡片详情时发生错误: ID=$id', e, stackTrace);
      return null;
    }
  }
  
  Future<String?> getProjectNameByCardId(int cardId) async {
    try {
      Log.debug('获取卡片所属项目名称: CardID=$cardId');
      final card = await _databaseService.getCardById(cardId);
      if (card != null) {
        final project = await _databaseService.getProjectById(card.projectId);
        if (project != null) {
          Log.info('获取项目名称成功: ${project.name}');
          return project.name;
        } else {
          Log.warning('未找到卡片所属项目: ProjectID=${card.projectId}');
        }
      } else {
        Log.warning('未找到指定ID的卡片: $cardId');
      }
      return null;
    } catch (e, stackTrace) {
      Log.error('获取项目名称时发生错误: CardID=$cardId', e, stackTrace);
      return null;
    }
  }
  
  Future<bool> addCard(PTCGCard card) async {
    try {
      Log.info('添加新卡片: ${card.name}');
      await _databaseService.insertCard(card);
      await loadAllCards(); // 重新加载列表
      Log.info('卡片添加成功: ${card.name}');
      return true;
    } catch (e, stackTrace) {
      Log.error('添加卡片时发生错误: ${card.name}', e, stackTrace);
      return false;
    }
  }
  
  Future<bool> updateCard(PTCGCard card) async {
    try {
      Log.info('更新卡片: ${card.name} (ID=${card.id})');
      await _databaseService.updateCard(card);
      await loadAllCards(); // 重新加载列表
      Log.info('卡片更新成功: ${card.name}');
      return true;
    } catch (e, stackTrace) {
      Log.error('更新卡片时发生错误: ${card.name} (ID=${card.id})', e, stackTrace);
      return false;
    }
  }
  
  Future<bool> deleteCard(int id) async {
    try {
      Log.info('删除卡片: ID=$id');
      await _databaseService.deleteCard(id);
      await loadAllCards(); // 重新加载列表
      Log.info('卡片删除成功: ID=$id');
      return true;
    } catch (e, stackTrace) {
      Log.error('删除卡片时发生错误: ID=$id', e, stackTrace);
      return false;
    }
  }
  
  void clearSearch() {
    Log.debug('清空搜索条件');
    _searchQuery = '';
    _filteredCards = List.from(_cards);
    notifyListeners();
  }
}