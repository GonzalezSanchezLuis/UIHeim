import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:holi/config/app_config.dart';
import 'package:flutter/material.dart';

typedef MessageCallback = void Function(Map<String, dynamic> data);
final onMoveCancelled = StreamController<String>.broadcast();

class WebsocketUserService {
  StompClient? _client;
  final String userId;
  final MessageCallback onMessage;
  WebsocketUserService({required this.userId, required this.onMessage});

  void connect() {
    if (_client != null && _client!.isActive) {
      debugPrint("⚠️ [WS] Ya existe una conexión WebSocket activa para el usuario $userId.");
      return;
    }

    _client = StompClient(
        config: StompConfig.SockJS(
      url: "$apiBaseUrl/ws",
      onConnect: _onConnect,
      onWebSocketError: (error) => print('WebSocket error: $error'),
      onDisconnect: (_) => print("WebSocket disconnected"),
      onStompError: (frame) => print('STOMP error: ${frame.body}'),

      connectionTimeout: const Duration(seconds: 10),
    ));

    _client!.activate();
  }

 void _onConnect(StompFrame frame) {
    _client!.subscribe(
        destination: '/topic/user/$userId',
        callback: (frame) {
          final data = frame.body;
          if (data != null) {
            onMessage.call(_parseJson(data));
          }
        }       
        );
        print("SOCKET USUARIO CONECTADO EXITOSAMENTE");
  }



  bool get isConnected => _client?.isActive ?? false;


  void disconnect() {
    _client!.deactivate();
  }

  Map<String, dynamic> _parseJson(String body) {
    try {
      return body.isNotEmpty ? Map<String, dynamic>.from(jsonDecode(body)) : {};
    } catch (e) {
      debugPrint("❌ Falló el parseo de JSON en el WebSocket: $e. Body recibido: $body");
      return {};
    }
  }
}
