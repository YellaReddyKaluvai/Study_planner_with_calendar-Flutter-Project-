import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/planner_provider.dart';
import '../../models/study_task.dart';
import '../widgets/neon_button.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  void _showAddTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();

    DateTime? dueDate;
    int minutes = 60;
    TaskDifficulty difficulty = TaskDifficulty.medium;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      )
                    ],
                  ),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),

                        const Text(
                          'Add Study Task',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: subjectCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: now,
                                    firstDate: now,
                                    lastDate: now.add(
                                      const Duration(days: 365),
                                    ),
                                  );

                                  if (picked != null) {
                                    setState(() => dueDate = picked);
                                  }
                                },
                                icon: const Icon(Icons.calendar_today_rounded),
                                label: Text(
                                  dueDate == null
                                      ? 'Due Date'
                                      : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                                ),
                              ),
                            ),

                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text('Minutes: '),

                                  DropdownButton<int>(
                                    dropdownColor: const Color(0xFF050816),
                                    value: minutes,
                                    underline: const SizedBox(),
                                    items: const [30, 45, 60, 90, 120]
                                        .map(
                                          (m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(m.toString()),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => minutes = v ?? 60),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Text('Difficulty: '),
                            const SizedBox(width: 12),

                            ChoiceChip(
                              label: const Text('Easy'),
                              selected: difficulty == TaskDifficulty.easy,
                              onSelected: (_) => setState(() {
                                difficulty = TaskDifficulty.easy;
                              }),
                            ),

                            const SizedBox(width: 8),

                            ChoiceChip(
                              label: const Text('Medium'),
                              selected: difficulty == TaskDifficulty.medium,
                              onSelected: (_) => setState(() {
                                difficulty = TaskDifficulty.medium;
                              }),
                            ),

                            const SizedBox(width: 8),

                            ChoiceChip(
                              label: const Text('Hard'),
                              selected: difficulty == TaskDifficulty.hard,
                              onSelected: (_) => setState(() {
                                difficulty = TaskDifficulty.hard;
                              }),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerRight,
                          child: NeonButton(
                            label: 'Save Task',
                            icon: Icons.check_rounded,
                            onTap: () {
                              if (titleCtrl.text.trim().isEmpty ||
                                  subjectCtrl.text.trim().isEmpty ||
                                  dueDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please fill all fields before saving",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final provider =
                                  Provider.of<PlannerProvider>(
                                    context,
                                    listen: false,
                                  );

                              provider.addTask(
                                title: titleCtrl.text.trim(),
                                subject: subjectCtrl.text.trim(),
                                dueDate: dueDate!,
                                minutes: minutes,
                                difficulty: difficulty,
                              );

                              Navigator.pop(context);
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlannerProvider>(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Today's Tasks",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                IconButton(
                  icon: const Icon(Icons.auto_awesome_rounded),
                  onPressed: () async {
                    await provider.generateAiPlan();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("AI generated a smarter schedule!"),
                      ),
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _showAddTaskDialog(context),
                )
              ],
            ),

            const SizedBox(height: 8),

            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : provider.tasks.isEmpty
                      ? const Center(
                          child: Text("No tasks yet — add one!"),
                        )
                      : ListView.builder(
                          itemCount: provider.tasks.length,
                          itemBuilder: (ctx, i) {
                            final task = provider.tasks[i];

                            return TaskTile(
                              task: task,
                              onToggle: () =>
                                  provider.toggleTaskCompletion(task),
                              onDelete: () =>
                                  provider.deleteTask(task),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
