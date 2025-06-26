import 'dart:convert';
import 'package:holi/src/model/auth/password_resert_model.dart';
import 'package:http/http.dart' as http;

class PasswordResertService {
  Future<void> sendResetEmail(String email) async {
    const  baseUrl = 'http://192.168.20.49:8080/api/v1/auth';
    PasswordResertModel passwordResertModel = PasswordResertModel(email:email);
    try {
      final url = Uri.parse('$baseUrl/forgot-password');
      final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(passwordResertModel.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Estado del conductor desde la BD: $data");

      } else {
        print("⚠️ Error al obtener el estado del conductor: ${response.body}");
      }
    } catch (e) {
      print("❌ Error al cambiar la contraseña: $e");
    }
  }
}
