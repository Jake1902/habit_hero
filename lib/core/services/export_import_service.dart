import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../data/habit_repository.dart';
import '../data/completion_repository.dart';
import '../data/models/habit.dart';

/// Service for exporting and importing habit data to JSON or CSV files.
class ExportImportService {
  ExportImportService(this._habitRepo, this._completionRepo);

  final HabitRepository _habitRepo;
  final CompletionRepository _completionRepo;

  /// Returns a timestamp string formatted as yyyyMMdd_HHmmss.
  String _timestamp() {
    final now = DateTime.now();
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }

  /// Export all habits and completions to a JSON file.
  Future<File> exportToJson() async {
    final dir = await getApplicationDocumentsDirectory();
    final habits = await HabitRepository.loadHabits();
    final completionData = <String, List<String>>{};
    for (final h in habits) {
      final dates = await _completionRepo.getCompletionDates(h.id);
      completionData[h.id] =
          dates.map((d) => d.toIso8601String()).toList();
    }
    final data = {
      'habits': habits.map((h) => h.toMap()).toList(),
      'completions': completionData,
    };
    final file = File('${dir.path}/habit_backup_${_timestamp()}.json');
    return file.writeAsString(jsonEncode(data));
  }

  /// Export all habits and completions to a CSV file.
  Future<File> exportToCsv() async {
    final dir = await getApplicationDocumentsDirectory();
    final habits = await HabitRepository.loadHabits();
    final rows = <List<dynamic>>[
      ['habitId', 'habitName', 'date', 'count'],
    ];
    for (final h in habits) {
      final map = await _completionRepo.getCompletionMap(h.id);
      for (final entry in map.entries) {
        final dateStr = entry.key;
        rows.add([h.id, h.name, dateStr, entry.value]);
      }
    }
    final csv = const ListToCsvConverter().convert(rows);
    final file = File('${dir.path}/habit_backup_${_timestamp()}.csv');
    return file.writeAsString(csv);
  }

  /// Import habits and completions from a JSON [file].
  Future<void> importFromJson(File file) async {
    final contents = await file.readAsString();
    final data = jsonDecode(contents) as Map<String, dynamic>;
    final List<dynamic> habitsData = data['habits'] as List<dynamic>? ?? [];
    final existing = await HabitRepository.loadHabits();
    final habitMap = {for (final h in existing) h.id: h};

    for (final item in habitsData) {
      final habit = Habit.fromMap(item as Map<String, dynamic>);
      if (habitMap.containsKey(habit.id)) {
        await HabitRepository.updateHabit(habit);
      } else {
        await HabitRepository.addHabit(habit);
      }
      habitMap[habit.id] = habit;
    }

    final completions = (data['completions'] as Map<String, dynamic>? ) ?? {};
    for (final entry in completions.entries) {
      final id = entry.key;
      final dates = (entry.value as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList();
      final existingDates = await _completionRepo.getCompletionDates(id);
      final set = <DateTime>{
        for (final d in existingDates)
          DateTime(d.year, d.month, d.day),
      };
      for (final d in dates) {
        set.add(DateTime(d.year, d.month, d.day));
      }
      final sorted = set.toList()..sort();
      await _completionRepo.saveCompletionDates(id, sorted);
    }
  }

  /// Import habits and completions from a CSV [file].
  Future<void> importFromCsv(File file) async {
    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);
    if (rows.isEmpty) return;

    final existing = await HabitRepository.loadHabits();
    final habitMap = {for (final h in existing) h.id: h};
    final completionMap = <String, Set<DateTime>>{};

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 4) continue;
      final id = row[0].toString();
      final name = row[1].toString();
      final date = DateTime.parse(row[2].toString());
      // Upsert habit
      if (!habitMap.containsKey(id)) {
        final habit = Habit(id: id, name: name);
        await HabitRepository.addHabit(habit);
        habitMap[id] = habit;
      }
      final set = completionMap.putIfAbsent(id, () => <DateTime>{});
      set.add(DateTime(date.year, date.month, date.day));
    }

    for (final entry in completionMap.entries) {
      final existingDates = await _completionRepo.getCompletionDates(entry.key);
      final set = <DateTime>{
        for (final d in existingDates)
          DateTime(d.year, d.month, d.day),
        ...entry.value,
      };
      final sorted = set.toList()..sort();
      await _completionRepo.saveCompletionDates(entry.key, sorted);
    }
  }
}
