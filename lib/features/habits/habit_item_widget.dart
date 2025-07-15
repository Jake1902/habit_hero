import 'package:flutter/material.dart';

import '../../core/data/models/habit.dart';
import '../dashboard/heatmap_widget.dart';

/// List item widget displaying a habit with its current streak.
class HabitItemWidget extends StatelessWidget {
  const HabitItemWidget({
    super.key,
    required this.habit,
    required this.completionMap,
    required this.completedToday,
    required this.onToggle,
    required this.onDayTapped,
    this.onEdit,
    this.onLongPress,
    this.currentStreak,
    this.longestStreak,
  });

  /// Habit being displayed.
  final Habit habit;

  /// Map of completion counts per day used for the heatmap.
  final Map<DateTime, int> completionMap;

  /// Whether the habit is completed today.
  final bool completedToday;

  /// Callback when today's completion state changes.
  final ValueChanged<bool?> onToggle;

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
    const purple = Color(0xFF8A2BE2);
    final icon = IconData(habit.iconData, fontFamily: 'MaterialIcons');
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
                    child: Icon(icon, color: Colors.white, size: 16),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (currentStreak != null)
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: purple,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$currentStreak',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              Checkbox(
                value: completedToday,
                onChanged: onToggle,
                activeColor: purple,
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: onEdit,
                ),
            ],
          ),
          const SizedBox(height: 8),
          HabitHeatmap(
            completionMap: completionMap,
            icon: icon,
            name: habit.name,
            fillColor: Color(habit.color),
            showHeader: false,
            onDayTapped: onDayTapped,
          ),
          const Divider(color: Colors.white24),
        ],
      ),
      )
    );
  }
}
