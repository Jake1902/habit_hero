import 'package:flutter/material.dart';

/// Screen allowing the user to select reminder days of the week.
class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key, this.current});
  final List<int>? current;

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late List<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<int>.from(widget.current ?? []);
  }

  void _toggle(int day) {
    setState(() {
      if (_selected.contains(day)) {
        _selected.remove(day);
      } else {
        _selected.add(day);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      if (_selected.length == 7) {
        _selected.clear();
      } else {
        _selected = [1, 2, 3, 4, 5, 6, 7];
      }
    });
  }

  void _save() {
    Navigator.pop(context, _selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Select all'),
            trailing: Checkbox(
              value: _selected.length == 7,
              onChanged: (_) => _toggleAll(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = index + 1;
                return CheckboxListTile(
                  title: Text(_weekdayName(day)),
                  value: _selected.contains(day),
                  onChanged: (_) => _toggle(day),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.check),
      ),
    );
  }

  String _weekdayName(int day) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[day - 1];
  }
}
