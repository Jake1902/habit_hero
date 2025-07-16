import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

const kBg = Color(0xFF131712);
const kBtnDark = Color(0xFF2d372a);
const kBtnGreen = Color(0xFF53d22c);
const kTextGreen = Color(0xFFa5b6a0);

final kHeadingStyle = GoogleFonts.manrope(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  height: 1.2,
);
final kDescStyle = GoogleFonts.notoSans(
  fontSize: 16,
  color: Colors.white,
);

Widget buildOnboardingImage(String url) => Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) context.go('/home');
  }

  void _next() {
    if (_currentIndex == 2) {
      _completeOnboarding();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          children: [
            _OnboardingPage1(onNext: _next, onBack: _back),
            _OnboardingPage2(onNext: _next, onBack: _back),
            _OnboardingPage3(onBack: _back, onFinish: _completeOnboarding),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage1 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _OnboardingPage1({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: buildOnboardingImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuATlYoG-jw_xHSnFBeN2rLzDhcrMepoyTekLprk4VBIY3Mo-en_3wYxfswCn06rZtck-M2itQarE9aVvXKkb9ZdHjDLZSEw-RRXDrmQDA8zh3z8ENwu5gpU3rz-rWihEy8IN61dp5SStrU1LiuCaBHuRvC8YjTfDcGk0kg0r6Ww3ZdyAPp2o3NQWcoH4Hc_Ok-WXLtdMWmv6N4lrh95YHOnsVqqVlGessWd5VfBzw4skBWtlLuUicRLghyxH5zJaIoklPDkZE8vvyjc',
            ),
          ),
          const SizedBox(height: 32),
          Text('Welcome to Habit Hero', style: kHeadingStyle.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Build healthy habits and achieve your goals with our easy-to-use app.',
              style: kDescStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _OnboardingBtn(
                    label: 'Back',
                    color: kBtnDark,
                    textColor: Colors.white,
                    onTap: onBack,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OnboardingBtn(
                    label: 'Next',
                    color: kBtnGreen,
                    textColor: kBg,
                    onTap: onNext,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _OnboardingPage2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _OnboardingPage2({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Skip', style: kDescStyle.copyWith(color: kTextGreen, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: buildOnboardingImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCk3piZIwhV66OciDmYNQwLLTaC3fwKJTJtA3Swp07cuwb7ma9Jb38MYJpyaVGbnNxGPy04dk327HoyRNNZNKZ5nEULJGj3P-Z4eA8W0w1P-RMydqA-rxKuZ66Yv0NHUq8pTykdHwvpNP-S_N6A4pOhV_5nEI81uzOMxVC1SUEjowifAG2PDJM5-zHeaOC8SpzTbRbckYCNVvkN6hktqVIwG-OU6_zsl9D-bhg6cIJVGJC8Ygx8xVsQ3wUIt3pI9gT0m5TXglCKXcOy',
            ),
          ),
          const SizedBox(height: 24),
          Text('Track your progress', style: kHeadingStyle, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Stay motivated by tracking your progress and seeing how far you've come. Celebrate your wins and learn from your challenges.",
              style: kDescStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _OnboardingBtn(
                    label: 'Back',
                    color: kBtnDark,
                    textColor: Colors.white,
                    onTap: onBack,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OnboardingBtn(
                    label: 'Next',
                    color: kBtnGreen,
                    textColor: kBg,
                    onTap: onNext,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _OnboardingPage3 extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onFinish;
  const _OnboardingPage3({required this.onBack, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Skip', style: kDescStyle.copyWith(color: kTextGreen, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _OnboardingDot(color: Color(0xFF42513e)),
                SizedBox(width: 8),
                _OnboardingDot(color: Color(0xFF42513e)),
                SizedBox(width: 8),
                _OnboardingDot(color: Colors.white),
              ],
            ),
          ),
          buildOnboardingImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAdttUruwVc9NnQKn3WgxEbYjVTQQxa2MMRrnOrpoz9aDiWQHneZmKLD9eTiI7HcjTCMmmmw4XBMXrWI71x-hUEi4jS5YUfE7FSOBOruIDPqVHINxu9Pn7_-0X4fN1MCk4cnt-fpFiENTB_inlp9GoK1Emf6tj2nyjDPIUmEzYj0-ftSkWQxPJyJq3KPYZGfZ7oScTS2wbn3hSm7XgKfk_0RMfAiqkZ0CkRpY7Q-Yy_drxWsnR22b9Y5fjIm8M8D1WQrJ7m5UGS26eu',
          ),
          const SizedBox(height: 24),
          Text('Set goals', style: kHeadingStyle, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Set goals to track your progress and stay motivated.',
              style: kDescStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _OnboardingBtn(
                    label: 'Back',
                    color: kBtnDark,
                    textColor: Colors.white,
                    onTap: onBack,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OnboardingBtn(
                    label: 'Get Started',
                    color: kBtnGreen,
                    textColor: kBg,
                    onTap: onFinish,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _OnboardingBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _OnboardingBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: const StadiumBorder(),
        minimumSize: const Size(84, 44),
        elevation: 0,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}

class _OnboardingDot extends StatelessWidget {
  final Color color;
  const _OnboardingDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
