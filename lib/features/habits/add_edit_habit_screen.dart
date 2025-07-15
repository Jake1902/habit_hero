import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/data/habit_repository.dart';
import '../../core/data/models/habit.dart';
import 'category_creation_screen.dart';
import 'streak_goal_screen.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/notification_permission_service.dart';
import '../../core/data/models/habit_template.dart';

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
  // Selected ARGB value used for progress tiles on the Home screen. This does
  // not tint the habit icon.
  int _color = Colors.blue.value;

  bool _advancedExpanded = false;

  StreakGoal _streakGoal = StreakGoal.none;
  TimeOfDay? _reminderTime;
  List<int> _reminderWeekdays = [];
  List<String> _categories = [];
  CompletionTrackingType _trackingType = CompletionTrackingType.stepByStep;
  int _completionTarget = 1;
  bool _isMultiple = false;

  static const List<String> _allCategories = [
    'Art',
    'Finance',
    'Fitness',
    'Health',
    'Nutrition',
    'Social',
    'Study',
    'Work',
    'Other',
    'Morning',
    'Day',
    'Evening',
  ];

  static const List<Color> _colorOptions = [
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.blue,
    Colors.indigo,
    Colors.deepPurple,
    Colors.purple,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Color(0xFFB39DDB),
    Color(0xFF80CBC4),
    Color(0xFFFFAB91),
    Color(0xFFE6EE9C),
    Color(0xFFCE93D8),
    Color(0xFFA5D6A7),
    Color(0xFFFFF59D),
    Color(0xFFB0BEC5),
    Color(0xFF90A4AE),
    Color(0xFFE0E0E0),
    Color(0xFF4DB6AC),
  ];

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
      _reminderTime = habit.reminderTime;
      _reminderWeekdays = List.of(habit.reminderWeekdays);
      _categories = List.of(habit.categories);
      _trackingType = habit.completionTrackingType;
      _completionTarget = habit.completionTarget;
      _isMultiple = habit.isMultiple;
    } else {
      _trackingType = CompletionTrackingType.stepByStep;
      _completionTarget = 1;
      _isMultiple = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Opens a fullscreen dialog allowing the user to pick an icon.
  Future<void> _pickIcon() async {
    final result = await showDialog<IconData>(
      context: context,
      builder: (context) => _IconPicker(initial: _icon),
    );
    if (result != null) setState(() => _icon = result);
  }

  /// Allows the user to pick a color using a modal dialog.
  Future<void> _pickColor() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _ColorPicker(initial: _color),
    );
    if (result != null) setState(() => _color = result);
  }

  /// Opens a time picker for selecting the reminder time.
  Future<void> _pickReminderTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (result != null) setState(() => _reminderTime = result);
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

  /// Navigates to the category creation screen and adds a new category.
  Future<void> _createCategory() async {
    final result = await context.push<String>('/create_category');
    if (result != null) {
      setState(() => _categories.add(result));
    }
  }

  void _toggleCategory(String name) {
    setState(() {
      if (_categories.contains(name)) {
        _categories.remove(name);
      } else {
        _categories.add(name);
      }
    });
  }

  String get _reminderSummaryText {
    if (_reminderTime == null || _reminderWeekdays.isEmpty) return 'None';
    final time = _reminderTime!.format(context);
    final labels = _reminderWeekdays
        .map((d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1])
        .join(', ');
    return '$time on $labels';
  }

  /// Saves the habit and pops the screen.
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (!_isMultiple) {
      _trackingType = CompletionTrackingType.customValue;
      _completionTarget = 1;
    }
    final habit = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      name: name,
      description: _descriptionController.text.trim(),
      color: _color,
      iconData: _icon.codePoint,
      streakGoal: _streakGoal,
      reminderDays: [],
      reminderTime: _reminderTime,
      reminderWeekdays: _reminderWeekdays,
      categories: _categories,
      completionTrackingType: _trackingType,
      completionTarget: _completionTarget,
      isMultiple: _isMultiple,
    );
    if (_isEditing) {
      await HabitRepository.updateHabit(habit);
    } else {
      await HabitRepository.addHabit(habit);
    }
    final notificationService = GetIt.I<NotificationService>();
    if (habit.reminderTime != null && habit.reminderWeekdays.isNotEmpty) {
      await GetIt.I<NotificationPermissionService>()
          .ensurePermissionRequested(context);
      await notificationService.scheduleHabitReminder(
        habitId: habit.id,
        title: habit.name,
        time: habit.reminderTime!,
        weekdays: habit.reminderWeekdays,
      );
    } else {
      await notificationService.cancelHabitReminders(habit.id);
    }
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _nameController.text.trim().isNotEmpty;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'New Habit',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.view_module),
                label: const Text('Browse templates'),
                onPressed: () async {
                  final tpl = await context.push<HabitTemplate>('/templates');
                  if (tpl != null) {
                    setState(() {
                      _nameController.text = tpl.name;
                      _descriptionController.text = tpl.description;
                      _icon =
                          IconData(tpl.iconData, fontFamily: 'MaterialIcons');
                      _color = tpl.color;
                      _reminderTime = tpl.reminderTime;
                      _reminderWeekdays = tpl.reminderWeekdays;
                      _trackingType =
                          tpl.completionTrackingType == 'customValue'
                              ? CompletionTrackingType.customValue
                              : CompletionTrackingType.stepByStep;
                      _completionTarget = tpl.completionTarget;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // Icon preview uses a neutral background. The selected color
                  // only affects progress tiles, not the icon itself.
                  child: Icon(_icon,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 40),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Name'),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Name',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              const Text('Description'),
              const SizedBox(height: 4),
              TextField(
                controller: _descriptionController,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final color in _colorOptions)
                    GestureDetector(
                      onTap: () => setState(() => _color = color.value),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _color == color.value
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF2A2A2A)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () =>
                    setState(() => _advancedExpanded = !_advancedExpanded),
                child: Row(
                  children: [
                    const Text('Advanced Options',
                        style: TextStyle(color: Color(0xFFB0B0B0))),
                    const Spacer(),
                    Icon(
                      _advancedExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildAdvancedOptions(),
                crossFadeState: _advancedExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isValid
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.24),
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: isValid ? _save : null,
              child: const Text('Save'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Icon'),
          // Icon color remains white; habit color only influences progress
          // tiles on the home screen.
          trailing:
              Icon(_icon, color: Theme.of(context).colorScheme.onBackground),
          onTap: _pickIcon,
        ),
        ListTile(
          title: const Text('Streak Goal'),
          subtitle: Text(_streakGoal.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: _editStreakGoal,
        ),
        ListTile(
          leading:
              Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.onBackground),
          title: Text(_reminderSummaryText,
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
          trailing:
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onBackground),
          onTap: () async {
            final result = await context.push<Map<String, dynamic>>(
              '/reminder_setup',
              extra: {
                'initialTime': _reminderTime,
                'initialWeekdays': _reminderWeekdays,
              },
            );
            if (result != null) {
              setState(() {
                _reminderTime = result['time'] as TimeOfDay?;
                _reminderWeekdays =
                    List<int>.from(result['weekdays'] as List<dynamic>);
              });
            }
          },
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._allCategories.map((c) => FilterChip(
                  label: Text(c),
                  selected: _categories.contains(c),
                  onSelected: (_) => _toggleCategory(c),
                )),
            ActionChip(
              label: const Text('+ Create your own'),
              onPressed: _createCategory,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Single'),
                selected: !_isMultiple,
                onSelected: (_) => setState(() => _isMultiple = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Multiple'),
                selected: _isMultiple,
                onSelected: (_) => setState(() => _isMultiple = true),
              ),
            ),
          ],
        ),
        if (_isMultiple) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Step By Step'),
                  selected: _trackingType == CompletionTrackingType.stepByStep,
                  onSelected: (_) => setState(
                      () => _trackingType = CompletionTrackingType.stepByStep),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Custom Value'),
                  selected: _trackingType == CompletionTrackingType.customValue,
                  onSelected: (_) => setState(
                      () => _trackingType = CompletionTrackingType.customValue),
                ),
              ),
            ],
          ),
        ],
        if (_isMultiple &&
            _trackingType == CompletionTrackingType.customValue) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _completionTarget > 1
                    ? () => setState(() => _completionTarget--)
                    : null,
              ),
              Expanded(
                child: Text(
                  '$_completionTarget',
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _completionTarget++),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'The square will be filled completely when this number is met',
            style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Increment by 1 with each completion.',
              style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
            ),
          ),
      ],
    );
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
          .where((e) => e.codePoint.toString().contains(query))
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Icon'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Type a search term',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final icon = _icons[index];
                final selected = icon == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(icon,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.blue,
    Colors.indigo,
    Colors.deepPurple,
    Colors.purple,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Color(0xFFB39DDB),
    Color(0xFF80CBC4),
    Color(0xFFFFAB91),
    Color(0xFFE6EE9C),
    Color(0xFFCE93D8),
    Color(0xFFA5D6A7),
    Color(0xFFFFF59D),
    Color(0xFFB0BEC5),
    Color(0xFF90A4AE),
    Color(0xFFE0E0E0),
    Color(0xFF4DB6AC),
  ];
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Color'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final selected = color.value == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = color.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
