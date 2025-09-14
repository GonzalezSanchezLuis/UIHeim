import 'dart:convert';
import 'dart:developer';
import 'package:holi/src/model/move/accept_move_model.dart';
import 'package:http/http.dart' as http;

class AcceptMoveService {
  // final String baseUrl = "http://192.168.20.49:8080/api/v1";
  final String baseUrl = "https://c2dafcfb21f9.ngrok-free.app/api/v1/move";

  Future<bool> acceptMove(int moveId, int driverId) async {
    final url = Uri.parse('$baseUrl/accept/$moveId');
    final body = AcceptMoveModel(driverId: driverId).toJson();
    log("CUERPO  QUE SE ENVIA AL ACPTAR LA MUDANZA $body");

    try {
      final response = await http.put(
        url, 
        headers: {'Content-Type': 'application/json'}, 
        body: jsonEncode(body)
        );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al aceptar viaje: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al aceptar viaje: $e');
      return false;
    }
  }
}
