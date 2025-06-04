import 'dart:convert';
import 'package:http/http.dart' as http;


class ConfirmMoveService {
  Future<Map<String, dynamic>?> confirmMove(
      {required String calculatedPrice, 
      required String distanceKm, 
      required String duration, 
      required String typeOfMove, 
      required String estimatedTime, 
      required List<Map<String, double>> route, 
      required double userLat, 
      required double userLng, 
      required int userId,
      double? destinationLat, 
      double? destinationLng, 
      String? originAddressText, 
      String? destinationAddressText, 
      String? paymentMethod
      }) async {
    try {
      final url = Uri.parse("http://192.168.20.49:8080/api/v1/trips/confirm");
    
      final Map<String, dynamic> requestBody = {
        "price": calculatedPrice, 
        "distanceKm": distanceKm, 
        "duration": duration, 
        "typeOfMove": typeOfMove, 
        "estimatedTime": estimatedTime, 
        "route": route, 
        "originLat": userLat, 
        "originLng": userLng,
        "destinationLat": destinationLat,
        "destinationLng": destinationLng, 
        "origin": originAddressText,
        "destination": destinationAddressText,
        'paymentMethod': paymentMethod,
        "userId": userId
        };

      // o getInt si es entero

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
        print("Mudanza confirmada: ${response.body}");
      } else {
        print("Error al confirmar: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
    return null;
  }
}
