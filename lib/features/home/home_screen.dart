import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/habit_repository.dart';
import '../../core/data/models/habit.dart';
import '../../core/data/completion_repository.dart';
import '../../core/streak/streak_service.dart';
import 'package:get_it/get_it.dart';
import '../habits/habit_item_widget.dart';
import '../../core/services/notification_service.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/services/settings_provider.dart';
import 'package:provider/provider.dart';
import '../analytics/analytics_quick_row.dart';
import 'package:intl/intl.dart';

/// Home screen shown when the user has completed onboarding.
///
/// Displays an empty state prompting the user to add their first habit.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Habit>> _habitsFuture;
  final Map<String, Map<String, int>> _completionData = {};
  final Map<String, int> _currentStreaks = {};
  final Map<String, int> _longestStreaks = {};

  @override
  void initState() {
    super.initState();
    _habitsFuture = _loadAndCompute();
    GetIt.I<AnalyticsService>().refresh();
  }

  Future<List<Habit>> _loadAndCompute() async {
    final habits = await HabitRepository.loadHabits();
    final service = GetIt.I<StreakService>();
    final completionRepo = GetIt.I<CompletionRepository>();
    for (final habit in habits) {
      final cs = await service.getCurrentStreak(habit);
      final ls = await service.getLongestStreak(habit);
      _currentStreaks[habit.id] = cs;
      _longestStreaks[habit.id] = ls;
      final map = await completionRepo.getCompletionMap(habit.id);
      _completionData[habit.id] = map;
    }
    return habits;
  }

  Future<void> _refresh() async {
    final habits = await _loadAndCompute();
    setState(() {
      _habitsFuture = Future.value(habits);
    });
  }

  Future<void> _goToAddHabit() async {
    await context.push('/add_habit');
    if (mounted) {
      _refresh();
    }
  }

  Future<void> _editHabit(Habit habit) async {
    await context.push('/add_habit', extra: habit);
    if (mounted) {
      _refresh();
    }
  }

  Future<void> _archiveHabit(Habit habit) async {
    final notificationService = GetIt.I<NotificationService>();
    await notificationService.cancelHabitReminders(habit.id);
    await HabitRepository.archiveHabit(habit.id);
    if (mounted) {
      _refresh();
    }
  }

  void _showHabitOptions(Habit habit) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.archive, color: Colors.white),
          title: const Text('Archive', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            _archiveHabit(habit);
          },
        ),
      ),
    );
  }


  int _todayCount(String id) {
    final key = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    final data = _completionData[id];
    if (data == null) return 0;
    return data[key] ?? 0;
  }

  Future<void> _incrementToday(String id) async {
    final repo = GetIt.I<CompletionRepository>();
    final service = GetIt.I<StreakService>();
    await repo.incrementToday(id);
    final map = await repo.getCompletionMap(id);
    final habits = await HabitRepository.loadHabits();
    final habit = habits.firstWhere((h) => h.id == id);
    final cs = await service.getCurrentStreak(habit);
    final ls = await service.getLongestStreak(habit);
    if (!mounted) return;
    setState(() {
      _completionData[id] = map;
      _currentStreaks[id] = cs;
      _longestStreaks[id] = ls;
    });
  }

  Future<void> _decrementToday(String id) async {
    final repo = GetIt.I<CompletionRepository>();
    final service = GetIt.I<StreakService>();
    await repo.decrementToday(id);
    final map = await repo.getCompletionMap(id);
    final habits = await HabitRepository.loadHabits();
    final habit = habits.firstWhere((h) => h.id == id);
    final cs = await service.getCurrentStreak(habit);
    final ls = await service.getLongestStreak(habit);
    if (!mounted) return;
    setState(() {
      _completionData[id] = map;
      _currentStreaks[id] = cs;
      _longestStreaks[id] = ls;
    });
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF8A2BE2);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => context.push('/settings'),
        ),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Roboto',
            ),
            children: [
              TextSpan(text: 'Habit', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Hero', style: TextStyle(color: purple)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => context.go('/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _goToAddHabit,
          ),
        ],
      ),
      body: FutureBuilder<List<Habit>>(
        future: _habitsFuture,
        builder: (context, snapshot) {
          final habits = snapshot.data ?? [];
          if (habits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No habit found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a new habit to track your progress',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _goToAddHabit,
                        child: const Text('Get started'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,

            child: ListView(
              children: [
                if (context.watch<SettingsProvider>().showQuickStats)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: AnalyticsQuickRow(),
                  ),
                for (final habit in habits)
                  HabitItemWidget(
                    habit: habit,

                    completionMap:
                        _completionData.putIfAbsent(habit.id, () => {}),
                    todayCount: _todayCount(habit.id),
                    onIncrement: () => _incrementToday(habit.id),
                    onDecrement: () => _decrementToday(habit.id),

                    currentStreak: _currentStreaks[habit.id],
                    longestStreak: _longestStreaks[habit.id],
                    onEdit: () => _editHabit(habit),

                    onLongPress: () => _showHabitOptions(habit),

                    onDayTapped: (day) {
                      context.push('/calendar_edit', extra: {
                        'habitId': habit.id,
                        'habitName': habit.name,
                        'completionMap': _completionData[habit.id],
                      });
                    },

                  ),
              ],

            ),
          );
        },
      ),
    );
  }
}
