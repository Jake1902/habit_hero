import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: scheme.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ListTile(
            leading:
                Icon(Icons.archive_outlined, color: scheme.onBackground),
            title: Text('Archived Habits',
                style: TextStyle(color: scheme.onBackground)),
            subtitle: const Text('View or restore archived habits',
                style: TextStyle(color: Color(0xFFB0B0B0))),
            trailing:
                Icon(Icons.chevron_right, color: scheme.onBackground),
            onTap: () => context.push('/archive'),
          ),
          ListTile(
            leading: Icon(Icons.backup, color: scheme.onBackground),
            title: Text('Backup & Restore',
                style: TextStyle(color: scheme.onBackground)),
            subtitle: const Text('Export or import your data',
                style: TextStyle(color: Color(0xFFB0B0B0))),
            trailing: Icon(Icons.chevron_right, color: scheme.onBackground),
            onTap: () => context.push('/backup_restore'),
          ),
          const Divider(color: Color(0xFF2A2A2A)),
          ListTile(
            leading:
                Icon(Icons.color_lens_outlined, color: scheme.onBackground),
            title: Text('Theme', style: TextStyle(color: scheme.onBackground)),
            subtitle: const Text('Choose between system, light and dark mode',
                style: TextStyle(color: Color(0xFFB0B0B0))),
            trailing: Icon(Icons.chevron_right, color: scheme.onBackground),
            onTap: () => context.push('/theme'),
          ),
          SwitchListTile(
            activeColor: scheme.primary,
            title: Text('Show quick stats on Home',
                style: TextStyle(color: scheme.onBackground)),
            value: context.watch<SettingsProvider>().showQuickStats,
            onChanged: (val) =>
                context.read<SettingsProvider>().setShowQuickStats(val),
          ),
        ],
      ),
    );
  }
}
