import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverRepository {
  static const String status = "Connected";
  
 Future<void> setStatus(int driverId, LatLng position) async {
   const String baseUrl = 'http://192.168.20.49:8080/api/v1/drivers/status';
  final url = Uri.parse('$baseUrl/$driverId');

  try {
    print("Enviando datos al servidor: $url");
    print(jsonEncode({
      'status': status,
      'driverId': driverId,
      'latitude': position.latitude,
      'longitude': position.longitude,
    }));

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        'driverId': driverId,
        'latitude': position.latitude,
        'longitude': position.longitude,
      }),
    );

    print("Código de respuesta: ${response.statusCode}");
    print("Respuesta del servidor: ${response.body}");

    if (response.statusCode == 200) {
      print("Ubicación enviada correctamente");
    } else {
      print("Error al enviar la ubicación: ${response.body}");
    }
  } catch (e) {
    print("Error en la solicitud: $e");
  }
}



Future<void> disconnectedDriver(int driverId) async {
const String status = "Disconnected";
const String baseUrl = 'http://192.168.20.49:8080/api/v1/drivers';
    final url = Uri.parse('$baseUrl/disconnected/$driverId');


try {
    print("Enviando datos al servidor de desconexion : $url");
    print(jsonEncode({
      'status': status,
    }));

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        'driverId': driverId,
  
      }),
    );

    print("Código de respuesta: ${response.statusCode}");
    print("Respuesta del servidor: ${response.body}");

    if (response.statusCode == 200) {
      print("Te haz desconetado satisfactriarmente");
    } else {
     // print("Error al enviar la ubicación: ${response.body}");
    }
  } catch (e) {
    print("Error en la solicitud: $e");
  }
  
}



    
   Future<bool> getDriverStatus(int driverId) async {
    const String baseUrl = 'http://192.168.20.49:8080/api/v1/drivers';
      final url = Uri.parse('$baseUrl/status/$driverId');
      try {
        final response = await http.get(
          Uri.parse('$url'),
          headers: {
            "Content-Type": "application/json",
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['status'] == "Connected"; // Ajusta según la respuesta de tu API
        } else {
          print("❌ Error al obtener el estado del conductor: ${response.body}");
          return false; // Si hay error, asumimos que no está conectado
        }
      } catch (e) {
        print("⚠️ Excepción al obtener estado del conductor: $e");
        return false;
      }
    }
  }


