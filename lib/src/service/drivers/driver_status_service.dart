import 'dart:convert';
import 'dart:developer';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/model/driver/driver_status_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holi/config/app_config.dart';

class DriverStatusSerive {
  ConnectionStatus _currentStatus = ConnectionStatus.DISCONNECTED;
  Future<void> connectDriver(int driverId, LatLng position) async {
    final url = Uri.parse('$apiBaseUrl/drivers/connect/$driverId');

    try {
      print("📡 Enviando ubicación: DriverID: $driverId, Lat: ${position.latitude}, Lng: ${position.longitude}");

      final payload = {
        'status': ConnectionStatus.CONNECTED.value,
        'driverId': driverId,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };

      _logRequest(url, payload, 'CONEXIÓN');

      final response = await http.put(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));

      _handleResponse(response, ConnectionStatus.CONNECTED);

      _currentStatus = ConnectionStatus.CONNECTED;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driverStatus', _currentStatus.value);

      print("✅ Conductor conectado como: ${_currentStatus}");
    } catch (e) {
      print("❌ Error al enviar la ubicación: $e");
      rethrow;
    }
  }

  Future<void> disconnectDriver(int driverId) async {
    final url = Uri.parse('$apiBaseUrl/disconnected/$driverId');

    try {
      print("🔌 Desconectando conductor: DriverID: $driverId");

      final payload = {
        'status': ConnectionStatus.DISCONNECTED.value,
        'driverId': driverId,
      };

      _logRequest(url, payload, 'DESCONEXIÓN');

      final response = await http.put(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));

      _handleResponse(response, ConnectionStatus.DISCONNECTED);

      _currentStatus = ConnectionStatus.DISCONNECTED;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('status', _currentStatus.value);

      print("✅ Conductor desconectado exitosamente.");
    } catch (e) {
      print("⚠️ Error al desconectar al conductor: $e");
      rethrow;
    }
  }

  Future<DriverStatusResponse?> loadDriverStatus(int driverId) async {
    try {
      final url = Uri.parse('$apiBaseUrl/drivers/$driverId/get/status');
      final response = await http.get(url, headers: {"Content-Type": "application/json"});

      log("STATUS CODE: ${response.statusCode}");
      log("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final driverStatus = DriverStatusResponse.fromJson(data);

        log("✅ Estado del conductor desde la BD: ${driverStatus.status}");
        return driverStatus;
      } else {
        print("⚠️ Error al obtener el estado del conductor: ${response.body}");
      }
    } catch (e) {
      log("⚠️ Error al obtener estado del conductor: $e");
      return null;
    }
    return null;
  }

 
  void _logRequest(Uri url, Map<String, dynamic> payload, String action) {
    log('🌐 [$action] Enviando solicitud a: $url');
    log('📦 Payload: ${jsonEncode(payload)}');
  }

  void _handleResponse(http.Response response, ConnectionStatus expectedStatus) {
    log('🔄 Código de respuesta: ${response.statusCode}');
    log('📨 Respuesta del servidor: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ ${expectedStatus} exitoso');
    } else {
      _logError('Error en la respuesta: ${response.body}');
      throw Exception('Failed to update status');
    }
  }

  void _logError(String message) {
    log(message);
  }
}
