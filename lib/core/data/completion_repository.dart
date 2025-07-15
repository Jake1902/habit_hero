import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting and loading habit completion dates.
class CompletionRepository {
  static const _prefix = 'completion_';

  /// Returns sorted unique dates when the habit was completed.
  Future<List<DateTime>> getCompletionDates(String habitId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_prefix$habitId');
    if (data == null) return [];
    final List list = jsonDecode(data) as List;
    final dates = list.map((e) => DateTime.parse(e as String)).toList();
    dates.sort();
    return dates;
  }

  /// Saves the provided list of completion [dates] for the habit.
  Future<void> saveCompletionDates(String habitId, List<DateTime> dates) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(dates.map((e) => e.toIso8601String()).toList());
    await prefs.setString('$_prefix$habitId', data);
  }

  /// Adds or removes [date] from the stored completion dates for [habitId].
  /// If a completion already exists for that day it is removed, otherwise it
  /// is added.
  Future<void> toggleCompletion(String habitId, DateTime date) async {
    final dates = await getCompletionDates(habitId);
    final day = DateTime(date.year, date.month, date.day);
    final index = dates.indexWhere((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day);
    if (index >= 0) {
      dates.removeAt(index);
    } else {
      dates.add(day);
    }
    await saveCompletionDates(habitId, dates);
  }

  /// Returns a map of completion counts keyed by date for [habitId].
  Future<Map<DateTime, int>> getCompletionMap(String habitId) async {
    final dates = await getCompletionDates(habitId);
    final map = <DateTime, int>{};
    for (final d in dates) {
      final key = DateTime(d.year, d.month, d.day);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }
}
