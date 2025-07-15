import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';

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

