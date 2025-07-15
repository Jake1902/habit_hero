import 'package:flutter/material.dart';

/// Simple theme selection screen placeholder.
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  ThemeMode _mode = ThemeMode.system;

  void _setMode(ThemeMode? mode) {
    if (mode == null) return;
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Theme'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: Column(
        children: [
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: _mode,
            onChanged: _setMode,
            activeColor: Colors.white,
            title: const Text('System', style: TextStyle(color: Colors.white)),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: _mode,
            onChanged: _setMode,
            activeColor: Colors.white,
            title: const Text('Light', style: TextStyle(color: Colors.white)),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: _mode,
            onChanged: _setMode,
            activeColor: Colors.white,
            title: const Text('Dark', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
