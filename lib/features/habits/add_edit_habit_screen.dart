import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/data/models/habit.dart';
import 'category_creation_screen.dart';
import 'streak_goal_screen.dart';
import 'reminder_screen.dart';

/// Screen used for both adding a new habit and editing an existing habit.
class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit;
  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  IconData _icon = Icons.star_border;
  int _color = Colors.deepPurple.value;
  StreakGoal _streakGoal = StreakGoal.none;
  Set<int> _reminderDays = {};

  List<Category> _categories = [
    Category(name: 'Fitness', icon: Icons.fitness_center),
    Category(name: 'Finance', icon: Icons.attach_money),
    Category(name: 'Study', icon: Icons.school),
    Category(name: 'Social', icon: Icons.people),
  ];
  Set<String> _selectedCategories = {};

  CompletionTrackingType _trackingType = CompletionTrackingType.stepByStep;
  int _completionTarget = 1;

  bool _advancedExpanded = false;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _nameController = TextEditingController(text: habit?.name ?? '');
    _descController = TextEditingController(text: habit?.description ?? '');
    if (habit != null) {
      _icon = IconData(habit.iconData, fontFamily: 'MaterialIcons');
      _color = habit.color;
      _streakGoal = habit.streakGoal;
      _reminderDays = habit.reminderDays.toSet();
      _selectedCategories = habit.categories.toSet();
      _trackingType = habit.completionTrackingType;
      _completionTarget = habit.completionTarget;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final result = await showModalBottomSheet<IconData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _IconPicker(selected: _icon),
    );
    if (result != null) {
      setState(() => _icon = result);
    }
  }

  Future<void> _pickColor() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => _ColorPicker(selected: _color),
    );
    if (result != null) {
      setState(() => _color = result);
    }
  }

  Future<void> _pickStreakGoal() async {
    final result = await Navigator.push<StreakGoal>(
      context,
      MaterialPageRoute(builder: (_) => StreakGoalScreen(selected: _streakGoal)),
    );
    if (result != null) setState(() => _streakGoal = result);
  }

  Future<void> _pickReminderDays() async {
    final result = await Navigator.push<Set<int>>(
      context,
      MaterialPageRoute(
          builder: (_) => ReminderScreen(selectedDays: _reminderDays)),
    );
    if (result != null) setState(() => _reminderDays = result);
  }

  Future<void> _createCategory() async {
    final result = await Navigator.push<Category>(
      context,
      MaterialPageRoute(builder: (_) => const CategoryCreationScreen()),
    );
    if (result != null) {
      setState(() {
        _categories.add(result);
        _selectedCategories.add(result.name);
      });
    }
  }

  String _weekdayLabel(int day) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(day - 1) % 7];
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newHabit = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      name: _nameController.text,
      description: _descController.text,
      color: _color,
      iconData: _icon.codePoint,
      streakGoal: _streakGoal,
      reminderDays: _reminderDays.toList(),
      categories: _selectedCategories.toList(),
      completionTrackingType: _trackingType,
      completionTarget: _completionTarget,
    );

    final habits = await HabitStorage.loadHabits();
    final index = habits.indexWhere((h) => h.id == newHabit.id);
    if (index >= 0) {
      habits[index] = newHabit;
    } else {
      habits.add(newHabit);
    }
    await HabitStorage.saveHabits(habits);
    if (!mounted) return;
    Navigator.pop(context, newHabit);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _nameController.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Habit Name *'),
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickIcon,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(_color),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_icon, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _pickColor,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(_color),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: ExpansionTile(
                  initiallyExpanded: _advancedExpanded,
                  onExpansionChanged: (v) => setState(() => _advancedExpanded = v),
                  title: const Text('Advanced Options'),
                  children: [
                    ListTile(
                      title: const Text('Streak Goal'),
                      subtitle: Text(_streakGoal.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _pickStreakGoal,
                    ),
                    ListTile(
                      title: const Text('Reminder'),
                      subtitle: Text(
                        _reminderDays.isEmpty
                            ? 'None'
                            : _reminderDays
                                .map((d) => _weekdayLabel(d))
                                .join(', '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _pickReminderDays,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          const Text('Categories'),
                          ..._categories.map(
                            (c) => CheckboxListTile(
                              value: _selectedCategories.contains(c.name),
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedCategories.add(c.name);
                                  } else {
                                    _selectedCategories.remove(c.name);
                                  }
                                });
                              },
                              title: Text(c.name),
                              secondary: Icon(c.icon, color: Colors.white),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _createCategory,
                            icon: const Icon(Icons.add),
                            label: const Text('New Category'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(),
                          const Text('Completion Tracking'),
                          RadioListTile<CompletionTrackingType>(
                            value: CompletionTrackingType.stepByStep,
                            groupValue: _trackingType,
                            onChanged: (v) =>
                                setState(() => _trackingType = v!),
                            title: const Text('Step By Step'),
                          ),
                          RadioListTile<CompletionTrackingType>(
                            value: CompletionTrackingType.customValue,
                            groupValue: _trackingType,
                            onChanged: (v) =>
                                setState(() => _trackingType = v!),
                            title: const Text('Custom Value'),
                          ),
                          if (_trackingType ==
                              CompletionTrackingType.customValue)
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_completionTarget > 1) _completionTarget--;
                                    });
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    controller: TextEditingController(
                                        text: '$_completionTarget'),
                                    onChanged: (v) {
                                      final val = int.tryParse(v) ?? 1;
                                      setState(() => _completionTarget = val);
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _completionTarget++);
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Number of completions required per day.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
}

/// Simple icon picker widget used inside a modal bottom sheet.
class _IconPicker extends StatefulWidget {
  final IconData selected;
  const _IconPicker({required this.selected});

  @override
  State<_IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<_IconPicker> {
  final TextEditingController _searchController = TextEditingController();

  static const _icons = <MapEntry<String, IconData>>[
    MapEntry('star', Icons.star),
    MapEntry('alarm', Icons.alarm),
    MapEntry('book', Icons.book),
    MapEntry('fitness', Icons.fitness_center),
    MapEntry('money', Icons.attach_money),
    MapEntry('school', Icons.school),
    MapEntry('music', Icons.music_note),
    MapEntry('heart', Icons.favorite),
    MapEntry('work', Icons.work),
    MapEntry('coffee', Icons.coffee),
    MapEntry('code', Icons.code),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final icons = _icons
        .where((e) => e.key.contains(query))
        .map((e) => e.value)
        .toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search icons',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                children: [
                  for (final icon in icons)
                    GestureDetector(
                      onTap: () => Navigator.pop(context, icon),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final int selected;
  const _ColorPicker({required this.selected});

  static const _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GridView.count(
        crossAxisCount: 4,
        padding: const EdgeInsets.all(16),
        children: [
          for (final color in _colors)
            GestureDetector(
              onTap: () => Navigator.pop(context, color.value),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected == color.value
                        ? Colors.white
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
