import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';

class CalculatePriceService {
  final String _baseUrl = apiBaseUrl;

  Future<Map<String, dynamic>> calculatedPrice({
    required MoveType? typeOfMove,
    required String numberOfRooms,
    required String originAddress,
    required String destinationAddress,
    required double? originLat,
    required double? originLng,
    required double? destinationLat,
    required double? destinationLng,
  }) async {
    try {
      final url = Uri.parse("$_baseUrl/price/calculate");

      final Map<String, dynamic> requestBody = {
        'typeOfMove': typeOfMove?.name,
        'numberOfRooms': numberOfRooms,
        'origin': originAddress,
        'destination': destinationAddress,
        if (originLat != null) 'originLat': originLat,
        if (originLng != null) 'originLng': originLng,
        if (destinationLat != null) 'destinationLat': destinationLat,
        if (destinationLng != null) 'destinationLng': destinationLng,
      };

      log("DATA QUE SE ENVIA PARA EL SERVIDOR $requestBody");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
       //   log("🛰️ Respuesta cruda del servidor: ${response.body}");

        return {
          'success': true,
          'price':decoded['price'],
          'formattedPrice': decoded['formattedPrice'],
          'distanceKm': decoded['formattedDistance'],
          'timeMin': decoded['formattedDuration'],
          'route': (decoded['route'] as List)
              .map((point) => {
                    'lat': (point['lat'] as num).toDouble(),
                    'lng': (point['lng'] as num).toDouble(),
                  })
              .toList(),
        };
        
      } else {
        final errorData = jsonDecode(response.body);
  
        return {'success': false, 'message': errorData['message'] ?? "Solicitud inválida"};
      }
    } on SocketException {
      return {'success': false, 'message': 'Sin conexión a internet'};
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }
}
