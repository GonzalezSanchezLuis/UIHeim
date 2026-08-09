import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';

class ConfirmMoveService {
  Future<Map<String, dynamic>?> confirmMove({
    required String calculatedPrice,
    required String distanceKm,
    required String duration,
    required MoveType typeOfMove,
    required String estimatedTime,
    required List<LatLng> route,
    required double userLat,
    required double userLng,
    required int userId,
    double? originLat,
    double? originLng,
    double? destinationLat,
    double? destinationLng,
    String? originAddressText,
    String? destinationAddressText,
    String? paymentMethod,
    String? accessType,
    String? addressee,
    String? recipientPhoneNumber,
    DateTime? scheduledTravel,
  }) async {
    try {
      final url = Uri.parse("$apiBaseUrl/move/confirm");
      final cleanedPrice = calculatedPrice.replaceAll('\$', '').replaceAll(' ', '').replaceAll('.', '').split(',')[0];

      // Coordenadas del viaje (prioridad) o GPS actual como fallback del origen
      final double resolvedOriginLat = originLat ?? userLat;
      final double resolvedOriginLng = originLng ?? userLng;

      // Direcciones en texto plano — nunca coordenadas
      final String originAddress = (originAddressText ?? '').trim();
      final String destinationAddress = (destinationAddressText ?? '').trim();

      final Map<String, dynamic> requestBody = {
        "price": double.tryParse(cleanedPrice) ?? 0.0,
        "distanceKm": distanceKm,
        "duration": duration,
        "typeOfMove": typeOfMove.name,
        "estimatedTime": estimatedTime,
        "route": route
            .map((p) => {
                  'lat': p.latitude,
                  'lng': p.longitude,
                })
            .toList(),
        "originLat": resolvedOriginLat,
        "originLng": resolvedOriginLng,
        "destinationLat": destinationLat,
        "destinationLng": destinationLng,
        "origin": originAddress,
        "destination": destinationAddress,
        'paymentMethod': paymentMethod,
        'addressee': addressee,
        'recipientPhoneNumber': recipientPhoneNumber,
        "userId": userId,
        'accessType': accessType,
        if (scheduledTravel != null) 'scheduledTime': scheduledTravel.toIso8601String(),
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
        print("Mudanza confirmada: ${response.body}");
        try {
          return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        } catch (_) {
          return {'success': true};
        }
      } else {
        print("Error al confirmar: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
    return null;
  }
}
