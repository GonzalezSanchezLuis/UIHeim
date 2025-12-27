import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetDriverLocationViewmodel extends ChangeNotifier {
  LatLng? _driverLocation;
  LatLng? get driverLocation => _driverLocation;
  Map<String, dynamic>? _moveData;

  Map<String, dynamic>? get moveData => _moveData;

  void setMoveData(Map<String, dynamic> data) {
    //  final dataMove = data;
    final Map<String, dynamic> source = data.containsKey('move') ? data['move'] : data;

    final lat = source['driverLat'] is String ? double.tryParse(data['driverLat']) : (data['driverLat'] as double?);
    final lng = source['driverLng'] is String ? double.tryParse(data['driverLng']) : (data['driverLng'] as double?);

    if (lat != null && lng != null) {
      _driverLocation = LatLng(lat, lng);
      _moveData = data;
      log("DATA DEL LA UBICACION DEL CONDUCTOR DESDE GetDriverLocationViewmodel $_moveData");
      log("✅ Notificando nueva ubicación del conductor: $_driverLocation");
      notifyListeners();
    }
  }
}
