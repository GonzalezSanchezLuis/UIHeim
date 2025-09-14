import 'dart:convert';
import 'package:holi/src/model/driver/driver_location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverLocationService {
  Future<void> sendLocation(DriverLocation location, int driverId) async {

    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('userId');

    if (driverId == null) {
      print("User ID no encontrado");
      return null;
    }
    
    final response = await http.post(Uri.parse('https://83a6203644ae.ngrok-free.app/api/v1/drivers/location/$driverId'),
    
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
