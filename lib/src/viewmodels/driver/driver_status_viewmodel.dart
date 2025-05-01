import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/service/controllers/drivers/driver_status_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverStatusViewmodel extends ChangeNotifier {
  ConnectionStatus? _connectionStatus;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  ConnectionStatus? get connectionStatus => _connectionStatus;

  Future<void> connectDriverViewmodel(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    print("Conectando...");

    try {
      final gpsEnabled = await GpsValidatorService.isGpsActuallyEnabled();
      if (!gpsEnabled) {
        if (!context.mounted) return;

        await GpsValidatorService.showGpsDialog(context);
      }

      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("❌ Driver ID no encontrado en SharedPreferences.");
        return;
      }

      // Obtener la ubicación actual del conductor
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("📍 Ubicación obtenida: Lat: ${position.latitude}, Lng: ${position.longitude}");

      // ✅ Convertir Position a LatLng
      LatLng latLngPosition = LatLng(position.latitude, position.longitude);

      // Llamar a StatusController para conectar al conductor
      final statusController = DriverStatusController();
      await statusController.connectDriver(driverId, latLngPosition);
      setStatus(ConnectionStatus.CONNECTED);

      print("✅ Conductor conectado exitosamente.");
    } catch (e) {
      print("⚠️ Error al conectar: $e");
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

      final statusController = DriverStatusController();
      await statusController.disconnectDriver(driverId);
      setStatus(ConnectionStatus.DISCONNECTED);
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

      final statusController = DriverStatusController();
      final driverStatusResponse = await statusController.loadDriverStatus(driverId);

      if (driverStatusResponse != null) {
        final connectionStatus = ConnectionStatus.fromString(driverStatusResponse.status);
        await prefs.setString('driverStatus', connectionStatus.toString());
        log("🔐 Estado del conductor guardado en SharedPreferences: ${connectionStatus}");

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
