import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static Function(Map<String, dynamic> data)? onNewTripData;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {}

  // 🔔 Inicializa las notificaciones locales (importante llamarlo al inicio)
  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    onDidReceiveNotificationResponse:
    (NotificationResponse response) {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        onNewTripData?.call(data);
      }
    };
  }

  // 🔔 Mostrar notificación usando flutter_local_notifications
  void showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', // ID único del canal (asegúrate de que sea consistente)
      'your_channel_name', // Nombre del canal visible
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: 'ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'Título por defecto', // Título
      message.notification?.body ?? 'Mensaje por defecto', // Mensaje
      platformChannelSpecifics,
      payload: jsonEncode(message.data), // Puedes usarlo para manejar clicks
    );
  }

  // 🔕 Manejo de notificación en background
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('🔕 Notificación en background');
    print('Título: ${message.notification?.title}');
    print('Mensaje: ${message.notification?.body}');

    if (message.data.isNotEmpty) {
      log('📦 Data payload: ${message.data}');
      if (message.data.containsKey('message')) {
        print('📨 Mensaje adicional: ${message.data['message']}');
      }

    } else {
      log("paylod VACIO");
    }
  }

  // 🔔 Inicialización general de FCM y listeners
  static Future<void> init() async {
    await Firebase.initializeApp();

    // 📬 Configurar handler de mensajes en background
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    // 📬 Configurar listener para mensajes en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Notificación en foreground');
      print('Título: ${message.notification?.title}');
      print('Mensaje: ${message.notification?.body}');

      final data = message.data;
      if (onNewTripData != null) {
        onNewTripData!(data);
      }

      FirebaseMessagingService service = FirebaseMessagingService();
      service.showNotification(message);
    });

    // 🔑 Obtener y mostrar el token FCM
    final token = await _firebaseMessaging.getToken();
    print('📱 Token FCM: $token');
  }
}
