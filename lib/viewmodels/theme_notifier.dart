import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

/// 主题模式管理（带持久化）
///
/// - 默认 [ThemeMode.system]（跟随系统）
/// - 通过 [shared_preferences] 持久化用户选择，重启 App 后保持
/// - 持久化失败仅记录日志，不影响内存中的切换体验
class ThemeNotifier extends ChangeNotifier {
  static const String _prefsKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  /// 切换主题：light/system → dark；dark → light
  Future<void> toggle() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _saveToPrefs(_themeMode);
  }

  /// 启动时异步加载持久化的主题选择
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      final loaded = _decode(stored);
      if (loaded != _themeMode) {
        _themeMode = loaded;
        notifyListeners();
      }
    } catch (e, st) {
      Log.error('ThemeNotifier 加载持久化主题失败，沿用默认 system', e, st);
    }
  }

  Future<void> _saveToPrefs(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _encode(mode));
    } catch (e, st) {
      Log.warning('ThemeNotifier 持久化主题失败（不影响当前会话切换）', e, st);
    }
  }

  String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _decode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
