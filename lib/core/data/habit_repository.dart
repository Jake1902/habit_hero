import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/habit.dart';

/// Simple repository persisting habits using [SharedPreferences].
class HabitRepository {
  static const _habitsKey = 'habits';

  /// Loads all saved habits.
  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_habitsKey);
    if (jsonString == null) return [];
    final List list = jsonDecode(jsonString) as List;
    return list.map((e) => Habit.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// Persists a list of habits.
  static Future<void> _saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(habits.map((e) => e.toMap()).toList());
    await prefs.setString(_habitsKey, data);
  }

  /// Adds a new habit.
  static Future<void> addHabit(Habit habit) async {
    final habits = await loadHabits();
    habits.add(habit);
    await _saveHabits(habits);
  }

  /// Updates an existing habit.
  static Future<void> updateHabit(Habit habit) async {
    final habits = await loadHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      habits[index] = habit;
      await _saveHabits(habits);
    }
  }
}
