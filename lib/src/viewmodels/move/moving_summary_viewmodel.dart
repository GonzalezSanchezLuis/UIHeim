import 'package:flutter/material.dart';
import 'package:holi/src/model/move/moving_summary_model.dart';
import 'package:holi/src/service/moves/moving%20_summary_service.dart';

class MovingSummaryViewmodel extends ChangeNotifier {
  final MovingSummaryService _movingSummaryService = MovingSummaryService();
  MovingSummaryModel? movingSummary;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadMovingSummary(int moveId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> rawData = await _movingSummaryService.fetchMovingSummary(moveId);
      movingSummary = MovingSummaryModel.fromJson(rawData);
      
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
