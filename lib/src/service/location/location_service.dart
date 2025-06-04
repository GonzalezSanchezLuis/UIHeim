import 'dart:convert';
import 'dart:developer';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holi/src/model/predictions/prediction_mdel.dart';
import 'package:http/http.dart' as http;

class LocationService {
  final String googleApiKey;
  LocationService({required this.googleApiKey});

  // Verifica y solicita permisos de ubicación
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
        log("📍 Coordenadas de destino:::: lat=${locations.first.latitude}, lng=${locations.first.longitude}");

        return {'latitude': locations.first.latitude, 'longitude': locations.first.longitude};
      }
      return null;
    } catch (e) {
      print('❌ Error en getCoordinatesFromAddress: $e');
      return null;
    }
  }

  /// Obtiene coordenadas precisas usando un placeId
  Future<Map<String, double>?> getCoordinatesFromPlaceId(String placeId) async {
    final String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyDB04XLcypB4xsGaRqNPjAGmf1xTegz0Rg";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];
          log("📍 Coordenadas desde placeId: lat=$lat, lng=$lng");
          return {'latitude': lat, 'longitude': lng};
        } else {
          log('❌ Google API Error: ${data['status']}');
        }
      } else {
        log('❌ Falló la solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error en getCoordinatesFromPlaceId: $e");
    }

    return null;
  }


  // Obtiene sugerencias de direcciones (requiere API key de Google)
  Future<List<Prediction>> getAddressSuggestions(String query) async {
    if (googleApiKey.isEmpty) {
      throw Exception("Google API key is required for address suggestions");
    }

    try {
      
     final encodedQuery = Uri.encodeComponent(query);
     final String url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
          "?input=$encodedQuery"
          "&key=$googleApiKey"
          "&language=es";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;
        return predictions
            .map((p) => Prediction(
                  description: p['description'],
                  placeId: p['place_id'],
                ))
            .toList();
      } else {
        throw Exception("No se pudieron obtener predicciones");
      }
    } catch (e) {
      print("❌ Error en getAddressSuggestions: $e");
      return [];
    }
  }
}
