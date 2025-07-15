import 'package:flutter/material.dart';

import '../../core/data/models/habit.dart';
import '../dashboard/heatmap_widget.dart';
import '../../core/constants/icon_mapping.dart';

/// List item widget displaying a habit with its current streak.
class HabitItemWidget extends StatelessWidget {
  const HabitItemWidget({
    super.key,
    required this.habit,
    required this.completionMap,
    required this.todayCount,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDayTapped,
    this.onEdit,
    this.onLongPress,
    this.currentStreak,
    this.longestStreak,
  });

  /// Habit being displayed.
  final Habit habit;

  /// Map of completion counts per day used for the heatmap.
  final Map<String, int> completionMap;

  /// Today's completion count.
  final int todayCount;

  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  /// Callback when the habit should be edited.
  final VoidCallback? onEdit;


  /// Callback when the item is long pressed.
  final VoidCallback? onLongPress;

  /// Callback when a heatmap day is tapped.
  final void Function(DateTime)? onDayTapped;


  /// Current streak count.
  final int? currentStreak;

  /// Longest streak count.
  final int? longestStreak;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = iconFromCodePoint(habit.iconData);
    final showBadge = currentStreak != null &&
        (currentStreak == 7 || currentStreak == 30 || currentStreak == 100);

    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(habit.color),
                    ),
                    child: Icon(icon,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 16),
                  ),
                  if (showBadge)
                    const Positioned(
                      right: -2,
                      bottom: -2,
                      child: Icon(
                        Icons.emoji_events,
                        size: 12,
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  habit.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (currentStreak != null)
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$currentStreak',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onBackground,
                          fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      habit.isMultiple
                          ? Icons.check_box
                          : (todayCount > 0
                              ? Icons.check_box
                              : Icons.check_box_outline_blank),
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    onPressed: () {
                      if (habit.isMultiple) {
                        onIncrement();
                      } else {
                        if (todayCount > 0) {
                          onDecrement();
                        } else {
                          onIncrement();
                        }
                      }
                    },
                  ),
                  if (habit.isMultiple)
                    Text(
                      '$todayCount',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 16),
                    ),
                ],
              ),
              if (onEdit != null)
                IconButton(
                  icon: Icon(Icons.edit,
                      color: Theme.of(context).colorScheme.onBackground,
                      size: 20),
                  onPressed: onEdit,
                ),
            ],
          ),
          const SizedBox(height: 8),
          HabitHeatmap(
            dailyCounts: completionMap,
            icon: icon,
            name: habit.name,
            fillColor: Color(habit.color),
            completionTarget: habit.completionTarget,
            trackingType: habit.completionTrackingType,
            showHeader: false,
            onDayTapped: onDayTapped,
          ),
          Divider(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.24)),
        ],
      ),
      )
    );
  }
}
