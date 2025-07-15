import 'package:flutter_test/flutter_test.dart';
import 'package:habit_hero_project/core/data/completion_repository.dart';
import 'package:habit_hero_project/core/data/habit_repository.dart';
import 'package:habit_hero_project/core/data/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('increment and decrement today count', () async {
    final repo = CompletionRepository();
    final habit = Habit(id: 'h1', name: 'Water', completionTarget: 8);
    await HabitRepository.addHabit(habit);

    await repo.incrementToday(habit.id);
    await repo.incrementToday(habit.id);
    await repo.incrementToday(habit.id);
    expect(await repo.todayCount(habit.id), 3);

    await repo.decrementToday(habit.id);
    expect(await repo.todayCount(habit.id), 2);

    final map = await repo.getCompletionMap(habit.id);
    final key = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    expect(map[key], 2);
  });
}
