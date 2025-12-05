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

  // Initialize logging
  Log.info('应用启动中...');

  try {
    // Initialize database
    Log.info('初始化数据库...');
    final databaseService = DatabaseService();
    await databaseService.initDatabase();
    Log.info('数据库初始化完成');

    runApp(MyApp(databaseService: databaseService));
  } catch (e, stackTrace) {
    Log.fatal('应用启动失败', e, stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;

  const MyApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    Log.info('构建应用主界面');

    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(databaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => CardViewModel(databaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => ProjectViewModel(databaseService),
        ),
      ],
      child: MaterialApp(
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
        home: const HomePage(),
      ),
    );
  }
}
