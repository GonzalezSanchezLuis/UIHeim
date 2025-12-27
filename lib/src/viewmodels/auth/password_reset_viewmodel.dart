import 'package:flutter/material.dart';
import 'package:holi/src/service/auth/password_resert_service.dart';

class PasswordResetViewmodel extends ChangeNotifier {
  final PasswordResertService _passwordResertService = PasswordResertService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _passwordResertService.sendResetEmail(email);
      _successMessage = response['message'] ?? "Proceso iniciado correctamente";
    } catch (e) {
      _errorMessage = e.toString().contains("error") ? e.toString() : 'Error de conexión con el servidor';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
