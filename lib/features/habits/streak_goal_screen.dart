import 'package:flutter/material.dart';

import '../../core/data/models/habit.dart';

/// Screen that allows the user to select a streak goal interval.
class StreakGoalScreen extends StatelessWidget {
  final StreakGoal selected;
  const StreakGoalScreen({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streak Goal')),
      body: ListView(
        children: [
          for (final goal in StreakGoal.values)
            RadioListTile<StreakGoal>(
              value: goal,
              groupValue: selected,
              onChanged: (v) => Navigator.pop(context, v),
              title: Text(goal.name),
            ),
        ],
      ),
    );
  }
}
