import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/service/drivers/driver_status_service.dart';
import 'package:holi/src/service/websocket/websocket_driver_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverStatusViewmodel extends ChangeNotifier {
  ConnectionStatus? _connectionStatus;
  bool _isLoading = false;
  WebSocketDriverService? _webSocketService;

  Map<String, dynamic>? tripData;
  final int _remainingTime = 15;
  int get remainingTime => _remainingTime;
  Timer? _timer;
  bool isTimerRunning = false;
  bool get isLoading => _isLoading;
  ConnectionStatus? get connectionStatus => _connectionStatus;

  Future<LatLng?> connectDriverViewmodel(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    print("Conectando...");

    try {
      bool gpsReady = await GpsValidatorService.ensureLocationServiceAndPermission(context);
      if (!gpsReady) return null;

      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("❌ Driver ID no encontrado en SharedPreferences.");
        return null;
      }

      // Obtener la ubicación actual del conductor
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      print("📍 Ubicación obtenida: Lat: ${position.latitude}, Lng: ${position.longitude}");

      // ✅ Convertir Position a LatLng
      LatLng latLngPosition = LatLng(position.latitude, position.longitude);

      // Llamar a StatusController para conectar al conductor
      final statusService = DriverStatusSerive();
      await statusService.connectDriver(driverId, latLngPosition);
      setStatus(ConnectionStatus.CONNECTED);

      print("✅ Conductor conectado exitosamente.");

      _webSocketService = WebSocketDriverService(
          driverId: driverId,
          onMessage: (data) {
            print("🧾 Mensaje WebSocket recibido: $data");
            // Puedes notificar listeners o actualizar el estado aquí
          });
      _webSocketService!.connect();

      return latLngPosition;
    } catch (e) {
      print("⚠️ Error al conectar: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnectDriverViewmodel() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("❌ Driver ID no encontrado en SharedPreferences.");
        return;
      }

      final statusService = DriverStatusSerive();
      await statusService.disconnectDriver(driverId);
      setStatus(ConnectionStatus.DISCONNECTED);

      _webSocketService?.disconnect();
      _webSocketService =  null;

      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Error al desconectar: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDriverStatusViewmodel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("User ID no encontrado en SharedPreferences.");
        return;
      }

      final statusService = DriverStatusSerive();
      final driverStatusResponse = await statusService.loadDriverStatus(driverId);

      if (driverStatusResponse != null) {
        final connectionStatus = ConnectionStatus.fromString(driverStatusResponse.status);
        await prefs.setString('driverStatus', connectionStatus.toString());
        log("🔐 Estado del conductor guardado en SharedPreferences: $connectionStatus");

        setStatus(connectionStatus);
      }
    } catch (e) {
      debugPrint("⚠️ Error al desconectar: $e");
    }
  }

  void setStatus(ConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners(); // Actualiza la UI
  }
}
