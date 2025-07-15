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
      appBar: AppBar(title: const Text('Streak Goal')),
      body: Column(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.check),
      ),
    );
  }
}
