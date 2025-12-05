import 'package:logger/logger.dart';

/// 应用日志工具类
/// 
/// 提供统一的日志记录接口，支持不同级别的日志输出
/// 在开发环境显示详细日志，生产环境只显示错误日志
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // 显示调用栈的方法数量
      errorMethodCount: 8, // 错误时显示更多调用栈
      lineLength: 120, // 每行字符数
      colors: true, // 启用颜色
      printEmojis: true, // 启用表情符号
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // 显示时间戳
    ),
    level: _getLogLevel(),
  );

  /// 根据环境获取日志级别
  static Level _getLogLevel() {
    // 在debug模式下显示所有日志，release模式下只显示错误
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    return isDebug ? Level.debug : Level.error;
  }

  /// 调试日志 - 用于开发调试
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 信息日志 - 用于记录一般信息
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志 - 用于记录警告信息
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志 - 用于记录错误信息
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 致命错误日志 - 用于记录致命错误
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

/// 日志工具类的简化别名
typedef Log = AppLogger;