import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/data/habit_repository.dart';
import '../../core/data/models/habit.dart';
import 'category_creation_screen.dart';
import 'reminder_screen.dart';
import 'streak_goal_screen.dart';

/// Screen for creating or editing a habit.
class AddEditHabitScreen extends StatefulWidget {
  const AddEditHabitScreen({super.key, this.habit});

  /// Habit being edited. When null, a new habit is created.
  final Habit? habit;

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  IconData _icon = Icons.check;
  int _color = Colors.blue.value;

  bool _advancedExpanded = false;

  StreakGoal _streakGoal = StreakGoal.none;
  List<int> _reminderDays = [];
  List<String> _categories = [];
  CompletionTrackingType _trackingType = CompletionTrackingType.stepByStep;
  int _completionTarget = 1;

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _nameController = TextEditingController(text: habit?.name ?? '');
    _descriptionController =
        TextEditingController(text: habit?.description ?? '');
    if (habit != null) {
      _icon = IconData(habit.iconData, fontFamily: 'MaterialIcons');
      _color = habit.color;
      _streakGoal = habit.streakGoal;
      _reminderDays = List.of(habit.reminderDays);
      _categories = List.of(habit.categories);
      _trackingType = habit.completionTrackingType;
      _completionTarget = habit.completionTarget;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Opens a bottom sheet allowing the user to pick an icon.
  Future<void> _pickIcon() async {
    final result = await showModalBottomSheet<IconData>(
      context: context,
      builder: (context) => _IconPicker(initial: _icon),
    );
    if (result != null) {
      setState(() => _icon = result);
    }
  }

  /// Allows the user to pick a color.
  Future<void> _pickColor() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => _ColorPicker(initial: _color),
    );
    if (result != null) {
      setState(() => _color = result);
    }
  }

  /// Navigates to the streak goal screen.
  Future<void> _editStreakGoal() async {
    final result = await context.push<StreakGoal>(
      '/streak_goal',
      extra: _streakGoal,
    );
    if (result != null) {
      setState(() => _streakGoal = result);
    }
  }

  /// Navigates to the reminder screen.
  Future<void> _editReminders() async {
    final result = await context.push<List<int>>(
      '/reminder',
      extra: _reminderDays,
    );
    if (result != null) {
      setState(() => _reminderDays = result);
    }
  }

  /// Navigates to the category creation screen and adds a new category.
  Future<void> _createCategory() async {
    final result = await context.push<String>('/create_category');
    if (result != null) {
      setState(() => _categories.add(result));
    }
  }

  /// Saves the habit and pops the screen.
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final habit = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      name: name,
      description: _descriptionController.text.trim(),
      color: _color,
      iconData: _icon.codePoint,
      streakGoal: _streakGoal,
      reminderDays: _reminderDays,
      categories: _categories,
      completionTrackingType: _trackingType,
      completionTarget: _completionTarget,
    );
    if (_isEditing) {
      await HabitRepository.updateHabit(habit);
    } else {
      await HabitRepository.addHabit(habit);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _nameController.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'New Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Habit Name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(_icon, color: Color(_color)),
              title: const Text('Icon'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickIcon,
            ),
            ListTile(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(_color),
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Color'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickColor,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _advancedExpanded = !_advancedExpanded),
              child: Row(
                children: [
                  const Text('Advanced Options'),
                  const Spacer(),
                  Icon(_advancedExpanded
                      ? Icons.expand_less
                      : Icons.expand_more),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  ListTile(
                    title: const Text('Streak Goal'),
                    subtitle: Text(_streakGoal.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _editStreakGoal,
                  ),
                  ListTile(
                    title: const Text('Reminder Days'),
                    subtitle: Text(
                      _reminderDays.isEmpty
                          ? 'None'
                          : _reminderDays.map(_weekdayName).join(', '),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _editReminders,
                  ),
                  ListTile(
                    title: const Text('Categories'),
                    subtitle: Text(
                      _categories.isEmpty
                          ? 'None'
                          : _categories.join(', '),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _createCategory,
                  ),
                  SwitchListTile(
                    title: const Text('Step By Step'),
                    value: _trackingType ==
                        CompletionTrackingType.stepByStep,
                    onChanged: (val) => setState(() {
                      _trackingType = val
                          ? CompletionTrackingType.stepByStep
                          : CompletionTrackingType.customValue;
                    }),
                  ),
                  if (_trackingType ==
                      CompletionTrackingType.customValue)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _completionTarget > 1
                              ? () => setState(() => _completionTarget--)
                              : null,
                        ),
                        Expanded(
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            initialValue: '$_completionTarget',
                            onChanged: (v) {
                              final val = int.tryParse(v) ?? 1;
                              setState(() => _completionTarget = val);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () =>
                              setState(() => _completionTarget++),
                        ),
                      ],
                    ),
                ],
              ),
              crossFadeState: _advancedExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: isValid ? _save : null,
          child: const Text('Save'),
        ),
      ),
    );
  }

  /// Returns weekday name for given int (1=Mon).
  String _weekdayName(int day) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[day - 1];
  }
}

/// Simple icon picker with a searchable grid.
class _IconPicker extends StatefulWidget {
  const _IconPicker({required this.initial});
  final IconData initial;

  @override
  State<_IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<_IconPicker> {
  final TextEditingController _searchController = TextEditingController();
  late List<IconData> _icons;
  late IconData _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _icons = _allIcons;
    _searchController.addListener(_filter);
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _icons = _allIcons
          .where((e) => e.codePoint
              .toString()
              .contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search icons',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final icon = _icons[index];
                final selected = icon == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = icon),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon,
                        color: selected ? Colors.white : Colors.white70),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selected),
              child: const Text('Select'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple color picker bottom sheet.
class _ColorPicker extends StatefulWidget {
  const _ColorPicker({required this.initial});
  final int initial;
  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  static const colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lime,
    Colors.orange,
    Colors.brown,
  ];
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final selected = color.value == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = color.value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: Colors.white,
                              width: 3,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _selected),
            child: const Text('Select'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Limited set of icons displayed in the picker.
const List<IconData> _allIcons = [
  Icons.star_border,
  Icons.favorite_border,
  Icons.run_circle_outlined,
  Icons.book_outlined,
  Icons.fitness_center,
  Icons.savings_outlined,
  Icons.school_outlined,
  Icons.self_improvement,
  Icons.work_outline,
  Icons.music_note,
  Icons.food_bank_outlined,
  Icons.water_drop_outlined,
  Icons.timer_outlined,
  Icons.mood_outlined,
  Icons.code,
];
