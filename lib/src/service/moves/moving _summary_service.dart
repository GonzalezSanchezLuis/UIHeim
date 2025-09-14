import 'dart:convert';
import 'package:http/http.dart' as http;

class MovingSummaryService {
   String baseUrl= "/api/v1/move";

  Future<Map<String, dynamic>> fetchMovingSummary(int moveId) async {
    final response = await http.get(Uri.parse('$baseUrl/$moveId/summary'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }else{
       throw Exception('Error al cargar el resumen del viaje');
    }
  }
}
