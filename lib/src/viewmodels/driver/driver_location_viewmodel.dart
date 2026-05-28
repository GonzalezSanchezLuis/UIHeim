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


final bool _activarSimuladorPrueba = false;
  Timer? _viajeSimuladoTimer;

  void startLocationUpdates(int driverId) {

   /*if (_activarSimuladorPrueba) {
      debugPrint("🕹️ [MODO SIMULADOR] Interceptando inicio de rastreo del conductor ID: $driverId");
      _ejecutarViajeSimulado(driverId);
      return; // Detiene la ejecución aquí. El GPS real y el Timer NO se encenderán.
    } */

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
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 3),
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


  // 🔄 MÉTODO AUXILIAR: Mueve al conductor por el sur de Bogotá hacia la Caracas
  void _ejecutarViajeSimulado(int driverId) {
    _viajeSimuladoTimer?.cancel();

    // Tu ruta exacta: Sale de la Cr 13a Bis y recorre la Av. Caracas hacia el norte
    final List<LatLng> puntosRuta = [
      const LatLng(4.568310, -74.116650), // Cr 13a Bis # 50b-09 Sur (Salida)
      const LatLng(4.568010, -74.116750),
      const LatLng(4.567820, -74.117420), // Giro por Cl 51 Sur
      const LatLng(4.567550, -74.118450),
      const LatLng(4.567340, -74.119250), // Esquina Caracas (Molinos)
      const LatLng(4.568250, -74.119050), // Avanzando por la Caracas
      const LatLng(4.569420, -74.118780), // Frente a Estación Molinos
      const LatLng(4.570650, -74.118500),
      const LatLng(4.571850, -74.118220), // Fin del tramo de prueba
    ];

    int indiceActual = 0;

    // Dispara una coordenada automática cada 3 segundos hacia tu servidor
    _viajeSimuladoTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (indiceActual < puntosRuta.length) {
        final coordenada = puntosRuta[indiceActual];

        // Actualizamos el estado interno para que la app sepa dónde está
        _currentLocation = DriverLocationModel(coordenada.latitude, coordenada.longitude);
        notifyListeners();

        try {
          // LLAMADA REAL A TU SERVICIO: Envía el punto al backend
          await _locationService.sendLocation(_currentLocation!, driverId);
          debugPrint("🚗 [Simulador Activo] Enviando coordenada: ${coordenada.latitude}, ${coordenada.longitude} (${indiceActual + 1}/${puntosRuta.length})");
        } catch (e) {
          debugPrint("❌ [Simulador Activo] Error en envío: $e");
        }

        indiceActual++;
      } else {
        debugPrint("🏁 [Simulador Activo] Fin de la ruta. Reiniciando bucle para seguir testeando...");
        indiceActual = 0; // Se reinicia para que el carro no se quede quieto si sigues probando
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _locationSubscription?.cancel();
    _sendTimer?.cancel();
    _serviceStatusSubscription?.cancel();
    _locationSubscription = null;
    _sendTimer = null;
    _viajeSimuladoTimer?.cancel();
    debugPrint("🛑 Simulación de viaje detenida.");
  }
}
