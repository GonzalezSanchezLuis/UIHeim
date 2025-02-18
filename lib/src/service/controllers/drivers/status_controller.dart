import 'dart:convert';
import 'dart:async';
import 'package:holi/src/model/driver/status_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatusController {
  final StreamController<Map<String, String>> _driverDataController = StreamController();
  Stream<Map<String, String>> get driverDataStream => _driverDataController.stream;

  static const String _apiUrl ='http://192.168.20.49:8080/api/v1/drivers/status/';
  static const String status = "Conectado";

  // Método para actualizar el estado del conductor
  Future<Map<String, dynamic>> updateStatus(String status) async {
    try {
      // Obtener el ID del conductor desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        return _createErrorResponse('User ID no encontrado');
      }

      

      final Map<String, dynamic> data = {
        'status': status, 
        'driverId':driverId
      };

      final response = await http.put(
        Uri.parse('$_apiUrl$driverId$status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final updatedStatus = jsonDecode(response.body);
        await prefs.setString('status', updatedStatus['status']);
        return _createSuccessResponse(updatedStatus);
      } else {
        return _createErrorResponse('Error al actualizar el estado');
      }
    } catch (e) {
      return _createErrorResponse('Error inesperado: $e');
    }
  }
  Map<String, dynamic> _createErrorResponse(String message) {
    return {'status': 'error', 'message': message};
  }

  // Crear una respuesta de éxito estandarizada
  Map<String, dynamic> _createSuccessResponse(Map<String, dynamic> data) {
    return {'status': 'success', 'data': data};
  }
  void dispose() {
    _driverDataController.close();
  }
}
