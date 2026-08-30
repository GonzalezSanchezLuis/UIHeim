import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionViewModel extends ChangeNotifier {
  int? userId;
  String? role;
  String? token;
  bool? hasFirstTripDiscount;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    role = prefs.getString('role');
    token = prefs.getString('token');
    hasFirstTripDiscount = prefs.getBool('hasFirstTripDiscount');

    debugPrint("🔍 userId cargado: $userId");
    debugPrint("🔍 role cargado: $role");
    debugPrint("🔍 token cargado: $token");

    _isInitialized = true;
    print("✅ Sesión cargada. userId: $userId,  role: $role, isInitialized: $_isInitialized , hasFirstTripDiscount: $hasFirstTripDiscount");

    notifyListeners();
  }

  void setUserId(int id) async {
    userId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
    notifyListeners();
  }

  void setRole(String newRole) async {
    role = newRole;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', newRole);
    notifyListeners();
  }

  Future<void> updateSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    userId = userData['userId'];
    role = userData['role'];
    token = userData['token']; 

    if (userId != null) {
      await prefs.setInt('userId', userId!);
    }
    if (role != null) {
      await prefs.setString('role', role!);
    }
    if (token != null) {
      await prefs.setString('token', token!);
    }

    debugPrint("🔄 Sesión actualizada con datos del servidor.");

    notifyListeners();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Solo limpia datos de sesión. NO usar prefs.clear():
    // borraría flags como intro_view y forzaría la introducción otra vez.
    await prefs.remove('userId');
    await prefs.remove('role');
    await prefs.remove('token');
    userId = null;
    role = null;
    token = null;
    notifyListeners();
  }
}
