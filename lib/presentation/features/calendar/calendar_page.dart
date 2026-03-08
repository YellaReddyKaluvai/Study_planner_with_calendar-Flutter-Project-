import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/task_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../../../domain/entities/task.dart';
import '../tasks/widgets/task_creation_sheet.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  CalendarView _currentView = CalendarView.workWeek;
  final CalendarController _calendarController = CalendarController();

  // Zoom support
  double _timeIntervalHeight = 60.0;
  static const double _minTimeInterval = 30.0;
  static const double _maxTimeInterval = 120.0;

  // Animation
  late AnimationController _headerAnimController;

  // Track displayed date
  DateTime _displayedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calendarController.view = _currentView;
    _calendarController.displayDate = DateTime.now();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headerAnimController.forward();

    // Listen for tab changes to reset to today when calendar tab becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navProvider = Provider.of<NavigationProvider>(context, listen: false);
      navProvider.addListener(_onTabChanged);
    });
  }

  void _onTabChanged() {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    // Calendar tab is index 1
    if (navProvider.currentIndex == 1 && mounted) {
      final now = DateTime.now();
      _calendarController.displayDate = now;
      setState(() => _displayedDate = now);
    }
  }

  @override
  void dispose() {
    // Remove the navigation listener
    try {
      final navProvider = Provider.of<NavigationProvider>(context, listen: false);
      navProvider.removeListener(_onTabChanged);
    } catch (_) {}
    _headerAnimController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  // Teams Purple palette
  static const Color _teamsPurple = Color(0xFF6264A7);
  static const Color _teamsPurpleLight = Color(0xFF7B83EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor =
              isDark ? const Color(0xFFF3F2F1) : const Color(0xFF242424);
          final surfaceColor =
              isDark ? const Color(0xFF1B1A19) : const Color(0xFFFAF9F8);
          final borderColor =
              isDark ? const Color(0xFF3B3A39) : const Color(0xFFEDEBE9);
          final headerBg =
              isDark ? const Color(0xFF292827) : const Color(0xFFFFFFFF);
          final mutedText =
              isDark ? const Color(0xFF979593) : const Color(0xFF605E5C);
          final cardBg =
              isDark ? const Color(0xFF252423) : const Color(0xFFFFFFFF);

          return SafeArea(
            child: Column(
              children: [
                // ── Teams Header ──
                _buildTeamsHeader(
                    isDark, textColor, headerBg, borderColor, mutedText),

                // ── View Selector ──
                _buildViewSelector(
                    isDark, borderColor, mutedText, textColor, cardBg),

                // ── Zoom Controls ──
                if (_currentView != CalendarView.month &&
                    _currentView != CalendarView.schedule)
                  _buildZoomBar(isDark, borderColor, mutedText),

                // ── Calendar ──
                Expanded(
                  child: GestureDetector(
                    // Pinch-to-zoom on time-based views
                    onScaleUpdate: (details) {
                      if (_currentView == CalendarView.month ||
                          _currentView == CalendarView.schedule) return;
                      setState(() {
                        _timeIntervalHeight =
                            (_timeIntervalHeight * details.scale)
                                .clamp(_minTimeInterval, _maxTimeInterval);
                      });
                    },
                    child: SfCalendar(
                      controller: _calendarController,
                      view: _currentView,
                      backgroundColor: surfaceColor,
                      dataSource: TaskDataSource(taskProvider.tasks),
                      allowViewNavigation: true,
                      allowAppointmentResize: false,
                      allowDragAndDrop: false,
                      showNavigationArrow: false,
                      showDatePickerButton: false,
                      headerHeight: 0,
                      firstDayOfWeek: 1,
                      cellBorderColor: borderColor,
                      todayHighlightColor: _teamsPurple,
                      showCurrentTimeIndicator: true,
                      todayTextStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      selectionDecoration: BoxDecoration(
                        border: Border.all(
                          color: _teamsPurple.withOpacity(0.6),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: _teamsPurple.withOpacity(0.06),
                      ),
                      viewHeaderStyle: ViewHeaderStyle(
                        dayTextStyle: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: mutedText,
                          letterSpacing: 0.5,
                        ),
                        dateTextStyle: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      timeSlotViewSettings: TimeSlotViewSettings(
                        startHour: 0,
                        endHour: 24,
                        timeIntervalHeight: _timeIntervalHeight,
                        minimumAppointmentDuration: const Duration(minutes: 15),
                        timeTextStyle: GoogleFonts.inter(
                          color: mutedText,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        timeRulerSize: 56,
                        timeInterval: const Duration(minutes: 30),
                        dayFormat: 'EEE',
                      ),
                      monthViewSettings: MonthViewSettings(
                        showAgenda: true,
                        navigationDirection: MonthNavigationDirection.vertical,
                        agendaItemHeight: 56,
                        numberOfWeeksInView: 6,
                        agendaStyle: AgendaStyle(
                          appointmentTextStyle: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                          dateTextStyle: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _teamsPurple,
                          ),
                          dayTextStyle: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: mutedText,
                          ),
                          backgroundColor: surfaceColor,
                        ),
                        monthCellStyle: MonthCellStyle(
                          textStyle: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: textColor,
                          ),
                          trailingDatesTextStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF555555)
                                : const Color(0xFFBBBBBB),
                          ),
                          leadingDatesTextStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF555555)
                                : const Color(0xFFBBBBBB),
                          ),
                          backgroundColor: surfaceColor,
                          todayBackgroundColor: _teamsPurple.withOpacity(0.08),
                        ),
                      ),
                      scheduleViewSettings: ScheduleViewSettings(
                        monthHeaderSettings: MonthHeaderSettings(
                          height: 64,
                          monthTextStyle: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          backgroundColor: headerBg,
                        ),
                        weekHeaderSettings: WeekHeaderSettings(
                          weekTextStyle: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _teamsPurple,
                          ),
                        ),
                        dayHeaderSettings: DayHeaderSettings(
                          dayTextStyle: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: mutedText,
                          ),
                          dateTextStyle: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      appointmentBuilder: (context, details) {
                        return _buildTeamsAppointment(
                            details, isDark, textColor);
                      },
                      onViewChanged: (ViewChangedDetails details) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (details.visibleDates.isNotEmpty && mounted) {
                            final mid = details
                                .visibleDates[details.visibleDates.length ~/ 2];
                            if (mid.month != _displayedDate.month ||
                                mid.year != _displayedDate.year) {
                              setState(() => _displayedDate = mid);
                            }
                          }
                        });
                      },
                      onTap: (CalendarTapDetails details) {
                        if (details.appointments != null &&
                            details.appointments!.isNotEmpty) {
                          final task = details.appointments!.first as Task;
                          _showTaskDetails(context, task, taskProvider, isDark,
                              textColor, borderColor, cardBg);
                        } else if (details.targetElement ==
                            CalendarElement.calendarCell) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const TaskCreationSheet(),
                          );
                        }
                      },

                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ─── Teams Header ─────────────────────────────────────────────
  Widget _buildTeamsHeader(bool isDark, Color textColor, Color headerBg,
      Color borderColor, Color mutedText) {
    final monthYear = DateFormat('MMMM yyyy').format(_displayedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Calendar icon with gradient
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_teamsPurple, _teamsPurpleLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: _teamsPurple.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          // Month + Year (Teams style)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthYear,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: mutedText,
                  ),
                ),
              ],
            ),
          ),
          // Today button
          _buildHeaderButton(
            label: 'Today',
            onTap: () {
              _calendarController.displayDate = DateTime.now();
              setState(() => _displayedDate = DateTime.now());
            },
            isDark: isDark,
          ),
          const SizedBox(width: 6),
          // Nav arrows
          _buildIconBtn(Icons.chevron_left_rounded, mutedText, () {
            _calendarController.backward!();
          }),
          _buildIconBtn(Icons.chevron_right_rounded, mutedText, () {
            _calendarController.forward!();
          }),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.15, end: 0);
  }

  Widget _buildHeaderButton({
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _teamsPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _teamsPurple.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _teamsPurple,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  // ─── View Selector ────────────────────────────────────────────
  Widget _buildViewSelector(bool isDark, Color borderColor, Color mutedText,
      Color textColor, Color cardBg) {
    final views = [
      {
        'label': 'Day',
        'view': CalendarView.day,
        'icon': Icons.view_day_rounded
      },
      {
        'label': 'Work Week',
        'view': CalendarView.workWeek,
        'icon': Icons.view_week_rounded
      },
      {
        'label': 'Week',
        'view': CalendarView.week,
        'icon': Icons.calendar_view_week_rounded
      },
      {
        'label': 'Month',
        'view': CalendarView.month,
        'icon': Icons.calendar_view_month_rounded
      },
      {
        'label': 'Schedule',
        'view': CalendarView.schedule,
        'icon': Icons.view_agenda_rounded
      },
    ];

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: views.map((v) {
          final isSelected = _currentView == v['view'];
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentView = v['view'] as CalendarView;
                    _calendarController.view = _currentView;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? _teamsPurple : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    color: isSelected
                        ? _teamsPurple.withOpacity(0.06)
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        v['icon'] as IconData,
                        size: 14,
                        color: isSelected ? _teamsPurple : mutedText,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          v['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? _teamsPurple : mutedText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  // ─── Zoom Bar ─────────────────────────────────────────────────
  Widget _buildZoomBar(bool isDark, Color borderColor, Color mutedText) {
    final zoomPercent = ((_timeIntervalHeight - _minTimeInterval) /
            (_maxTimeInterval - _minTimeInterval) *
            100)
        .toInt();

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252423) : const Color(0xFFF3F2F1),
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.zoom_out_rounded, size: 16, color: mutedText),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _teamsPurple,
                inactiveTrackColor: _teamsPurple.withOpacity(0.15),
                thumbColor: _teamsPurple,
                overlayColor: _teamsPurple.withOpacity(0.12),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: _timeIntervalHeight,
                min: _minTimeInterval,
                max: _maxTimeInterval,
                onChanged: (v) => setState(() => _timeIntervalHeight = v),
              ),
            ),
          ),
          Icon(Icons.zoom_in_rounded, size: 16, color: mutedText),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _teamsPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$zoomPercent%',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _teamsPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Appointment Card ─────────────────────────────────────────
  Widget _buildTeamsAppointment(
      CalendarAppointmentDetails details, bool isDark, Color textColor) {
    final task = details.appointments.first as Task;
    final isCompleted = task.isCompleted;
    final w = details.bounds.width;
    final h = details.bounds.height;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: isDark
            ? task.color.withOpacity(0.18)
            : task.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(
            color: isCompleted ? task.color.withOpacity(0.4) : task.color,
            width: 4,
          ),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.only(left: 4, right: 4, top: 2, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.check_circle,
                    size: 11,
                    color: task.color.withOpacity(0.6),
                  ),
                ),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? (isDark ? Colors.white54 : Colors.black38)
                        : (isDark ? Colors.white : const Color(0xFF242424)),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          if (h > 36)
            Text(
              '${_formatTime(task.startTime)} – ${_formatTime(task.endTime)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white38 : const Color(0xFF999999),
              ),
            ),
          if (h > 56)
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: task.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    task.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? Colors.white30 : const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  // ─── Task Details Sheet ───────────────────────────────────────
  void _showTaskDetails(BuildContext context, Task task, TaskProvider provider,
      bool isDark, Color textColor, Color borderColor, Color cardBg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top color strip
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: task.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              // Title + time
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 32,
                          decoration: BoxDecoration(
                            color: task.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: isDark
                                        ? const Color(0xFF979593)
                                        : const Color(0xFF605E5C),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_formatTime(task.startTime)} – ${_formatTime(task.endTime)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: isDark
                                          ? const Color(0xFF979593)
                                          : const Color(0xFF605E5C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        task.description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFFB3B0AD)
                              : const Color(0xFF605E5C),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Divider(height: 1, color: borderColor),
              // Actions
              _buildActionTile(
                icon: task.isCompleted
                    ? Icons.undo_rounded
                    : Icons.check_circle_outline_rounded,
                label: task.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                color:
                    task.isCompleted ? const Color(0xFFF59E0B) : _teamsPurple,
                textColor: textColor,
                onTap: () {
                  Navigator.pop(context);
                  provider.toggleTaskCompletion(task.id);
                },
              ),
              _buildActionTile(
                icon: Icons.edit_outlined,
                label: 'Edit Task',
                color: _teamsPurple,
                textColor: textColor,
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
              _buildActionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: const Color(0xFFC4314B),
                textColor: const Color(0xFFC4314B),
                onTap: () {
                  Navigator.pop(context);
                  provider.deleteTask(task.id);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_teamsPurple, _teamsPurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _teamsPurple.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const TaskCreationSheet(),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

// ═══ Data Source ══════════════════════════════════════════════════
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
