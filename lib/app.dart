import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/services/settings_provider.dart';
import 'routes/app_router.dart';

/// Root app widget
class App extends StatefulWidget {
  final bool onboardingComplete;
  final GlobalKey<NavigatorState> navigatorKey;
  const App({super.key, required this.onboardingComplete, required this.navigatorKey});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(widget.onboardingComplete, widget.navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
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
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ),
    );

    return MaterialApp.router(
      title: 'Habit Tracker',
      themeMode: settings.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: _router,
    );
  }
}

