import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/radii.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';
import '../../widgets/app_button.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: scheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => context.push('/settings'),
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Roboto',
            ),
            children: [
              const TextSpan(
                text: 'Habit',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Hero',
                style: TextStyle(color: scheme.primary),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => context.push('/analytics'),
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
                padding: const EdgeInsets.all(AppSpacing.s24),
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
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    Text(
                      'No habit found',
                      style: AppTextStyles.headline.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    const Text(
                      'Create a new habit to track your progress',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.s32),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Get started',
                        onPressed: _goToAddHabit,
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
                    padding: EdgeInsets.only(bottom: AppSpacing.s16),
                    child: AnalyticsQuickRow(),
                  ),
                for (final habit in habits)
                  HabitItemWidget(
                    habit: habit,

                    completionMap: _completionData.putIfAbsent(
                      habit.id,
                      () => {},
                    ),
                    todayCount: _todayCount(habit.id),
                    onIncrement: () => _incrementToday(habit.id),
                    onDecrement: () => _decrementToday(habit.id),

                    currentStreak: _currentStreaks[habit.id],
                    longestStreak: _longestStreaks[habit.id],
                    onEdit: () => _editHabit(habit),

                    onLongPress: () => _showHabitOptions(habit),

                    onDayTapped: (day) {
                      context.push(
                        '/calendar_edit',
                        extra: {
                          'habitId': habit.id,
                          'habitName': habit.name,
                          'completionMap': _completionData[habit.id],
                        },
                      );
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
