import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool? _isWebOverride; // For testing

  // SharedPreferences key for web fallback
  static const String _webTasksKey = 'local_tasks_store';

  DatabaseHelper._init();

  bool get _isWeb => _isWebOverride ?? kIsWeb;

  Future<Database?> get database async {
    if (_isWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('study_planner_tasks.db');
    return _database!;
  }

  Future<Database?> _initDB(String filePath) async {
    if (_isWeb) return null;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
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
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tasks_new (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL,
            color INTEGER NOT NULL,
            type TEXT NOT NULL,
            isCompleted INTEGER NOT NULL,
            priority INTEGER NOT NULL DEFAULT 2,
            hasAiPlan INTEGER NOT NULL DEFAULT 0,
            preparationPlan TEXT
          )
        ''');
        await db.execute('INSERT OR IGNORE INTO tasks_new SELECT * FROM tasks');
        await db.execute('DROP TABLE tasks');
        await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
      } catch (_) {
        // If already correct schema, ignore
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
  preparationPlan TEXT
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

    // Key-Value Store for simple settings
    await db.execute('''
CREATE TABLE settings (
  key $textType PRIMARY KEY,
  value $textType
)
''');
  }

  // ═══════════════════════════════════════════════════════════════
  // Web fallback helpers (SharedPreferences JSON store)
  // ═══════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _loadWebTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webTasksKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      return List<Map<String, dynamic>>.from(
        (decoded as List).map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      debugPrint("Error loading web tasks: $e");
      return [];
    }
  }

  Future<void> _saveWebTasks(List<Map<String, dynamic>> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_webTasksKey, jsonEncode(tasks));
    } catch (e) {
      debugPrint("Error saving web tasks: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Task Operations (with web fallback)
  // ═══════════════════════════════════════════════════════════════

  Future<int> createTask(Task task) async {
    if (_isWeb) {
      final tasks = await _loadWebTasks();
      tasks.removeWhere((t) => t['id'] == task.id);
      tasks.add(task.toMap());
      await _saveWebTasks(tasks);
      return 1;
    }
    final db = await instance.database;
    if (db == null) return 0;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Task> readTask(String id) async {
    if (_isWeb) {
      final tasks = await _loadWebTasks();
      final match = tasks.where((t) => t['id'] == id).toList();
      if (match.isNotEmpty) {
        return Task.fromMap(match.first);
      }
      throw Exception('ID $id not found');
    }
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
    if (_isWeb) {
      final tasks = await _loadWebTasks();
      return tasks.map((json) => Task.fromMap(json)).toList();
    }
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('tasks');
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    if (_isWeb) {
      final tasks = await _loadWebTasks();
      final index = tasks.indexWhere((t) => t['id'] == task.id);
      if (index != -1) {
        tasks[index] = task.toMap();
      } else {
        tasks.add(task.toMap());
      }
      await _saveWebTasks(tasks);
      return 1;
    }
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
    if (_isWeb) {
      final tasks = await _loadWebTasks();
      tasks.removeWhere((t) => t['id'] == id);
      await _saveWebTasks(tasks);
      return 1;
    }
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
