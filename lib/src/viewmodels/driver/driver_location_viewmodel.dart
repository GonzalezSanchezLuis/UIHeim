import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holi/src/model/driver/driver_location.dart';
import 'package:holi/src/service/drivers/driver_location_service.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLocationViewmodel extends ChangeNotifier {
  final SessionViewModel sessionViewModel = SessionViewModel();
  final DriverLocationService driverLocationService = DriverLocationService();
  StreamSubscription<Position>? locationSubscription;
  Timer? _locationTimer;
  DriverLocation? _currentLocation;

  DriverLocation? get currentLocation => _currentLocation;

  void startLocationUpdates() {
    locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 100,
      ),
    ).listen((Position position) async {
      _currentLocation = DriverLocation(position.latitude, position.longitude);
      notifyListeners();
      _sendLocationToServer();

      _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_currentLocation != null) {
          _sendLocationToServer();
        }
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final driverId = prefs.getInt('userId');

        if (driverId == null) {
          print("User ID no encontrado");
          return null;
        }

        await driverLocationService.sendLocation(_currentLocation!, driverId);
        debugPrint('Ubicación enviada');
      } catch (e) {
        debugPrint('Error al enviar ubicación: $e');
      }
    });
  }

  void _sendLocationToServer() async {
    if (_currentLocation == null) return;

    try {
      final driverId = sessionViewModel.userId;
      if (driverId == null) {
        print("USER ID NOT FOUND");
        return;
      }

      await driverLocationService.sendLocation(_currentLocation!, driverId);
      debugPrint('Ubicación enviada');
    } catch (e) {
      debugPrint('Error al enviar ubicación: $e');
    }
  }

  void stopLocationUpdates() {
    locationSubscription?.cancel();
    _locationTimer?.cancel();
  }
}
