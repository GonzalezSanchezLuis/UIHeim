import 'dart:convert';
import 'package:http/http.dart' as http;

class MovingDetailsService {
  String baseUrl = "http://192.168.20.49:8080/api/v1/move";

  Future<Map<String, dynamic>> fetchMovingDetails(int moveId) async {
    final response = await http.get(Uri.parse('$baseUrl/$moveId/details'));

    if (response.statusCode == 200) {
      print("datos de la mudanza ${response.body}");
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody) as Map<String, dynamic>;
    } else {
      throw Exception('Error al cargar el resumen del viaje');
    }
  }
}
