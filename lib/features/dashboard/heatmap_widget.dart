import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Widget that displays a calendar-style heatmap representing
/// habit completion over the past [days] days.
class HabitHeatmap extends StatelessWidget {
  /// Map of dates to completion counts.
  final Map<DateTime, int> completionData;

  /// Icon representing the habit.
  final IconData icon;

  /// Name of the habit.
  final String name;

  /// Base color used for completion tiles.
  final Color tileColor;

  /// Number of days to show, defaults to 90.
  final int days;

  /// Whether to show the icon and name above the heatmap.
  final bool showHeader;

  /// Callback when a day square is tapped.
  final void Function(DateTime tappedDay)? onDayTapped;

  const HabitHeatmap({
    super.key,
    required this.completionData,
    required this.icon,
    required this.name,
    required this.tileColor,
    required this.onDayTapped,
    this.days = 90,
    this.showHeader = true,
  });

  /// Returns a color ranging from a light variant of [tileColor] to the full
  /// color based on [count].
  Color _colorForCount(int count, int maxCount) {
    final t = maxCount == 0 ? 1.0 : count / maxCount;
    return Color.lerp(tileColor.withOpacity(0.5), tileColor, t)!;
  }

  @override
  Widget build(BuildContext context) {
    final maxCount =
        completionData.values.isEmpty ? 0 : completionData.values.reduce(math.max);
    final today = DateTime.now();
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
        final key = DateTime(date.year, date.month, date.day);
        final count = completionData[key] ?? 0;
        final color =
            count > 0 ? _colorForCount(count, maxCount) : const Color(0xFF1E1E1E);
        final message = '${key.toIso8601String().split('T').first}: $count';
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
            onDayTapped?.call(key);
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

    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
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
