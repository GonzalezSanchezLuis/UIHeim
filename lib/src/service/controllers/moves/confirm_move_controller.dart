import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConfirmMoveController with ChangeNotifier{
  Future<Map<String, dynamic>?> confirmMove({
   required String calculatedPrice,
    required String distanceKm,
    required String duration,
    required String typeOfMove,
    required String estimatedTime,
    required List<Map<String, double>> route,
    required double  userLat,
    required double userLng
  }) async {
    try {
      final url = Uri.parse("http://192.168.20.49:8080/api/v1/users/drivers/nearby");

      final Map<String, dynamic> requestBody = {
        "calculatedPrice": calculatedPrice,
        "distanceKm": distanceKm,
        "duration": duration,
        "typeOfMove": typeOfMove,
        "estimatedTime": estimatedTime,
        "route": route,
        "userLat": userLat,
        "userLng": userLng
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
      } else {
        print("Error al confirmar: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
    return null;
      
  }
  
}