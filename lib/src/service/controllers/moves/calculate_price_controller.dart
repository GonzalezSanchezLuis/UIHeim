import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CalculatePriceController {
  Future<Map<String, dynamic>?> calculatedPrice({
    required String? typeOfMove,
    required String numberOfRooms,
    required String originAddress,
    required String destinationAddress,
    required String? originLat,
    required String? originLng,
    required String? destinationLat,
    required String? destinationLng,
  }) async {
    try {
      final url = Uri.parse("http://192.168.20.49:8080/api/v1/price/calculate");

      final Map<String, dynamic> requestBody = {
        'typeOfMove': typeOfMove,
        'numberOfRooms': numberOfRooms,
        'origin': originAddress,
        if (originLat != null) 'originLat': originLat,
        if (originLng != null) 'originLng': originLng,
        'destination': destinationAddress,
        if (destinationLat != null) 'destinationLat': destinationLat,
        if (destinationLng != null) 'destinationLng': destinationLng,
      };

      print("🚀 Enviando datos al servidor:");
      print(jsonEncode(requestBody));

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("🔄 Código de respuesta: ${response.statusCode}");
      print("📩 Respuesta del servidor: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final List<Map<String, double>> route = (decodedResponse['route'] as List)
        .map((point) => {
           'lat': (point['lat'] as num).toDouble(), // Convertir a double
            'lng': (point['lng'] as num).toDouble(),
        }).toList();

        return {
        'formattedPrice': decodedResponse['formattedPrice'], 
        'distanceKm': decodedResponse['formattedDistance'], 
        'timeMin': decodedResponse['formattedDuration'], 
        'route':  route
        };
        
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Solicitud inválida";
      } else {
        print("Error inesperado: ${response.body}");
      }
    } on SocketException {
      // return "No se pudo conectar al servidor. Verifica tu conexión.";
    } catch (e) {
      // return "Error desconocido: $e";
    }
  }
}
