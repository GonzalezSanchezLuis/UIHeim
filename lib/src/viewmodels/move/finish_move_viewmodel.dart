import 'package:flutter/foundation.dart';
import 'package:holi/src/core/enums/status_of_the_move.dart';
import 'package:holi/src/model/move/move_status_update_model.dart';
import 'package:holi/src/service/moves/update_status_move_service.dart';
import 'package:holi/src/viewmodels/driver/route_driver_viewmodel.dart';

class FinishMoveViewmodel extends ChangeNotifier {
  final UpdateStatusMoveService _moveStatusService;
  final RouteDriverViewmodel _routeDriverVM;

  FinishMoveViewmodel(this._moveStatusService, this._routeDriverVM);

  Future<bool> finishMove(int moveId, int driverId) async {
    final DateTime currentTimestamp = DateTime.now();

    final data = MoveStatusUpdateModel(moveId: moveId, driverId: driverId, timestamp: currentTimestamp);

    try {
      await _moveStatusService.updateMoveStatus(data, StatusOfTheMove.MOVE_COMPLETE);
      _routeDriverVM.handleMoveFinished();
      return true;
    } catch (e) {
      print('Error al finalizar la mudanza: $e');
      return false;
    }
  }
} 
