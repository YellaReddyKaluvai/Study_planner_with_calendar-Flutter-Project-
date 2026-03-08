import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/task_provider.dart';
import '../../../shared/glass_container.dart';
import '../../../../domain/entities/task.dart';
import '../qr_scan_page.dart';
import '../../../../ui/widgets/success_dialog.dart';

class TaskCreationSheet extends StatefulWidget {
  /// Pass an existing task to open the sheet in edit mode.
  final Task? task;

  const TaskCreationSheet({super.key, this.task});

  @override
  State<TaskCreationSheet> createState() => _TaskCreationSheetState();
}

class _TaskCreationSheetState extends State<TaskCreationSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late DateTime _startTime;
  late DateTime _endTime;
  late Color _selectedColor;
  late int _selectedPriority;
  late String _selectedCategory;
  String? _titleError;
  String? _timeError;

  bool get _isEditing => widget.task != null;

  final List<Color> _colors = [
    AppTheme.primary,
    AppTheme.secondary,
    AppTheme.success,
    AppTheme.warning,
    const Color(0xFFFF2E51), // Error/High Priority
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _notesController = TextEditingController(text: t?.description ?? '');
    _startTime = t?.startTime ?? DateTime.now();
    _endTime = t?.endTime ?? DateTime.now().add(const Duration(hours: 1));
    _selectedColor = t?.color ?? AppTheme.primary;
    _selectedPriority = t?.priority ?? 2;
    _selectedCategory = t?.type ?? 'study';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    final hintColor = isDark ? Colors.white38 : Colors.black38;
    final chipBg = isDark ? Colors.white10 : Colors.grey.shade200;
    final dividerColor = isDark ? Colors.white10 : Colors.grey.shade300;
    final handleColor = isDark ? Colors.white24 : Colors.grey.shade400;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: mediaQuery.size.height * 0.9,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Header Row with QR button
                  Row(
                    children: [
                      Text(
                        _isEditing ? "Edit Task" : "New Task",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      if (!_isEditing)
                        Flexible(
                          child: TextButton.icon(
                            onPressed: _openQrScan,
                            icon: const Icon(Icons.qr_code_scanner,
                                color: AppTheme.primary, size: 18),
                            label: const Text(
                              'Import QR',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppTheme.primary, fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title Input
                  TextField(
                    controller: _titleController,
                    autofocus: !_isEditing,
                    style: TextStyle(color: textColor, fontSize: 18),
                    onChanged: (_) {
                      if (_titleError != null)
                        setState(() => _titleError = null);
                    },
                    decoration: InputDecoration(
                      hintText: "What do you need to do?",
                      hintStyle: TextStyle(color: hintColor),
                      border: InputBorder.none,
                      errorText: _titleError,
                      errorStyle: const TextStyle(
                          color: Colors.redAccent, fontSize: 11),
                    ),
                  ),

                  Divider(color: dividerColor),

                  // Notes Input
                  TextField(
                    controller: _notesController,
                    style: TextStyle(color: subtextColor, fontSize: 14),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: "Add notes, subtasks, or links...",
                      hintStyle: TextStyle(color: hintColor),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.notes, color: hintColor, size: 20),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Options Row
                  Row(
                    children: [
                      // Date & Time Pickers
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Start",
                                      style: TextStyle(
                                          color: subtextColor, fontSize: 12)),
                                  ActionChip(
                                    padding: EdgeInsets.zero,
                                    label: Text(
                                      "${_startTime.day}/${_startTime.month} ${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}",
                                      style: TextStyle(color: textColor),
                                    ),
                                    backgroundColor: chipBg,
                                    side: BorderSide.none,
                                    onPressed: () => _pickDateTime(true),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("End",
                                      style: TextStyle(
                                          color: subtextColor, fontSize: 12)),
                                  ActionChip(
                                    padding: EdgeInsets.zero,
                                    label: Text(
                                      "${_endTime.day}/${_endTime.month} ${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}",
                                      style: TextStyle(color: textColor),
                                    ),
                                    backgroundColor: chipBg,
                                    side: BorderSide.none,
                                    onPressed: () => _pickDateTime(false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Color Picker
                      DropdownButtonHideUnderline(
                        child: DropdownButton<Color>(
                          value: _selectedColor,
                          dropdownColor: AppTheme.surface,
                          icon: const Icon(Icons.circle, size: 12),
                          items: _colors.map((color) {
                            return DropdownMenuItem(
                              value: color,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                              ),
                            );
                          }).toList(),
                          onChanged: (color) {
                            if (color != null)
                              setState(() => _selectedColor = color);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Priority Selector
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text("Priority:", style: TextStyle(color: subtextColor)),
                      ...[1, 2, 3].map((priority) {
                        final isSelected = _selectedPriority == priority;
                        String label = priority == 1
                            ? "High"
                            : (priority == 2 ? "Med" : "Low");
                        Color color = priority == 1
                            ? Colors.redAccent
                            : (priority == 2
                                ? Colors.orangeAccent
                                : Colors.greenAccent);

                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedPriority = priority);
                          },
                          backgroundColor: chipBg,
                          selectedColor: color.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? color : subtextColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? color : Colors.transparent,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Category Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor:
                            isDark ? const Color(0xFF1E2433) : Colors.white,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: subtextColor),
                        items: ['Study', 'Assignment', 'Exam', 'Other']
                            .map((String category) {
                          return DropdownMenuItem<String>(
                            value: category.toLowerCase(),
                            child: Text(
                              category,
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Create / Update Button with Animation
                  _AnimatedCreateButton(
                    onPressed: _submit,
                    label: _isEditing ? "Update Task" : "Create Task",
                    isEditing: _isEditing,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    // Validate
    setState(() {
      _titleError = _titleController.text.trim().isEmpty
          ? 'Please enter a task title'
          : null;
      _timeError = _endTime.isBefore(_startTime) || _endTime == _startTime
          ? 'End time must be after start time'
          : null;
    });

    if (_titleError != null || _timeError != null) {
      if (_timeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_timeError!),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final provider = Provider.of<TaskProvider>(context, listen: false);

    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _notesController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        priority: _selectedPriority,
        type: _selectedCategory,
      );
      provider.updateTask(updated);
    } else {
      provider.addTask(
        title: _titleController.text.trim(),
        description: _notesController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        priority: _selectedPriority,
        type: _selectedCategory,
      );
    }
    Navigator.pop(context);

    // Show success animation for new task
    if (!_isEditing && context.mounted) {
      SuccessDialog.show(
        context: context,
        message: 'Task Added Successfully! 🎉',
      );
    }
  }

  Future<void> _openQrScan() async {
    Navigator.pop(context); // close this sheet first
    final scannedTask = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (scannedTask != null && context.mounted) {
      final provider = Provider.of<TaskProvider>(context, listen: false);
      provider.addTask(
        title: scannedTask.title,
        description: scannedTask.description,
        startTime: scannedTask.startTime,
        endTime: scannedTask.endTime,
        color: scannedTask.color,
        priority: scannedTask.priority,
        type: scannedTask.type,
      );
      if (context.mounted) {
        SuccessDialog.show(
          context: context,
          message: 'Task Imported from QR! 🎉',
        );
      }
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initialDate = isStart ? _startTime : _endTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        setState(() {
          final newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          if (isStart) {
            _startTime = newDateTime;
            if (_endTime.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(hours: 1));
            }
          } else {
            if (newDateTime.isAfter(_startTime)) {
              _endTime = newDateTime;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("End time must be after start time"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
      }
    }
  }
}

/// Animated Create/Update Task Button with Lottie
class _AnimatedCreateButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isEditing;

  const _AnimatedCreateButton({
    required this.onPressed,
    required this.label,
    required this.isEditing,
  });

  @override
  State<_AnimatedCreateButton> createState() => _AnimatedCreateButtonState();
}

class _AnimatedCreateButtonState extends State<_AnimatedCreateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showAnimation = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    setState(() {
      _showAnimation = true;
      _isPressed = true;
    });

    _controller.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showAnimation = false;
          _isPressed = false;
        });
      }
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: _handlePress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          if (_showAnimation)
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  widget.isEditing
                      ? 'assets/lottie/save.json'
                      : 'assets/lottie/add.json',
                  controller: _controller,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
