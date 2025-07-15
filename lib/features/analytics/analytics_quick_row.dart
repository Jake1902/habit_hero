import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/analytics/analytics_service.dart';

/// Row of quick analytics stats shown on the home screen.
class AnalyticsQuickRow extends StatelessWidget {
  const AnalyticsQuickRow({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF8A2BE2);
    final service = context.watch<AnalyticsService>();
    final overall = service.overall;
    final todayCount =
        service.perHabit.values.where((s) => s.currentStreak > 0).length;
    final totalHabits = service.perHabit.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _chip('Today', '$todayCount / $totalHabits'),
        _chip('7-Day', '${overall.sevenDaySuccessRate.toStringAsFixed(0)} %'),
        _chip('Longest Streak', '${overall.longestStreak} days'),
      ],
    );
  }

  Widget _chip(String label, String value) {
    const purple = Color(0xFF8A2BE2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
