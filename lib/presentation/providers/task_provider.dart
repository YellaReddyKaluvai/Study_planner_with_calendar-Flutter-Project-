import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Complete Math Assignment',
      description: 'Chapter 5 exercises',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      color: AppTheme.primary,
      type: 'study',
    ),
    Task(
      id: '2',
      title: 'Physics Project Research',
      description: 'Find sources for paper',
      startTime: DateTime.now().add(const Duration(hours: 3)),
      endTime: DateTime.now().add(const Duration(hours: 5)),
      color: AppTheme.secondary,
      type: 'assignment',
    ),
  ];

  List<Task> get tasks => _tasks;

  void addTask(
      {required String title,
      required String description,
      required DateTime startTime,
      required DateTime endTime,
      required Color color,
      int priority = 2}) {
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
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
