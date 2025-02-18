import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileController {
  final StreamController<Map<String, String>> _userDataController = StreamController();
  Stream<Map<String, String>> get userDataStream => _userDataController.stream;

  // Emite los nuevos datos de usuario a través del Stream
  void updateUserData(Map<String, String> userData) {
    _userDataController.sink.add(userData);
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        print("User ID no encontrado");
        return null;
      }

      // Construir la solicitud
      final response = await http.get(
        Uri.parse('http://192.168.20.49:8080/api/v1/users/user/$userId'), // El ID va en la URL
        headers: {
          'Content-Type': 'application/json', // (opcional) Indica el tipo de contenido
        },
      );

      // Manejar la respuesta del servidor
      if (response.statusCode == 200) {
        print(response.body); // Devuelve los datos del usuario
        return jsonDecode(response.body);
      } else {
        print("Error al obtener los datos del usuario: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error al realizar la solicitud: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateDataUser(
    String urlAvatarProfile, 
    String fullName, 
    String document, 
    String email, 
    String phone, 
    String? password) async {
    try {
      const String apiUrl = 'http://192.168.20.49:8080/api/v1/users/update/';

      // Verificar si el ID de usuario está disponible en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        print("User ID no encontrado");
        return {'status': 'error', 'message': 'ID de usuario no encontrado'};
      }

      // Crear el objeto de datos
      final Map<String, dynamic> data = {
        'fullName': fullName,
        'urlAvatarProfile': urlAvatarProfile,
        'document': document,
        'email': email,
        'phone': phone,
        'password': password
      };
      print("url del avatar $urlAvatarProfile");

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      // Hacer la solicitud HTTP POST
      final response = await http.put(
        Uri.parse('$apiUrl$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      // Manejar la respuesta
      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, actualizar datos en SharedPreferences
        final Map<String, dynamic> updatedUser = jsonDecode(response.body);
        await prefs.setString('urlAvatarProfile', updatedUser['urlAvatarProfile']);
        await prefs.setString('fullName', updatedUser['fullName']);
        await prefs.setString('document', updatedUser['document']);
        await prefs.setString('email', updatedUser['email']);
        await prefs.setString('phone', updatedUser['phone']);

        if (password != null && password.isNotEmpty) {
          data['password'] = password; // Solo agrega la contraseña si no es null
        }

        debugPrint("Datos actualizados exitosamente.");
        return {'status': 'success', 'data': updatedUser};
      } else {
        // Si hay un error con la respuesta del servidor
        debugPrint("Error al actualizar los datos: ${response.body}");
        return {'status': 'error', 'message': 'Error al actualizar los datos'};
      }
    } catch (e) {
      print("Error al realizar la solicitud: $e");
      return {'status': 'error', 'message': 'Error inesperado al intentar actualizar los datos'};
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        print("User ID no encontrado");
        return;
      }

      // Construir la solicitud
      final response = await http.delete(
        Uri.parse('http://192.168.20.49:8080/api/v1/users/delete/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Manejar la respuesta del servidor
      if (response.statusCode == 200) {
        await prefs.clear();
      } else {
        print("Error al eliminar la cuenta: ${response.body}");
      }
    } catch (e) {
      print("Error al realizar la solicitud: $e");
    }
  }

  void dispose() {
    _userDataController.close();
  }
}
