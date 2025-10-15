import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holi/config/app_config.dart';

class DriverProfileService {
  final StreamController<Map<String, String>> _driverDataController = StreamController();
  Stream<Map<String, String>> get driverDataStream => _driverDataController.stream;

  void updateDriverData(Map<String, String> driverData) {
    _driverDataController.sink.add(driverData);
  }

  Future<Map<String, dynamic>?> fetchDriverData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      log("ID DEL CONDUCTOR $driverId");
      if (driverId == null) {
        print("User ID no encontrado");
        return null;
      }

      // Construir la solicitud
      final response = await http.get(
        Uri.parse('$apiBaseUrl/drivers/driver/$driverId'), 
        headers: {
          'Content-Type':'application/json', 
          });
    

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

  Future<Map<String, dynamic>?> updateDataDriver(
    String fullName,
    String document,
    String email,
    String phone,
    String? password,
    String urlAvatarProfile,
  ) async {
    try {
       String apiUrl = '$apiBaseUrl/users/update/';

      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("User ID no encontrado");
        return {'status': 'error', 'message': 'ID de usuario no encontrado'};
      }

      // Crear el objeto de datos
      final Map<String, dynamic> data = {
        'document': document,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'urlAvatarProfile': urlAvatarProfile,
      };
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      print("DATOS QUE SE ENVIAN AL SERVIDOR $data");

      final response = await http.put(
        Uri.parse('$apiUrl$driverId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data));

      if (response.statusCode == 200) {
        final Map<String, dynamic> updatedDataDriver = jsonDecode(response.body);
        await prefs.setString('fullName', updatedDataDriver['fullName']);
        await prefs.setString('email', updatedDataDriver['email']);
        await prefs.setString('phone', updatedDataDriver['phone']);
        await prefs.setString('urlAvatarProfile', updatedDataDriver['urlAvatarProfile']);

        if (password != null && password.isNotEmpty) {
          data['password'] = password; 
        }

        debugPrint("Datos actualizados exitosamente.");
        return {'status': 'success', 'data': updatedDataDriver};
      } else {
        // Si hay un error con la respuesta del servidor
        debugPrint("Error al actualizar los datos: ${response.body}");
        return {'status': 'error', 'message': 'Error al actualizar los datos'};
      }
    } catch (e) {
      debugPrint("Error al realizar la solicitud: $e");
      return {
        'status': 'error',
        'message': 'Error inesperado al intentar actualizar los datos'
      };
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("User ID no encontrado");
        return;
      }

      // Construir la solicitud
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/drivers/delete/$driverId'),
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
    _driverDataController.close();
  }
}
