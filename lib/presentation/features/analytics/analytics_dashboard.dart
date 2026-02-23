import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/glass_container.dart';
import '../../../presentation/providers/analytics_provider.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, _) {
        if (analyticsProvider.isLoading) {
          return GlassContainer(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
              ),
            ),
          );
        }

        return Column(
          children: [
            // Weekly Progress Chart
            _buildWeeklyChart(analyticsProvider),
            const SizedBox(height: 24),

            // Stats Grid
            _buildStatsGrid(analyticsProvider),
            const SizedBox(height: 24),

            // Subject Performance
            _buildSubjectPerformance(analyticsProvider),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyChart(AnalyticsProvider provider) {
    return GlassContainer(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Progress",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.bolt, color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: provider.weeklyData.isEmpty
                ? _buildEmptyState()
                : _buildBarChart(provider.weeklyData),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    final maxValue =
        (data.values.isEmpty ? 0 : data.values.reduce((a, b) => a > b ? a : b))
            .toDouble();
    final normalizedMaxValue = maxValue == 0 ? 1.0 : maxValue;

    List<BarChartGroupData> barCharts = [];
    int index = 0;

    data.forEach((day, minutes) {
      barCharts.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: minutes.toDouble(),
              color: Color(0xFF00F0FF)
                  .withOpacity(0.7 + (0.3 * (minutes / normalizedMaxValue))),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ],
        ),
      );
      index++;
    });

    return BarChart(
      BarChartData(
        barGroups: barCharts,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final keys = data.keys.toList();
                final key = keys[value.toInt()];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    key.split('/')[1],
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Widget _buildStatsGrid(AnalyticsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            title: 'Total Time',
            value: provider.getFormattedTotalTime(),
            icon: Icons.timer,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            title: 'Avg Session',
            value: provider.getFormattedAverageTime(),
            icon: Icons.trending_up,
            color: const Color(0xFFFFA500),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            title: 'Current Streak',
            value: '${provider.currentStreak}d',
            icon: Icons.local_fire_department,
            color: const Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectPerformance(AnalyticsProvider provider) {
    if (provider.subjectData.isEmpty) {
      return const SizedBox.shrink();
    }

    final topSubjects = provider.subjectData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Subjects',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'This Week',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...topSubjects.take(3).map((entry) {
            final percentage =
                (entry.value / topSubjects.first.value * 100).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.outfit(fontSize: 12),
                      ),
                      Text(
                        '${entry.value}m',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00F0FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.lerp(
                          const Color(0xFF00F0FF),
                          const Color(0xFFFFC043),
                          (100 - percentage) / 100,
                        )!,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_outlined, size: 48, color: Colors.white10),
          const SizedBox(height: 8),
          Text(
            'No data yet\nStart a study session to see analytics',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
