import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/task.dart';
import '../data/database_helper.dart';

/// Service for backing up and restoring all local data to/from Firestore.
class CloudBackupService {
  static final CloudBackupService _instance = CloudBackupService._internal();
  factory CloudBackupService() => _instance;
  CloudBackupService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference? get _backupDoc {
    if (_userId == null) return null;
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('backups')
        .doc('latest');
  }

  /// Backs up all local data (tasks, chat history, settings) to Firestore.
  Future<bool> backupToCloud() async {
    if (_userId == null) return false;

    try {
      final db = DatabaseHelper.instance;

      // Read all local data
      final tasks = await db.readAllTasks();
      final chatHistory = await db.getChatHistory();
      final apiKey = await db.getSetting('gemini_api_key');

      // Serialize and upload
      await _backupDoc!.set({
        'tasks': tasks.map((t) => t.toMap()).toList(),
        'chatHistory': chatHistory,
        'settings': {
          'gemini_api_key': apiKey ?? '',
        },
        'taskCount': tasks.length,
        'chatCount': chatHistory.length,
        'backedUpAt': FieldValue.serverTimestamp(),
        'deviceInfo': defaultTargetPlatform.toString(),
      });

      debugPrint(
          '☁️ Backup OK: ${tasks.length} tasks, ${chatHistory.length} messages');
      return true;
    } catch (e) {
      debugPrint('☁️ Backup failed: $e');
      return false;
    }
  }

  /// Restores data from the latest cloud backup to local database.
  Future<bool> restoreFromCloud() async {
    if (_userId == null) return false;

    try {
      final snapshot = await _backupDoc!.get();
      if (!snapshot.exists) return false;

      final data = snapshot.data() as Map<String, dynamic>;
      final db = DatabaseHelper.instance;

      // Restore tasks
      final taskMaps = data['tasks'] as List<dynamic>? ?? [];
      for (final raw in taskMaps) {
        try {
          final map = Map<String, dynamic>.from(raw);
          final task = Task.fromMap(map);
          await db.createTask(task);
        } catch (_) {
          // Skip malformed tasks
        }
      }

      // Restore chat history
      final chatMaps = data['chatHistory'] as List<dynamic>? ?? [];
      await db.clearChatHistory();
      for (final raw in chatMaps) {
        await db.saveMessage(Map<String, dynamic>.from(raw));
      }

      // Restore settings
      final settings = data['settings'] as Map<String, dynamic>? ?? {};
      final apiKey = settings['gemini_api_key'] as String?;
      if (apiKey != null && apiKey.isNotEmpty) {
        await db.saveSetting('gemini_api_key', apiKey);
      }

      debugPrint(
          '☁️ Restore OK: ${taskMaps.length} tasks, ${chatMaps.length} messages');
      return true;
    } catch (e) {
      debugPrint('☁️ Restore failed: $e');
      return false;
    }
  }

  /// Returns the timestamp of the last backup, or null if none exists.
  Future<DateTime?> getLastBackupTime() async {
    if (_userId == null) return null;
    try {
      final snapshot = await _backupDoc!.get();
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      final ts = data['backedUpAt'] as Timestamp?;
      return ts?.toDate();
    } catch (e) {
      return null;
    }
  }

  /// Returns backup metadata (counts, timestamp, device).
  Future<Map<String, dynamic>?> getBackupInfo() async {
    if (_userId == null) return null;
    try {
      final snapshot = await _backupDoc!.get();
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        'taskCount': data['taskCount'] ?? 0,
        'chatCount': data['chatCount'] ?? 0,
        'backedUpAt': (data['backedUpAt'] as Timestamp?)?.toDate(),
        'deviceInfo': data['deviceInfo'] ?? 'Unknown',
      };
    } catch (_) {
      return null;
    }
  }
}
