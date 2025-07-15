import 'package:flutter/material.dart';
import '../../core/data/habit_repository.dart';
import '../../core/data/models/habit.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/notification_service.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late Future<List<Habit>> _archivedFuture;

  @override
  void initState() {
    super.initState();
    _archivedFuture = HabitRepository.loadArchivedHabits();
  }

  Future<void> _refresh() async {
    final list = await HabitRepository.loadArchivedHabits();
    setState(() {
      _archivedFuture = Future.value(list);
    });
  }

  Future<void> _restore(Habit habit) async {
    await HabitRepository.restoreHabit(habit.id);
    final notificationService = GetIt.I<NotificationService>();
    if (habit.reminderTime != null && habit.reminderWeekdays.isNotEmpty) {
      await notificationService.scheduleHabitReminder(
        habitId: habit.id,
        title: habit.name,
        time: habit.reminderTime!,
        weekdays: habit.reminderWeekdays,
      );
    }
    _refresh();
  }

  Future<void> _delete(Habit habit) async {
    final notificationService = GetIt.I<NotificationService>();
    await notificationService.cancelHabitReminders(habit.id);
    await HabitRepository.deleteArchivedHabit(habit.id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Archive'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: FutureBuilder<List<Habit>>(
        future: _archivedFuture,
        builder: (context, snapshot) {
          final habits = snapshot.data ?? [];
          if (habits.isEmpty) {
            return const Center(
              child: Text(
                'No archived habits',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final icon =
                    IconData(habit.iconData, fontFamily: 'MaterialIcons');
                return ListTile(
                  leading: Icon(icon, color: Colors.white),
                  title: Text(habit.name,
                      style: const TextStyle(color: Colors.white)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.white),
                        onPressed: () => _restore(habit),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _delete(habit),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
