import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'features/home/home_screen.dart';

/// Root app widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const OnboardingScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

