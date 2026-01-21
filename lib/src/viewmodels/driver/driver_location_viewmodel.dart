import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/model/driver/driver_location_model.dart';
import 'package:holi/src/service/drivers/driver_location_service.dart';

class DriverLocationViewmodel extends ChangeNotifier {
  final DriverLocationService _locationService = DriverLocationService();
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  DriverLocationModel? _currentLocation;

  DriverLocationModel? get currentLocation => _currentLocation;
  bool _sending = false;
  Timer? _sendTimer;

  void startLocationUpdates(int driverId) {
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.enabled) {
        debugPrint("🚀 GPS detectado como ENCENDIDO. Reiniciando Stream...");
        _initPositionStream(driverId);
        _startPeriodicSend(driverId);
      }
    });
  }

  void _initPositionStream(int driverId) {
    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 15),
    ).listen((Position position) async {
      if (_sending) return;
      _sending = true;
      try {
        _currentLocation = DriverLocationModel(position.latitude, position.longitude);
        notifyListeners();
        debugPrint("📍 GPS movido: ${position.latitude}, ${position.longitude}");

        await _locationService.sendLocation(_currentLocation!, driverId);
        debugPrint("✅ Ubicación enviada al servidor");
      } catch (e) {
        debugPrint("❌ Error enviando al servidor: $e");
      } finally {
        _sending = false;
      }
    }, onError: (error) {
      debugPrint("⚠️ Error en el Stream de posición: $error");
    });
  }

  void _startPeriodicSend(int driverId) {
    _sendTimer?.cancel();
    _sendTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_currentLocation != null && !_sending) {
        _sending = true;
        try {
          await _locationService.sendLocation(_currentLocation!, driverId);
          debugPrint("✅ Ubicación enviada al servidor (timer)");
        } catch (e) {
          debugPrint("❌ Error en envío timer: $e");
        } finally {
          _sending = false;
        }
      }
    });
  }

  void updateInitialPosition(Position position) {
    _currentLocation = DriverLocationModel(position.latitude, position.longitude);
    notifyListeners();
  }

  void setManualLocation(LatLng location) {
    _currentLocation = DriverLocationModel(location.latitude, location.longitude);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _locationSubscription?.cancel();
    _sendTimer?.cancel();
    _serviceStatusSubscription?.cancel();
    _locationSubscription = null;
    _sendTimer = null;
  }
}
