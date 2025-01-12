import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController {
  Future<String?> registerUser({required String name,required String email,required String password}) async {
    
    try {
      final url = Uri.parse("http://192.168.20.49:8080/api/v1/users/register");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "fullName": name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        print("Token $token");

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();

  
    
        }
      } else if (response.statusCode == 400) {
        // Manejar errores específicos del servidor
      final Map<String, dynamic> errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Error desconocido";
      } else {
        return "Error inesperado: ${response.body}";
      }
    } on SocketException catch (_) {
      print("No se pudo conectar al servidor. Verifica tu conexión.");
    } catch (e) {
      print("Error desconocido: $e");
    }
    return null; // Agregar retorno nulo si no hubo error
  }

   Future<String?> registerDriver(
      {required String name,
      required String email,
      required String document,
      required String phone,
      required String licenseNumber,
      required String  vehicleType,
      required String enrollVehicle,
      required String password}) async {
    try {
      final url = Uri.parse("http://192.168.20.49:8080/api/v1/drivers/register");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "fullName": name,
          'email': email,
          'document' : document,
          'phone': phone,
          'licenseNumber': licenseNumber,
          'vehicleType': vehicleType,
          'enrollVehicle':enrollVehicle,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        print("Token $token");

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
        }
      } else if (response.statusCode == 400) {
        // Manejar errores específicos del servidor
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Error desconocido";
      } else {
        return "Error inesperado: ${response.body}";
      }
    } on SocketException catch (_) {
      print("No se pudo conectar al servidor. Verifica tu conexión.");
    } catch (e) {
      print("Error desconocido: $e");
    }
    return null; // Agregar retorno nulo si no hubo error
  }
}

