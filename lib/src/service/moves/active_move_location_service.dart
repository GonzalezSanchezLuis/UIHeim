import 'package:holi/src/service/moves/moving_details_service.dart';
import 'package:holi/src/service/moves/restore_move_service.dart';

/// Obtiene el estado más reciente del viaje (incl. driverLat/driverLng) vía HTTP.
class ActiveMoveLocationService {
  final RestoreMoveService _restoreMoveService = RestoreMoveService();
  final MovingDetailsService _movingDetailsService = MovingDetailsService();

  Future<Map<String, dynamic>?> fetchLatestMoveState({
    required int moveId,
    int? driverId,
  }) async {
    if (driverId != null && driverId > 0) {
      return _restoreMoveService.restoreMove(moveId, driverId);
    }
    try {
      return await _movingDetailsService.fetchMovingDetails(moveId);
    } catch (_) {
      return null;
    }
  }
}
