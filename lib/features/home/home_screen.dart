import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/data/habit_repository.dart';
import '../../core/data/models/habit.dart';

/// Home screen displaying the user's habits.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Loaded habits.
  List<Habit> _habits = [];

  /// Completion status for today keyed by habit id.
  final Map<String, bool> _completed = {};

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  /// Loads habits and today's completion status from local storage.
  Future<void> loadHabits() async {
    final loaded = await HabitRepository.loadHabits();
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final status = <String, bool>{};
    for (final habit in loaded) {
      final key = 'completion_${habit.id}_$todayKey';
      status[habit.id] = prefs.getBool(key) ?? false;
    }
    setState(() {
      _habits = loaded;
      _completed
        ..clear()
        ..addAll(status);
    });
  }

  /// Toggles today's completion status for [habit].
  Future<void> _toggleCompletion(Habit habit, bool? value) async {
    final newValue = value ?? false;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final key = 'completion_${habit.id}_$todayKey';
    await prefs.setBool(key, newValue);
    setState(() => _completed[habit.id] = newValue);
  }

  /// Navigates to the habit creation screen and reloads on return.
  Future<void> _goToAddHabit() async {
    await context.push('/add_habit');
    if (mounted) await loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: false,
      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, size: 24, color: Colors.white),
          padding: const EdgeInsets.all(16),
          onPressed: () {},
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Habit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Kit',
              style: TextStyle(
                color: Color(0xFF8A2BE2),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, size: 24, color: Colors.white),
            padding: const EdgeInsets.all(12),
            onPressed: () {},
          ),
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, size: 28, color: Colors.white),
            padding: const EdgeInsets.all(12),
            onPressed: _goToAddHabit,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadHabits,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _habits.isEmpty
              // Empty state
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E1E1E),
                      ),
                      child: const Icon(Icons.add, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No habit found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a new habit to track your progress',
                      style: TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _goToAddHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A2BE2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Get started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
              // Habit list
              : ListView.separated(
                  itemCount: _habits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final habit = _habits[index];
                    final checked = _completed[habit.id] ?? false;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(habit.color),
                            ),
                            child: Icon(
                              IconData(habit.iconData,
                                  fontFamily: 'MaterialIcons'),
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              habit.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: checked,
                            activeColor: const Color(0xFF8A2BE2),
                            onChanged: (v) => _toggleCompletion(habit, v),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
