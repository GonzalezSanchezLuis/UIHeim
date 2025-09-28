import 'dart:convert';
import 'package:http/http.dart' as http;

class DriverDataService {
  //final String baseUrl = "https://7f0e158e1302.ngrok-free.app/api/v1/drivers";
  final String baseUrl = "http://192.168.20.49:8080/api/v1/drivers";


  Future<Map<String, dynamic>> fetchDriverData(int driverId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$driverId/profile'));

      if (response.statusCode == 200) {
        // You can use a more robust cast or check the type before casting
        final dynamic decodedBody = jsonDecode(response.body);

        if (decodedBody is Map<String, dynamic>) {
          return decodedBody;
        } else {
          // Handle cases where the response is not a single map
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
