import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

class AuthService {
  final _facebookAppEvents = FacebookAppEvents();

  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _register("/users/register", {
      "fullName": name,
      'email': email,
      'password': password,
    });
    if (data != null && !data.containsKey('error')) {
      await _facebookAppEvents.logCompletedRegistration(
        registrationMethod: 'App Form Client',
      );
    }
    return data;
  }

  Future<Map<String, dynamic>?> registerDriver(
      {required int userId, required String phoneNumber, required String document, required String licenseCategory, required String licenseNumber, required String vehicleType, required String enrollVehicle, required String fcmToken, required String role}) async {
    final data = await _register("/drivers/register", {'userId': userId, 'phone': phoneNumber, 'document': document, 'licenseCategory': licenseCategory, 'licenseNumber': licenseNumber, 'vehicleType': vehicleType, 'enrollVehicle': enrollVehicle, 'fcmToken': fcmToken, 'role': role});
    if (data != null && !data.containsKey('error')) {
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_complete_registration',
        parameters: {
          'fb_registration_method': 'App Form Driver',
          'user_role': role,
          'vehicle_type': vehicleType,
        },
      );
    }
    return data;
  }

  Future<Map<String, dynamic>?> _register(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse("$apiBaseUrl$endpoint");
      if (apiBaseUrl.isEmpty) {
        throw Exception("API BASE URL no configurada");
      }
      log("URL QUE SE ENVIA AL SERVIDOR $url");

      log("📦 Datos enviados al servidor: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _facebookAppEvents.logCompletedRegistration(registrationMethod: 'App Form');
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
      if (apiBaseUrl.isEmpty) {
        throw Exception("API BASE URL no configurada");
      }

      print("🔐 [LOGIN] URL: $url");
      print("🔐 [LOGIN] Email: $email");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("🔐 [LOGIN] Status code: ${response.statusCode}");
      print("🔐 [LOGIN] Body raw: ${response.body}");

      if (response.body.isEmpty) {
        throw Exception("El servidor no devolvió respuesta para el código ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          print("✅ [LOGIN] Respuesta parseada: $data");
          print("✅ [LOGIN] userId=${data['userId']}, fullName=${data['fullName']}, email=${data['email']}, role=${data['role']}, token=${data['token']}");

          if (data is Map<String, dynamic> && data['token'] != null) {
            return data;
          } else {
            throw Exception("La respuesta del servidor no contiene un token válido.");
          }
        } catch (e) {
          print("❌ [LOGIN] Error parseando JSON: $e");
          throw Exception("Respuesta exitosa (200) pero el JSON es inválido o no es JSON.");
        }
      } else {
        String errorMessage = "Error desconocido con código ${response.statusCode}.";
        try {
          final responseData = jsonDecode(utf8.decode(response.bodyBytes));
          print("❌ [LOGIN] Error del servidor: $responseData");
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            errorMessage = "Error ${response.statusCode}: ${responseData.toString()}";
          }
        } catch (e) {
          errorMessage = "Error ${response.statusCode}. Respuesta no JSON: ${response.body}";
        }

        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print("❌ [LOGIN] Sin conexión: $e");
      throw Exception("No se pudo conectar al servidor. Revisa tu conexión a internet.");
    } on Exception catch (e) {
      print("❌ [LOGIN] Error: $e");
      rethrow;
    }
  }

  /// Valida el token con el servidor.
  /// - `null`: no hay token o el servidor lo rechazó (401/etc).
  /// - `{'_networkError': true}`: no se pudo contactar al servidor (no borrar sesión local).
  /// - Map con datos de usuario: token válido.
  Future<Map<String, dynamic>?> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      log("🔍 [ValidateToken] No hay token para validar.");
      return null;
    }

    final url = Uri.parse("$apiBaseUrl/auth/validate/me");
    log("🔐 [ValidateToken] Validando token en: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("✅ [ValidateToken] Token válido. Datos recibidos: $data");
        return data as Map<String, dynamic>;
      } else {
        log("⚠️ [ValidateToken] Token inválido o expirado. Status: ${response.statusCode}");
        return null;
      }
    } on SocketException catch (e) {
      log("❌ [ValidateToken] Sin conexión: $e");
      return {'_networkError': true};
    } catch (e) {
      log("❌ [ValidateToken] Error de red al validar token: $e");
      return {'_networkError': true};
    }
  }

  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/auth/logout"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('userId');
        await prefs.remove('role');
        await prefs.remove('token');
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
