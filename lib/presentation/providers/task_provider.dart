import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/gemini_service.dart';
import '../../core/data/database_helper.dart';
import 'gamification_provider.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await DatabaseHelper.instance.readAllTasks();
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required Color color,
    int priority = 2,
  }) async {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      color: color,
      priority: priority,
    );

    _tasks.add(newTask);
    notifyListeners();

    await DatabaseHelper.instance.createTask(newTask);

    // Trigger AI Generation
    _generatePlanForTask(newTask);
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

      if (isNowCompleted) {
        _gamificationProvider?.addXP(50);
      }
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    await DatabaseHelper.instance.deleteTask(id);
  }
}
