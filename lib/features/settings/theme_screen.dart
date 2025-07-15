import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/settings_provider.dart';

/// Simple theme selection screen placeholder.
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  void _setMode(ThemeMode? mode) {
    if (mode == null) return;
    context.read<SettingsProvider>().setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Theme'),
        leading: BackButton(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: context.watch<SettingsProvider>().themeMode,
            onChanged: _setMode,
            activeColor: Theme.of(context).colorScheme.primary,
            title: const Text('System'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: context.watch<SettingsProvider>().themeMode,
            onChanged: _setMode,
            activeColor: Theme.of(context).colorScheme.primary,
            title: const Text('Light'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: context.watch<SettingsProvider>().themeMode,
            onChanged: _setMode,
            activeColor: Theme.of(context).colorScheme.primary,
            title: const Text('Dark'),
          ),
        ],
      ),
    );
  }
}
