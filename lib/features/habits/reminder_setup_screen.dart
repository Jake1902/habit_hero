import 'package:flutter/material.dart';

class ReminderSetupScreen extends StatefulWidget {
  const ReminderSetupScreen({
    super.key,
    this.initialTime,
    required this.initialWeekdays,
  });

  final TimeOfDay? initialTime;
  final List<int> initialWeekdays;

  @override
  State<ReminderSetupScreen> createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends State<ReminderSetupScreen> {
  TimeOfDay? _time;
  late List<int> _weekdays;

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime;
    _weekdays = List<int>.from(widget.initialWeekdays);
  }

  void _toggleDay(int day) {
    setState(() {
      if (_weekdays.contains(day)) {
        _weekdays.remove(day);
      } else {
        _weekdays.add(day);
      }
    });
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (result != null) setState(() => _time = result);
  }

  String get _previewText {
    if (_weekdays.isEmpty || _time == null) return 'None';
    final days = _weekdays
        .map((d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1])
        .join(', ');
    return 'Reminder set for ${_time!.format(context)} on $days';
  }

  void _save() {
    Navigator.pop(context, {'time': _time, 'weekdays': _weekdays});
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF8A2BE2);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Set Reminder'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final day = i + 1;
                final label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];
                final selected = _weekdays.contains(day);
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  selectedColor: purple,
                  onSelected: (_) => _toggleDay(day),
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_weekdays.isNotEmpty)
              ElevatedButton(
                onPressed: _pickTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(_time == null ? 'Pick time' : _time!.format(context)),
              ),
            const SizedBox(height: 16),
            Text(
              _previewText,
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
