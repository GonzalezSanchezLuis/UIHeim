import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';

class UserMovingHistoryService {
  String baseUrl = "$apiBaseUrl/move";

  Future<List<Map<String, dynamic>>> loadUserMoveHistory(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$id/history'));

    if (response.statusCode == 200) {
      print("JSON RECIBIDO: ${response.body}");

      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar el resumen del viaje');
    }
  }


  Future<bool> cancelMove(int moveId, int userId) async {

    final url = Uri.parse('$baseUrl/$moveId/cancel');
    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) return true;
    throw Exception('Error al cancelar el viaje: ${response.body}');
  }
}
