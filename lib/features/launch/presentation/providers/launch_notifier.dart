import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/notification_service.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

part 'launch_notifier.g.dart';

enum LaunchDestination { permissions, home }

@riverpod
class LaunchNotifier extends _$LaunchNotifier {
  @override
  Future<LaunchDestination> build() async {
    LaunchDestination? destination;

    // Run the destination check in parallel with the minimum display delay.
    await Future.wait([
      _checkDestination().then((d) => destination = d),
      Future<void>.delayed(const Duration(milliseconds: 1500)),
    ]);

    return destination!;
  }

  Future<LaunchDestination> _checkDestination() async {
    final local = ref.read(authLocalDatasourceProvider);
    final isFirst = await local.isFirstLaunch();
    if (!isFirst) return LaunchDestination.home;

    final notifService = ref.read(notificationServiceProvider);
    final isGranted = await notifService.isPermissionGranted();
    return isGranted ? LaunchDestination.home : LaunchDestination.permissions;
  }
}
