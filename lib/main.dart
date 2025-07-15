import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool('onboarding_complete') ?? false;
  runApp(App(onboardingComplete: completed));
}
