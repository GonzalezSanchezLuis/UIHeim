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
    required String phoneNumber,
    required String document,
    required String licenseCategory,
    required String licenseNumber,
    required String vehicleType,
    required String enrollVehicle,
  }) async {
    return _register("/drivers/register", {
      'userId': userId,
      'phone': phoneNumber,
      'document' :document,
      'licenseCategory' : licenseCategory,
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
      final String responseBody = utf8.decode(response.bodyBytes);
      final String cleanBody = responseBody.trim();
      if (cleanBody.isEmpty) {
        throw Exception("El servidor no devolvió respuesta para el código ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(cleanBody);
          log("DATA $data");
          return data as Map<String, dynamic>;
        } catch (e) {
          throw Exception("Respuesta exitosa (200) pero el JSON es inválido o no es JSON.");
        }
      }
      else {
        String errorMessage = "Error desconocido con código ${response.statusCode}.";
        try {
          final responseData = jsonDecode(responseBody);
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            errorMessage = "Error ${response.statusCode}: ${responseData.toString()}";
          }
        } catch (e) {
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
