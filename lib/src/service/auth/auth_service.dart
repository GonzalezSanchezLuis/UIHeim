import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';

class AuthService {
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
      final url = Uri.parse("$apiBaseUrl$endpoint");
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
      final url = Uri.parse("$apiBaseUrl/auth/auth");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        log("DATA $data");
        return data;
        /*  return {
          'userId': data['userId'],
          'role': data['role'],
        };*/
      } else if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 503) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(decodedBody);
        final String errorMessage = responseBody['message'];

        throw Exception(errorMessage);
      } else {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(decodedBody);
        throw Exception(responseBody['message'] ?? "Error desconocido con código ${response.statusCode}");

        //return {'error': data['message'] ?? "Error desconocido"};
      }
    } on Exception catch (e) {
      throw Exception(e.toString());
      // return {'error': "Error de conexión: $e"};
    }
  }

  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/auth/logout"),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
