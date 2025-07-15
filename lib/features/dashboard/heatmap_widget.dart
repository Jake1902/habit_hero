import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/data/models/habit.dart';

/// Widget that displays a calendar-style heatmap representing
/// habit completion over the past [days] days.
class HabitHeatmap extends StatelessWidget {
  /// Map of dates to completion counts (yyyy-MM-dd).
  final Map<String, int> dailyCounts;

  /// Icon representing the habit.
  final IconData icon;

  /// Name of the habit.
  final String name;

  /// Base color used for completion tiles.
  final Color fillColor;

  /// Target count when using custom tracking.
  final int completionTarget;
  final CompletionTrackingType trackingType;

  /// Number of days to show, defaults to 90.
  final int days;

  /// Whether to show the icon and name above the heatmap.
  final bool showHeader;

  /// Callback when a day square is tapped.
  final void Function(DateTime tappedDay)? onDayTapped;

  const HabitHeatmap({
    super.key,
    required this.dailyCounts,
    required this.icon,
    required this.name,
    required this.fillColor,
    required this.onDayTapped,
    required this.completionTarget,
    required this.trackingType,
    this.days = 90,
    this.showHeader = true,
  });

  /// Returns a color ranging from the full [fillColor] to a lighter
  /// variant based on [count].

  Color _colorForCount(int count) {
    final maxCount = trackingType == CompletionTrackingType.customValue
        ? completionTarget
        : (dailyCounts.values.isEmpty
            ? 1
            : dailyCounts.values.reduce(math.max));
    final capped = math.min(count, maxCount);
    final t = maxCount == 0 ? 1.0 : capped / maxCount;
    return Color.lerp(fillColor, fillColor.withOpacity(0.5), t)!;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toUtc();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    final weekCount = (days / 7).ceil();

    final columns = <Widget>[];
    for (var w = 0; w < weekCount; w++) {
      final squares = <Widget>[];
      for (var d = 0; d < 7; d++) {
        final index = w * 7 + d;
        if (index >= days) break;
        final date = start.add(Duration(days: index));
        final keyDate = DateTime(date.year, date.month, date.day).toUtc();
        final key =
            '${keyDate.year.toString().padLeft(4, '0')}-${keyDate.month.toString().padLeft(2, '0')}-${keyDate.day.toString().padLeft(2, '0')}';
        final count = dailyCounts[key] ?? 0;
        final scheme = Theme.of(context).colorScheme;
        final color = count > 0
            ? _colorForCount(count)
            : scheme.surfaceVariant;
        final message = '$key: $count';
        squares.add(GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 1),
                ),
              );
            onDayTapped?.call(keyDate);
          },
          child: Tooltip(
            message: message,
            child: Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ));
      }
      columns.add(Column(children: squares));
    }

    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.background,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Row(
              children: [
                Icon(icon, color: scheme.onBackground),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: TextStyle(
                    color: scheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (showHeader) const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns
                  .map((c) => Padding(padding: const EdgeInsets.only(right: 4), child: c))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
