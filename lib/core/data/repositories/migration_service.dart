import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Migrates old completion data to the new multi-entry format.
class MigrationService {
  static const _prefix = 'completion_';

  /// Scans stored completion maps and converts integer counts
  /// to lists of timestamp strings.
  Future<void> run() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      final data = prefs.getString(key);
      if (data == null) continue;
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic> && decoded.values.isNotEmpty) {
        final first = decoded.values.first;
        if (first is int) {
          final newMap = <String, List<String>>{};
          for (final entry in decoded.entries) {
            final count = entry.value as int;
            newMap[entry.key] = List.generate(count, (_) => 'legacy');
          }
          await prefs.setString(key, jsonEncode(newMap));
        }
      }
    }
  }
}

