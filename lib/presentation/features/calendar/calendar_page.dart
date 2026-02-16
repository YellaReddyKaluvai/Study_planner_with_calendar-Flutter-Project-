import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/glass_container.dart';
import '../../../../domain/entities/task.dart';
import '../tasks/widgets/task_creation_sheet.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Task> _getEventsForDay(DateTime day, List<Task> allTasks) {
    return allTasks.where((task) => isSameDay(task.startTime, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0E17),
                  Color(0xFF161B28),
                ],
              ),
            ),
          ),

          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final events = _getEventsForDay(
                  _selectedDay ?? _focusedDay, taskProvider.tasks);

              return SafeArea(
                child: Column(
                  children: [
                    // Header
                    GlassContainer(
                      margin: const EdgeInsets.all(16),
                      child: TableCalendar(
                        eventLoader: (day) =>
                            _getEventsForDay(day, taskProvider.tasks),
                        firstDay: DateTime.utc(2020, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(_selectedDay, selectedDay)) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          }
                        },
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: const CalendarStyle(
                          defaultTextStyle: TextStyle(color: Colors.white),
                          weekendTextStyle: TextStyle(color: Colors.white70),
                          outsideTextStyle: TextStyle(color: Colors.white24),
                          markerDecoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonDecoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          formatButtonTextStyle:
                              const TextStyle(color: Colors.white),
                          titleTextStyle: const TextStyle(
                              color: Colors.white, fontSize: 17),
                          leftChevronIcon: const Icon(Icons.chevron_left,
                              color: Colors.white),
                          rightChevronIcon: const Icon(Icons.chevron_right,
                              color: Colors.white),
                        ),
                      ),
                    ),

                    // Event List
                    Expanded(
                      child: events.isEmpty
                          ? const Center(
                              child: Text("No tasks for this day",
                                  style: TextStyle(color: Colors.white54)))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final task = events[index];
                                return GlassContainer(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: task.color,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${task.startTime.hour}:${task.startTime.minute.toString().padLeft(2, '0')} - ${task.endTime.hour}:${task.endTime.minute.toString().padLeft(2, '0')}",
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.white30, size: 20),
                                        onPressed: () {
                                          taskProvider.deleteTask(task.id);
                                        },
                                      )
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fade(
                                        duration: 400.ms,
                                        delay: (index * 50).ms)
                                    .slideX(begin: 0.2, end: 0);
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
