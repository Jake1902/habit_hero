import '../data/completion_repository.dart';

/// Service calculating habit streaks.
class StreakService {
  /// Creates a [StreakService] with the provided [CompletionRepository].
  StreakService(this._repo);

  final CompletionRepository _repo;

  /// Returns the number of consecutive days the habit has been completed
  /// ending today.
  Future<int> getCurrentStreak(String habitId) async {
    final dates = await _repo.getCompletionDates(habitId);
    dates.sort();
    if (dates.isEmpty) return 0;
    var streak = 0;
    var day = DateTime.now();
    for (var i = dates.length - 1; i >= 0; i--) {
      final d = DateTime(dates[i].year, dates[i].month, dates[i].day);
      if (d.isAtSameMomentAs(DateTime(day.year, day.month, day.day))) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Returns the longest run of consecutive completion days for the habit.
  Future<int> getLongestStreak(String habitId) async {
    final dates = await _repo.getCompletionDates(habitId);
    dates.sort();
    if (dates.isEmpty) return 0;
    var longest = 1;
    var current = 1;
    for (var i = 1; i < dates.length; i++) {
      final prev = DateTime(dates[i - 1].year, dates[i - 1].month, dates[i - 1].day);
      final cur = DateTime(dates[i].year, dates[i].month, dates[i].day);
      if (cur.difference(prev).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (!cur.isAtSameMomentAs(prev)) {
        current = 1;
      }
    }
    return longest;
  }
}
