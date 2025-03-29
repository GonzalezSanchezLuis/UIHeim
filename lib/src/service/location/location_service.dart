// location_service.dart
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
//String googleApiKey = "AIzaSyCox00NukoO4C-N-V-0ChQBjwl3y34faw0";

class LocationService {
  final String? googleApiKey;

  LocationService({this.googleApiKey});

  /// Verifica y solicita permisos de ubicación
  Future<bool> requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      print("❌ Error en requestLocationPermission: $e");
      return false;
    }
  }

  /// Obtiene la ubicación actual
  Future<Position?> getCurrentPosition() async {
    try {
      if (await requestLocationPermission()) {
        return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }
      return null;
    } catch (e) {
      print("❌ Error en getCurrentPosition: $e");
      return null;
    }
  }

  /// Obtiene dirección a partir de coordenadas
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return null;
    } catch (e) {
      print('❌ Error en getAddressFromCoordinates: $e');
      return null;
    }
  }

  /// Convierte dirección en coordenadas
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return {'latitude': locations.first.latitude, 'longitude': locations.first.longitude};
      }
      return null;
    } catch (e) {
      print('❌ Error en getCoordinatesFromAddress: $e');
      return null;
    }
  }

  /// Obtiene sugerencias de direcciones (requiere API key de Google)
  Future<List<String>> getAddressSuggestions(String query) async {
    if (googleApiKey == null || googleApiKey!.isEmpty) {
      throw Exception("Google API key is required for address suggestions");
    }

    try {
      final String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
          "?input=$query"
          "&key=$googleApiKey"
          "&language=es";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('error_message')) {
          throw Exception(data['error_message']);
        }

        final predictions = data['predictions'] as List;
        return predictions.map<String>((p) => p['description'].toString()).toList();
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error en getAddressSuggestions: $e");
      return [];
    }
  }
}
