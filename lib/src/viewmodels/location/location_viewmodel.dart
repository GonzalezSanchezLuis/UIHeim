import 'package:flutter/material.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/service/data/repository/location_repository.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationRepository _locationRepository = LocationRepository();

  String _currentAddress = "Ubicación no disponible";
  Position? _currentPosition;
  bool _isLoading = false;

  String get currentAddress => _currentAddress;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;

  Future<Position?> updateLocation(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      bool gpsEnabled = await GpsValidatorService.isGpsActuallyEnabled();
      bool gpsFuctioning = await _checkGpsFunctionality();

      if (!gpsEnabled || !gpsFuctioning) {
        if (context.mounted) {
          await GpsValidatorService.showGpsDialog(context);
          gpsEnabled = await Geolocator.isLocationServiceEnabled();
        }

        if (!gpsEnabled) {
          _currentAddress = "GPS no activado";
          return null;
        }
      }

      Position? position = await _getPositionWithRetry();

      if (position != null) {
        _currentPosition = position;
        _currentAddress = await _getAddress(position);
      } else {
        _currentAddress = "No se pudo obtener ubicación";
      }

      return position;
    } catch (e) {
      _currentAddress = "Error: ${e.toString()}";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

   Future<bool> _checkGpsFunctionality() async {
    try {
      final status = await Geolocator.checkPermission();
      return status == LocationPermission.always || status == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }


  Future<Position?> _getPositionWithRetry({int retries = 2}) async {
    for (int i = 0; i < retries; i++) {
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        if (i == retries - 1) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return null;
  }

  Future<String> _getAddress(Position position) async {
    try {
      return await _locationRepository.fetchAddress(
        position.latitude, 
        position.longitude
      ) ?? "Dirección no encontrada";
    } catch (e) {
      return "Error obteniendo dirección";
    }
  }

}
