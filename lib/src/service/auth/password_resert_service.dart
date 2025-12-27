import 'dart:convert';
import 'package:holi/config/app_config.dart';
import 'package:holi/src/model/auth/password_resert_model.dart';
import 'package:http/http.dart' as http;

class PasswordResertService {
  Future<Map<String, dynamic>> sendResetEmail(String email) async {
    final baseUrl = '$apiBaseUrl/auth/forgot-password';
    PasswordResertModel passwordResertModel = PasswordResertModel(email: email);
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(passwordResertModel.toJson()),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['error'] ?? 'Error desconociado';
      }
    } catch (e) {
      throw Exception('No se pudo conectar con el servidor');
    }
  }
}
