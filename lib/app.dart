import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_router.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/habits/add_edit_habit_screen.dart';
import 'features/habits/category_creation_screen.dart';
import 'features/habits/streak_goal_screen.dart';
import 'features/habits/reminder_screen.dart';
import 'core/data/models/habit.dart';
import 'package:provider/provider.dart';
import 'core/services/settings_provider.dart';

/// Root app widget
class App extends StatelessWidget {
  final bool onboardingComplete;
  final GlobalKey<NavigatorState> navigatorKey;
  const App({super.key, required this.onboardingComplete, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(onboardingComplete, navigatorKey);
    final settings = context.watch<SettingsProvider>();
    final baseDark = ThemeData.dark();
    final baseLight = ThemeData.light();

    final darkTheme = ThemeData.dark().copyWith(
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
    );

    final lightTheme = ThemeData.light().copyWith(
      colorScheme: baseLight.colorScheme.copyWith(
        primary: const Color(0xFF8A2BE2),
        secondary: const Color(0xFF8A2BE2),
      ),
    );

    return MaterialApp.router(
      title: 'Habit Tracker',
      themeMode: settings.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
    );
  }
}

