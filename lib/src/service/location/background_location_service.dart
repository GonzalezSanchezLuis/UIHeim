import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:holi/src/service/location/foreground_callback_service.dart';
class BackgroundLocationService {
  static void initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'tracking_conductor_channel',
        channelName: 'Seguimiento de Mudanza',
        channelDescription: 'Permite rastrear la ubicación del viaje en curso.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> start() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) return;

    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'Mudanza en curso',
      notificationText: 'Rastreando ubicación para el cliente',
      callback: startCallback,
    );

    print("🚀 Resultado de inicio de servicio: $result");
  }

  static Future<void> stop() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (!isRunning) return;
    await FlutterForegroundTask.stopService();
  }
}
