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
  bool _isSendingFromStream = false;
  bool _isSendingFromTimer = false;
  Timer? _sendTimer;

  void startLocationUpdates(int driverId) {
    _initPositionStream(driverId);
    _startPeriodicSend(driverId);
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
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 5),
    ).listen((Position position) async {
      _currentLocation = DriverLocationModel(position.latitude, position.longitude);
      notifyListeners();

      if (_isSendingFromStream) return;
      _isSendingFromStream = true;

      try {
        await _locationService.sendLocation(_currentLocation!, driverId);
        debugPrint("📍 GPS movido: ${position.latitude}, ${position.longitude}");
        debugPrint("✅ Ubicación enviada al servidor");
      } catch (e) {
        debugPrint("❌ Error  Stream: $e");
      } finally {
        _isSendingFromStream = false;
      }
    }, onError: (error) {
      debugPrint("⚠️ Error en el Stream de posición: $error");
    });
  }

  void _startPeriodicSend(int driverId) {
    _sendTimer?.cancel();
    _sendTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_currentLocation != null && !_isSendingFromTimer) {
        _isSendingFromTimer = true;
        try {
          await _locationService.sendLocation(_currentLocation!, driverId);
          debugPrint("⏰ Respaldo (Timer): Envío periódico exitoso");
        } catch (e) {
          debugPrint("❌ Error en envío timer: $e");
        } finally {
          _isSendingFromTimer = false;
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
