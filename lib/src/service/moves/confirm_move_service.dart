import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:http/http.dart' as http;

class ConfirmMoveService {
  Future<Map<String, dynamic>?> confirmMove(
      {required String calculatedPrice,
      required String distanceKm,
      required String duration,
      required MoveType typeOfMove,
      required String estimatedTime,
      required List<LatLng> route,
      required double userLat,
      required double userLng,
      required int userId,
      double? destinationLat,
      double? destinationLng,
      String? originAddressText,
      String? destinationAddressText,
      String? paymentMethod}) async {
    try {
      final url = Uri.parse("https://c2dafcfb21f9.ngrok-free.app/api/v1/move/confirm");
      final cleanedPrice = calculatedPrice.replaceAll(',', '');

      final Map<String, dynamic> requestBody = {
        "price": cleanedPrice,
        "distanceKm": distanceKm,
        "duration": duration,
        "typeOfMove": typeOfMove.name,
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
