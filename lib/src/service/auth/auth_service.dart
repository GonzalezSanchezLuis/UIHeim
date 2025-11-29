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

      // 1. Decodificar solo una vez
      final String responseBody = utf8.decode(response.bodyBytes);
      final String cleanBody = responseBody.trim();

      // 2. Comprobar si la respuesta contiene un cuerpo (no vacío)
      if (cleanBody.isEmpty) {
        throw Exception("El servidor no devolvió respuesta para el código ${response.statusCode}");
      }

      // 3. Comprobar el código de estado exitoso (200)
      if (response.statusCode == 200) {
        // Intentar decodificar la respuesta exitosa
        try {
          final data = jsonDecode(cleanBody);
          log("DATA $data");
          return data as Map<String, dynamic>;
        } catch (e) {
          // Fallo en la decodificación del JSON (aunque el status fue 200)
          throw Exception("Respuesta exitosa (200) pero el JSON es inválido o no es JSON.");
        }
      }

      // 4. Manejo de errores específicos (400, 401, 503) y otros
      else {
        String errorMessage = "Error desconocido con código ${response.statusCode}.";

        // Intentar decodificar el cuerpo, asumiendo que es un JSON de error
        try {
          final responseData = jsonDecode(responseBody);
          // Si tiene un campo 'message', usarlo
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            // Si el JSON no tiene 'message', mostrar el cuerpo completo
            errorMessage = "Error ${response.statusCode}: ${responseData.toString()}";
          }
        } catch (e) {
          // ¡ESTE BLOQUE CAPTURA EL ERROR FormatUnexpected character!
          // Si falla la decodificación, usamos el cuerpo crudo como mensaje.
          errorMessage = "Error ${response.statusCode}. Respuesta no JSON: $responseBody";
        }

        throw Exception(errorMessage);
      }
    } on Exception catch (e) {
      print("ERROR DE COPNEXION $e.toString()");
      throw Exception("Error de conexión: ${e.toString()}");
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
