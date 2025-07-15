// imports
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get_it/get_it.dart';

import '../../core/data/completion_repository.dart';

/// Screen allowing users to back-date or edit habit completions.
class CalendarEditScreen extends StatefulWidget {
  const CalendarEditScreen({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.completionMap,
  });

  /// Identifier of the habit being edited.
  final String habitId;

  /// Display name of the habit.
  final String habitName;

  /// Initial map of completion counts for each day.
  final Map<String, int> completionMap;

  @override
  State<CalendarEditScreen> createState() => _CalendarEditScreenState();
}

class _CalendarEditScreenState extends State<CalendarEditScreen> {
  final CompletionRepository _repo = GetIt.I<CompletionRepository>();

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late Map<String, int> _completionMap;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _completionMap = widget.completionMap;
  }

  Future<void> _handleDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() => _loading = true);
    try {
      await _repo.toggleCompletion(widget.habitId, selectedDay);
      final updatedMap = await _repo.getCompletionMap(widget.habitId);
      if (!mounted) return;
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _completionMap = updatedMap;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isSelected(DateTime day) {
    final key =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return _completionMap[key] != null && _completionMap[key]! > 0;
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF8A2BE2);
    final firstDay = DateTime.now().subtract(const Duration(days: 365));
    final lastDay = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.habitName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                TableCalendar<DateTime>(
                  firstDay: firstDay,
                  lastDay: lastDay,
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  onDaySelected: _handleDaySelected,
                  selectedDayPredicate: _isSelected,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.white),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Color(0xFFB0B0B0)),
                    weekendStyle: TextStyle(color: Color(0xFFB0B0B0)),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: purple),
                    ),
                    selectedDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: purple,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: purple,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle:
                        const TextStyle(color: Colors.white, fontSize: 14),
                    weekendTextStyle:
                        const TextStyle(color: Colors.white, fontSize: 14),
                    disabledTextStyle:
                        const TextStyle(color: Color(0xFF555555)),
                  ),
                ),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
