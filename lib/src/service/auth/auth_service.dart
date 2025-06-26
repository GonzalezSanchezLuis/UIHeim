import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
 //final String baseUrl = "http://192.168.20.49:8080/api/v1";
 final String baseUrl = "https://5d69-2800-484-3981-2300-6c2d-a295-49e3-d121.ngrok-free.app/api/v1";

  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    return _register("/users/register", {
      "fullName": name,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> registerDriver({
    required int userId,
    required String licenseNumber,
    required String vehicleType,
    required String enrollVehicle,
  }) async {
    return _register("/drivers/register", {
      'userId': userId,
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'enrollVehicle': enrollVehicle,
    });
  }

  Future<Map<String, dynamic>?> _register(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse("$baseUrl$endpoint");
      log("URL QUE SE ENVIA AL SERVIDOR $url");

      log("📦 Datos enviados al servidor: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {'error': data['message'] ?? "Error desconocido"};
      }
    } on SocketException {
      return {'error': "No se pudo conectar al servidor."};
    } catch (e) {
      return {'error': "Error desconocido: $e"};
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final url = Uri.parse("$baseUrl/auth/auth");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
         log("DATA $data");
        return {
          'userId': data['userId'],
          'role': data['role'],
        };
      } else {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {'error': data['message'] ?? "Error desconocido"};
      }
    } catch (e) {
      return {'error': "Error de conexión: $e"};
    }
  }

  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/logout"),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
