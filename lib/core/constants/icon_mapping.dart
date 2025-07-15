import 'package:flutter/material.dart';

/// Mapping of icon code points to constant [IconData] instances.
///
/// Using this map allows the app to reference icons without invoking
/// the [IconData] constructor at runtime, enabling tree shaking of the
/// Material icon font.
const Map<int, IconData> kIconMap = {
  Icons.star_border.codePoint: Icons.star_border,
  Icons.favorite_border.codePoint: Icons.favorite_border,
  Icons.run_circle_outlined.codePoint: Icons.run_circle_outlined,
  Icons.book_outlined.codePoint: Icons.book_outlined,
  Icons.fitness_center.codePoint: Icons.fitness_center,
  Icons.savings_outlined.codePoint: Icons.savings_outlined,
  Icons.school_outlined.codePoint: Icons.school_outlined,
  Icons.self_improvement.codePoint: Icons.self_improvement,
  Icons.work_outline.codePoint: Icons.work_outline,
  Icons.music_note.codePoint: Icons.music_note,
  Icons.food_bank_outlined.codePoint: Icons.food_bank_outlined,
  Icons.water_drop_outlined.codePoint: Icons.water_drop_outlined,
  Icons.timer_outlined.codePoint: Icons.timer_outlined,
  Icons.mood_outlined.codePoint: Icons.mood_outlined,
  Icons.code.codePoint: Icons.code,
  // Icons referenced in templates.
  Icons.book_online.codePoint: Icons.book_online,
  Icons.access_alarm.codePoint: Icons.access_alarm,
  Icons.account_box.codePoint: Icons.account_box,
};

/// Returns a constant [IconData] for the given [codePoint].
///
/// If the [codePoint] is not found in [kIconMap], a fallback icon is
/// returned to avoid instantiating [IconData] at runtime.
IconData iconFromCodePoint(int codePoint) =>
    kIconMap[codePoint] ?? Icons.help_outline;

