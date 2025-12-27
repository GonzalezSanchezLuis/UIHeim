import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holi/src/model/driver/driver_location_model.dart';
import 'package:holi/src/service/drivers/driver_location_service.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLocationViewmodel extends ChangeNotifier {
  final DriverLocationService _locationService = DriverLocationService();
  StreamSubscription<Position>? _locationSubscription;
  Timer? _timer;
  DriverLocationModel? _currentLocation;

  DriverLocationModel? get currentLocation => _currentLocation;

  void startLocationUpdates(int driverId) {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 50),
    ).listen((Position position) {
      _currentLocation = DriverLocationModel(position.latitude, position.longitude);
      notifyListeners();
      debugPrint("📍 GPS movido: ${position.latitude}, ${position.longitude}");
    });

    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_currentLocation != null) {
        try {
          await _locationService.sendLocation(currentLocation!, driverId);
          debugPrint('🚀 Ubicación enviada al servidor');
        } catch (e) {
          debugPrint('❌ Error al enviar ubicación: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    stopLocationUpdates();
    super.dispose();
  }

  void stopLocationUpdates(){
    _locationSubscription?.cancel();
    _timer?.cancel();
    _locationSubscription = null;
    _timer = null;
  }

}
