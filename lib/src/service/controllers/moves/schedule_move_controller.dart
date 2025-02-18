import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

class ScheduleMoveController {
  Future<String?> registerScheduleMove(
      {required String moveType,
      required String originAddress,
      required String destinationAddress,
      required String originLat,
      required String originLng,
      required String destinationLat,
      required String destinationLng,
      required String status,
      required int userId,
      required int driverId,
      required DateTime moveDate}) async {
    try {
      String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(moveDate);
      final url = Uri.parse("http://192.168.20.49:8080/api/v1/reservations/reservation");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "moveType": moveType,
          'originAddress': originAddress,
          'originLat': originLat,
          'originLng': originLng,
          'destination': destinationAddress,
          'destinationLat': destinationLat,
          'destinationLng': destinationLng,
          'status': status,
          'userId': userId,
          "driverId": driverId,
          'reservedAt': formattedDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        // Manejar errores específicos del servidor
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Error desconocido";
      } else {
        return "Error inesperado: ${response.body}";
      }
    } on SocketException catch (_) {
      print("No se pudo conectar al servidor. Verifica tu conexión.");
    } catch (e) {
      print("Error desconocido: $e");
    }
    return null;
  }
}
