import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_hero_project/core/data/habit_repository.dart';
import 'package:habit_hero_project/core/data/models/habit.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('archive and restore habit', () async {
    final habit = Habit(id: '1', name: 'Test');
    await HabitRepository.addHabit(habit);

    var active = await HabitRepository.loadHabits();
    expect(active.length, 1);

    await HabitRepository.archiveHabit(habit.id);
    active = await HabitRepository.loadHabits();
    expect(active, isEmpty);
    var archived = await HabitRepository.loadArchivedHabits();
    expect(archived.length, 1);

    await HabitRepository.restoreHabit(habit.id);
    active = await HabitRepository.loadHabits();
    archived = await HabitRepository.loadArchivedHabits();
    expect(active.length, 1);
    expect(archived, isEmpty);

    await HabitRepository.deleteHabit(habit.id);
    active = await HabitRepository.loadHabits();
    expect(active, isEmpty);
  });

  test('delete archived habit', () async {
    final habit = Habit(id: '2', name: 'Another');
    await HabitRepository.addHabit(habit);
    await HabitRepository.archiveHabit(habit.id);
    var archived = await HabitRepository.loadArchivedHabits();
    expect(archived.length, 1);

    await HabitRepository.deleteArchivedHabit(habit.id);
    archived = await HabitRepository.loadArchivedHabits();
    expect(archived, isEmpty);
  });
}
