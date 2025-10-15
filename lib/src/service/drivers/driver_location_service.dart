import 'dart:convert';
import 'package:holi/src/model/driver/driver_location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holi/config/app_config.dart';

class DriverLocationService {
  Future<void> sendLocation(DriverLocation location, int driverId) async {

    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('userId');

    if (driverId == null) {
      print("User ID no encontrado");
      return null;
    }
    
    final response = await http.post(Uri.parse('$apiBaseUrl/location/$driverId'),
    
    headers: {'Content-Type' : 'application/json'}, 
    body: jsonEncode({
          'driverId': driverId,
          ...location.toJson(),
    }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar ubicación');
    }
  }
}
