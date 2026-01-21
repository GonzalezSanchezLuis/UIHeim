import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holi/src/model/driver/driver_location_model.dart';
import 'package:holi/src/service/drivers/driver_location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundTaskHandler extends TaskHandler{
  final DriverLocationService _service = DriverLocationService();

@override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('🔵 Servicio en primer plano iniciado');
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final prefs = await SharedPreferences.getInstance();
      final int? driverId = prefs.getInt("driverId");

      if (driverId != null) {
        final locationModel = DriverLocationModel(position.latitude, position.longitude);
        await _service.sendLocation(locationModel, driverId);

        FlutterForegroundTask.updateService(
          notificationTitle: 'En ruta - Ubicación activa',
          notificationText: 'Última actualización: ${DateTime.now().hour}:${DateTime.now().minute}',
        );

        print('🟢 TICK BACKGROUND ${DateTime.now()}');
        
        FlutterForegroundTask.sendDataToMain(position.toJson());

        print("📍 Ubicación enviada (Foreground): ${position.latitude}, ${position.longitude}");
      }
    } catch (e) {
      print("❌ Error en tarea de segundo plano: $e");
    }
  }

@override
  Future<void> onDestroy(DateTime timestamp, bool isUserStopped) async {
    print('🔴 Servicio en primer plano detenido. Detenido por usuario: $isUserStopped');
  }

  @override
  void onReceiveData(Object data) {
    print('📥 Datos recibidos en el servicio: $data');
  }
}