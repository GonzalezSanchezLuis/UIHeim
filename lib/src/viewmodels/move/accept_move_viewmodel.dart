import 'package:flutter/foundation.dart';
import 'package:holi/src/service/moves/accept_move_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcceptMoveViewmodel extends ChangeNotifier {
  final AcceptMoveService _acceptMoveService;

  AcceptMoveViewmodel(this._acceptMoveService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;
  int? _driverId;



  Future<bool> acceptMove(int moveId) async {

      final prefs = await SharedPreferences.getInstance();
    _driverId = prefs.getInt('userId');

      if (_driverId == null) {
      print('Error: driverId no disponible');
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _acceptMoveService.acceptMove(moveId, _driverId!);
      _isLoading = false;
      return success;
    } catch (e) {
      _isLoading = false;
      _error.toString();
      notifyListeners();
      return false;
    }
  }
}
