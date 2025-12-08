import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/viewmodels/home_viewmodel.dart';
import 'package:tpcg_collection_record/viewmodels/card_viewmodel.dart';
import 'package:tpcg_collection_record/viewmodels/project_viewmodel.dart';
import 'package:tpcg_collection_record/views/home_page.dart';
import 'package:tpcg_collection_record/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging with error handling
  try {
    Log.info('应用启动中...');
  } catch (e) {
    print('日志系统初始化失败: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TPCG Collection Record',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigoAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const DatabaseInitializer(),
    );
  }
}

class DatabaseInitializer extends StatefulWidget {
  const DatabaseInitializer({super.key});

  @override
  State<DatabaseInitializer> createState() => _DatabaseInitializerState();
}

class _DatabaseInitializerState extends State<DatabaseInitializer> {
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
      
      // 添加超时保护
      await service.initDatabase().timeout(
        const Duration(seconds: 10),
      );
      
      if (mounted) {
        setState(() {
          databaseService = service;
          isLoading = false;
        });
      }
      Log.info('数据库初始化完成');
    } catch (e, stackTrace) {
      Log.fatal('数据库初始化失败', e, stackTrace);
      if (mounted) {
        setState(() {
          errorMessage = '数据库初始化失败: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在初始化应用...'),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  '应用初始化失败',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
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
              ],
            ),
          ),
        ),
      );
    }

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
      ],
      child: const HomePage(),
    );
  }
}
