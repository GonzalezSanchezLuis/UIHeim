import 'package:flutter/material.dart';
import 'package:holi/src/service/data/repository/location_repository.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationRepository _locationRepository = LocationRepository();

  String _currentAddress = "Ubicación no disponible";
  Position? _currentPosition;

  String get currentAddress => _currentAddress;
  Position? get currentPosition => _currentPosition;

  Future<Position?> updateLocation() async {
    try {
      Position? position = await _locationRepository.fetchCurrentLocation();

      if (position != null) {
        _currentPosition = position;
        print("📍 Coordenadas obtenidas: ${position.latitude}, ${position.longitude}");

        String? address = await _locationRepository.fetchAddress(position.latitude, position.longitude);
        _currentAddress = address ?? "No se encontró una dirección";

        notifyListeners();
      } else {
        print("❌ Error: No se pudo obtener la posición actual.");
      }
    } catch (e) {
      print("❌ Error al actualizar ubicación: $e");
    }
    return null;
  }
}
