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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Reminder',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _toggleAll,
            child: const Text('Select all'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (i) {
            final day = i + 1;
            final selected = _selected.contains(day);
            return FilterChip(
              label: Text(_weekdayName(day)),
              selected: selected,
              onSelected: (_) => _toggle(day),
              selectedColor: Theme.of(context).colorScheme.primary,
              checkmarkColor: Theme.of(context).colorScheme.onPrimary,
            );
          }),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ),
      ),
    );
  }

  String _weekdayName(int day) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[day - 1];
  }
}
