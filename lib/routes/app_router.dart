import 'package:go_router/go_router.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/habits/add_edit_habit_screen.dart';
import '../features/habits/category_creation_screen.dart';
import '../features/habits/streak_goal_screen.dart';
import '../features/habits/reminder_screen.dart';
import '../features/archive/archive_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/theme_screen.dart';
import '../core/data/models/habit.dart';

GoRouter createRouter(bool onboardingComplete) {
  return GoRouter(
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
        path: '/archive',
        builder: (context, state) => const ArchiveScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/theme',
        builder: (_, __) => const ThemeScreen(),
      ),
    ],
  );
}
