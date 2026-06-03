import 'package:flutter/foundation.dart';
import 'package:tpcg_collection_record/models/ptcg_project.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

class ProjectViewModel extends ChangeNotifier {
  final DatabaseService _databaseService;
  
  ProjectViewModel(this._databaseService) {
    Log.info('初始化项目ViewModel');
  }
  
  List<TCGProject> _projects = [];
  List<TCGProject> _filteredProjects = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;
  
  List<TCGProject> get projects => _filteredProjects;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllProjects() async {
    Log.debug('开始加载所有项目');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // 添加超时保护
      _projects = await _databaseService.getAllProjects().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('数据库查询超时（10秒）');
        },
      );
      _filteredProjects = List.from(_projects);
      Log.info('项目加载成功，总数: ${_projects.length}');
    } catch (e, stackTrace) {
      Log.error('加载项目时发生错误', e, stackTrace);
      _errorMessage = '加载项目失败: ${e.toString()}';
      _projects = [];
      _filteredProjects = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> searchProjects(String query) async {
    Log.debug('搜索项目: "$query"');
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredProjects = List.from(_projects);
      Log.debug('清空搜索，显示所有项目: ${_filteredProjects.length}');
    } else {
      try {
        _filteredProjects = await _databaseService.searchProjects(query);
        Log.info('搜索完成，找到 ${_filteredProjects.length} 个项目');
      } catch (e, stackTrace) {
        Log.error('搜索项目时发生错误: "$query"', e, stackTrace);
        _filteredProjects = [];
      }
    }
    
    notifyListeners();
  }
  
  Future<TCGProject?> getProjectById(int id) async {
    try {
      Log.debug('获取项目详情: ID=$id');
      final project = await _databaseService.getProjectById(id);
      if (project != null) {
        Log.info('项目详情获取成功: ${project.name} (包含${project.cards.length}张卡片)');
      } else {
        Log.warning('未找到指定ID的项目: $id');
      }
      return project;
    } catch (e, stackTrace) {
      Log.error('获取项目详情时发生错误: ID=$id', e, stackTrace);
      return null;
    }
  }
  
  Future<bool> addProject(TCGProject project) async {
    try {
      Log.info('添加新项目: ${project.name}');
      await _databaseService.insertProject(project);
      await loadAllProjects(); // 重新加载列表
      Log.info('项目添加成功: ${project.name}');
      return true;
    } catch (e, stackTrace) {
      Log.error('添加项目时发生错误: ${project.name}', e, stackTrace);
      return false;
    }
  }
  
  Future<bool> updateProject(TCGProject project) async {
    try {
      Log.info('更新项目: ${project.name} (ID=${project.id})');
      await _databaseService.updateProject(project);
      await loadAllProjects(); // 重新加载列表
      Log.info('项目更新成功: ${project.name}');
      return true;
    } catch (e, stackTrace) {
      Log.error('更新项目时发生错误: ${project.name} (ID=${project.id})', e, stackTrace);
      return false;
    }
  }
  
  Future<bool> deleteProject(int id) async {
    try {
      Log.info('删除项目: ID=$id');
      await _databaseService.deleteProject(id);
      await loadAllProjects(); // 重新加载列表
      Log.info('项目删除成功: ID=$id');
      return true;
    } catch (e, stackTrace) {
      Log.error('删除项目时发生错误: ID=$id', e, stackTrace);
      return false;
    }
  }
  
  void clearSearch() {
    Log.debug('清空搜索条件');
    _searchQuery = '';
    _filteredProjects = List.from(_projects);
    notifyListeners();
  }

  /// 拖拽调整项目顺序：先本地调整顺序并即时刷新 UI，再异步持久化到数据库。
  /// 仅在未搜索（完整列表）状态下调用。
  ///
  /// 返回值：
  /// - true  表示已成功落库（含被忽略的越界/同位移动等 no-op 场景）
  /// - false 表示本地已调整但持久化失败，调用方可据此提示用户
  Future<bool> reorderProjects(int oldIndex, int newIndex) async {
    // ReorderableListView 的 newIndex 在向下移动时是「插入位置」，需要 -1 修正
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (oldIndex < 0 ||
        oldIndex >= _projects.length ||
        newIndex < 0 ||
        newIndex >= _projects.length) {
      Log.warning('拖拽索引越界，忽略: old=$oldIndex new=$newIndex len=${_projects.length}');
      return true; // no-op，无须提示用户
    }
    if (oldIndex == newIndex) return true;

    final moved = _projects.removeAt(oldIndex);
    _projects.insert(newIndex, moved);
    _filteredProjects = List.from(_projects);
    notifyListeners();

    try {
      // 防御性过滤：理论上 DB 读出的项目 id 恒非空，
      // 此处用 whereType<int> 过滤未持久化对象，避免非空断言带来的潜在 crash。
      final orderedIds = _projects
          .map((p) => p.id)
          .whereType<int>()
          .toList(growable: false);
      if (orderedIds.length != _projects.length) {
        Log.warning(
            '存在未持久化项目，跳过 ${_projects.length - orderedIds.length} 个无 id 项');
      }
      await _databaseService.updateProjectsOrder(orderedIds);
      Log.info('项目顺序调整成功: ${moved.name} ($oldIndex -> $newIndex)');
      return true;
    } catch (e, stackTrace) {
      Log.error('持久化项目顺序失败', e, stackTrace);
      return false;
    }
  }

  double getProjectTotalValue(TCGProject project) {
    final totalValue = project.cards.fold(0.0, (sum, card) => sum + card.currentPrice);
    Log.debug('计算项目总价值: ${project.name} = ¥${totalValue.toStringAsFixed(2)}');
    return totalValue;
  }
}