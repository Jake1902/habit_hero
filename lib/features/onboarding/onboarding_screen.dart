import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Displays a simple three page onboarding flow.
///
/// The screen uses a [PageView] so the user can swipe horizontally between
/// pages. Each page shows an icon, title and subtitle describing a feature of
/// the app. Users can navigate with Back/Next buttons or skip the onboarding
/// entirely. Completion is stored with [SharedPreferences] and the user is
/// navigated to the '/home' route.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  /// Data describing each onboarding page.
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
      icon: Icons.notifications,
      title: 'Never Miss a Reminder',
      subtitle: 'Get notified so you never forget.',
    ),
  ];

  /// Marks onboarding as complete and navigates to the home route.
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  /// Advances to the next page or finishes onboarding on the last page.
  void _next() {
    if (_currentIndex == _pages.length - 1) {
      _completeOnboarding();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Returns to the previous page if possible.
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
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
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
                            color: theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Icon(
                            page.icon,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                  _currentIndex == _pages.length - 1
                      ? 'Get Started'
                      : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model class holding icon and text for a single page.
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
