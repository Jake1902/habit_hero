import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/habits/add_edit_habit_screen.dart';
import '../features/habits/category_creation_screen.dart';
import '../features/habits/streak_goal_screen.dart';
import '../features/habits/reminder_screen.dart';
import '../features/habits/reminder_setup_screen.dart';
import '../features/calendar/calendar_edit_screen.dart';
import '../features/archive/archive_screen.dart';
import '../features/settings/settings_screen.dart';

import '../features/export_import/export_import_screen.dart';

import '../features/settings/theme_screen.dart';

import '../core/data/models/habit.dart';

GoRouter createRouter(bool onboardingComplete, GlobalKey<NavigatorState> key) {
  return GoRouter(
    navigatorKey: key,
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
        builder: (context, state) =>
            AddEditHabitScreen(habit: state.extra as Habit?),
      ),
      GoRoute(
        path: '/create_category',
        builder: (context, state) => const CategoryCreationScreen(),
      ),
      GoRoute(
        path: '/streak_goal',
        builder: (context, state) =>
            StreakGoalScreen(current: state.extra as StreakGoal?),
      ),
      GoRoute(
        path: '/reminder',
        builder: (context, state) =>
            ReminderScreen(current: state.extra as List<int>?),
      ),
      GoRoute(
        path: '/calendar_edit',
        name: 'calendar_edit',
        builder: (_, state) {
          final args = state.extra! as Map<String, dynamic>;
          return CalendarEditScreen(
            habitId: args['habitId'],
            habitName: args['habitName'],
            completionMap: args['completionMap'],
          );
        },
      ),
      GoRoute(
        path: '/reminder_setup',
        builder: (_, state) {
          final extra = state.extra! as Map<String, dynamic>;
          return ReminderSetupScreen(
            initialTime: extra['initialTime'] as TimeOfDay?,
            initialWeekdays:
                List<int>.from(extra['initialWeekdays'] as List<dynamic>),
          );
        },
      ),
      GoRoute(
        path: '/archive',
        builder: (context, state) => const ArchiveScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/backup_restore',
        name: 'backup_restore',
        builder: (_, __) => const ExportImportScreen(),
      ),
      GoRoute(
        path: '/theme',
        builder: (_, __) => const ThemeScreen(),
      ),
    ],
  );
}
