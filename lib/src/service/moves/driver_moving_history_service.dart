import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';

class DriverMovingHistoryService {
  String baseUrl = "$apiBaseUrl/move";

  Future<List<Map<String, dynamic>>> loadDriverMoveHistory(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/driver/$id/history'));

    if (response.statusCode == 200) {
      print("JSON RECIBIDO: ${response.body}");

      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar el resumen del viaje');
    }
  }
}
