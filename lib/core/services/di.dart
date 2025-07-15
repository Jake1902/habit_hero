import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';
import 'notification_permission_service.dart';

/// Registers app services in the provided [getIt] instance.
void registerServices(GetIt getIt, SharedPreferences prefs) {
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<NotificationPermissionService>(
      () => NotificationPermissionService(prefs));
}
