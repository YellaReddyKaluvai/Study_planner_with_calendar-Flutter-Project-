import 'package:flutter/material.dart';
import '../../models/study_task.dart';
import '../../theme/app_theme.dart';

class TaskTile extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyColor = {
      TaskDifficulty.easy: Colors.greenAccent,
      TaskDifficulty.medium: Colors.orangeAccent,
      TaskDifficulty.hard: Colors.redAccent,
    }[task.difficulty];

    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: Colors.green.withOpacity(0.5),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red.withOpacity(0.7),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        } else {
          onDelete();
          return false;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: task.isCompleted
                ? Colors.greenAccent.withOpacity(0.5)
                : AppTheme.neonCyan.withOpacity(0.3),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: task.isCompleted ? Colors.greenAccent : AppTheme.neonCyan,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          task.isCompleted ? FontWeight.w400 : FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          task.subject,
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: AppTheme.bgDark,
                        side: BorderSide(
                            color: AppTheme.neonCyan.withOpacity(0.5)),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          '${task.estimatedMinutes} min',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: AppTheme.bgDark,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: difficultyColor!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: difficultyColor),
                        ),
                        child: Text(
                          task.difficulty.name.toUpperCase(),
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
