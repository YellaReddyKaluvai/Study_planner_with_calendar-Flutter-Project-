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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.bgCard : Colors.white;
    final borderColor = task.isCompleted
        ? Colors.greenAccent.withOpacity(0.5)
        : AppTheme.neonCyan.withOpacity(0.3);
    
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        } else {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Task'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          if (result == true) {
            onDelete();
          }
          return false;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 12),
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
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight:
                          task.isCompleted ? FontWeight.w400 : FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        label: Text(
                          task.subject,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        backgroundColor: isDark ? AppTheme.bgDark : Colors.grey[200],
                        side: BorderSide(
                            color: AppTheme.neonCyan.withOpacity(0.5)),
                      ),
                      Chip(
                        label: Text(
                          '${task.estimatedMinutes} min',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        backgroundColor: isDark ? AppTheme.bgDark : Colors.grey[200],
                      ),
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
                            fontWeight: FontWeight.bold,
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
