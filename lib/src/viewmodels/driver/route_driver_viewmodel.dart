import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/utils/to_double.dart';

class RouteDriverViewmodel extends ChangeNotifier {
  List<LatLng> _route = [];
  LatLng? _driverLocation;
  List<LatLng> _driverToOriginRoute = [];
  Map<String, dynamic>? moveData;

  Timer? _timer;
  bool isTimerRunning = false;
  int _remainingTime = 15;

  List<LatLng> get route => _route;
  LatLng? get driverLocation => _driverLocation;
  int get remainingTime => _remainingTime;
  List<LatLng> get driverToOriginRoute => _driverToOriginRoute;

  final String _googleMapsApiKey = 'AIzaSyDB04XLcypB4xsGaRqNPjAGmf1xTegz0Rg';

  Future<void> updateMoveData(Map<String, dynamic> data) async {
    print("Datos recibidos - Conductor----: ${data['driverLat']},${data['driverLng']}");
    final driverLatString = data['driverLat']?.toString();
    final driverLngString = data['driverLng']?.toString();

    final double? driverLat = double.tryParse(driverLatString ?? '');
    final double? driverLng = double.tryParse(driverLngString ?? '');

    print("Origen----: ${data['originLat']},${data['originLng']}");
    print("Destino---: ${data['destinationLat']},${data['destinationLng']}");

    try {
      if (driverLat != null && driverLng != null) {
        _driverLocation = LatLng(driverLat, driverLng);
      }

      if (data['originLat'] != null && data['originLng'] != null && data['destinationLat'] != null && data['destinationLng'] != null) {
        final origin = LatLng(ToDouble(data['originLat']), ToDouble(data['originLng']));
        final destination = LatLng(ToDouble(data['destinationLat']), ToDouble(data['destinationLng']));

        moveData = {'origin': origin, 'destination': destination, ...data};
        _startTimer();
        isTimerRunning = true;
        notifyListeners();

        await Future.wait([_fetchRealRoute(origin, destination), if (_driverLocation != null) _fetchDriverRoute(_driverLocation!, origin)]);
        notifyListeners();
      } else {
        print("Datos de viaje incompletos");
      }
    } catch (e) {
      print('Error al actualizar datos del viaje: $e');
    }
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    _remainingTime = 15;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        timer.cancel();
        handleMoveCancelled();
        isTimerRunning = false;
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    isTimerRunning = false;
    _remainingTime = 15;
    notifyListeners();
  }

  void handleIncomingMove(Map<String, dynamic> data) {
    updateMoveData(data);
  }

  void stopTimerAndRemoveRequest() {
    stopTimer();
    moveData = null;
    notifyListeners();
  }

  void handleMoveCancelled() {
    moveData = null;
    _route = [];
    _driverToOriginRoute = [];
    stopTimer();
    notifyListeners();
  }

  void handleMoveFinished() {
    handleMoveCancelled();
  }

  Future<void> _fetchRealRoute(LatLng origin, LatLng destination) async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();

      PolylineRequest request =
          PolylineRequest(origin: PointLatLng(origin.latitude, origin.longitude), destination: PointLatLng(destination.latitude, destination.longitude), mode: TravelMode.driving, optimizeWaypoints: true, alternatives: false, avoidHighways: false, avoidTolls: false, avoidFerries: true
              // wayPoints: [], // opcional, si quieres agregar paradas intermedias
              );

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _googleMapsApiKey,
        request: request,
      );

      print('Mensaje de error: ${result.errorMessage}');

      if (result.points.isNotEmpty) {
        _route = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
        print('Ruta obtenida con ${_route.length} puntos');
        notifyListeners();
      } else {
        print("No se pudo obtener la ruta: ${result.errorMessage}");
        throw Exception("No se pudo obtener la ruta: ${result.errorMessage}");
      }
    } catch (e) {
      print("Error al obtener ruta: $e");
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _fetchDriverRoute(LatLng driver, LatLng origin) async {
    print('Solicitando ruta conductor -> origen: ${driver.latitude},${driver.longitude} -> ${origin.latitude},${origin.longitude}');

    try {
      PolylinePoints polylinePoints = PolylinePoints();

      PolylineRequest request = PolylineRequest(
        origin: PointLatLng(driver.latitude, driver.longitude),
        destination: PointLatLng(origin.latitude, origin.longitude),
        mode: TravelMode.driving,
        optimizeWaypoints: true,
        alternatives: false,
        avoidHighways: false,
        avoidTolls: false,
        avoidFerries: true,
      );

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _googleMapsApiKey,
        request: request,
      );

      if (result.points.isNotEmpty) {
        _driverToOriginRoute = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
        print('Ruta del conductor al origen obtenida con ${_driverToOriginRoute.length} puntos');
      } else {
        print("No se pudo obtener la ruta del conductor: ${result.errorMessage}");
      }

      notifyListeners();
    } catch (e) {
      print("Error al obtener ruta del conductor: $e");
      rethrow;
    }
  }

 

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
