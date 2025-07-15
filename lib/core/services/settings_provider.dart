import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider storing user settings like whether quick stats should be shown on the home screen.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs);

  final SharedPreferences _prefs;

  static const _keyShowQuick = 'show_quick_stats';

  bool _showQuickStats = true;

  /// Whether quick stats row is visible on the home screen.
  bool get showQuickStats => _showQuickStats;

  /// Loads persisted settings.
  void load() {
    _showQuickStats = _prefs.getBool(_keyShowQuick) ?? true;
    notifyListeners();
  }

  /// Updates the quick stats setting and persists it.
  Future<void> setShowQuickStats(bool value) async {
    _showQuickStats = value;
    await _prefs.setBool(_keyShowQuick, value);
    notifyListeners();
  }
}
