import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_hero_project/core/data/habit_repository.dart';
import 'package:habit_hero_project/core/data/completion_repository.dart';
import 'package:habit_hero_project/core/services/export_import_service.dart';
import 'package:habit_hero_project/core/data/models/habit.dart';

void main() {
  final getIt = GetIt.instance;
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  getIt.registerLazySingleton<HabitRepository>(() => HabitRepository());
  getIt.registerLazySingleton<CompletionRepository>(
    () => CompletionRepository(),
  );
  final service = ExportImportService(
    getIt<HabitRepository>(),
    getIt<CompletionRepository>(),
  );

  test('export and import json retains habit count', () async {
    final habit = Habit(id: '1', name: 'Test');
    await HabitRepository.addHabit(habit);

    final file = await service.exportToJson();
    final countBefore = (await HabitRepository.loadHabits()).length;

    await service.importFromJson(file);
    final countAfter = (await HabitRepository.loadHabits()).length;

    expect(countBefore, countAfter);

    // cleanup
    await file.delete();
  });
}
