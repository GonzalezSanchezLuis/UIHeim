import 'package:flutter/material.dart';
import 'package:holi/src/service/moves/restore_move_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestoreMoveViewmodel extends ChangeNotifier {
  Map<String, dynamic>? _activeMove;
  Map<String, dynamic>? get activeMove => _activeMove;
  final RestoreMoveService _restoreMoveService = RestoreMoveService();

  void restoreMoveIfExists(int? driverId) async {
    if (driverId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final moveId = prefs.getInt("active_moveId");

    if (moveId == null) return;

    try {
      final moveData = await _restoreMoveService.restoreMove(moveId,driverId);
      if (moveData != null) {
        _activeMove = moveData;
        notifyListeners();
        print("Viaje reuperad");
      } else {
        prefs.remove("active_-moveId");
      }
    } catch (e) {
      print("Error al recuperar el viaje ");
    }
  }

  void clearMove() {
    _activeMove = null;
    notifyListeners();
  }
}
