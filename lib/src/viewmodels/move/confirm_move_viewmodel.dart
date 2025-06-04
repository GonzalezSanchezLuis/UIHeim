import 'package:flutter/material.dart';
import 'package:holi/src/service/moves/confirm_move_service.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';


class ConfirmMoveViewModel with ChangeNotifier {
  final ConfirmMoveService _service = ConfirmMoveService();

  String? originAddressText;
  String? destinationAddressText;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get response => _response;

  Future<void> confirmMove({
    required BuildContext context,
    required String calculatedPrice,
    required String distanceKm,
    required String duration,
    required String typeOfMove,
    required String estimatedTime,
    required List<Map<String, double>> route,
    required int userId,
    required LocationViewModel locationViewModel,
    double? destinationLat, 
    double? destinationLng,
    String? originAddressText,
    String? destinationAddressText,
    String? paymentMethod,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
   
      // 🧭 Obtener ubicación actual
      final position = await locationViewModel.updateLocation(context);
      if (position == null) {
        _errorMessage = "No se pudo obtener tu ubicación actual.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final double userLat = position.latitude;
      final double userLng = position.longitude;

  
      final result = await _service.confirmMove(
        calculatedPrice: calculatedPrice,
        distanceKm: distanceKm,
        duration: duration,
        typeOfMove: typeOfMove,
        estimatedTime: estimatedTime,
        route: route,
        userLat: userLat,
        userLng: userLng,
        destinationLat: destinationLat, 
        destinationLng: destinationLng,
        originAddressText: originAddressText,
        destinationAddressText: destinationAddressText,
        paymentMethod: paymentMethod,
        userId: userId
      );

      if (result != null) {
        _response = result;
      } else {
        _errorMessage = "Error al confirmar la mudanza.";
      }
    } catch (e) {
      _errorMessage = "Ocurrió un error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }


    void setAddresses({required String origin, required String destination}) {
    originAddressText = origin;
    destinationAddressText = destination;
    // notifyListeners(); // Para notificar cambios si lo necesitas
  }
}
