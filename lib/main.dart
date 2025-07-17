import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'app.dart';
import 'core/data/completion_repository.dart';
import 'core/data/habit_repository.dart';
import 'core/streak/streak_service.dart';
import 'core/services/di.dart';
import 'core/services/notification_permission_service.dart';
import 'core/analytics/analytics_service.dart';
import 'core/services/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final envFile = File('.env');
  if (envFile.existsSync()) {
    await dotenv.load(fileName: '.env');
  } else {
    await dotenv.load(fileName: '.env.example');
  }
  final getIt = GetIt.instance;
  getIt.registerLazySingleton<HabitRepository>(() => HabitRepository());
  getIt.registerLazySingleton<CompletionRepository>(() => CompletionRepository());
  getIt.registerLazySingleton<StreakService>(
      () => StreakService(getIt<CompletionRepository>()));
  final prefs = await SharedPreferences.getInstance();
  registerServices(getIt, prefs);

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
  final navigatorKey = GlobalKey<NavigatorState>();
  final completed = prefs.getBool('onboarding_complete') ?? false;
  final permSvc = getIt<NotificationPermissionService>();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    permSvc.ensurePermissionRequested(navigatorKey.currentContext!);
  });
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AnalyticsService>()),
        ChangeNotifierProvider(
            create: (_) => getIt<SettingsProvider>()..load()),
      ],
      child: App(onboardingComplete: completed, navigatorKey: navigatorKey),
    ),
  );
}
