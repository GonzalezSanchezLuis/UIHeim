import 'package:flutter/material.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  bool isLoading = false;
  String? errorMessage;

  AuthViewModel(this._authService);

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      print("📦 [AuthViewModel] Respuesta recibida del service: $response");

      if (response == null || response["error"] != null) {
        errorMessage = response?['error'] ?? "Error desconocido";
        print("❌ [AuthViewModel] Login falló: $errorMessage");
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = response['userId'];
      final token = response['token'];
      final role = response['role'];
      final fullName = response['fullName'];
      final userEmail = response['email'];
      bool hasDiscount = response['hasFirstTripDiscount'] as bool;


      print("👤 [AuthViewModel] Guardando sesión → userId=$userId, fullName=$fullName, email=$userEmail, role=$role, token=$token");

      if (token is! String || token.isEmpty) {
        errorMessage = "El servidor no devolvió un token válido.";
        return false;
      }

      if (role is! String || role.isEmpty) {
        errorMessage = "El servidor no devolvió un rol válido.";
        return false;
      }

      if (userId is int) {
        await prefs.setInt('userId', userId);
      } else if (userId is String) {
        await prefs.setInt('userId', int.tryParse(userId) ?? 0);
      }

      await prefs.setString('role', role);
      await prefs.setString('token', token);
      await prefs.setBool('hasFirstTripDiscount', hasDiscount);
      await prefs.setBool('intro_view', true);

      print("✅ [AuthViewModel] Sesión guardada correctamente");
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      print("❌ [AuthViewModel] Exception: $errorMessage");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerUser(String name, String email, String password, String fcmToken) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.registerUser(name: name, email: email, password: password);
    isLoading = false;

    if (result == null || result["error"] != null) {
      errorMessage = result?["error"] ?? "ERROR DESCONOCIDO";
      notifyListeners();
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    final userId = result['userId'];
    if (userId is int) {
      await prefs.setInt('userId', userId);
    } else if (userId is String) {
      await prefs.setInt('userId', int.parse(userId));
    }

    await prefs.setString('role', result['role'].toString());
    await prefs.setString('token', result['token'].toString());
    await prefs.setBool('hasFirstTripDiscount', true);

    notifyListeners();
    return true;
  }

  Future<bool> registerDriver({
    required int userId,
    required String phone,
    required String document,
    required String licenseCategory,
    required licenseNumber,
    required String vehicleType,
    required String enrollVehicle,
    required String fcmToken,
    required String role,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.registerDriver(userId: userId, phoneNumber: phone, document: document, licenseCategory: licenseCategory, licenseNumber: licenseNumber, vehicleType: vehicleType, enrollVehicle: enrollVehicle, fcmToken: fcmToken, role: role);
    isLoading = false;

    if (result == null || result["error"] != null) {
      errorMessage = result?["error"] ?? "ERROR DESCONOCIDO";
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<bool> logout() async {
    final success = await _authService.logout();
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('role');
      await prefs.remove('token');
    }
    return success;
  }
}
