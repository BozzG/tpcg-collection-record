import 'package:flutter/foundation.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/models/sort_option.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

/// 卡片列表的展示形态。
/// - [wall] 卡墙陈列：2 列竖版大图，仿实体卡册，突出卡面
/// - [list] 列表：信息密集，便于检索核对
enum CardViewMode { wall, list }

class CardViewModel extends ChangeNotifier {
  final DatabaseService _databaseService;

  CardViewModel(this._databaseService) {
    Log.info('初始化卡片ViewModel');
  }

  List<TCGCard> _cards = [];
  List<TCGCard> _filteredCards = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // 筛选状态
  Set<String> _selectedGrades = {};
  Set<int> _selectedProjectIds = {};
  SortOption _sortOption = SortOption.pokedexAsc;

  // 项目名映射（projectId → name），用于 UI 显示
  Map<int, String> _projectNameMap = {};

  // 展示形态：默认卡墙陈列，突出「收藏手账」的藏品感
  CardViewMode _viewMode = CardViewMode.wall;

  List<TCGCard> get cards => _filteredCards;
  bool get isLoading => _isLoading;

  /// 当前列表展示形态
  CardViewMode get viewMode => _viewMode;

  /// 切换列表 / 卡墙展示形态
  void setViewMode(CardViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    Log.debug('切换卡片展示形态: $mode');
    notifyListeners();
  }

  /// 在列表与卡墙之间翻转
  void toggleViewMode() {
    setViewMode(
        _viewMode == CardViewMode.wall ? CardViewMode.list : CardViewMode.wall);
  }
  String get searchQuery => _searchQuery;
  Set<String> get selectedGrades => _selectedGrades;
  Set<int> get selectedProjectIds => _selectedProjectIds;
  SortOption get sortOption => _sortOption;
  Map<int, String> get projectNameMap => _projectNameMap;

  /// 获取当前数据库中已有的 grade 值列表
  List<String> get availableGrades {
    final grades = _cards.map((c) => c.grade).where((g) => g.isNotEmpty).toSet().toList();
    grades.sort();
    return grades;
  }

  /// 获取当前数据库中已有的项目 ID+名称 列表
  List<MapEntry<int, String>> get availableProjects {
    return _projectNameMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
  }

  /// 排序提示文案
  String get sortLabel => _sortOption.label;

  Future<void> loadAllCards() async {
    Log.debug('开始加载所有卡片');
    _isLoading = true;
    notifyListeners();

    try {
      _cards = await _databaseService.getAllCards();
      // 加载项目名映射
      await _loadProjectNameMap();
      _applyFilters();
      Log.info('卡片加载成功，总数: ${_cards.length}');
    } catch (e, stackTrace) {
      Log.error('加载卡片时发生错误', e, stackTrace);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProjectNameMap() async {
    try {
      final projects = await _databaseService.getAllProjects();
      _projectNameMap = {for (var p in projects) p.id!: p.name};
    } catch (e, stackTrace) {
      Log.error('加载项目名映射时发生错误', e, stackTrace);
    }
  }

  Future<void> searchCards(String query) async {
    Log.debug('搜索卡片: "$query"');
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setGradeFilter(Set<String> grades) {
    _selectedGrades = grades;
    _applyFilters();
    notifyListeners();
  }

  void setProjectFilter(Set<int> projectIds) {
    _selectedProjectIds = projectIds;
    _applyFilters();
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<TCGCard>.from(_cards);

    // 文本搜索
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.issueNumber.toLowerCase().contains(q);
      }).toList();
    }

    // 评级筛选
    if (_selectedGrades.isNotEmpty) {
      result = result.where((c) => _selectedGrades.contains(c.grade)).toList();
    }

    // 项目筛选
    if (_selectedProjectIds.isNotEmpty) {
      result =
          result.where((c) => _selectedProjectIds.contains(c.projectId)).toList();
    }

    // 排序
    switch (_sortOption) {
      case SortOption.pokedexAsc:
        result.sort((a, b) => a.pokedexNumber.compareTo(b.pokedexNumber));
      case SortOption.currentValueDesc:
        result.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
      case SortOption.acquiredPriceDesc:
        result.sort((a, b) => b.acquiredPrice.compareTo(a.acquiredPrice));
      case SortOption.acquiredDateDesc:
        result.sort((a, b) => b.acquiredDate.compareTo(a.acquiredDate));
    }

    _filteredCards = result;
    Log.debug('筛选完成，结果数: ${_filteredCards.length}');
  }

  Future<TCGCard?> getCardById(int id) async {
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

  Future<bool> addCard(TCGCard card) async {
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

  Future<bool> updateCard(TCGCard card) async {
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
    _applyFilters();
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _selectedGrades = {};
    _selectedProjectIds = {};
    _sortOption = SortOption.pokedexAsc;
    _applyFilters();
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _selectedGrades.isNotEmpty || _selectedProjectIds.isNotEmpty;
}
