import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:habit_hero_project/features/home/home_screen.dart';
import 'package:habit_hero_project/core/data/models/habit.dart';
import 'package:habit_hero_project/core/data/habit_repository.dart';
import 'package:habit_hero_project/core/data/completion_repository.dart';
import 'package:habit_hero_project/core/streak/streak_service.dart';
import 'package:habit_hero_project/core/services/notification_service.dart';
import 'package:habit_hero_project/core/analytics/analytics_service.dart';
import 'package:habit_hero_project/core/services/settings_provider.dart';

void main() {
  final getIt = GetIt.instance;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<HabitRepository>(() => HabitRepository());
    getIt.registerLazySingleton<CompletionRepository>(
      () => CompletionRepository(),
    );
    getIt.registerLazySingleton<StreakService>(
      () => StreakService(getIt<CompletionRepository>()),
    );
    getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(),
    );
    getIt.registerLazySingleton<AnalyticsService>(
      () => AnalyticsService(
        getIt<HabitRepository>(),
        getIt<CompletionRepository>(),
      ),
    );
    getIt.registerLazySingleton<SettingsProvider>(
      () => SettingsProvider(prefs),
    );
  });

  testWidgets('new habit heatmap empty then toggles', (tester) async {
    final habit = Habit(id: 'h1', name: 'Test', color: Colors.red.value);
    await HabitRepository.addHabit(habit);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: getIt<SettingsProvider>()..load(),
          ),
          ChangeNotifierProvider<AnalyticsService>.value(
            value: getIt<AnalyticsService>(),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final predicate = (Widget w) {
      return w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color == Color(habit.color);
    };

    expect(find.byWidgetPredicate(predicate), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate(predicate), findsOneWidget);
  });
}
