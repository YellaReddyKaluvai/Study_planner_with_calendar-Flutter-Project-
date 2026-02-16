import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/planner_provider.dart';
import '../../models/study_task.dart';
import '../widgets/neon_card.dart';
import '../widgets/task_tile.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<StudyTask> _getTasksForDay(
      List<StudyTask> all, DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return all.where((t) {
      if (t.scheduledStart != null) {
        final s = t.scheduledStart!;
        final sd = DateTime(s.year, s.month, s.day);
        return sd == d;
      }
      // fallback: dueDate
      final dd = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return dd == d;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlannerProvider>(context);
    final tasks = provider.tasks;
    final selectedTasks =
        _getTasksForDay(tasks, _selectedDay ?? DateTime.now());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            NeonCard(
              padding: const EdgeInsets.all(8),
              child: TableCalendar<StudyTask>(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.twoWeeks,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) => _getTasksForDay(tasks, day),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0x3300F5FF),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF00F5FF),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Color(0xFFFF00FF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Schedule for ${_selectedDay?.toLocal().toString().split(' ').first ?? 'Today'}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: selectedTasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No sessions scheduled on this day.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedTasks.length,
                      itemBuilder: (ctx, i) {
                        final task = selectedTasks[i];
                        return TaskTile(
                          task: task,
                          onToggle: () =>
                              provider.toggleTaskCompletion(task),
                          onDelete: () => provider.deleteTask(task),
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
