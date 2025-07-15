import 'dart:convert';
import 'package:flutter/material.dart';

/// Enum describing possible streak goal intervals.
enum StreakGoal { none, daily, weekly, monthly }

/// Enum describing completion tracking behavior.
enum CompletionTrackingType { stepByStep, customValue }

/// Model class representing a habit.
class Habit {
  Habit({
    required this.id,
    required this.name,
    this.description = '',
    this.color = 0xFF2196F3,
    this.iconData = 0xe3af, // default Icons.check
    this.streakGoal = StreakGoal.none,
    this.reminderDays = const [],
    this.reminderTime,
    this.reminderWeekdays = const [],
    this.categories = const [],
    this.completionTrackingType = CompletionTrackingType.stepByStep,
    this.completionTarget = 1,
  });

  /// Unique identifier for the habit.
  final String id;

  /// Name displayed to the user.
  String name;

  /// Optional description text.
  String description;

  /// ARGB color value used for progress tiles on the home screen heatmap and
  /// completion squares. Does not affect the icon color.
  int color;

  /// CodePoint for the [IconData] used to display the habit.
  int iconData;

  /// Streak goal interval.
  StreakGoal streakGoal;

  /// Days of week to show reminders. 1 = Monday ... 7 = Sunday.
  List<int> reminderDays;

  /// Time of day when a reminder notification should fire.
  /// Null disables daily notifications.
  TimeOfDay? reminderTime;

  /// Weekdays the reminder repeats on. 1=Monday ... 7=Sunday.
  /// Together with [reminderTime] this configures daily notifications.
  List<int> reminderWeekdays;

  /// Names of categories assigned to this habit.
  List<String> categories;

  /// How completion is tracked.
  CompletionTrackingType completionTrackingType;

  /// Target value per day when using [CompletionTrackingType.customValue].
  int completionTarget;

  /// Serializes this habit to a map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'color': color,
        'iconData': iconData,
        'streakGoal': streakGoal.index,
        'reminderDays': reminderDays,
        // Time for daily reminder notification.
        'reminderTime': reminderTime == null
            ? null
            : {'hour': reminderTime!.hour, 'minute': reminderTime!.minute},
        // Weekdays the reminder repeats on.
        'reminderWeekdays': reminderWeekdays,
        'categories': categories,
        'completionTrackingType': completionTrackingType.index,
        'completionTarget': completionTarget,
      };

  /// Converts this habit to JSON.
  String toJson() => jsonEncode(toMap());

  /// Creates a habit from a map.
  factory Habit.fromMap(Map<String, dynamic> map) => Habit(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        color: map['color'] as int? ?? 0xFF2196F3,
        iconData: map['iconData'] as int? ?? 0xe3af,
        streakGoal: StreakGoal.values[map['streakGoal'] as int? ?? 0],
        reminderDays: List<int>.from(map['reminderDays'] as List? ?? []),
        reminderTime: map['reminderTime'] == null
            ? null
            : TimeOfDay(
                hour: map['reminderTime']['hour'] as int,
                minute: map['reminderTime']['minute'] as int,
              ),
        reminderWeekdays:
            List<int>.from(map['reminderWeekdays'] as List? ?? []),
        categories: List<String>.from(map['categories'] as List? ?? []),
        completionTrackingType: CompletionTrackingType
            .values[map['completionTrackingType'] as int? ?? 0],
        completionTarget: map['completionTarget'] as int? ?? 1,
      );

  /// Creates a habit from JSON string.
  factory Habit.fromJson(String json) =>
      Habit.fromMap(jsonDecode(json) as Map<String, dynamic>);

  /// Creates a copy of this habit with the given fields replaced.
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    int? color,
    int? iconData,
    StreakGoal? streakGoal,
    List<int>? reminderDays,
    TimeOfDay? reminderTime,
    List<int>? reminderWeekdays,
    List<String>? categories,
    CompletionTrackingType? completionTrackingType,
    int? completionTarget,
  }) =>
      Habit(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        color: color ?? this.color,
        iconData: iconData ?? this.iconData,
        streakGoal: streakGoal ?? this.streakGoal,
        reminderDays: reminderDays ?? this.reminderDays,
        reminderTime: reminderTime ?? this.reminderTime,
        reminderWeekdays: reminderWeekdays ?? this.reminderWeekdays,
        categories: categories ?? this.categories,
        completionTrackingType:
            completionTrackingType ?? this.completionTrackingType,
        completionTarget: completionTarget ?? this.completionTarget,
      );
}
