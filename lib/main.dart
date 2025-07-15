import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'app.dart';
import 'core/data/completion_repository.dart';
import 'core/streak/streak_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;
  getIt.registerLazySingleton<CompletionRepository>(() => CompletionRepository());
  getIt.registerLazySingleton<StreakService>(
      () => StreakService(getIt<CompletionRepository>()));
  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool('onboarding_complete') ?? false;
  runApp(App(onboardingComplete: completed));
}
