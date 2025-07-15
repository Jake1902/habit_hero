import 'package:permission_handler/permission_handler.dart';

class StoragePermissionService {
  Future<void> ensureStoragePermission() async {
    if (await Permission.storage.isGranted) return;
    await Permission.storage.request();
  }
}
