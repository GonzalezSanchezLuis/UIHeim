import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetDriverLocationViewmodel  extends ChangeNotifier{
  LatLng? _driverLocation;
  LatLng? get driverLocation => _driverLocation;

  void setMoveData(Map<String, dynamic> data) {
   final  dataMove = data;

    // Extraer ubicación del conductor si existe
    final lat = double.tryParse(data['driverLat'] ?? '');
    final lng = double.tryParse(data['driverLng'] ?? '');

    if (lat != null && lng != null) {
      _driverLocation = LatLng(lat, lng);
    }

    notifyListeners();
  }
}