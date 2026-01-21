import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:holi/src/service/location/background_task_handler.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(BackgroundTaskHandler());
}