import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool? _isWebOverride; // For testing

  DatabaseHelper._init();

  bool get _isWeb => _isWebOverride ?? kIsWeb;

  Future<Database?> get database async {
    if (_isWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('study_planner.db');
    return _database!;
  }

  Future<Database?> _initDB(String filePath) async {
    if (_isWeb) return null;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery('PRAGMA table_info(tasks)');
      final columnNames = columns.map((c) => c['name'] as String).toList();
      
      if (!columnNames.contains('priority')) {
        await db.execute('ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 2');
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Tasks Table
    await db.execute('''
CREATE TABLE tasks (
  id $idType,
  title $textType,
  description $textType,
  startTime $textType,
  endTime $textType,
  color $integerType,
  type $textType,
  isCompleted $boolType,
  priority $integerType,
  hasAiPlan $boolType,
  preparationPlan $textType
)
''');

    // Chat Messages Table
    await db.execute('''
CREATE TABLE chat_messages (
  id $idType,
  role $textType,
  content $textType,
  timestamp $textType
)
''');

    // Key-Value Store for simple settings (API Key, etc)
    await db.execute('''
CREATE TABLE settings (
  key $textType PRIMARY KEY,
  value $textType
)
''');
  }

  // --- Task Operations ---

  Future<int> createTask(Task task) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Task> readTask(String id) async {
    final db = await instance.database;
    if (db == null) throw Exception('Database not available on Web');
    final maps = await db.query(
      'tasks',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('tasks');
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    if (db == null) return 0;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Chat Operations ---

  Future<int> saveMessage(Map<String, dynamic> message) async {
    final db = await instance.database;
    if (db == null) return 0;
    return await db.insert('chat_messages', message);
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final db = await instance.database;
    if (db == null) return [];
    return await db.query('chat_messages', orderBy: 'timestamp ASC');
  }

  Future<void> clearChatHistory() async {
    final db = await instance.database;
    if (db == null) return;
    await db.delete('chat_messages');
  }

  // --- Settings Operations ---

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    if (db == null) return;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    if (db == null) return null;
    final maps = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }
}
