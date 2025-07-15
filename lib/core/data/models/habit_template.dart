import 'package:flutter/material.dart';

class HabitTemplate {
  final String id;
  final String name;
  final String description;
  final int iconData;
  final int color;
  final TimeOfDay? reminderTime;
  final List<int> reminderWeekdays;
  final String completionTrackingType;
  final int completionTarget;

  HabitTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.iconData,
    required this.color,
    this.reminderTime,
    this.reminderWeekdays = const [],
    required this.completionTrackingType,
    required this.completionTarget,
  });

  factory HabitTemplate.fromJson(Map<String, dynamic> j) => HabitTemplate(
        id: j['id'],
        name: j['name'],
        description: j['description'],
        iconData: j['iconData'],
        color: j['color'],
        reminderTime: j['reminderTime'] != null
            ? TimeOfDay(
                hour: j['reminderTime']['hour'],
                minute: j['reminderTime']['minute'],
              )
            : null,
        reminderWeekdays:
            (j['reminderWeekdays'] as List?)?.cast<int>() ?? const [],
        completionTrackingType: j['completionTrackingType'],
        completionTarget: j['completionTarget'],
      );
}
