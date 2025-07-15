import 'package:flutter/material.dart';

/// Simple model representing a habit category.
class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});
}

/// Screen allowing the user to create a new [Category].
class CategoryCreationScreen extends StatefulWidget {
  const CategoryCreationScreen({super.key});

  @override
  State<CategoryCreationScreen> createState() => _CategoryCreationScreenState();
}

class _CategoryCreationScreenState extends State<CategoryCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  IconData _icon = Icons.category;

  Future<void> _pickIcon() async {
    final result = await showModalBottomSheet<IconData>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _IconPicker(selected: _icon),
    );
    if (result != null) setState(() => _icon = result);
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, Category(name: name, icon: _icon));
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _nameController.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('New Category')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickIcon,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: Colors.white),
              ),
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
}

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
              decoration: const InputDecoration(hintText: 'Search icons'),
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
