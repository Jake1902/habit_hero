import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'app.dart';
import 'core/data/completion_repository.dart';
import 'core/data/habit_repository.dart';
import 'core/streak/streak_service.dart';
import 'core/services/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;
  getIt.registerLazySingleton<HabitRepository>(() => HabitRepository());
  getIt.registerLazySingleton<CompletionRepository>(() => CompletionRepository());
  getIt.registerLazySingleton<StreakService>(
      () => StreakService(getIt<CompletionRepository>()));
  registerServices(getIt);

  AwesomeNotifications().initialize(
    'resource://drawable/ic_launcher',
    [
      NotificationChannel(
        channelKey: 'habit_reminders',
        channelName: 'Habit Reminders',
        channelDescription: 'Daily habit reminders',
        defaultColor: const Color(0xFF8A2BE2),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      ),
    ],
    debug: true,
  );
  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool('onboarding_complete') ?? false;
  runApp(App(onboardingComplete: completed));
}
