import 'package:get_it/get_it.dart';

import 'notification_service.dart';

/// Registers app services in the provided [getIt] instance.
void registerServices(GetIt getIt) {
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
}
