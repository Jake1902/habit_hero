import 'package:flutter/material.dart';

import '../data/habit_repository.dart';
import '../data/completion_repository.dart';
import '../streak/streak_service.dart';

/// Overall analytics statistics for all habits.
class OverallStats {
  OverallStats({
    required this.totalCompletions,
    required this.sevenDaySuccessRate,
    required this.longestStreak,
  });

  int totalCompletions;
  double sevenDaySuccessRate;
  int longestStreak;
}

/// Analytics statistics for a single habit.
class HabitStats {
  HabitStats({
    required this.last30Completions,
    required this.last30SuccessRate,
    required this.currentStreak,
  });

  int last30Completions;
  double last30SuccessRate;
  int currentStreak;
}

/// Service computing analytics information about habits and completions.
class AnalyticsService extends ChangeNotifier {
  AnalyticsService(this._habitRepo, this._completionRepo);

  final HabitRepository _habitRepo;
  final CompletionRepository _completionRepo;

  OverallStats _overall =
      OverallStats(totalCompletions: 0, sevenDaySuccessRate: 0, longestStreak: 0);
  Map<String, HabitStats> _perHabit = {};
  List<int> _last7Totals = [];

  OverallStats get overall => _overall;
  Map<String, HabitStats> get perHabit => _perHabit;
  List<int> get last7Totals => _last7Totals;

  /// Recalculate all analytics values.
  Future<void> refresh() async {
    final habits = await HabitRepository.loadHabits();
    final streakService = StreakService(_completionRepo);

    var totalCompletions = 0;
    var sevenDayCompletions = 0; // days with completion across all habits
    var longestStreak = 0;
    final perHabit = <String, HabitStats>{};
    final last7Totals = List<int>.filled(7, 0);

    final today = DateTime.now();
    final start7 = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));
    final start30 = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 29));

    for (final habit in habits) {
      final dates = await _completionRepo.getCompletionDates(habit.id);
      totalCompletions += dates.length;

      final unique7 = <DateTime>{};
      final unique30 = <DateTime>{};
      var count30 = 0;

      for (final d in dates) {
        final day = DateTime(d.year, d.month, d.day);
        if (!day.isBefore(start7)) {
          unique7.add(day);
          final index = day.difference(start7).inDays;
          if (index >= 0 && index < 7) {
            last7Totals[index] += 1;
          }
        }
        if (!day.isBefore(start30)) {
          unique30.add(day);
          count30++;
        }
      }

      sevenDayCompletions += unique7.length;

      final currentStreak = await streakService.getCurrentStreak(habit.id);
      final longest = await streakService.getLongestStreak(habit.id);
      if (longest > longestStreak) longestStreak = longest;

      perHabit[habit.id] = HabitStats(
        last30Completions: count30,
        last30SuccessRate: unique30.length / 30 * 100,
        currentStreak: currentStreak,
      );
    }

    final habitCount = habits.length;
    final successRate = habitCount == 0
        ? 0.0
        : (sevenDayCompletions / (habitCount * 7)) * 100;

    _overall = OverallStats(
      totalCompletions: totalCompletions,
      sevenDaySuccessRate: successRate,
      longestStreak: longestStreak,
    );
    _perHabit = perHabit;
    _last7Totals = last7Totals;
    notifyListeners();
  }
}
