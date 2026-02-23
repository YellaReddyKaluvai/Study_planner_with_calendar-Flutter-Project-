import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/glass_container.dart';
import '../../../../domain/entities/task.dart';
import '../tasks/widgets/task_creation_sheet.dart';
import '../../../../core/data/database_helper.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isDayView = false;
  double _hourHeight = 80.0;
  double _baseHourHeight = 80.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedHeight =
        await DatabaseHelper.instance.getSetting('calendar_hour_height');
    if (savedHeight != null) {
      setState(() {
        _hourHeight = double.tryParse(savedHeight) ?? 80.0;
      });
    }
  }

  Future<void> _saveSettings() async {
    await DatabaseHelper.instance
        .saveSetting('calendar_hour_height', _hourHeight.toString());
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
              return SafeArea(
                child: Column(
                  children: [
                    // Header & Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isDayView ? "Daily Schedule" : "Calendar",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                _buildToggleBtn("Month", !_isDayView, () {
                                  setState(() => _isDayView = false);
                                }),
                                _buildToggleBtn("Day", _isDayView, () {
                                  setState(() => _isDayView = true);
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Calendar Content
                    Expanded(
                      child: _isDayView
                          ? _buildDayView(taskProvider)
                          : _buildMonthView(taskProvider),
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

  Widget _buildToggleBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthView(TaskProvider taskProvider) {
    final events =
        _getEventsForDay(_selectedDay ?? _focusedDay, taskProvider.tasks);

    return Column(
      children: [
        GlassContainer(
          margin: const EdgeInsets.all(16),
          child: TableCalendar(
            eventLoader: (day) => _getEventsForDay(day, taskProvider.tasks),
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
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
              formatButtonVisible: false,
              titleTextStyle:
                  const TextStyle(color: Colors.white, fontSize: 17),
              leftChevronIcon:
                  const Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon:
                  const Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final task = events[index];
              return _buildTaskItem(task, taskProvider)
                  .animate()
                  .fade(duration: 400.ms, delay: (index * 50).ms)
                  .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(Task task, TaskProvider provider) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: task.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                if (task.hasAiPlan)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 12, color: AppTheme.secondary),
                        const SizedBox(width: 4),
                        Text("AI Plan Ready",
                            style: TextStyle(
                                color: AppTheme.secondary, fontSize: 10)),
                      ],
                    ),
                  )
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.white30, size: 20),
            onPressed: () => provider.deleteTask(task.id),
          )
        ],
      ),
    );
  }

  Widget _buildDayView(TaskProvider taskProvider) {
    final events =
        _getEventsForDay(_selectedDay ?? _focusedDay, taskProvider.tasks);

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 30,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index - 2));
              final isSelected = isSameDay(date, _selectedDay);

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDay = date;
                  _focusedDay = date;
                }),
                child: Container(
                  width: 50,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ][date.weekday - 1],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: GestureDetector(
            onScaleStart: (details) {
              _baseHourHeight = _hourHeight;
            },
            onScaleUpdate: (details) {
              setState(() {
                _hourHeight =
                    (_baseHourHeight * details.scale).clamp(40.0, 200.0);
              });
            },
            onScaleEnd: (details) {
              _saveSettings();
            },
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: List.generate(24, (index) {
                      return Container(
                        height: _hourHeight,
                        decoration: const BoxDecoration(
                          border:
                              Border(top: BorderSide(color: Colors.white10)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 50,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8, left: 8),
                                child: Text(
                                  "${index.toString().padLeft(2, '0')}:00",
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12),
                                ),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      );
                    }),
                  ),
                  if (isSameDay(_selectedDay, DateTime.now()))
                    Positioned(
                      top: (DateTime.now().hour + DateTime.now().minute / 60) *
                          _hourHeight,
                      left: 50,
                      right: 0,
                      child: Row(
                        children: [
                          const CircleAvatar(
                              radius: 4, backgroundColor: Colors.red),
                          Expanded(
                              child: Container(height: 2, color: Colors.red)),
                        ],
                      ),
                    ),
                  ...events.map((task) {
                    final startMinutes =
                        task.startTime.hour * 60 + task.startTime.minute;
                    final durationMinutes =
                        task.endTime.difference(task.startTime).inMinutes;
                    final top = (startMinutes / 60) * _hourHeight;
                    final height = (durationMinutes / 60) * _hourHeight;

                    return Positioned(
                      top: top,
                      left: 60,
                      right: 8,
                      height: height < 20 ? 20 : height,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: task.color.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: task.color.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _hourHeight < 50 ? 10 : 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (height > 40 && _hourHeight > 60)
                                Text(
                                  "${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                ),
                            ],
                          ),
                        ),
                      ).animate().fade().scale(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
