import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteUserViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<LatLng> _route = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LatLng> get route => _route;
  final String _googleMapsApiKey = 'AIzaSyDB04XLcypB4xsGaRqNPjAGmf1xTegz0Rg';

  Future<void> fetchRoute(LatLng origin, LatLng destination) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&overview=full'
        '&key=$_googleMapsApiKey',
      );

      print("SOLICITANDO DATOS A LA URL ${url.toString()}");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("RESPUESTA  DE GOOGLE ${data['status']}");

        if (data['status'] == 'OK') {
          final steps = data['routes'][0]['legs'][0]['steps'] as List;

          List<LatLng> allPoints = [];
          for (var step in steps) {
            final encoded = step['polyline']['points'];
            allPoints.addAll(_decodePolyline(encoded));
          }

          _route = allPoints;
          print("✅ Ruta cargada con ${_route.length} puntos");

          for (var i = 0; i < (route.length < 5 ? route.length : 5); i++) {
            print("🔹 Punto $i: ${_route[i].latitude}, ${_route[i].longitude}");
          }

        } else {
          _error = data['error_message'] ?? 'Error en la respuesta de Google Directions';
          print("❌ Google Directions error: $_error");
        }
      } else {
        _error = 'HTTP error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de red o decodificación: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    try {
      while (index < len) {
        int b, shift = 0, result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        points.add(LatLng(lat / 1E5, lng / 1E5));
      }
    } catch (e) {
      print("Error decodificando polilínea: $e");
    }

    return points;
  }
}
