import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionViewModel extends ChangeNotifier {
  int? userId;
  String? role;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    role = prefs.getString('role');

    debugPrint("🔍 userId cargado: $userId");
    debugPrint("🔍 role cargado: $role");
    _isInitialized = true;
    print("✅ Sesión cargada. userId: $userId,  role: $role, isInitialized: $_isInitialized");

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

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userId = null;
    role = null;
    notifyListeners();
  }
}
