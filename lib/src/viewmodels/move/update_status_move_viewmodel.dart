import 'package:flutter/material.dart';
import 'package:holi/src/model/move/move_status_update_model.dart';
import 'package:holi/src/service/moves/update_status_move_service.dart';

class UpdateStatusMoveViewmodel extends ChangeNotifier {
  final UpdateStatusMoveService _updateStatusMoveService = UpdateStatusMoveService();

    Future<void> changeStatus({
    required int moveId,
    required int driverId

  }) async {
    notifyListeners();
 
    final payLoad = MoveStatusUpdateModel(
      moveId: moveId,
      driverId: driverId,
      timestamp: DateTime.now(),
    );

    await _updateStatusMoveService.updateMoveStatus(payLoad);
  }

 
}
