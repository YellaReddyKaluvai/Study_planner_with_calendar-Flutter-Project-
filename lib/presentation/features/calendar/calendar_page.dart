import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return SafeArea(
            child: SfCalendar(
              view: CalendarView.workWeek,
              allowedViews: const [
                CalendarView.day,
                CalendarView.workWeek,
                CalendarView.week,
                CalendarView.month,
                CalendarView.schedule
              ],
              firstDayOfWeek: 1, // Monday
              dataSource: TaskDataSource(taskProvider.tasks),
              allowViewNavigation: true, // click month day opens day
              allowAppointmentResize: true,
              allowDragAndDrop: true,
              timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 0,
                endHour: 24,
                timeIntervalHeight: 80,
                minimumAppointmentDuration: Duration(minutes: 15),
              ),
              monthViewSettings: const MonthViewSettings(
                showAgenda: true,
                agendaItemHeight: 60,
              ),
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null && details.appointments!.isNotEmpty) {
                  final task = details.appointments!.first as Task;
                  _showTaskOptions(context, task, taskProvider);
                } else if (details.targetElement == CalendarElement.calendarCell) {
                  // Optionally tap on empty slot to add event
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const TaskCreationSheet(),
                  );
                }
              },
            ),
          );
        },
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

  void _showTaskOptions(BuildContext context, Task task, TaskProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black26, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(task.isCompleted ? Icons.undo : Icons.check_circle, color: task.isCompleted ? Colors.orange : AppTheme.success),
                title: Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  provider.toggleTaskCompletion(task.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit Task', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => TaskCreationSheet(task: task),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Task', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  provider.deleteTask(task.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Task> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return (appointments![index] as Task).startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments![index] as Task).endTime;
  }

  @override
  String getSubject(int index) {
    return (appointments![index] as Task).title;
  }

  @override
  Color getColor(int index) {
    final task = appointments![index] as Task;
    return task.isCompleted ? task.color.withOpacity(0.5) : task.color;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}
