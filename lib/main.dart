import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/services/image_service.dart';
import 'package:tpcg_collection_record/viewmodels/home_viewmodel.dart';
import 'package:tpcg_collection_record/viewmodels/card_viewmodel.dart';
import 'package:tpcg_collection_record/viewmodels/project_viewmodel.dart';
import 'package:tpcg_collection_record/viewmodels/theme_notifier.dart';
import 'package:tpcg_collection_record/views/home_page.dart';
import 'package:tpcg_collection_record/theme/app_theme.dart';
import 'package:tpcg_collection_record/utils/logger.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // 添加全局错误处理，防止未捕获的异常导致闪退
  FlutterError.onError = (FlutterErrorDetails details) {
    try {
      debugPrint('Flutter错误: ${details.exception}');
      debugPrint('堆栈跟踪: ${details.stack}');
    } catch (e) {
      // 忽略日志输出错误，防止因日志系统问题导致崩溃
    }
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 安全的日志初始化
    try {
      Log.info('应用启动中...');
    } catch (e) {
      debugPrint('日志系统初始化失败: $e');
    }

    // 桌面平台数据库初始化
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } catch (e) {
        debugPrint('桌面平台数据库初始化失败: $e');
      }
    }

    // 启动应用
    runApp(const AppInitializer());
  }, (error, stackTrace) {
    debugPrint('未捕获的错误: $error');
    debugPrint('堆栈跟踪: $stackTrace');
  });
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  DatabaseService? databaseService;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      Log.info('初始化数据库...');

      final service = DatabaseService();
      await service.initDatabase().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('数据库初始化超时', const Duration(seconds: 30));
        },
      );

      // 预热 ImageService 沙箱路径缓存
      await ImageService.getImagesDirectory();

      if (mounted) {
        setState(() {
          databaseService = service;
          isLoading = false;
        });
      }
      Log.info('数据库初始化完成');
    } on TimeoutException catch (e) {
      Log.error('数据库初始化超时', e);
      if (mounted) {
        setState(() {
          errorMessage = '数据库初始化超时，请重试';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      Log.fatal('数据库初始化失败', e, stackTrace);
      if (mounted) {
        setState(() {
          errorMessage = '数据库初始化失败: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在初始化应用...'),
                SizedBox(height: 8),
                _InitHintText(),
              ],
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _ErrorIcon(),
                  const SizedBox(height: 16),
                  const Text(
                    '应用初始化失败',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const _ErrorText(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _initializeDatabase();
                        },
                        child: const Text('重试'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 启动一个简化版本的应用
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const _SafeModeScaffold(),
                            ),
                          );
                        },
                        child: const Text('安全模式'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 数据库初始化成功，启动正常应用
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService!),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(databaseService!),
        ),
        ChangeNotifierProvider(
          create: (context) => CardViewModel(databaseService!),
        ),
        ChangeNotifierProvider(
          create: (context) => ProjectViewModel(databaseService!),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp(
            title: 'TPCG Collection Record',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeNotifier.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class _InitHintText extends StatelessWidget {
  const _InitHintText();

  @override
  Widget build(BuildContext context) {
    return Text(
      '首次启动可能需要几秒钟',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 12,
      ),
    );
  }
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.error,
      size: 64,
      color: Theme.of(context).colorScheme.error,
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText();

  @override
  Widget build(BuildContext context) {
    final appState = context.findAncestorStateOfType<_AppInitializerState>();
    return Text(
      appState?.errorMessage ?? '',
      style: TextStyle(color: Theme.of(context).colorScheme.error),
      textAlign: TextAlign.center,
    );
  }
}

class _SafeModeScaffold extends StatelessWidget {
  const _SafeModeScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TPCG Collection Record')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              size: 64,
              color: Theme.of(context).colorScheme.errorContainer,
            ),
            const SizedBox(height: 16),
            const Text('应用运行在安全模式'),
            const Text('部分功能可能不可用'),
          ],
        ),
      ),
    );
  }
}
