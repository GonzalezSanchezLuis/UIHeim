import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthController {
 /* Future<String?> login(
      {required String email, required String password}) async {
    try {
      final url = Uri.parse("http://192.168.20.49:8080/api/v1/auth/auth");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['userId'];
        print("ID DEL USUARIO $userId");
        if (userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          log("id:  $userId");
        }
      } else if (response.statusCode == 400) {
        // Manejar errores específicos del servidor
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Error desconocido";
      } else {
        return "Error inesperado: ${response.body}";
      }
    } catch (e) {
      log("Error durante el inicio de sesion: $e");
      return "Error durante el inicio de sesión: $e";
    }
  } */

  /* Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      return false;
    }

    bool isExpired = JwtDecoder.isExpired(token);
    return !isExpired;
  } */

  /* Future<bool> logout() async {
    const String url = "http://192.168.20.49:8080/api/v1/auth/logout";
    try {
      //final prefs = await SharedPreferences.getInstance();
      //final token = prefs.getString('authToken');

    //  if (token == null) return false;

      final response = await http.post(Uri.parse("$url"), headers: {
       // "Authorization": "Bearer $token",
       // "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
      //  await prefs.remove('authToken');
        return true;
      } else {
        log("Error al cerrar sesion ${response.body}");
        return false;
      }
    } catch (e) {
      log("Excepción al cerrar sesión: $e");
      return false;
    }
  }*/

Future<String?> login(
      {required String email, required String password}) async {
    try {
      final url = Uri.parse("http://192.168.20.49:8080/api/v1/auth/auth");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['userId'];
        print("ID DEL USUARIO $userId");

        if (userId != null && userId is int) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId); // Guardamos como int
          log("id:  $userId");
        }
      } else if (response.statusCode == 400) {
        // Manejar errores específicos del servidor
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Error desconocido";
      } else {
        return "Error inesperado: ${response.body}";
      }
    } catch (e) {
      log("Error durante el inicio de sesion: $e");
      return "Error durante el inicio de sesión: $e";
    }
  }



  Future<bool> logout() async {
    const String url = "http://192.168.20.49:8080/api/v1/auth/logout";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // Limpiar datos locales relacionados con la sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs
            .clear(); 
        log("Sesión cerrada con éxito");
        return true;
      } else {
        log("Error al cerrar sesión: ${response.body}");
        return false;
      }
    } catch (e) {
      log("Excepción al cerrar sesión: $e");
      return false;
    }
  }
}
