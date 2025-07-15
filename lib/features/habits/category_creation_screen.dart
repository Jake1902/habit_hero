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
    final icon = await showDialog<IconData>(
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Create Category',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValid
                      ? const Color(0xFF8A2BE2)
                      : Colors.white24,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: isValid ? _save : null,
                child: const Text('Save'),
              ),
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
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF8A2BE2)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white),
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
