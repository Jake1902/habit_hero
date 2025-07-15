import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_hero_project/features/home/home_screen.dart';
import 'package:habit_hero_project/core/data/models/habit.dart';
import 'package:habit_hero_project/core/data/habit_repository.dart';
import 'package:habit_hero_project/core/data/completion_repository.dart';
import 'package:habit_hero_project/core/streak/streak_service.dart';
import 'package:habit_hero_project/core/services/notification_service.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();
    SharedPreferences.setMockInitialValues({});
    getIt.registerLazySingleton<HabitRepository>(() => HabitRepository());
    getIt.registerLazySingleton<CompletionRepository>(() => CompletionRepository());
    getIt.registerLazySingleton<StreakService>(
        () => StreakService(getIt<CompletionRepository>()));
    getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  });

  testWidgets('new habit heatmap empty then toggles', (tester) async {
    final habit = Habit(id: 'h1', name: 'Test', color: Colors.red.value);
    await HabitRepository.addHabit(habit);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
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
