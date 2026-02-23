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
                    if (taskProvider.tasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in_outlined,
                                size: 80, color: Colors.white24),
                            SizedBox(height: 16),
                            Text(
                              "No tasks yet!",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 18),
                            ),
                          ],
                        ),
                      );
                    }
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
                            child: ExpansionTile(
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.description,
                                    style:
                                        const TextStyle(color: Colors.white54),
                                  ),
                                  if (task.hasAiPlan) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.auto_awesome,
                                            size: 14,
                                            color: AppTheme.secondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          "AI Plan Generated",
                                          style: TextStyle(
                                            color: AppTheme.secondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              children: [
                                if (task.hasAiPlan)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            AppTheme.secondary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppTheme.secondary
                                                .withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Preparation Plan",
                                            style: TextStyle(
                                              color: AppTheme.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            task.preparationPlan!,
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                              collapsedIconColor: Colors.white54,
                              iconColor: AppTheme.primary,
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
