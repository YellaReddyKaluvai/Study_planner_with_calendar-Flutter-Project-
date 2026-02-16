import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_task.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Database? _db;

  // ---------------------------
  // MOBILE (SQLite)
  // ---------------------------
  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'study_planner.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT,
            subject TEXT,
            dueDate TEXT,
            estimatedMinutes INTEGER,
            difficulty INTEGER,
            isCompleted INTEGER,
            scheduledStart TEXT,
            scheduledEnd TEXT
          )
        ''');
      },
    );
  }

  // ---------------------------
  // WEB (Shared Preferences)
  // ---------------------------
  static const _storeKey = "tasks_store";

  Future<List<Map<String, dynamic>>> _loadWebStore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  Future<void> _saveWebStore(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKey, jsonEncode(data));
  }

  // ---------------------------
  // UPSERT
  // ---------------------------
  Future<void> upsertTask(StudyTask task) async {
    if (kIsWeb) {
      final data = await _loadWebStore();
      data.removeWhere((t) => t["id"] == task.id);
      data.add(_encode(task));
      await _saveWebStore(data);
      return;
    }

    final db = await _database;
    await db.insert(
      'tasks',
      _encode(task),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------
  // DELETE
  // ---------------------------
  Future<void> deleteTask(String id) async {
    if (kIsWeb) {
      final data = await _loadWebStore();
      data.removeWhere((t) => t["id"] == id);
      await _saveWebStore(data);
      return;
    }

    final db = await _database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------
  // READ ALL
  // ---------------------------
  Future<List<StudyTask>> getTasks() async {
    List<Map<String, dynamic>> rows;

    if (kIsWeb) {
      rows = await _loadWebStore();
    } else {
      final db = await _database;
      rows = await db.query('tasks');
    }

    return rows.map(_decode).toList();
  }

  // ---------------------------
  // SERIALIZERS
  // ---------------------------
  Map<String, dynamic> _encode(StudyTask t) => {
        'id': t.id,
        'title': t.title,
        'subject': t.subject,
        'dueDate': t.dueDate.toIso8601String(),
        'estimatedMinutes': t.estimatedMinutes,
        'difficulty': t.difficulty.index,
        'isCompleted': t.isCompleted ? 1 : 0,
        'scheduledStart': t.scheduledStart?.toIso8601String(),
        'scheduledEnd': t.scheduledEnd?.toIso8601String(),
      };

  StudyTask _decode(Map<String, dynamic> m) {
    return StudyTask(
      id: m['id'] as String,
      title: m['title'] as String,
      subject: m['subject'] as String,
      dueDate: DateTime.parse(m['dueDate'] as String),
      estimatedMinutes: m['estimatedMinutes'] as int,
      difficulty: TaskDifficulty.values[m['difficulty'] as int],
      isCompleted: (m['isCompleted'] as int) == 1,
      scheduledStart: m['scheduledStart'] != null
          ? DateTime.parse(m['scheduledStart'] as String)
          : null,
      scheduledEnd: m['scheduledEnd'] != null
          ? DateTime.parse(m['scheduledEnd'] as String)
          : null,
    );
  }
}
