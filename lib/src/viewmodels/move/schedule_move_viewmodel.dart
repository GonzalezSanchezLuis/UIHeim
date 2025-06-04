import 'package:flutter/material.dart';
import 'package:holi/src/service/moves/schedule_move_controller.dart';

class ScheduleMoveViewModel with ChangeNotifier {
  final ScheduleMoveController _controller = ScheduleMoveController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> registerScheduleMove({
    required String moveType,
    required String originAddress,
    required String destinationAddress,
    required String originLat,
    required String originLng,
    required String destinationLat,
    required String destinationLng,
    required String status,
    required int userId,
    required int driverId,
    required DateTime moveDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _controller.registerScheduleMove(
        moveType: moveType,
        originAddress: originAddress,
        destinationAddress: destinationAddress,
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        status: status,
        userId: userId,
        driverId: driverId,
        moveDate: moveDate,
      );

      if (result != null) {
        _errorMessage = result;
      } else {
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = "Error desconocido: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
