import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class   RouteModel {
  final String apiKey;

  RouteModel(this.apiKey);

  Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if ((json['routes'] as List).isNotEmpty) {
        final points = json['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(points);
      }
    }
    return [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    final polylinePoints = PolylinePoints();
    final result = polylinePoints.decodePolyline(encoded);
    return result.map((point) => LatLng(point.latitude, point.longitude)).toList();
  }
}
