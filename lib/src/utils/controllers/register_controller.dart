import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RegisterController {
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("http://192.168.20.49:8080/api/v1/users/register");
    print("Nombre: $name");
    print("Email: $email");
    print("Password: $password");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Registro exitoso: ${response.body}");
      } else {
        print("Error al registrar: ${response.statusCode}");
        print("Detalles del error: ${response.body}");
      }
    } on SocketException catch (_) {
      print("No se pudo conectar al servidor. Verifica tu conexión.");
    } catch (e) {
      print("Error desconocido: $e");
    }
  }
}
