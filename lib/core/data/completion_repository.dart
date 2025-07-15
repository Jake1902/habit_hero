import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting and loading habit completion timestamps.
class CompletionRepository {
  static const _prefix = 'completion_';
  final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  Future<Map<String, List<String>>> _load(String habitId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_prefix$habitId');
    if (data == null) return {};
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    return decoded.map(
        (k, v) => MapEntry(k, List<String>.from(v as List<dynamic>)));
  }

  Future<void> _save(String habitId, Map<String, List<String>> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$habitId', jsonEncode(map));
  }

  /// Returns every saved completion timestamp for the habit.
  Future<List<DateTime>> getCompletionDates(String habitId) async {
    final map = await _load(habitId);
    final dates = <DateTime>[];
    for (final list in map.values) {
      for (final ts in list) {
        dates.add(DateTime.parse(ts as String));
      }
    }
    dates.sort();
    return dates;
  }

  /// Saves the provided list of completion [dates] for the habit.
  Future<void> saveCompletionDates(String habitId, List<DateTime> dates) async {
    final map = <String, List<String>>{};
    for (final d in dates) {
      final key = _fmt.format(d);
      final list = map.putIfAbsent(key, () => <String>[]);
      list.add(d.toIso8601String());
    }
    await _save(habitId, map);
  }

  /// Returns a map of completion counts keyed by day string (yyyy-MM-dd).
  Future<Map<String, int>> getCompletionMap(String habitId) async {
    final map = await _load(habitId);
    return {for (final e in map.entries) e.key: e.value.length};
  }

  /// Toggles completion state for a [date] of the habit (0/1 legacy).
  Future<void> toggleCompletion(String habitId, DateTime date) async {
    final map = await _load(habitId);
    final key = _fmt.format(date);
    if (map.containsKey(key)) {
      map.remove(key);
    } else {
      map[key] = [date.toIso8601String()];
    }
    await _save(habitId, map);
  }

  /// Increment today's completion count.
  Future<void> incrementToday(String habitId) async {
    final map = await _load(habitId);
    final now = DateTime.now();
    final key = _fmt.format(now);
    final list = map.putIfAbsent(key, () => <String>[]);
    list.add(now.toIso8601String());
    await _save(habitId, map);
  }

  /// Decrement today's completion count.
  Future<void> decrementToday(String habitId) async {
    final map = await _load(habitId);
    final now = DateTime.now();
    final key = _fmt.format(now);
    final list = map[key];
    if (list == null || list.isEmpty) return;
    list.removeLast();
    if (list.isEmpty) map.remove(key);
    await _save(habitId, map);
  }

  /// Returns today's completion count.
  Future<int> todayCount(String habitId) async {
    final map = await _load(habitId);
    final key = _fmt.format(DateTime.now());
    return map[key]?.length ?? 0;
  }
}
