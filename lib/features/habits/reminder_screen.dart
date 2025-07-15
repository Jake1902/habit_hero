import 'package:flutter/material.dart';

/// Screen allowing the user to select reminder days of the week.
class ReminderScreen extends StatefulWidget {
  final Set<int> selectedDays; // 1-7 where 1 = Monday
  const ReminderScreen({super.key, required this.selectedDays});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late Set<int> _days;

  @override
  void initState() {
    super.initState();
    _days = {...widget.selectedDays};
  }

  void _toggle(int day) {
    setState(() {
      if (_days.contains(day)) {
        _days.remove(day);
      } else {
        _days.add(day);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_days.length == 7) {
        _days.clear();
      } else {
        _days = {1, 2, 3, 4, 5, 6, 7};
      }
    });
  }

  void _save() => Navigator.pop(context, _days);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Days')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Select All'),
            trailing: Checkbox(
              value: _days.length == 7,
              onChanged: (_) => _selectAll(),
            ),
            onTap: _selectAll,
          ),
          const Divider(),
          for (var i = 1; i <= 7; i++)
            CheckboxListTile(
              value: _days.contains(i),
              onChanged: (_) => _toggle(i),
              title: Text(_weekdayLabel(i)),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ),
    );
  }

  String _weekdayLabel(int day) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(day - 1) % 7];
  }
}
