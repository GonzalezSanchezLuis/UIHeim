import 'package:holi/src/service/location/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationRepository {
  final LocationService _locationService = LocationService();

  Future<Position?> fetchCurrentLocation() async {
    return await _locationService.getCurrentPosition();
  }

  Future<Map<String, double>?> fetchCoordinates(String address) async {
    return await _locationService.getCoordinatesFromAddress(
        address); 
  }

  Future<String?> fetchAddress(double latitude, double longitude) async {
    return await _locationService.getAddressFromCoordinates(
        latitude, longitude);
  }
}
