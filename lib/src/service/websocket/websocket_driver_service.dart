import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:holi/config/app_config.dart';

typedef MessageCallback = void Function(Map<String, dynamic> data);

class WebSocketDriverService {
  late StompClient _client;
  final int driverId;
  final MessageCallback onMessage;

  WebSocketDriverService({required this.driverId, required this.onMessage});

  void connect() {
    _client = StompClient(
      config: StompConfig.SockJS(
        url: "$apiBaseUrl/ws",
        onConnect: _onConnect,
        onWebSocketError: (error) => print('WebSocket error: $error'),
        onDisconnect: (_) => print('WebSocket disconnected'),
        onStompError: (frame) => print('STOMP error: ${frame.body}'),
      ),
    );

    _client.activate();
  }

  void _onConnect(StompFrame frame) {
    _client.subscribe(
      destination: '/topic/driver/available',
      callback: (frame) {
        final data = frame.body;
        if (data != null) {
          onMessage.call(_parseJson(data));
        }
      },
    );
    print("SOCKET CONECTADO EXITOSAMENTE");
  }

  void disconnect() {
    _client.deactivate();
  }

  Map<String, dynamic> _parseJson(String body) {
    return body.isNotEmpty ? Map<String, dynamic>.from(jsonDecode(body)) : {};
  }

}
