import 'package:flutter/material.dart';
import 'package:holi/src/service/moves/moving_details_service.dart';

class MovingDetailsViewmodel extends ChangeNotifier {
  MovingDetailsService movingDetailsService = MovingDetailsService();
  Map<String, dynamic>? movingDetails;
  bool isLoading = false;
  String? errorMessage;

  Future<void> showMovingDetails(int moveId) async {
isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      movingDetails = await movingDetailsService.fetchMovingDetails(moveId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  }

