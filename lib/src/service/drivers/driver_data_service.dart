import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';
class DriverDataService {

  Future<Map<String, dynamic>> fetchDriverData(int driverId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/$driverId/profile'));

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);

        if (decodedBody is Map<String, dynamic>) {
          return decodedBody;
        } else {
          throw const FormatException('El formato de la respuesta del servidor es inesperado.');
        }
      } else {
        throw Exception('Error al cargar datos del conductor: ${response.statusCode}');
      }
    } catch (e) {
      // Log the error for debugging
      print("ERROR: Fallo al obtener los datos del conductor. $e");
      // Re-throw the exception so the ViewModel can handle it
      rethrow;
    }
  }
}
