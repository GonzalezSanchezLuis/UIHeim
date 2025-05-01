import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://192.168.20.49:8080/api/v1";
 //final String baseUrl = "https://ef35-2800-484-3981-2300-8ab7-395e-c1fd-a3fe.ngrok-free.app/api/v1";


  Future<String?> registerUser({
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

  Future<String?> registerDriver({
    required String name,
    required String email,
    required String document,
    required String phone,
    required String licenseNumber,
    required String vehicleType,
    required String enrollVehicle,
    required String password,
  }) async {
    return _register("/drivers/register", {
      "fullName": name,
      'email': email,
      'document': document,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'enrollVehicle': enrollVehicle,
      'password': password,
    });
  }

  Future<String?> _register(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse("$baseUrl$endpoint");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Error desconocido";
      }
    } on SocketException {
      return "No se pudo conectar al servidor. Verifica tu conexión.";
    } catch (e) {
      return "Error desconocido: $e";
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/auth/auth");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json',
        'User-Agent': 'FlutterApp/1.0'
        },

        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      Uint8List bodyBytes = response.bodyBytes;
      String decodedBody = utf8.decode(bodyBytes);
     // Map<String, dynamic> data = jsonDecode(decodedBody);

     log("STATUS: ${response.statusCode}");
      log("BODY RAW: $decodedBody");

      if (response.statusCode == 200) {
         final data = jsonDecode(decodedBody);
        final userId = data['userId'];
        final role = data['role'];

        if (userId != null && userId is int && role != null && role is String) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);
          await prefs.setString('role', role);
          log("ID del usuario: $userId, Rol: $role");
          return null; // Éxito
        }
        return "Datos incompletos en la respuesta.";
      }
      final data = jsonDecode(decodedBody);
      return data['message'] ?? "Error desconocido";
    } catch (e) {
      return "Error de conexión: $e";
    }
  }



  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/logout"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        log("Sesión cerrada con éxito");
        return true;
      }
      return false;
    } catch (e) {
      log("Excepción al cerrar sesión: $e");
      return false;
    }
  }
}
