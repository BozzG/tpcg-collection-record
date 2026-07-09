import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

/// 图鉴手动封面覆盖的持久化存储（`pokedexNumber → cardId`）。
///
/// 用户可在「编号详情」里手动把某张卡设为该图鉴号的封面。为避免改动数据库
/// 表结构，这里仿 [ThemeNotifier] 的 shared_preferences 模式，将覆盖映射以
/// JSON 字符串存于单个 key。读写失败仅记日志、回退为空映射，不阻断 UI
/// （无覆盖时上层走默认封面算法）。
class PokedexCoverStore {
  PokedexCoverStore._();

  static final PokedexCoverStore instance = PokedexCoverStore._();

  static const String _prefsKey = 'pokedex_cover_overrides';

  Map<int, int> _overrides = {};
  bool _loaded = false;
  Future<void>? _loading;

  /// 幂等加载覆盖映射。
  Future<void> ensureLoaded() {
    if (_loaded) return Future.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      _overrides = _decode(raw);
      _loaded = true;
      Log.info('图鉴封面覆盖加载成功，共 ${_overrides.length} 条');
    } catch (e, st) {
      Log.error('图鉴封面覆盖加载失败，回退为空映射', e, st);
      _overrides = {};
      _loaded = true;
    } finally {
      _loading = null;
    }
  }

  /// 返回某编号的手动封面 cardId；无覆盖返回 null。
  int? overrideFor(int number) => _overrides[number];

  /// 当前全部覆盖映射的只读副本。
  Map<int, int> get all => Map.unmodifiable(_overrides);

  /// 设置某编号的手动封面并持久化。
  Future<void> setCover(int number, int cardId) async {
    _overrides[number] = cardId;
    await _save();
  }

  /// 清除某编号的手动封面（回退默认算法）并持久化。
  Future<void> clearCover(int number) async {
    _overrides.remove(number);
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _encode(_overrides));
    } catch (e, st) {
      Log.warning('图鉴封面覆盖持久化失败（不影响当前会话）', e, st);
    }
  }

  String _encode(Map<int, int> map) {
    return json.encode(map.map((k, v) => MapEntry(k.toString(), v)));
  }

  Map<int, int> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final out = <int, int>{};
      decoded.forEach((k, v) {
        final key = int.tryParse(k);
        final value = v is int ? v : int.tryParse('$v');
        if (key != null && value != null) out[key] = value;
      });
      return out;
    } catch (_) {
      return {};
    }
  }
}
