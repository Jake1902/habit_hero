import 'package:get_it/get_it.dart';

import 'notification_service.dart';
import '../data/habit_repository.dart';
import '../data/completion_repository.dart';
import 'export_import_service.dart';

/// Registers app services in the provided [getIt] instance.
void registerServices(GetIt getIt) {
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<ExportImportService>(
      () => ExportImportService(getIt<HabitRepository>(), getIt<CompletionRepository>()));
}
