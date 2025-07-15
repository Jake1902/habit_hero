import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

import '../data/habit_repository.dart';
import '../data/completion_repository.dart';
import 'export_import_service.dart';
import '../analytics/analytics_service.dart';
import 'settings_provider.dart';

import 'notification_permission_service.dart';


/// Registers app services in the provided [getIt] instance.
void registerServices(GetIt getIt, SharedPreferences prefs) {
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  getIt.registerLazySingleton<ExportImportService>(
      () => ExportImportService(getIt<HabitRepository>(), getIt<CompletionRepository>()));

  getIt.registerLazySingleton<NotificationPermissionService>(
      () => NotificationPermissionService(prefs));

  getIt.registerLazySingleton<AnalyticsService>(
      () => AnalyticsService(getIt<HabitRepository>(), getIt<CompletionRepository>()));

  getIt.registerLazySingleton<SettingsProvider>(() => SettingsProvider(prefs));

}
