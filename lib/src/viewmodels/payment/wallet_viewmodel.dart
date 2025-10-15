import 'package:flutter/material.dart';
import 'package:holi/src/model/payment/wallet_model.dart';
import 'package:holi/src/service/payment/wallet_service.dart';

class WalletViewmodel extends ChangeNotifier {
  final WalletService _earningService = WalletService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WalletModel? _wallet;
  WalletModel? get wallet => _wallet;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadWallet(int driverId) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      final result = await _earningService.fetchEarning(driverId);

      if (result != null) {
        _wallet = result;
        print("data $result");
      } else {
        _errorMessage = "No se pudieron cargar las ganancias. Intenta de nuevo.";
      }
    } catch (e) {
      _errorMessage = "Error: $e";
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
