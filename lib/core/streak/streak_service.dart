import '../data/completion_repository.dart';
import '../data/models/habit.dart';
import 'package:intl/intl.dart';

/// Service calculating habit streaks.
class StreakService {
  /// Creates a [StreakService] with the provided [CompletionRepository].
  StreakService(this._repo);

  final CompletionRepository _repo;
  final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  bool _isComplete(Map<String, int> map, Habit habit, String key) {
    final count = map[key] ?? 0;
    if (habit.completionTrackingType == CompletionTrackingType.customValue) {
      return count >= habit.completionTarget;
    }
    return count > 0;
  }

  /// Returns the number of consecutive days the habit has been completed
  /// ending today.
  Future<int> getCurrentStreak(Habit habit) async {
    final map = await _repo.getCompletionMap(habit.id);
    if (map.isEmpty) return 0;
    var streak = 0;
    var day = DateTime.now();
    while (true) {
      final key = _fmt.format(day);
      if (_isComplete(map, habit, key)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Returns the longest run of consecutive completion days for the habit.
  Future<int> getLongestStreak(Habit habit) async {
    final map = await _repo.getCompletionMap(habit.id);
    if (map.isEmpty) return 0;
    final keys = map.keys.toList()..sort();
    var longest = 0;
    var current = 0;
    DateTime? prev;
    for (final key in keys) {
      final date = _fmt.parse(key);
      if (!_isComplete(map, habit, key)) {
        prev = null;
        current = 0;
        continue;
      }
      if (prev != null && date.difference(prev!).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > longest) longest = current;
      prev = date;
    }
    return longest;
  }
}
