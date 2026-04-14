import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel extends ChangeNotifier {
  
  String _currentAddress = "Ubicación no disponible";
  Position? _currentPosition;
  bool _isLoading = false;

  String get currentAddress => _currentAddress;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;

Future<Position?> updateLocation(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    final isGpsActive = await GpsValidatorService.ensureLocationServiceAndPermission(context);

    if (!isGpsActive) {
      _isLoading = false;
      notifyListeners();
      _currentAddress = "Permisos o GPS no habilitados";
      return null;
    }

    try {
      // 2. Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      log("🟢 Coordenadas de origen obtenidas: lat=${position.latitude}, lng=${position.longitude}");
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        _currentAddress = "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        _currentAddress = "Dirección no encontrada";
      }

      _isLoading = false;
      notifyListeners();
      return position;
    } catch (e) {
      _isLoading = false;
      _currentAddress = "Error al obtener ubicación: $e";
      notifyListeners();
      return null;
    }
  }

}
