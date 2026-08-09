import 'package:flutter/material.dart';
import 'package:holi/src/model/travel/history_moving_model.dart';
import 'package:holi/src/service/travel/driver_moving_history_service.dart';
import 'package:holi/src/service/travel/user_moving_history_service.dart';

class MovingHistoryViewmodel extends ChangeNotifier {
  DriverMovingHistoryService driverMovingHistoryService = DriverMovingHistoryService();
  UserMovingHistoryService userMovingHistoryService = UserMovingHistoryService();

  List<HistoryMovingModel>? movingHistory;
  bool isLoading = false;
  String? errorMessage;

  int? _currentUserId;
  String? _currentUserRole;

  Future<void> loadMoveHistory(int id, String role) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      List<Map<String, dynamic>> rawData;
      _currentUserId = id;
      _currentUserRole = role;

      if (role.toUpperCase() == "DRIVER") {
        rawData = await driverMovingHistoryService.loadDriverMoveHistory(id);
      } else if (role.toUpperCase() == "USER") {
        rawData = await userMovingHistoryService.loadUserMoveHistory(id);
      } else {
        throw Exception("Role desconocido: $role");
      }

      movingHistory = rawData.map((json) => HistoryMovingModel.fromJson(json)).toList();

      print("HISTORIAL DE MUDANZA $movingHistory");
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Cancela un viaje específico.
  /// Utiliza el rol del usuario para determinar qué servicio de cancelación llamar.
  Future<bool> cancelMove(int moveId) async {
    if (_currentUserId == null || _currentUserRole == null) {
      errorMessage = "No se pudo determinar el usuario o el rol para cancelar el viaje.";
      notifyListeners();
      return false;
    }

    errorMessage = null;
    try {
      bool success = false;
      if (_currentUserRole!.toUpperCase() == "USER") {
        success = await userMovingHistoryService.cancelMove(moveId, _currentUserId!);
      } else if (_currentUserRole!.toUpperCase() == "DRIVER") {
        // TODO: Implementar la lógica de cancelación para conductores si es necesario
        errorMessage = "La cancelación de viajes para conductores no está implementada.";
        success = false;
      }

      if (success) {
        // Recarga sin activar isLoading para no desmontar la UI (Flushbar).
        await _refreshHistoryQuietly();
      } else {
        errorMessage = errorMessage ?? "No se pudo cancelar el viaje.";
        notifyListeners();
      }
      return success;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _refreshHistoryQuietly() async {
    if (_currentUserId == null || _currentUserRole == null) return;

    try {
      List<Map<String, dynamic>> rawData;
      if (_currentUserRole!.toUpperCase() == "DRIVER") {
        rawData = await driverMovingHistoryService.loadDriverMoveHistory(_currentUserId!);
      } else {
        rawData = await userMovingHistoryService.loadUserMoveHistory(_currentUserId!);
      }
      movingHistory = rawData.map((json) => HistoryMovingModel.fromJson(json)).toList();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
