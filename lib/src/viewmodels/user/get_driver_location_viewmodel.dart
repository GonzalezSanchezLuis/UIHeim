import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/utils/to_double.dart';

class GetDriverLocationViewmodel extends ChangeNotifier {
  LatLng? _driverLocation;
  LatLng? get driverLocation => _driverLocation;
  Map<String, dynamic>? _moveData;

  Map<String, dynamic>? get moveData => _moveData;

  void setMoveData(Map<String, dynamic> data) {
    final Map<String, dynamic> source =
        data.containsKey('move') ? Map<String, dynamic>.from(data['move'] as Map) : Map<String, dynamic>.from(data);

    if (_moveData != null && _moveData!.isNotEmpty) {
      _moveData = {..._moveData!, ...source};
    } else {
      _moveData = source;
    }

    _applyCoordinatesFromMap(_moveData!);
    notifyListeners();
  }

  void updateDriverCoordinates(dynamic latRaw, dynamic lngRaw) {
    final double? lat = _parseCoord(latRaw);
    final double? lng = _parseCoord(lngRaw);
    if (lat == null || lng == null) return;

    final newLocation = LatLng(lat, lng);
    if (_isSameLocation(_driverLocation, newLocation)) return;

    _driverLocation = newLocation;
    if (_moveData != null) {
      _moveData = {..._moveData!, 'driverLat': lat, 'driverLng': lng};
    }
    log("✅ Ubicación del conductor actualizada: $_driverLocation");
    notifyListeners();
  }

  void applyPayload(Map<String, dynamic> data) {
    if (data.containsKey('move') && data['move'] is Map) {
      setMoveData(Map<String, dynamic>.from(data['move'] as Map));
      return;
    }

    final hasRootCoords = data['driverLat'] != null && data['driverLng'] != null;
    if (hasRootCoords) {
      updateDriverCoordinates(data['driverLat'], data['driverLng']);
      return;
    }

    if (data['driverLat'] != null || data['driverLng'] != null || data['moveId'] != null) {
      setMoveData(data);
    }
  }

  void clear() {
    _driverLocation = null;
    _moveData = null;
    notifyListeners();
  }

  void _applyCoordinatesFromMap(Map<String, dynamic> source) {
    final double? lat = _parseCoord(source['driverLat']);
    final double? lng = _parseCoord(source['driverLng']);
    if (lat == null || lng == null) return;

    final newLocation = LatLng(lat, lng);
    if (_isSameLocation(_driverLocation, newLocation)) return;

    _driverLocation = newLocation;
    log("✅ Notificando nueva ubicación del conductor: $_driverLocation");
  }

  double? _parseCoord(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isEmpty) return null;
    return ToDouble(value);
  }

  bool _isSameLocation(LatLng? current, LatLng next) {
    if (current == null) return false;
    const epsilon = 0.000001;
    return (current.latitude - next.latitude).abs() < epsilon &&
        (current.longitude - next.longitude).abs() < epsilon;
  }
}
