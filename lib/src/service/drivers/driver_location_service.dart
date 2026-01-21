import 'dart:convert';
import 'package:holi/src/model/driver/driver_location_model.dart';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';

class DriverLocationService {
  Future<void> sendLocation(DriverLocationModel location, int driverId) async {
    final response = await http.put(
      Uri.parse('$apiBaseUrl/drivers/$driverId/location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'driverId': driverId,
          'latitude': location.latitude,
          'longitude': location.longitude,
      })
    );
    if(response.statusCode != 200){
       throw Exception('Error al enviar ubicación al servidor: ${response.statusCode}'); 
    }else{

    }
  }
}
