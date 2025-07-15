import 'package:flutter/material.dart';

/// Screen allowing the user to create a new category by selecting an icon and
/// entering a name.
class CategoryCreationScreen extends StatefulWidget {
  const CategoryCreationScreen({super.key});

  @override
  State<CategoryCreationScreen> createState() => _CategoryCreationScreenState();
}

class _CategoryCreationScreenState extends State<CategoryCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  IconData _icon = Icons.category;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final icon = await showModalBottomSheet<IconData>(
      context: context,
      builder: (context) => const _IconPicker(),
    );
    if (icon != null) setState(() => _icon = icon);
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _nameController.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('New Category')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(_icon),
              title: const Text('Icon'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickIcon,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (_) => setState(() {}),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isValid ? _save : null,
              child: const Text('Create'),
            )
          ],
        ),
      ),
    );
  }
}

class _IconPicker extends StatefulWidget {
  const _IconPicker();
  @override
  State<_IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<_IconPicker> {
  final TextEditingController _searchController = TextEditingController();
  late List<IconData> _icons;
  IconData? _selected;

  @override
  void initState() {
    super.initState();
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
