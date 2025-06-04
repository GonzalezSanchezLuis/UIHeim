import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:holi/src/model/fcm/fcm_token_request_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FcmViewModel extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = "";
  bool _notificationPermissionGranted = false;

  Future<void> initFcm(int userId, String type) async {
    isLoading = true;
    notifyListeners();

    try {
      await Firebase.initializeApp();

      await _requestNotificationPermissions();
      if (!_notificationPermissionGranted) {
        errorMessage = "Permisos de notificación no concedidos";
        return;
      }

      await _handleFcmToken(userId, type);
    } catch (e) {
      errorMessage = 'Excepción: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleFcmToken(int userId, String ownerType) async {
    try {
      // Obtener el token FCM
      final token = await FirebaseMessaging.instance.getToken();
      print('📱 Token FCM: $token');

      if (token != null) {
        final fcmTokenRequest = FcmTokenRequestModel(token: token, ownerId: userId, ownerType: ownerType);
       await sendTokenToBackend(fcmTokenRequest);
      } else {
        errorMessage = 'Error: El token FCM es nulo.';
      }

      // Escuchar cambios de token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('🔄 Token actualizado: $newToken');

        sendTokenToBackend(FcmTokenRequestModel(token: newToken, ownerId: userId, ownerType: ownerType));
      });
    } catch (e) {
      errorMessage = 'Error al obtener token: $e';
      rethrow;
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      final NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true, provisional: false, carPlay: true);

      _notificationPermissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized;

      if (!_notificationPermissionGranted) {
        print('Permisos denegados: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('Error al solicitar permisos: $e');
      _notificationPermissionGranted = false;
    }
  }

  Future<void> sendTokenToBackend(FcmTokenRequestModel request) async {
    final url = Uri.parse('https://54d7-2800-484-3981-2300-c37a-2c50-fa4a-d396.ngrok-free.app/api/v1/fcm/register');

    try {
      final jsonBody = jsonEncode(request.toJson());
      log('📤 Enviando token al backend: $jsonBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );



      print('🔁 Respuesta del servidor: ${response.statusCode}');
      print('📝 Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        log('✅ Token enviado al backend correctamente.');
      } else {
        errorMessage = 'Error al enviar token: ${response.statusCode} - ${response.body}';
        notifyListeners();
      }
    } catch (e) {
      log('🛑 Excepción al enviar token: $e');
      errorMessage = '⚠️ Excepción al enviar token: $e';
      notifyListeners();
    }
  }
}
