import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../data/models/habit_template.dart';

class TemplateService {
  Future<List<HabitTemplate>> loadTemplates() async {
    final manifest = await rootBundle.loadString('AssetManifest.json');
    final files = jsonDecode(manifest) as Map<String, dynamic>;
    final templatePaths = files.keys
        .where((p) => p.startsWith('assets/templates/') && p.endsWith('.json'))
        .toList();
    final templates = <HabitTemplate>[];
    for (final path in templatePaths) {
      final data = await rootBundle.loadString(path);
      templates.add(HabitTemplate.fromJson(jsonDecode(data)));
    }
    return templates;
  }
}
