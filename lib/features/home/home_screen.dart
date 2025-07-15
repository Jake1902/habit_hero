import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/habit_repository.dart';
import '../../core/data/models/habit.dart';
import '../../core/streak/streak_service.dart';
import 'package:get_it/get_it.dart';
import 'dart:math';
import '../habits/habit_item_widget.dart';

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
  final Map<String, Map<DateTime, int>> _completionData = {};
  final Map<String, int> _currentStreaks = {};
  final Map<String, int> _longestStreaks = {};

  @override
  void initState() {
    super.initState();
    _habitsFuture = _loadAndCompute();
  }

  Future<List<Habit>> _loadAndCompute() async {
    final habits = await HabitRepository.loadHabits();
    final service = GetIt.I<StreakService>();
    for (final habit in habits) {
      final cs = await service.getCurrentStreak(habit.id);
      final ls = await service.getLongestStreak(habit.id);
      _currentStreaks[habit.id] = cs;
      _longestStreaks[habit.id] = ls;
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

  Map<DateTime, int> _generateMockCompletion() {
    final map = <DateTime, int>{};
    final now = DateTime.now();
    final random = Random();
    for (var i = 0; i < 90; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      map[day] = random.nextInt(3); // 0-2 completions
    }
    return map;
  }

  bool _completedToday(String id) {
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    final data = _completionData[id];
    if (data == null) return false;
    return (data[key] ?? 0) > 0;
  }

  void _toggleToday(String id, bool? value) {
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    final data = _completionData.putIfAbsent(id, _generateMockCompletion);
    data[key] = (value ?? false) ? 1 : 0;
    setState(() {});
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
          onPressed: () => context.go('/settings'),
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
            onPressed: () {},
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
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final data =
                    _completionData.putIfAbsent(habit.id, _generateMockCompletion);

                final current = _currentStreaks[habit.id];
                final longest = _longestStreaks[habit.id];
                return HabitItemWidget(
                  habit: habit,
                  completionData: data,
                  completedToday: _completedToday(habit.id),
                  onToggle: (v) => _toggleToday(habit.id, v),
                  currentStreak: current,
                  longestStreak: longest,
                  onEdit: () => _editHabit(habit),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
