import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ListTile(
            leading: const Icon(Icons.archive_outlined, color: Colors.white),
            title: const Text('Archived Habits',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('View or restore archived habits',
                style: TextStyle(color: Color(0xFFB0B0B0))),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () => context.push('/archive'),
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.white),
            title: const Text('Backup & Restore',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Export or import your data',
                style: TextStyle(color: Color(0xFFB0B0B0))),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () => context.go('/backup_restore'),
          ),
          const Divider(color: Color(0xFF2A2A2A)),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined, color: Colors.white),
            title: const Text('Theme', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Choose between system, light and dark mode',
                style: TextStyle(color: Color(0xFFB0B0B0))),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () => context.push('/theme'),
          ),
        ],
      ),
    );
  }
}
