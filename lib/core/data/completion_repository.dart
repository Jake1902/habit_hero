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
}
