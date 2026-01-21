import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/status_of_the_move.dart';
import 'package:holi/src/model/move/move_status_update_model.dart';
import 'package:holi/src/service/moves/update_status_move_service.dart';

class UpdateStatusMoveViewmodel extends ChangeNotifier {
  final UpdateStatusMoveService _updateStatusMoveService = UpdateStatusMoveService();

  Future<void> changeStatus({required int moveId, required int driverId,
    required StatusOfTheMove status,
  }) async {
    notifyListeners();

    final payLoad = MoveStatusUpdateModel(
      moveId: moveId,
      driverId: driverId,
      timestamp: DateTime.now(),
    );

    await _updateStatusMoveService.updateMoveStatus(payLoad,status);
  }

  Future<StatusOfTheMove> getCurrentStatus(int moveId) async {
    try {
      final statusString = await _updateStatusMoveService.getStatus(moveId);
      return StatusOfTheMove.values.firstWhere(
        (e) => e.name.toUpperCase() == statusString.toUpperCase(),
        orElse: () {
          debugPrint("⚠️ Alerta: El estado '$statusString' no existe en el Enum.");
          return StatusOfTheMove.ASSIGNED;
        },
      );
    } catch (e) {
      debugPrint("❌ Error en getCurrentStatus: $e");
      return StatusOfTheMove.ASSIGNED;
    }
  }

}
