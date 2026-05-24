import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/service/drivers/driver_status_service.dart';
import 'package:holi/src/service/websocket/websocket_driver_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverStatusViewmodel extends ChangeNotifier {
  ConnectionStatus? _connectionStatus;
  bool _isLoading = false;
  WebSocketDriverService? _webSocketService;
  StreamSubscription<geo.Position>? _positionStreamSubscription;

  Map<String, dynamic>? tripData;
  final int _remainingTime = 15;

  double _currentHeading = 0.0;
  LatLng? _currentPosition;
  BitmapDescriptor? _driverIcon;

  int get remainingTime => _remainingTime;
  double get currentHeading => _currentHeading;
  LatLng? get currentPosition => _currentPosition;
  BitmapDescriptor? get driverIcon => _driverIcon;
  Timer? _timer;
  bool isTimerRunning = false;
  bool get isLoading => _isLoading;
  ConnectionStatus? get connectionStatus => _connectionStatus;

  Future<LatLng?> connectDriverViewmodel(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    print("Conectando...");

    try {
      bool gpsReady = await GpsValidatorService.ensureLocationServiceAndPermission(context);
      if (!gpsReady) return null;

      // Cargamos el nuevo icono circular
      await _loadMarkerIcon();

      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("❌ Driver ID no encontrado en SharedPreferences.");
        return null;
      }

      // Obtener la ubicación actual del conductor
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      _currentHeading = position.heading;
      _currentPosition = LatLng(position.latitude, position.longitude);
      print("📍 Ubicación inicial: Lat: ${position.latitude}, Lng: ${position.longitude}, Rumbo: $_currentHeading");

      // ✅ Convertir Position a LatLng
      LatLng latLngPosition = _currentPosition!;

      // Llamar a StatusController para conectar al conductor
      final statusService = DriverStatusSerive();
      await statusService.connectDriver(driverId, latLngPosition);
      setStatus(ConnectionStatus.CONNECTED);

      print("✅ Conductor conectado exitosamente.");

      _webSocketService = WebSocketDriverService(
          driverId: driverId,
          onMessage: (data) {
            print("🧾 Mensaje WebSocket recibido: $data");
            // Puedes notificar listeners o actualizar el estado aquí
          });
      _webSocketService!.connect();

      _startLocationTracking();

      return latLngPosition;
    } catch (e) {
      print("⚠️ Error al conectar: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga el icono circular para el marcador del conductor.
  Future<void> _loadMarkerIcon() async {
    _driverIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/images/driver_circle_icon.png', // Cambia esto por tu nuevo asset circular
    );
    notifyListeners();
  }

  void _startLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 2, // Equilibrio entre precisión y estabilidad
      ),
    ).listen((geo.Position position) {
      // Al usar un icono circular, el heading ya no es crítico para el Marker,
      // pero lo mantenemos suavizado por si decides rotar la cámara del mapa.
      if (position.speed > 1.0 && position.heading > 0) {
        _currentHeading = _interpolateHeading(_currentHeading, position.heading, 0.20);
      }

      _currentPosition = LatLng(position.latitude, position.longitude);
      notifyListeners();
    });
  }

  /// Suaviza la transición entre el rumbo actual y el nuevo, manejando el wrap-around de 360 grados.
  double _interpolateHeading(double oldHeading, double newHeading, double alpha) {
    double diff = newHeading - oldHeading;

    // Ajuste para el camino más corto en un círculo
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    return (oldHeading + alpha * diff) % 360;
  }

  Future<void> disconnectDriverViewmodel() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("❌ Driver ID no encontrado en SharedPreferences.");
        return;
      }

      final statusService = DriverStatusSerive();
      await statusService.disconnectDriver(driverId);
      setStatus(ConnectionStatus.DISCONNECTED);

      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      _webSocketService?.disconnect();
      _webSocketService = null;

      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Error al desconectar: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDriverStatusViewmodel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getInt('userId');

      if (driverId == null) {
        print("User ID no encontrado en SharedPreferences.");
        return;
      }

      final statusService = DriverStatusSerive();
      final driverStatusResponse = await statusService.loadDriverStatus(driverId);

      if (driverStatusResponse != null) {
        final connectionStatus = ConnectionStatus.fromString(driverStatusResponse.status);
        await prefs.setString('driverStatus', connectionStatus.toString());
        log("🔐 Estado del conductor guardado en SharedPreferences: $connectionStatus");

        setStatus(connectionStatus);
      }
    } catch (e) {
      debugPrint("⚠️ Error al desconectar: $e");
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void setStatus(ConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners();
  }
}
