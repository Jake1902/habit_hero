import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/analytics/analytics_service.dart';

/// Row of quick analytics stats shown on the home screen.
class AnalyticsQuickRow extends StatelessWidget {
  const AnalyticsQuickRow({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final service = context.watch<AnalyticsService>();
    final overall = service.overall;
    final todayCount =
        service.perHabit.values.where((s) => s.currentStreak > 0).length;
    final totalHabits = service.perHabit.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _chip(context, 'Today', '$todayCount / $totalHabits'),
        _chip(context, '7-Day', '${overall.sevenDaySuccessRate.toStringAsFixed(0)} %'),
        _chip(context, 'Longest Streak', '${overall.longestStreak} days'),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style:
                TextStyle(color: scheme.onBackground.withOpacity(0.7), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
