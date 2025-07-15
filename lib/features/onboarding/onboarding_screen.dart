import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// OnboardingScreen displays a 3-page introduction to the app.
///
/// A [PageView] is used to let users swipe horizontally between pages.
/// Each page shows an icon, a title and a subtitle explaining a feature.
/// Users can navigate using the Back/Next buttons at the bottom or skip
/// the onboarding entirely using the button at the top right.
/// When the onboarding is finished or skipped, a flag is stored using
/// [SharedPreferences] and the app navigates to the `/home` route.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Marks the onboarding as complete and navigates to the home screen.
  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  /// Moves to the next page or completes onboarding on the last page.
  void _nextPage() {
    if (_currentPage == 2) {
      _completeOnboarding(context);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Moves to the previous page if possible.
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        icon: Icons.track_changes,
        title: 'Track Habits',
        subtitle: 'Monitor your daily habits and stay consistent.',
      ),
      _buildPage(
        icon: Icons.star,
        title: 'Earn Rewards',
        subtitle: 'Achieve goals and collect badges for motivation.',
      ),
      _buildPage(
        icon: Icons.insights,
        title: 'Get Insights',
        subtitle: 'Analyze your progress with detailed statistics.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          TextButton(
            onPressed: () => _completeOnboarding(context),
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentPage == 0 ? null : _previousPage,
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build a single onboarding page.
  Widget _buildPage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
