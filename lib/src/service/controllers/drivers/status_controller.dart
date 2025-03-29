import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/service/data/repository/driver/driver_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusController extends ChangeNotifier {
  final DriverRepository _driverRepository = DriverRepository();

 Future<void> connectDriver(int driverId, LatLng position) async {
    try {
      print("📡 Enviando ubicación: DriverID: $driverId, Lat: ${position.latitude}, Lng: ${position.longitude}");

      await _driverRepository.setStatus(driverId, position);
    } catch (e) {
      print("❌ Error al enviar la ubicación: $e");
    }
  }




  Future<void> disconnectDriver(int driverId) async {
    try {
      print("🔌 Desconectando conductor: DriverID: $driverId");

      await _driverRepository.disconnectedDriver(driverId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('status', "Disconnected");

      print("✅ Conductor desconectado exitosamente.");
      notifyListeners(); // Asegurar que la UI se actualiza
    } catch (e) {
      print("⚠️ Error al desconectar al conductor: $e");
    }
  }



  

  Future<void> checkDriverStatus() async {
    final DriverRepository _driverRepository = DriverRepository();
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("❌ User ID no encontrado en SharedPreferences.");
        return;
      }

      // ✅ Llamar al repositorio para obtener el estado del conductor
      bool isConnected = await _driverRepository.getDriverStatus(driverId);

      // ✅ Guardar el estado en SharedPreferences
      await prefs.setString('status', isConnected ? "Connected" : "Disconnected");

      print("🔍 Estado del conductor actualizado: ${isConnected ? "Connected" : "Disconnected"}");
    } catch (e) {
      print("⚠️ Error al obtener estado del conductor: $e");
    }
  }



}
