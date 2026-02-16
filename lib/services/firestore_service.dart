import '../models/study_task.dart';

/// Temporary offline stub.
/// Prevents Firebase from being required during development.

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  /// Do nothing — offline mode
  Future<void> addOrUpdateTask(StudyTask task) async {}

  Future<void> deleteTask(String id) async {}

  /// Return empty stream (no Firebase required)
  Stream<List<StudyTask>> watchTasks() async* {
    yield const [];
  }
}
