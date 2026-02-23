import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/gemini_service.dart';
import '../../core/data/database_helper.dart';
import 'gamification_provider.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    loadTasks();
    // Listen to auth changes to sync when user logs in
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadTasks();
      }
    });
  }

  String? get _userId => _auth.currentUser?.uid;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Load from local DB first (fast)
      _tasks = await DatabaseHelper.instance.readAllTasks();
      notifyListeners();
      
      // Then sync from Firestore if user is logged in
      if (_userId != null) {
        await _syncFromFirestore();
      }
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncFromFirestore() async {
    if (_userId == null) return;
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final startTime = data['startTime'];
        final endTime = data['endTime'];

        final task = Task(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          startTime: startTime is Timestamp
              ? startTime.toDate()
              : (startTime is String ? DateTime.parse(startTime) : DateTime.now()),
          endTime: endTime is Timestamp
              ? endTime.toDate()
              : (endTime is String ? DateTime.parse(endTime) : DateTime.now()),
          color: Color(data['color'] ?? 0xFF6366F1),
          priority: data['priority'] ?? 2,
          type: data['type'] ?? 'study',
          isCompleted: data['isCompleted'] ?? false,
          preparationPlan: data['preparationPlan'],
        );
        
        // Update local DB
        await DatabaseHelper.instance.createTask(task);
      }
      
      // Reload from local DB
      _tasks = await DatabaseHelper.instance.readAllTasks();
      notifyListeners();
    } catch (e) {
      debugPrint("Error syncing from Firestore: $e");
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required Color color,
    int priority = 2,
    String type = 'study',
  }) async {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      color: color,
      priority: priority,
      type: type,
    );

    _tasks.add(newTask);
    notifyListeners();

    // Save to local DB
    await DatabaseHelper.instance.createTask(newTask);
    
    // Save to Firestore
    if (_userId != null) {
      await _saveToFirestore(newTask);
    }

    // Trigger AI Generation
    _generatePlanForTask(newTask);
  }

  Future<void> _saveToFirestore(Task task) async {
    if (_userId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(task.id)
          .set({
        'title': task.title,
        'description': task.description,
        'startTime': Timestamp.fromDate(task.startTime),
        'endTime': Timestamp.fromDate(task.endTime),
        'color': task.color.value,
        'priority': task.priority,
        'type': task.type,
        'isCompleted': task.isCompleted,
        'preparationPlan': task.preparationPlan,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error saving to Firestore: $e");
    }
  }

  Future<void> _generatePlanForTask(Task task) async {
    try {
      final aiService = GeminiService();
      final plan = await aiService.generatePreparationPlan(task);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final updatedTask = _tasks[index].copyWith(preparationPlan: plan);
        _tasks[index] = updatedTask;
        notifyListeners();

        await DatabaseHelper.instance.updateTask(updatedTask);
        
        // Update in Firestore
        if (_userId != null) {
          await _saveToFirestore(updatedTask);
        }
      }
    } catch (e) {
      debugPrint("Failed to generate AI plan: $e");
    }
  }

  GamificationProvider? _gamificationProvider;

  void updateGamification(GamificationProvider provider) {
    _gamificationProvider = provider;
  }

  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final isNowCompleted = !task.isCompleted;
      final updatedTask = task.copyWith(isCompleted: isNowCompleted);

      _tasks[index] = updatedTask;
      notifyListeners();

      await DatabaseHelper.instance.updateTask(updatedTask);
      
      // Update in Firestore
      if (_userId != null) {
        await _saveToFirestore(updatedTask);
      }

      if (isNowCompleted) {
        _gamificationProvider?.addXP(50);
      }
    }
  }
  
  // Alias for compatibility
  Future<void> toggleTaskCompletion(String id) async {
    await toggleTaskStatus(id);
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
      await DatabaseHelper.instance.updateTask(updatedTask);
      if (_userId != null) {
        await _saveToFirestore(updatedTask);
      }
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    
    await DatabaseHelper.instance.deleteTask(id);
    
    // Delete from Firestore
    if (_userId != null) {
      try {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('tasks')
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint("Error deleting from Firestore: $e");
      }
    }
  }
}
