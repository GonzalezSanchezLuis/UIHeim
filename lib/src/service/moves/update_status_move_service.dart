import 'dart:convert';
import 'package:holi/src/model/move/move_status_update_model.dart';
import 'package:http/http.dart' as http;

class UpdateStatusMoveService {
  // final String _baseUrl = "http://192.168.20.49:8080/api/v1";
  final String _baseUrl = "https://c7cb-2800-484-3981-2300-6521-7940-970-5d03.ngrok-free.app/api/v1/move";

  Future<void> updateMoveStatus(MoveStatusUpdateModel data) async {
    final url = Uri.parse('$_baseUrl/driver-arrived');

    final response = await http.patch(
      url,
      headers: {
        // 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estado del viaje: ${response.body}');
    }

     final urlStartMoving = Uri.parse('$_baseUrl/start');

     final response2 = await http.patch(
      urlStartMoving,
      headers: {
        // 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data.toJson()),
    );

    if (response2.statusCode != 200) {
      throw Exception('Error al iniciar el  viaje: ${response.body}');
    }

  /*  final urlCompleteMoving = Uri.parse('$_baseUrl/complete');

    final response3 = await http.patch(
      urlCompleteMoving,
      headers: {
        // 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data.toJson()),
    );

    if (response3.statusCode != 200) {
      throw Exception('Error al iniciar el  viaje: ${response.body}');
    }*/

    
  }
}
