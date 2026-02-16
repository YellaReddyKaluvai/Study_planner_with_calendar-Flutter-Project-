import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../shared/glass_container.dart';
import 'widgets/task_creation_sheet.dart';
import '../../../../core/theme/app_theme.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background moved here if not covered by HomePage stack, but HomePage stack covers it.
        // Actually HomePage stack covers this, so we just need content.
        // But let's be safe and make it transparent or just content.
        color: const Color(0xff0A0E17).withOpacity(0.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "My Tasks",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: taskProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = taskProvider.tasks[index];
                        return Dismissible(
                          key: Key(task.id),
                          background: Container(
                            color: AppTheme.success,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: AppTheme.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            taskProvider.deleteTask(task.id);
                          },
                          child: GlassContainer(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: task.color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              title: Text(
                                task.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                task.description,
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: const Icon(Icons.chevron_right,
                                  color: Colors.white54),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const TaskCreationSheet(),
          );
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
