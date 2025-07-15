import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider storing user settings like whether quick stats should be shown on the home screen.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs);

  final SharedPreferences _prefs;

  static const _keyShowQuick = 'show_quick_stats';
  static const _keyThemeMode = 'theme_mode';

  bool _showQuickStats = true;
  ThemeMode _themeMode = ThemeMode.system;

  /// Whether quick stats row is visible on the home screen.
  bool get showQuickStats => _showQuickStats;

  /// Loads persisted settings.
  void load() {
    _showQuickStats = _prefs.getBool(_keyShowQuick) ?? true;
    final modeIndex = _prefs.getInt(_keyThemeMode);
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[modeIndex];
    }
    notifyListeners();
  }

  /// Updates the quick stats setting and persists it.
  Future<void> setShowQuickStats(bool value) async {
    _showQuickStats = value;
    await _prefs.setBool(_keyShowQuick, value);
    notifyListeners();
  }

  /// Current theme mode used by the application.
  ThemeMode get themeMode => _themeMode;

  /// Persists and updates the theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }
}
