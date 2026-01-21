import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
class FirebaseMessagingService {
  static Function(Map<String, dynamic> data)? onNewTripData;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 🔔 Inicializa todo: notificaciones locales + listeners de FCM
  Future<void> initialize() async {
    await Firebase.initializeApp();
    initializeNotifications();
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Notificación en foreground');
      print('Título: ${message.notification?.title}');
      print('Mensaje: ${message.notification?.body}');
      print(message.data);

      if (onNewTripData != null) {
        onNewTripData!(message.data);
      }

      showNotification(message);
    });

    final token = await _firebaseMessaging.getToken();
    print('📱 Token FCM: $token');
  }

  // 🔔 Inicializa las notificaciones locales
  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_notification'); 

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          onNewTripData?.call(data);
        }
      },
    );

    _createNotificationChannel();
  }

  // 🔔 Mostrar notificación local
  void showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      icon: 'ic_notification', 
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'Título por defecto',
      message.notification?.body ?? 'Mensaje por defecto',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

 

  // 🔧 Crear canal de notificación
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id',
      'Viajes nuevos',
      description: 'Canal para notificaciones de nuevos viajes',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }
}
 // 🔕 Notificación en background
  @pragma('vm:entry-point')
   Future<void> _backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('🔕 Notificación en background');
    print('Título: ${message.notification?.title}');
    print('Mensaje: ${message.notification?.body}');
    log('📦 Data payload: ${message.data}');
  }
