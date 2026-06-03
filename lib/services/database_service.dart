import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/models/ptcg_project.dart';
import 'package:tpcg_collection_record/utils/logger.dart';
import 'package:path/path.dart' as p;

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    try {
      Log.info('开始初始化数据库');
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'tpcg_collection.db');
      Log.debug('数据库路径: $path');

      final db = await openDatabase(
        path,
        version: 4,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
      
      Log.info('数据库初始化成功');
      return db;
    } catch (e, stackTrace) {
      Log.fatal('数据库初始化失败', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    try {
      Log.info('创建数据库表结构，版本: $version');
      
      // 创建项目表
      await db.execute('''
        CREATE TABLE projects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          sort_order INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // 创建卡片表
      await db.execute('''
        CREATE TABLE cards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          project_id INTEGER NOT NULL,
          pokedex_number INTEGER NOT NULL,
          name TEXT NOT NULL,
          issue_number TEXT NOT NULL,
          issue_date TEXT NOT NULL,
          grade TEXT NOT NULL,
          acquired_date TEXT NOT NULL,
          acquired_price REAL NOT NULL,
          current_price REAL NOT NULL,
          front_image TEXT,
          back_image TEXT,
          grade_image TEXT,
          FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
        )
      ''');
      Log.info('数据库表结构创建完成');
    } catch (e, stackTrace) {
      Log.fatal('创建数据库表失败', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    try {
      Log.info('开始数据库升级: $oldVersion -> $newVersion');

      if (oldVersion < 2) {
        Log.debug('升级步骤1: 添加pokedex_number字段');
        // 添加 pokedex_number 字段
        await db.execute(
            'ALTER TABLE cards ADD COLUMN pokedex_number INTEGER DEFAULT 0');
        Log.debug('升级步骤2: pokedex_number字段添加成功');
      }

      if (oldVersion < 3) {
        Log.info('升级步骤: 迁移图片绝对路径为纯文件名');
        await _migrateImagePaths(db);
      }

      if (oldVersion < 4) {
        Log.info('升级步骤: 为 projects 添加 sort_order 列并回填存量顺序');
        await _migrateProjectSortOrder(db);
        Log.info('升级步骤: 规范化 cards 日期字段为零填充 yyyy-MM-dd');
        await _normalizeCardDateFormats(db);
      }

      Log.info('数据库升级完成');
    } catch (e, stackTrace) {
      Log.fatal('数据库升级失败', e, stackTrace);
      rethrow;
    }
  }

  /// 将 front_image / back_image / grade_image 中的绝对路径转为纯文件名。
  /// 这样 App 重装/升级导致沙箱 UUID 变化时，图片仍可被找回。
  Future<void> _migrateImagePaths(Database db) async {
    final columns = ['front_image', 'back_image', 'grade_image'];
    final rows = await db.query('cards', columns: ['id', ...columns]);
    int migrated = 0;

    for (final row in rows) {
      final id = row['id'] as int;
      final updates = <String, Object?>{};

      for (final col in columns) {
        final value = row[col] as String?;
        if (value != null && value.contains('/')) {
          // 绝对路径 → 取纯文件名
          updates[col] = p.basename(value);
        }
      }

      if (updates.isNotEmpty) {
        await db.update('cards', updates, where: 'id = ?', whereArgs: [id]);
        migrated++;
      }
    }

    Log.info('图片路径迁移完成: $migrated 条记录已更新');
  }

  /// 为 projects 表新增 sort_order 列，并按现有 id 升序回填初始顺序，
  /// 保证升级用户首次进入时的项目顺序与历史（id 升序）一致。
  Future<void> _migrateProjectSortOrder(Database db) async {
    await db.execute(
        'ALTER TABLE projects ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0');

    final rows = await db.query('projects', columns: ['id'], orderBy: 'id ASC');
    await db.transaction((txn) async {
      for (int i = 0; i < rows.length; i++) {
        await txn.update(
          'projects',
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [rows[i]['id']],
        );
      }
    });

    Log.info('项目 sort_order 回填完成: ${rows.length} 个项目');
  }

  /// 将 cards 表的 acquired_date / issue_date 规范化为零填充 yyyy-MM-dd。
  ///
  /// 当前写入侧（add/edit_card）已使用 padLeft('0') 写入零填充格式，
  /// 但极早期版本可能存在 `2026-6-3` 这样的非零填充值，
  /// 会导致 `ORDER BY acquired_date DESC` 字符串排序偏离真实时间序。
  /// 此方法对存量数据做一次性规范化；对已合规数据为 no-op。
  Future<void> _normalizeCardDateFormats(Database db) async {
    const columns = ['acquired_date', 'issue_date'];
    int normalized = 0;

    final rows = await db.query('cards', columns: ['id', ...columns]);
    await db.transaction((txn) async {
      for (final row in rows) {
        final updates = <String, Object?>{};
        for (final col in columns) {
          final raw = row[col] as String?;
          final fixed = _normalizeDateString(raw);
          if (fixed != null && fixed != raw) {
            updates[col] = fixed;
          }
        }
        if (updates.isNotEmpty) {
          await txn.update(
            'cards',
            updates,
            where: 'id = ?',
            whereArgs: [row['id']],
          );
          normalized++;
        }
      }
    });

    Log.info('日期字段规范化完成: $normalized 条记录已更新');
  }

  /// 将 `yyyy-M-d` / `yyyy-M-dd` / `yyyy-MM-d` 等非零填充日期转为 `yyyy-MM-dd`；
  /// 无法识别的字符串（含空串）原样返回。
  String? _normalizeDateString(String? raw) {
    if (raw == null || raw.isEmpty) return raw;
    final parts = raw.split('-');
    if (parts.length != 3) return raw;
    final y = parts[0];
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y.length != 4 || m == null || d == null) return raw;
    return '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
  }

  // 项目相关操作
  Future<int> insertProject(TCGProject project) async {
    final db = await database;
    // 新项目排到列表末尾：取当前最大 sort_order + 1
    final result = await db
        .rawQuery('SELECT MAX(sort_order) as max_order FROM projects');
    final maxOrder = (result.first['max_order'] as int?) ?? -1;
    return await db.insert('projects', {
      'name': project.name,
      'description': project.description,
      'sort_order': maxOrder + 1,
    });
  }

  Future<List<TCGProject>> getAllProjects() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query('projects', orderBy: 'sort_order ASC, id ASC');

      List<TCGProject> projects = [];
      for (var map in maps) {
        try {
          final cards = await getCardsByProjectId(map['id']);
          projects.add(TCGProject(
            id: map['id'],
            name: map['name'],
            description: map['description'],
            cards: cards,
          ));
        } catch (e, stackTrace) {
          Log.error('处理项目 ${map['name']} 时出错', e, stackTrace);
          continue;
        }
      }
      
      return projects;
    } catch (e, stackTrace) {
      Log.error('查询所有项目时发生错误', e, stackTrace);
      rethrow;
    }
  }

  Future<TCGProject?> getProjectById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final cards = await getCardsByProjectId(id);
    return TCGProject(
      id: maps.first['id'],
      name: maps.first['name'],
      description: maps.first['description'],
      cards: cards,
    );
  }

  Future<int> updateProject(TCGProject project) async {
    final db = await database;
    return await db.update(
      'projects',
      {
        'name': project.name,
        'description': project.description,
      },
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    // 先删除关联的卡片
    await db.delete('cards', where: 'project_id = ?', whereArgs: [id]);
    // 再删除项目
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TCGProject>> searchProjects(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'sort_order ASC, id ASC',
    );

    List<TCGProject> projects = [];
    for (var map in maps) {
      final cards = await getCardsByProjectId(map['id']);
      projects.add(TCGProject(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        cards: cards,
      ));
    }
    return projects;
  }

  /// 按给定的项目 id 顺序批量写回 sort_order。
  /// 使用单事务批量提交，避免逐条 I/O，O(n) 一次落库。
  Future<void> updateProjectsOrder(List<int> orderedIds) async {
    final db = await database;
    await db.transaction((txn) async {
      for (int i = 0; i < orderedIds.length; i++) {
        await txn.update(
          'projects',
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [orderedIds[i]],
        );
      }
    });
    Log.info('项目顺序已持久化: ${orderedIds.length} 个项目');
  }

  // 卡片相关操作
  Future<int> insertCard(TCGCard card) async {
    final db = await database;
    return await db.insert('cards', {
      'project_id': card.projectId,
      'pokedex_number': card.pokedexNumber,
      'name': card.name,
      'issue_number': card.issueNumber,
      'issue_date': card.issueDate,
      'grade': card.grade,
      'acquired_date': card.acquiredDate,
      'acquired_price': card.acquiredPrice,
      'current_price': card.currentPrice,
      'front_image': card.frontImage,
      'back_image': card.backImage,
      'grade_image': card.gradeImage,
    });
  }

  Future<List<TCGCard>> getAllCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      orderBy: 'pokedex_number ASC', // 按图鉴编号升序排列
    );

    return List.generate(maps.length, (i) {
      return TCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
        pokedexNumber: maps[i]['pokedex_number'],
        name: maps[i]['name'],
        issueNumber: maps[i]['issue_number'],
        issueDate: maps[i]['issue_date'],
        grade: maps[i]['grade'],
        acquiredDate: maps[i]['acquired_date'],
        acquiredPrice: maps[i]['acquired_price'],
        currentPrice: maps[i]['current_price'],
        frontImage: maps[i]['front_image'],
        backImage: maps[i]['back_image'],
        gradeImage: maps[i]['grade_image'],
      );
    });
  }

  Future<List<TCGCard>> getCardsByProjectId(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'pokedex_number ASC', // 按图鉴编号升序排列
    );

    return List.generate(maps.length, (i) {
      return TCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
        pokedexNumber: maps[i]['pokedex_number'],
        name: maps[i]['name'],
        issueNumber: maps[i]['issue_number'],
        issueDate: maps[i]['issue_date'],
        grade: maps[i]['grade'],
        acquiredDate: maps[i]['acquired_date'],
        acquiredPrice: maps[i]['acquired_price'],
        currentPrice: maps[i]['current_price'],
        frontImage: maps[i]['front_image'],
        backImage: maps[i]['back_image'],
        gradeImage: maps[i]['grade_image'],
      );
    });
  }

  Future<TCGCard?> getCardById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return TCGCard(
      id: maps.first['id'],
      projectId: maps.first['project_id'],
      pokedexNumber: maps.first['pokedex_number'],
      name: maps.first['name'],
      issueNumber: maps.first['issue_number'],
      issueDate: maps.first['issue_date'],
      grade: maps.first['grade'],
      acquiredDate: maps.first['acquired_date'],
      acquiredPrice: maps.first['acquired_price'],
      currentPrice: maps.first['current_price'],
      frontImage: maps.first['front_image'],
      backImage: maps.first['back_image'],
      gradeImage: maps.first['grade_image'],
    );
  }

  Future<int> updateCard(TCGCard card) async {
    final db = await database;
    return await db.update(
      'cards',
      {
        'project_id': card.projectId,
        'pokedex_number': card.pokedexNumber,
        'name': card.name,
        'issue_number': card.issueNumber,
        'issue_date': card.issueDate,
        'grade': card.grade,
        'acquired_date': card.acquiredDate,
        'acquired_price': card.acquiredPrice,
        'current_price': card.currentPrice,
        'front_image': card.frontImage,
        'back_image': card.backImage,
        'grade_image': card.gradeImage,
      },
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TCGCard>> searchCards(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'name LIKE ? OR issue_number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return TCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
        pokedexNumber: maps[i]['pokedex_number'],
        name: maps[i]['name'],
        issueNumber: maps[i]['issue_number'],
        issueDate: maps[i]['issue_date'],
        grade: maps[i]['grade'],
        acquiredDate: maps[i]['acquired_date'],
        acquiredPrice: maps[i]['acquired_price'],
        currentPrice: maps[i]['current_price'],
        frontImage: maps[i]['front_image'],
        backImage: maps[i]['back_image'],
        gradeImage: maps[i]['grade_image'],
      );
    });
  }

  Future<List<TCGCard>> getRecentCards({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      orderBy: 'id DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return TCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
        pokedexNumber: maps[i]['pokedex_number'],
        name: maps[i]['name'],
        issueNumber: maps[i]['issue_number'],
        issueDate: maps[i]['issue_date'],
        grade: maps[i]['grade'],
        acquiredDate: maps[i]['acquired_date'],
        acquiredPrice: maps[i]['acquired_price'],
        currentPrice: maps[i]['current_price'],
        frontImage: maps[i]['front_image'],
        backImage: maps[i]['back_image'],
        gradeImage: maps[i]['grade_image'],
      );
    });
  }

  Future<List<TCGCard>> getTopValueCards({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      orderBy: 'current_price DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return TCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
        pokedexNumber: maps[i]['pokedex_number'],
        name: maps[i]['name'],
        issueNumber: maps[i]['issue_number'],
        issueDate: maps[i]['issue_date'],
        grade: maps[i]['grade'],
        acquiredDate: maps[i]['acquired_date'],
        acquiredPrice: maps[i]['acquired_price'],
        currentPrice: maps[i]['current_price'],
        frontImage: maps[i]['front_image'],
        backImage: maps[i]['back_image'],
        gradeImage: maps[i]['grade_image'],
      );
    });
  }

  /// 按入手时间倒序获取卡片（最新入手在前）。
  ///
  /// 排序约定：`acquired_date` 写入侧（add/edit_card 的 _selectDate）已统一
  /// 输出零填充的 `yyyy-MM-dd` 文本；DB v4 升级也对存量数据做了一次性规范化
  /// （见 [_normalizeCardDateFormats]），因此字符串倒序即真实时间倒序。
  /// 同日卡片以 id DESC 作次级排序。
  Future<List<TCGCard>> getRecentAcquiredCards({int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      orderBy: 'acquired_date DESC, id DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return TCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
        pokedexNumber: maps[i]['pokedex_number'],
        name: maps[i]['name'],
        issueNumber: maps[i]['issue_number'],
        issueDate: maps[i]['issue_date'],
        grade: maps[i]['grade'],
        acquiredDate: maps[i]['acquired_date'],
        acquiredPrice: maps[i]['acquired_price'],
        currentPrice: maps[i]['current_price'],
        frontImage: maps[i]['front_image'],
        backImage: maps[i]['back_image'],
        gradeImage: maps[i]['grade_image'],
      );
    });
  }

  // 统计相关操作
  Future<int> getTotalCardCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cards');
    return result.first['count'] as int;
  }

  Future<int> getTotalProjectCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM projects');
    return result.first['count'] as int;
  }

  Future<double> getTotalValue() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT SUM(current_price) as total FROM cards');
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<double> getTotalCost() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT SUM(acquired_price) as total FROM cards');
    return (result.first['total'] as double?) ?? 0.0;
  }
}
