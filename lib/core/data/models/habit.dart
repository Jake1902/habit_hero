import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enumeration of supported streak goal intervals.
enum StreakGoal { none, daily, weekly, monthly }

/// Types of completion tracking.
enum CompletionTrackingType { stepByStep, customValue }

/// Simple Habit model containing basic and advanced properties.
class Habit {
  final String id;
  String name;
  String description;
  int color;
  int iconData;
  StreakGoal streakGoal;
  List<int> reminderDays; // 1 (Mon) - 7 (Sun)
  List<String> categories;
  CompletionTrackingType completionTrackingType;
  int completionTarget;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    this.color = 0xFF8A2BE2,
    this.iconData = 0,
    this.streakGoal = StreakGoal.none,
    List<int>? reminderDays,
    List<String>? categories,
    this.completionTrackingType = CompletionTrackingType.stepByStep,
    this.completionTarget = 1,
  })  : reminderDays = reminderDays ?? [],
        categories = categories ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'color': color,
        'iconData': iconData,
        'streakGoal': streakGoal.name,
        'reminderDays': reminderDays,
        'categories': categories,
        'completionTrackingType': completionTrackingType.name,
        'completionTarget': completionTarget,
      };

  factory Habit.fromMap(Map<String, dynamic> map) => Habit(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        color: map['color'] as int? ?? 0xFF8A2BE2,
        iconData: map['iconData'] as int? ?? 0,
        streakGoal: StreakGoal.values.firstWhere(
            (e) => e.name == map['streakGoal'],
            orElse: () => StreakGoal.none),
        reminderDays: List<int>.from(map['reminderDays'] ?? []),
        categories: List<String>.from(map['categories'] ?? []),
        completionTrackingType: CompletionTrackingType.values.firstWhere(
            (e) => e.name == map['completionTrackingType'],
            orElse: () => CompletionTrackingType.stepByStep),
        completionTarget: map['completionTarget'] as int? ?? 1,
      );

  String toJson() => jsonEncode(toMap());

  factory Habit.fromJson(String source) => Habit.fromMap(jsonDecode(source));
}

/// Simple local storage for habits using [SharedPreferences].
class HabitStorage {
  static const _key = 'habits';

  /// Load all habits from storage.
  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map(Habit.fromJson).toList();
  }

  /// Save the given list of habits to storage.
  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final list = habits.map((h) => h.toJson()).toList();
    await prefs.setStringList(_key, list);
  }
}
