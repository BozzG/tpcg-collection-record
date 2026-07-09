import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tpcg_collection_record/utils/logger.dart';

/// 宝可梦中文名录服务（离线）。
///
/// 一次性从打包的 `assets/pokedex/pokedex_names_zh.json` 加载 1..1025 的
/// 简体中文名并缓存为 `Map<int,String>`，之后 [nameOf] 查名为 O(1)。
/// **运行时零联网**。加载失败仅记日志，[nameOf] 回退为「No.xxx」。
class PokedexNameService {
  PokedexNameService._();

  static final PokedexNameService instance = PokedexNameService._();

  static const String _assetPath = 'assets/pokedex/pokedex_names_zh.json';

  Map<int, String> _names = const {};
  bool _loaded = false;
  Future<void>? _loading;

  /// 是否已成功加载名录。
  bool get isLoaded => _loaded;

  /// 幂等加载名录；并发调用共享同一次加载 Future。
  Future<void> ensureLoaded() {
    if (_loaded) return Future.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> decoded =
          json.decode(raw) as Map<String, dynamic>;
      final parsed = <int, String>{};
      decoded.forEach((key, value) {
        final n = int.tryParse(key);
        if (n != null && value is String) {
          parsed[n] = value;
        }
      });
      _names = parsed;
      _loaded = true;
      Log.info('宝可梦中文名录加载成功，共 ${_names.length} 条');
    } catch (e, st) {
      Log.error('宝可梦中文名录加载失败，查名将回退为编号占位', e, st);
      _names = const {};
      _loaded = true; // 标记为已加载以避免反复重试，走占位回退
    } finally {
      _loading = null;
    }
  }

  /// 按编号查中文名；未命中（含未加载）时回退为「No.xxx」占位。
  String nameOf(int number) {
    final name = _names[number];
    if (name != null && name.isNotEmpty) return name;
    return 'No.$number';
  }
}
