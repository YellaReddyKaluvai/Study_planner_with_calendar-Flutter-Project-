import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('study_planner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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
    return await db.insert('tasks', task.toMap());
  }

  Future<Task> readTask(String id) async {
    final db = await instance.database;
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
    final result = await db.query('tasks');
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Chat Operations ---

  Future<int> saveMessage(Map<String, dynamic> message) async {
    final db = await instance.database;
    return await db.insert('chat_messages', message);
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final db = await instance.database;
    return await db.query('chat_messages', orderBy: 'timestamp ASC');
  }

  Future<void> clearChatHistory() async {
    final db = await instance.database;
    await db.delete('chat_messages');
  }

  // --- Settings Operations ---

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
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
