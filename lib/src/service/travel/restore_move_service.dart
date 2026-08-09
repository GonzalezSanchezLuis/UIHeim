import 'dart:convert';
import 'package:holi/config/app_config.dart';
import 'package:http/http.dart' as http;

class RestoreMoveService {
  Future<Map<String, dynamic>?> restoreMove(int moveId,int driverId) async {
    try {
      final response = await http.get(Uri.parse(
        "$apiBaseUrl/moves/$moveId/$driverId/restore-move",
      ));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error al consultar el vieje activo $e");
      return null;
    }
  }
}
