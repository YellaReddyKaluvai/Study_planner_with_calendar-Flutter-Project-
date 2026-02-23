import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../services/focus_timer_service.dart';
import '../../../presentation/providers/analytics_provider.dart';
import '../../shared/glass_container.dart';

class FocusTimerPage extends StatefulWidget {
  final String subject;

  const FocusTimerPage({super.key, this.subject = 'Study'});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    Future.microtask(() {
      final timerService = context.read<FocusTimerService>();
      if (!timerService.isRunning) {
        timerService.setPomodoro();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusTimerService>(
      builder: (context, timerService, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${widget.subject} Focus',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0E17), Color(0xFF161B28)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTimerDisplay(timerService),
                    const SizedBox(height: 48),
                    _buildProgressRing(timerService),
                    const SizedBox(height: 48),
                    _buildControls(timerService),
                    const SizedBox(height: 32),
                    _buildPresets(timerService),
                    const SizedBox(height: 32),
                    _buildSessionInfo(timerService),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerDisplay(FocusTimerService timerService) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: timerService.isRunning
              ? [
                  const Color(0xFF00F0FF).withOpacity(0.2),
                  const Color(0xFF00D4FF).withOpacity(0.1)
                ]
              : [Colors.transparent, Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00F0FF).withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: timerService.isRunning
            ? [
                BoxShadow(
                  color: const Color(0xFF00F0FF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          Text(
            'Time Remaining',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            timerService.formattedTime,
            style: GoogleFonts.outfit(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00F0FF),
              letterSpacing: 2,
            ),
          ).animate(onPlay: (controller) => _pulseController.repeat()).scale(
                duration: const Duration(milliseconds: 1500),
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(FocusTimerService timerService) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: CircularProgressIndicator(
            value: timerService.progress,
            strokeWidth: 8,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              timerService.isRunning
                  ? const Color(0xFF00F0FF)
                  : const Color(0xFFFFC043),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(timerService.progress * 100).toInt()}%',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(FocusTimerService timerService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Play / Pause button
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(50),
          child: IconButton(
            iconSize: 32,
            icon: Icon(
              timerService.isRunning ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF00F0FF),
            ),
            onPressed: () {
              if (timerService.isRunning) {
                timerService.pauseTimer();
              } else if (timerService.timeRemaining > 0) {
                timerService.resumeTimer();
              } else {
                timerService.startTimer(subject: widget.subject);
              }
            },
          ),
        ),
        const SizedBox(width: 16),

        // Stop / Save button
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(50),
          child: IconButton(
            iconSize: 28,
            icon: const Icon(Icons.stop, color: Color(0xFFFF6B6B)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E2746),
                  title: const Text('End Session?'),
                  content: Text(
                    'Save this session to your study time?',
                    style: GoogleFonts.outfit(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Continue'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await timerService.completeSession();
                        if (ctx.mounted) {
                          // Refresh analytics so dashboard updates immediately
                          context.read<AnalyticsProvider>().refreshData();
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save & Exit',
                          style: TextStyle(color: Color(0xFF00F0FF))),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPresets(FocusTimerService timerService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Existing preset chips (with active highlight)
            ...TimerPreset.presets.map((preset) {
              final isActive = !timerService.isRunning &&
                  timerService.sessionDuration == preset.seconds;
              return GestureDetector(
                onTap: () => timerService.setDuration(preset.seconds),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF00F0FF).withOpacity(0.15)
                        : Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF00F0FF).withOpacity(0.6)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(preset.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        preset.name,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? const Color(0xFF00F0FF)
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // ⏱️ Custom Duration chip
            GestureDetector(
              onTap: () => _showCustomDurationDialog(timerService),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.purpleAccent.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⏱️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'Custom',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Custom duration picker dialog (MM : SS + quick chips)
  void _showCustomDurationDialog(FocusTimerService timerService) {
    int minutes = timerService.sessionDuration ~/ 60;
    int seconds = timerService.sessionDuration % 60;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E2746),
          title: Text(
            '⏱️  Set Custom Duration',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose your focus session length',
                style:
                    GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // MM : SS picker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minutes
                  Column(
                    children: [
                      Text('Min',
                          style: GoogleFonts.outfit(
                              color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.white54),
                            onPressed: () => setDialogState(
                                () => minutes = (minutes - 1).clamp(0, 180)),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              minutes.toString().padLeft(2, '0'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00F0FF),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.white54),
                            onPressed: () => setDialogState(
                                () => minutes = (minutes + 1).clamp(0, 180)),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Text(
                      ':',
                      style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54),
                    ),
                  ),

                  // Seconds (steps of 5)
                  Column(
                    children: [
                      Text('Sec',
                          style: GoogleFonts.outfit(
                              color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.white54),
                            onPressed: () => setDialogState(
                                () => seconds = (seconds - 5).clamp(0, 55)),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              seconds.toString().padLeft(2, '0'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00F0FF),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.white54),
                            onPressed: () => setDialogState(
                                () => seconds = (seconds + 5).clamp(0, 55)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Quick duration chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [5, 10, 15, 30, 45, 60].map((m) {
                  return ActionChip(
                    label: Text('${m}m',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.white)),
                    backgroundColor: Colors.white10,
                    side: BorderSide.none,
                    onPressed: () => setDialogState(() {
                      minutes = m;
                      seconds = 0;
                    }),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Cancel',
                  style: GoogleFonts.outfit(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F0FF).withOpacity(0.2),
                foregroundColor: const Color(0xFF00F0FF),
                side: const BorderSide(color: Color(0xFF00F0FF), width: 1),
              ),
              onPressed: () {
                final totalSeconds = (minutes * 60) + seconds;
                if (totalSeconds > 0) {
                  timerService.setDuration(totalSeconds);
                }
                Navigator.pop(dialogCtx);
              },
              child: Text('Set Timer', style: GoogleFonts.outfit()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(FocusTimerService timerService) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session Details',
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                '${widget.subject} • ${(timerService.sessionDuration / 60).toStringAsFixed(0)}m',
                style:
                    GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.white70)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: timerService.isRunning
                      ? const Color(0xFF00FF88).withOpacity(0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: timerService.isRunning
                        ? const Color(0xFF00FF88)
                        : Colors.white10,
                    width: 1,
                  ),
                ),
                child: Text(
                  timerService.isRunning ? '🟢 Active' : '⏸️ Paused',
                  style: GoogleFonts.outfit(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
