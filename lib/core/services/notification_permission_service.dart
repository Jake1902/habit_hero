import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPermissionService {
  final SharedPreferences prefs;
  NotificationPermissionService(this.prefs);

  static const _key = 'notifications_requested';

  Future<void> ensurePermissionRequested(BuildContext context) async {
    final requested = prefs.getBool(_key) ?? false;
    if (!requested) {
      final allowed = await AwesomeNotifications().isNotificationAllowed();
      if (!allowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      await prefs.setBool(_key, true);
    }
  }
}
