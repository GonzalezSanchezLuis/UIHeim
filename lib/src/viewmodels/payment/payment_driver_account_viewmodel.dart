import 'package:flutter/material.dart';
import 'package:holi/src/model/payment/payment_driver_account_model.dart';
import 'package:holi/src/service/payment/payment_driver_account_service.dart';

class PaymentDriverAccountViewmodel extends ChangeNotifier {
  final PaymentDriverAccountService driverAccountService = PaymentDriverAccountService();
  PaymentDriverAccountModel? _currentAccount;
  bool _isLoading = false;

  PaymentDriverAccountModel? get currentAccount => _currentAccount;
  bool get isLoading => _isLoading;

  Future<bool> savePaymentAccount(PaymentDriverAccountModel accountData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedAccount = await driverAccountService.savePaymentAccount(accountData);

      if (updatedAccount != null) {
        // ÉXITO
        _currentAccount = updatedAccount;
        return true;
      } else {
        // FALLO (ej. error 400, 500 manejado por el Service)
        return false;
      }
    } catch (e) {
      print('Error crítico en el ViewModel al guardar cuenta: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPaymentAccount(int  driverId) async {
    _isLoading = true;
    notifyListeners(); 

    try {
      final account = await driverAccountService.getDriverPaymentAccount(driverId);

      if (account != null) {
        _currentAccount = account;
      } else {
        _currentAccount = null;
      }
    } catch (e) {
      print('Error en VM durante la carga: $e');
      _currentAccount = null;

    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
}
