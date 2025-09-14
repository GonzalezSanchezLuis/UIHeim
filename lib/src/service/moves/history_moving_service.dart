import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryMovingService {
  String baseUrl = "http://192.168.20.49:8080/api/v1/move";

  Future<List<Map<String, dynamic>>> loadMovingHistory(int driverId) async {
    final response = await http.get(Uri.parse('$baseUrl/$driverId/history'));

    if (response.statusCode == 200) {
      print("JSON RECIBIDO: ${response.body}");
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar el resumen del viaje');
    }
  }
}
