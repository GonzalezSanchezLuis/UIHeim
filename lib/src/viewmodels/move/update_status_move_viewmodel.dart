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
    final statusString = await _updateStatusMoveService.getStatus(moveId);
    return StatusOfTheMove.values.firstWhere((e) => e.name == statusString,orElse: () => throw Exception("Estado desconocido recibido: $statusString"));
  }

}
