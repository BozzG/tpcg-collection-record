import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/models/ptcg_project.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path =
        join(documentsDirectory.path, 'tpcg_collection_production.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // 创建项目表
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // 创建卡片表
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
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
  }

  // 项目相关操作
  Future<int> insertProject(PTCGProject project) async {
    final db = await database;
    return await db.insert('projects', {
      'name': project.name,
      'description': project.description,
    });
  }

  Future<List<PTCGProject>> getAllProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('projects');

    List<PTCGProject> projects = [];
    for (var map in maps) {
      final cards = await getCardsByProjectId(map['id']);
      projects.add(PTCGProject(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        cards: cards,
      ));
    }
    return projects;
  }

  Future<PTCGProject?> getProjectById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final cards = await getCardsByProjectId(id);
    return PTCGProject(
      id: maps.first['id'],
      name: maps.first['name'],
      description: maps.first['description'],
      cards: cards,
    );
  }

  Future<int> updateProject(PTCGProject project) async {
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

  Future<List<PTCGProject>> searchProjects(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    List<PTCGProject> projects = [];
    for (var map in maps) {
      final cards = await getCardsByProjectId(map['id']);
      projects.add(PTCGProject(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        cards: cards,
      ));
    }
    return projects;
  }

  // 卡片相关操作
  Future<int> insertCard(PTCGCard card) async {
    final db = await database;
    return await db.insert('cards', {
      'project_id': card.projectId,
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

  Future<List<PTCGCard>> getAllCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cards');

    return List.generate(maps.length, (i) {
      return PTCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
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

  Future<List<PTCGCard>> getCardsByProjectId(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );

    return List.generate(maps.length, (i) {
      return PTCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
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

  Future<PTCGCard?> getCardById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return PTCGCard(
      id: maps.first['id'],
      projectId: maps.first['project_id'],
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

  Future<int> updateCard(PTCGCard card) async {
    final db = await database;
    return await db.update(
      'cards',
      {
        'project_id': card.projectId,
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

  Future<List<PTCGCard>> searchCards(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'name LIKE ? OR issue_number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return PTCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
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

  Future<List<PTCGCard>> getRecentCards({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      orderBy: 'id DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return PTCGCard(
        id: maps[i]['id'],
        projectId: maps[i]['project_id'],
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
