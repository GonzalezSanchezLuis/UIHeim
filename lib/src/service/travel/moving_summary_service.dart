import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';

class MovingSummaryService {
  String baseUrl = "$apiBaseUrl/move";

  Future<Map<String, dynamic>> fetchMovingSummary(int moveId) async {
    final response = await http.get(Uri.parse('$baseUrl/$moveId/summary'));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody) as Map<String, dynamic>;

    } else {
      throw Exception('Error al cargar el resumen del viaje');
    }
  }
}
