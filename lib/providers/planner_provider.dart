import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/study_task.dart';
import '../services/local_db_service.dart';
import '../services/ai_planner_service.dart';

class PlannerProvider extends ChangeNotifier {
  final _localDb = LocalDbService();
  final _ai = AiPlannerService();
  final _uuid = const Uuid();

  List<StudyTask> _tasks = [];
  bool _loading = false;

  List<StudyTask> get tasks => _tasks;
  bool get isLoading => _loading;

  // -----------------------------
  // LOAD TASKS (OFFLINE ONLY)
  // -----------------------------
  Future<void> loadTasks() async {
    _loading = true;
    notifyListeners();

    try {
      _tasks = await _localDb.getTasks();
    } catch (_) {
      _tasks = [];
    }

    _loading = false;
    notifyListeners();
  }

  // -----------------------------
  // ADD TASK
  // (auto schedules on due date)
  // -----------------------------
  Future<void> addTask({
    required String title,
    required String subject,
    required DateTime dueDate,
    required int minutes,
    required TaskDifficulty difficulty,
  }) async {

    final task = StudyTask(
      id: _uuid.v4(),
      title: title,
      subject: subject,
      dueDate: dueDate,
      estimatedMinutes: minutes,
      difficulty: difficulty,

      // ensures calendar slot appears
      scheduledStart: DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        18, 0,
      ),
      scheduledEnd: DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        19, 0,
      ),
    );

    await _localDb.upsertTask(task);

    _tasks.add(task);
    notifyListeners();
      print("Task added: ${task.title}");
  }

  // -----------------------------
  // TOGGLE COMPLETION
  // -----------------------------
  Future<void> toggleTaskCompletion(StudyTask task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
    );

    await _localDb.upsertTask(updated);

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = updated;
    }

    notifyListeners();
  }

  // -----------------------------
  // DELETE TASK
  // -----------------------------
  Future<void> deleteTask(StudyTask task) async {
    await _localDb.deleteTask(task.id);

    _tasks.removeWhere((t) => t.id == task.id);

    notifyListeners();
  }

  // -----------------------------
  // AI PLANNER (OFFLINE)
  // -----------------------------
  Future<void> generateAiPlan() async {
    final planned = _ai.generatePlan(
      tasks: _tasks,
      startDate: DateTime.now(),
    );

    for (final t in planned) {
      await _localDb.upsertTask(t);
    }

    _tasks = planned;
    notifyListeners();
  }

  // -----------------------------
  // PATTERN ANALYTICS
  // -----------------------------
  Map<String, dynamic> getPatterns() {
    return _ai.detectPatterns(_tasks);
  }
}
