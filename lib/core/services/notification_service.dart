import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

/// Service handling scheduling of habit reminder notifications.
class NotificationService {
  /// Schedule a repeating notification for each weekday at [time].
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String title,
    required TimeOfDay time,
    required List<int> weekdays,
  }) async {
    for (final d in weekdays) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _notificationId(habitId, d),
          channelKey: 'habit_reminders',
          title: title,
          body: 'Time to complete your habit!',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          weekday: d,
          hour: time.hour,
          minute: time.minute,
          second: 0,
          millisecond: 0,
          repeats: true,
        ),
      );
    }
  }

  /// Cancel all scheduled notifications for this habit.
  Future<void> cancelHabitReminders(String habitId) async {
    final base = int.tryParse(habitId) ?? habitId.hashCode;
    final scheduled = await AwesomeNotifications().listScheduledNotifications();
    for (final n in scheduled) {
      final id = n.content?.id;
      if (id != null && id ~/ 10 == base) {
        await AwesomeNotifications().cancel(id);
      }
    }
  }

  /// Internal helper to construct a unique ID per habit & weekday.
  int _notificationId(String habitId, int weekday) {
    final base = int.tryParse(habitId) ?? habitId.hashCode;
    return base * 10 + weekday;
  }
}
