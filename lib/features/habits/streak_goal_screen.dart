import 'package:flutter/material.dart';
import '../../core/data/models/habit.dart';

/// Screen to select a streak goal interval.
class StreakGoalScreen extends StatefulWidget {
  const StreakGoalScreen({super.key, this.current});
  final StreakGoal? current;

  @override
  State<StreakGoalScreen> createState() => _StreakGoalScreenState();
}

class _StreakGoalScreenState extends State<StreakGoalScreen> {
  late StreakGoal _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current ?? StreakGoal.none;
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
        title: const Text('Streak Goal',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: StreakGoal.values
            .map(
              (e) => RadioListTile<StreakGoal>(
                title: Text(e.name),
                value: e,
                groupValue: _selected,
                onChanged: (val) => setState(() => _selected = val!),
              ),
            )
            .toList(),
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
}
