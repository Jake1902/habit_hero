import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/habits/add_edit_habit_screen.dart';
import 'features/habits/category_creation_screen.dart';
import 'features/habits/streak_goal_screen.dart';
import 'features/habits/reminder_screen.dart';
import 'core/data/models/habit.dart';

/// Root app widget
class App extends StatelessWidget {
  final bool onboardingComplete;
  const App({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: onboardingComplete ? '/home' : '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/add_habit',
          builder: (context, state) => AddEditHabitScreen(habit: state.extra as Habit?),
        ),
        GoRoute(
          path: '/create_category',
          builder: (context, state) => const CategoryCreationScreen(),
        ),
        GoRoute(
          path: '/streak_goal',
          builder: (context, state) => StreakGoalScreen(current: state.extra as StreakGoal?),
        ),
        GoRoute(
          path: '/reminder',
          builder: (context, state) => ReminderScreen(current: state.extra as List<int>?),
        ),
      ],
    );
    final baseDark = ThemeData.dark();
    return MaterialApp.router(
      title: 'Habit Tracker',
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        colorScheme: baseDark.colorScheme.copyWith(
          primary: const Color(0xFF8A2BE2),
          secondary: const Color(0xFF8A2BE2),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.white70),
        ),
      ),
      routerConfig: router,
    );
  }
}

