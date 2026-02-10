import 'package:flutter/material.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  bool isLoading = false;
  String? errorMessage;

  AuthViewModel(this._authService);

  /*Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final response = await _authService.login(email, password);
    isLoading = false;

    if (response == null || response['error'] != null) {
      errorMessage = response?['error'] ?? "Error desconocido";
      notifyListeners();
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = response['userId'];
    final role = response['role'];
    
    if (userId is int) {
      await prefs.setInt('userId', userId);
    } else if (userId is String) {
      await prefs.setInt('userId', int.tryParse(userId) ?? 0); // 0 por defecto si falla
    }

    if (role is String) {
      await prefs.setString('role', role); 
    }

    notifyListeners();
    return true;
  }*/

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
   notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response == null || response["error"] != null) {
        errorMessage = response?['error'] ?? "Error desconocido";
        throw Exception(errorMessage);
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = response!['userId'];
      final role = response['role'];

      if (userId is int) {
        await prefs.setInt('userId', userId);
      } else if (userId is String) {
        await prefs.setInt('userId', int.tryParse(userId) ?? 0);
      }

      if (role is String) {
        await prefs.setString('role', role);
      }
    } on Exception catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      throw e;
    } 
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerUser(String name, String email, String password) async {
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

    notifyListeners();
    return true;
  }

  Future<bool> registerDriver(int userId, String phone,  String document, String licenseCategory, licenseNumber, String vehicleType, String enrollVehicle) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.registerDriver(
      userId: userId, 
      phoneNumber: phone,
      document: document, 
      licenseCategory: licenseCategory, 
      licenseNumber: licenseNumber, 
      vehicleType: vehicleType, 
      enrollVehicle: enrollVehicle);
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
      await prefs.clear();
    }
    return success;
  }
}
