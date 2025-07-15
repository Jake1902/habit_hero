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
    return MaterialApp.router(
      title: 'Habit Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

