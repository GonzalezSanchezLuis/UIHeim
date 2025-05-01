import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holi/src/service/location/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _error;

  LocationProvider(this._locationService);

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPosition = await _locationService.getCurrentPosition();

      if (_currentPosition != null) {
        _currentAddress = await _locationService.getAddressFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 Future<void> updateLocationFromAddress(String address) async {
    _isLoading = true;
    notifyListeners();

    try {
      final coords = await _locationService.getCoordinatesFromAddress(address);
      if (coords != null) {
        _currentPosition = Position(
          latitude: coords['latitude']!,
          longitude: coords['longitude']!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          // Nuevos parámetros requeridos
          altitudeAccuracy: 0,
          headingAccuracy: 0,
          floor: null,
          isMocked: false,
        );

        _currentAddress = address;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
