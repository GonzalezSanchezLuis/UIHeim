import 'package:flutter/material.dart';
import 'package:holi/src/model/move/history_moving_model.dart';
import 'package:holi/src/service/moves/history_moving_service.dart';

class HistoryMovingViewmodel extends ChangeNotifier {
  HistoryMovingService historyMovingService = HistoryMovingService();
 List<HistoryMovingModel>? movingHistory;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadMovingHistory(int driverId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> rawData = await historyMovingService.loadMovingHistory(driverId);
      movingHistory = rawData.map((json) => HistoryMovingModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
