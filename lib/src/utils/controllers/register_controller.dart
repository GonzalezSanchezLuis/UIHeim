import 'dart:convert';
import 'package:http/http.dart' as http;

class RegsiterController {
  Future<void> register({required String email, required String password}) async {
    try {
      final url = Uri.parse("http/localhost/8080/api/v1/users/register");
      print("Email: $email");
      print("Password: $password");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {}
    } catch (e) {
      print("Error durante el inicio de sesion: $e");
    }
  }
}
