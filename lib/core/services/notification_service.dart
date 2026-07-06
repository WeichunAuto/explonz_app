import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

abstract interface class NotificationService {
  /// Returns true if the notification permission is already granted.
  Future<bool> isPermissionGranted();

  /// Requests notification permission. Returns true if the user grants it.
  Future<bool> requestPermission();

  /// Opens the system notification settings page for this app.
  Future<void> openNotificationSettings();
}

class NotificationServiceImpl implements NotificationService {
  @override
  Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  @override
  Future<void> openNotificationSettings() =>
      AppSettings.openAppSettings(type: AppSettingsType.notification);
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationServiceImpl();
