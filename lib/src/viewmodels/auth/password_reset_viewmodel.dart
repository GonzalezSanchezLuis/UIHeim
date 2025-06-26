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
      await _passwordResertService.sendResetEmail(email);
      _successMessage = "Se ha enviado un correo de recuperación.";
    } catch (e) {
      _errorMessage = "Error al enviar el correo de recuperación.";
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
