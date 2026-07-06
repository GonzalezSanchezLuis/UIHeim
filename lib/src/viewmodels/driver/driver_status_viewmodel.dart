import 'dart:async';
import 'dart:convert';
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

      final driverId = await _getDriverId();
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
            // Solo logueamos, no guardamos en tripData aquí para no saltarnos el modal de aceptación
            log("🧾 [DriverStatus] Mensaje WebSocket recibido: $data");
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
      final driverId = await _getDriverId();
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
    final prefs = await SharedPreferences.getInstance();
    try {
      final driverId = await _getDriverId();
      final statusService = DriverStatusSerive();
      final driverStatusResponse = await statusService.loadDriverStatus(driverId);

      if (driverStatusResponse != null) {
        final connectionStatus = ConnectionStatus.fromString(driverStatusResponse.status);
        await prefs.setString('driverStatus', connectionStatus.toString());
        log("🔐 Estado del conductor guardado en SharedPreferences: $connectionStatus");

        setStatus(connectionStatus);
      }

      // ✅ Recuperamos el viaje si existía uno antes de que la app se cerrara
      await loadPersistedTrip();
    } catch (e) {
      debugPrint("⚠️ Error al cargar estado: $e");
    }
  }

  /// Obtiene el ID del conductor desde SharedPreferences y lanza una excepción si no se encuentra.
  Future<int> _getDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('userId');
    if (driverId == null || driverId == 0) {
      log("❌ Error crítico: No se pudo obtener un driverId válido desde SharedPreferences.");
      throw Exception("Driver ID no encontrado o es inválido (0)");
    }
    return driverId;
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

  /// Guarda los datos del viaje en la memoria del teléfono (SharedPreferences)
  Future<void> _persistTripData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(data);
    await prefs.setString('driver_active_trip', jsonData);
    log("💾 [DriverStatus] Guardando viaje en disco: $jsonData");
  }

  /// Intenta recuperar un viaje activo de la memoria
  Future<void> loadPersistedTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTrip = prefs.getString('driver_active_trip');
    log("🔍 [DriverStatus] Buscando viaje persistido en SharedPreferences...");

    if (savedTrip != null && savedTrip.isNotEmpty) {
      try {
        tripData = jsonDecode(savedTrip);

        // Si recuperamos un viaje, el conductor debe estar rastreable
        _startLocationTracking();

        // También reconectamos el WebSocket para seguir recibiendo actualizaciones del servicio
        final driverId = prefs.getInt('userId');
        if (driverId != null && _webSocketService == null) {
          _webSocketService = WebSocketDriverService(
            driverId: driverId,
            onMessage: (data) {
              log("🧾 [DriverStatus] Mensaje WebSocket recibido (reconexión): $data");
            },
          );
          _webSocketService!.connect();
        }

        notifyListeners();
        log("🚗 [DriverStatus] Viaje recuperado exitosamente desde disco.");
      } catch (e) {
        log("❌ Error al recuperar viaje persistido: $e");
      }
    } else {
      log("ℹ️ [DriverStatus] No se encontró ningún viaje activo en el disco.");
    }
  }

  /// Registra el inicio de un viaje aceptado y lo persiste inmediatamente
  Future<void> acceptTrip(Map<String, dynamic> data) async {
    log("🤝 [DriverStatus] Guardando viaje aceptado en persistencia...");
    tripData = data;
    await _persistTripData(data);
    _startLocationTracking(); // Aseguramos rastreo activo
    notifyListeners();
  }

  /// Elimina los datos del viaje de la memoria cuando el servicio termina
  Future<void> clearTripData() async {
    log("🏁 [DriverStatus] Finalizando viaje. Limpiando datos...");
    tripData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_active_trip');
    notifyListeners();
    log("🧹 [DriverStatus] Memoria de viaje limpiada correctamente.");
  }
}
