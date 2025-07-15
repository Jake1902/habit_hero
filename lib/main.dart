import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/home/home_screen.dart';
import 'features/habits/add_edit_habit_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool('onboarding_complete') ?? false;
  runApp(MyApp(onboardingComplete: completed));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;
  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Hero',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: onboardingComplete
          ? const MyHomePage(title: 'Habit Hero')
          : const OnboardingScreen(),
      routes: {
        '/add_habit': (_) => const AddEditHabitScreen(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Reuse the home screen from the features folder so that the
    // onboarding flow can push directly into the main app experience.
    return const HomeScreen();
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_PageData> _pages = const [
    _PageData(
      icon: Icons.checklist,
      title: 'Track Your Habits',
      subtitle: 'Stay on top of your daily goals.',
    ),
    _PageData(
      icon: Icons.local_fire_department,
      title: 'Stay Motivated with Streaks',
      subtitle: 'Build momentum and keep going!',
    ),
    _PageData(
      icon: Icons.notifications_active,
      title: 'Never Miss a Reminder',
      subtitle: 'Get notified so you never forget.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MyHomePage(title: 'Habit Hero')),
    );
  }

  void _next() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _back() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Icon(page.icon,
                              size: 64, color: theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.subtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              right: 0,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _currentIndex == 0 ? null : _back,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                    _currentIndex == _pages.length - 1 ? 'Get Started' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PageData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
