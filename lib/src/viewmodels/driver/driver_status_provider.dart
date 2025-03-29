import 'package:flutter/material.dart';
import 'package:holi/src/service/controllers/drivers/status_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverStatusProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool _isLoading = false;

  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;

  DriverStatusProvider() {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('userId');

    if (driverId == null) {
      print("❌ Driver ID no encontrado en SharedPreferences.");
      return;
    }

    try {
      final statusController = StatusController();
      await statusController.checkDriverStatus();

      final prefs = await SharedPreferences.getInstance();
      _isConnected = prefs.getString('status') == "Connected";
      notifyListeners();

      print("🔄 Estado del conductor actualizado desde la BD: $_isConnected");
    } catch (e) {
      print("⚠️ Error al obtener estado del conductor: $e");
    }

    notifyListeners();
  }



  Future<void> connectDriver() async {
    if (_isConnected || _isLoading) return;

    _isLoading = true;
    notifyListeners();
    print("Conectando...");

    try {
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
      final statusController = StatusController();
      await statusController.connectDriver(driverId, latLngPosition);

      await prefs.setString('status', "Connected");
      _isConnected = true;
      print("✅ Conductor conectado exitosamente.");
    } catch (e) {
      print("⚠️ Error al conectar: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



Future<void> disconnectDriver() async {
    if (!_isConnected || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("❌ Driver ID no encontrado en SharedPreferences.");
        return;
      }

      final statusController = StatusController();
      await statusController.disconnectDriver(driverId); // ✅ Desconectar en backend

      await prefs.setString('status', "Disconnected");
      _isConnected = false;
      print("✅ Conductor desconectado correctamente.");
    } catch (e) {
      debugPrint("⚠️ Error al desconectar: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
