import 'package:flutter/material.dart';
import 'package:holi/src/model/move/history_moving_model.dart';
import 'package:holi/src/service/moves/driver_moving_history_service.dart';
import 'package:holi/src/service/moves/user_moving_history_service.dart';

class MovingHistoryViewmodel extends ChangeNotifier {
  DriverMovingHistoryService driverMovingHistoryService = DriverMovingHistoryService();
  UserMovingHistoryService userMovingHistoryService = UserMovingHistoryService();

  List<HistoryMovingModel>? movingHistory;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadMoveHistory(int id, String role) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      List<Map<String, dynamic>> rawData;
      

      if (role.toUpperCase() == "DRIVER") {
        rawData = await driverMovingHistoryService.loadDriverMoveHistory(id);
      }else if(role.toUpperCase() == "USER"){
        rawData = await userMovingHistoryService.loadUserMoveHistory(id);
      }else{
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
}
