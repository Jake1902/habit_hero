import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/habit.dart';

/// Simple repository persisting habits using [SharedPreferences].
class HabitRepository {
  static const _habitsKey = 'habits';
  static const _archivedKey = 'archived_habits';

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

  /// Loads archived habits.
  static Future<List<Habit>> loadArchivedHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_archivedKey);
    if (jsonString == null) return [];
    final List list = jsonDecode(jsonString) as List;
    return list
        .map((e) => Habit.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> _saveArchivedHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(habits.map((e) => e.toMap()).toList());
    await prefs.setString(_archivedKey, data);
  }

  /// Move habit with [id] from active list to archive.
  static Future<void> archiveHabit(String id) async {
    final habits = await loadHabits();
    final index = habits.indexWhere((h) => h.id == id);
    if (index < 0) return;
    final habit = habits.removeAt(index);
    await _saveHabits(habits);
    final archived = await loadArchivedHabits();
    archived.add(habit);
    await _saveArchivedHabits(archived);
  }

  /// Restore habit with [id] from archive back to active list.
  static Future<void> restoreHabit(String id) async {
    final archived = await loadArchivedHabits();
    final index = archived.indexWhere((h) => h.id == id);
    if (index < 0) return;
    final habit = archived.removeAt(index);
    await _saveArchivedHabits(archived);
    final habits = await loadHabits();
    habits.add(habit);
    await _saveHabits(habits);
  }

  /// Permanently delete a habit from the active list.
  static Future<void> deleteHabit(String id) async {
    final habits = await loadHabits();
    habits.removeWhere((h) => h.id == id);
    await _saveHabits(habits);
  }

  /// Permanently delete a habit from the archive.
  static Future<void> deleteArchivedHabit(String id) async {
    final archived = await loadArchivedHabits();
    archived.removeWhere((h) => h.id == id);
    await _saveArchivedHabits(archived);
  }
}
