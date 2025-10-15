import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:holi/config/app_config.dart';

class ProfileUserService {
  final StreamController<Map<String, String>> _userDataController = StreamController();
  Stream<Map<String, String>> get userDataStream => _userDataController.stream;

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

      final response = await http.get(
        Uri.parse('$apiBaseUrl/users/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print(response.body); 
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

  Future<Map<String, dynamic>?> updateDataUser(String urlAvatarProfile, String fullName, String document, String email, String phone, String? password) async {
    try {
       String apiUrl = '$apiBaseUrl/users/update/';

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        print("User ID no encontrado");
        return {'status': 'error', 'message': 'ID de usuario no encontrado'};
      }

      final Map<String, dynamic> data = {
        'fullName': fullName,
        'urlAvatarProfile': urlAvatarProfile,
        'document': document,
        'email': email,
        'phone': phone,
      };
      print("url del avatar $urlAvatarProfile");

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      print("🧾 Payload para actualizar usuario:");
      data.forEach((key, value) {
        print("🔹 $key: $value (${value.runtimeType})");
      });

      final response = await http.put(
        Uri.parse('$apiUrl$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> updatedUser = jsonDecode(response.body);
        await prefs.setString('urlAvatarProfile', updatedUser['urlAvatarProfile']);
        await prefs.setString('fullName', updatedUser['fullName']);
        await prefs.setString('document', updatedUser['document']);
        await prefs.setString('email', updatedUser['email']);
        await prefs.setString('phone', updatedUser['phone']);

        if (password != null && password.isNotEmpty) {
          data['password'] = password;
        }

        debugPrint("Datos actualizados exitosamente.");
        return {'status': 'success', 'data': updatedUser};
      } else {
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

      final response = await http.delete(
        Uri.parse('$apiBaseUrl/users/delete/$userId'),
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
