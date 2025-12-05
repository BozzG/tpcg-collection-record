import 'package:tpcg_collection_record/utils/logger.dart';

/// 日志使用示例
/// 
/// 这个文件展示了如何在应用中使用日志组件
class LoggerExample {
  
  /// 演示各种日志级别的使用
  static void demonstrateLogging() {
    // 调试日志 - 用于开发调试，生产环境不显示
    Log.debug('这是调试信息，用于开发时追踪程序执行');
    
    // 信息日志 - 记录一般信息
    Log.info('用户登录成功');
    Log.info('数据加载完成，共加载 ${100} 条记录');
    
    // 警告日志 - 记录可能的问题
    Log.warning('网络连接不稳定，正在重试');
    Log.warning('缓存即将过期');
    
    // 错误日志 - 记录错误信息
    Log.error('网络请求失败');
    
    // 带异常信息的错误日志
    try {
      throw Exception('模拟异常');
    } catch (e, stackTrace) {
      Log.error('捕获到异常', e, stackTrace);
    }
    
    // 致命错误日志 - 记录致命错误
    Log.fatal('应用启动失败，无法继续运行');
  }
  
  /// 演示在异步操作中使用日志
  static Future<void> demonstrateAsyncLogging() async {
    Log.info('开始异步操作');
    
    try {
      // 模拟异步操作
      await Future.delayed(const Duration(seconds: 1));
      Log.info('异步操作完成');
    } catch (e, stackTrace) {
      Log.error('异步操作失败', e, stackTrace);
    }
  }
  
  /// 演示在数据库操作中使用日志
  static Future<void> demonstrateDatabaseLogging() async {
    Log.debug('准备执行数据库查询');
    
    try {
      // 模拟数据库操作
      Log.info('执行SQL: SELECT * FROM cards WHERE project_id = ?');
      await Future.delayed(const Duration(milliseconds: 100));
      Log.info('查询完成，返回 5 条记录');
    } catch (e, stackTrace) {
      Log.error('数据库查询失败', e, stackTrace);
    }
  }
}

/// 日志最佳实践
/// 
/// 1. 使用合适的日志级别：
///    - Debug: 开发调试信息
///    - Info: 一般业务信息
///    - Warning: 潜在问题
///    - Error: 错误信息
///    - Fatal: 致命错误
/// 
/// 2. 提供有意义的日志消息：
///    - 包含足够的上下文信息
///    - 使用清晰的描述
///    - 避免敏感信息（如密码、令牌）
/// 
/// 3. 在异常处理中使用日志：
///    - 记录异常信息和堆栈跟踪
///    - 提供错误发生的上下文
/// 
/// 4. 性能考虑：
///    - Debug日志在生产环境会被过滤
///    - 避免在循环中大量打印日志
///    - 使用延迟计算避免不必要的字符串构建