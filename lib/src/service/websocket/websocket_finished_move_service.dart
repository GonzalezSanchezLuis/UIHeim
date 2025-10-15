import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:holi/config/app_config.dart';

typedef MessageCallback = void Function(Map<String, dynamic> data);

class WebsocketFinishedMoveService {
  late StompClient _client;
  final int  moveId;
  final MessageCallback onMessage;

  WebsocketFinishedMoveService({required this.onMessage, required this.moveId});

  void connect() {
    _client = StompClient(
      config: StompConfig.SockJS(
      url: "$apiBaseUrl/ws",
      onConnect: _onConnect,
      onWebSocketError: (error) => print('WebSocket error: $error'),
      onDisconnect: (_) => print("WebSocket disconnected"),
      onStompError: (frame) => print('STOMP error: ${frame.body}'),
    ));

    _client.activate();
  }

  void _onConnect(StompFrame frame) {
    _client.subscribe(
        destination: '/topic/move/finished/$moveId',
        callback: (frame) {
          final paymentInfo = frame.body;
          if (paymentInfo != null) {
            onMessage.call(_parseJson(paymentInfo));
          }
        });
    print("SOCKET DE PAGO CONECTADO EXITOSAMENTE");
  }

  void disconnect() {
    _client.deactivate();
  }

  Map<String, dynamic> _parseJson(String body) {
    return body.isNotEmpty ? Map<String, dynamic>.from(jsonDecode(body)) : {};
  }
}
