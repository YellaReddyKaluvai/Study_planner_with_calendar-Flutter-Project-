import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/task_provider.dart';
import '../../../shared/glass_container.dart';

class TaskCreationSheet extends StatefulWidget {
  const TaskCreationSheet({super.key});

  @override
  State<TaskCreationSheet> createState() => _TaskCreationSheetState();
}

class _TaskCreationSheetState extends State<TaskCreationSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  Color _selectedColor = AppTheme.primary;
  int _selectedPriority = 2;
  String _selectedCategory = 'study';

  final List<Color> _colors = [
    AppTheme.primary,
    AppTheme.secondary,
    AppTheme.success,
    AppTheme.warning,
    const Color(0xFFFF2E51), // Error/High Priority
  ];

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "New Task",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Title Input
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: "What do you need to do?",
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),

            const Divider(color: Colors.white10),

            // Notes Input
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: "Add notes, subtasks, or links...",
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.notes, color: Colors.white38, size: 20),
              ),
            ),

            const SizedBox(height: 16),

            // Options Row
            Row(
              children: [
                // Date Picker Chip
                // Date & Time Pickers
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Start",
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                            ActionChip(
                              padding: EdgeInsets.zero,
                              label: Text(
                                "${_startTime.day}/${_startTime.month} ${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.white10,
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
                            const Text("End",
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                            ActionChip(
                              padding: EdgeInsets.zero,
                              label: Text(
                                "${_endTime.day}/${_endTime.month} ${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.white10,
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
                    icon:
                        const Icon(Icons.circle, size: 12), // Hide default icon
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
                      if (color != null) setState(() => _selectedColor = color);
                    },
                    /*selectedItemBuilder: (context) {
                      return _colors.map((c) => Container(
                          width: 20, 
                          height: 20, 
                          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                        )).toList();
                    },*/
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Priority Selector
            Row(
              children: [
                const Text("Priority:",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 3].map((priority) {
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
                      backgroundColor: Colors.white10,
                      selectedColor: color.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? color : Colors.white60,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? color : Colors.transparent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Category Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF1E2433),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white54),
                  items: ['Study', 'Assignment', 'Exam', 'Other']
                      .map((String category) {
                    return DropdownMenuItem<String>(
                      value: category.toLowerCase(),
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
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

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    Provider.of<TaskProvider>(context, listen: false).addTask(
                      title: _titleController.text,
                      description: _notesController.text,
                      startTime: _startTime,
                      endTime: _endTime,
                      color: _selectedColor,
                      priority: _selectedPriority,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Create Task",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initialDate = isStart ? _startTime : _endTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(
          days: 365)), // Allow past dates for editing/flexibility
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
            // Auto-adjust end time if it's before start time
            if (_endTime.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(hours: 1));
            }
          } else {
            // Validate End Time
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
