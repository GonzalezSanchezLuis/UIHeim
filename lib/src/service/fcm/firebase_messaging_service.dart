import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
class FirebaseMessagingService {
  /// Llamado cuando llega un mensaje FCM en foreground (sin tap).
  static Function(Map<String, dynamic> data)? onNewTripData;

  /// Llamado cuando el usuario toca la notificación local.
  static Function(Map<String, dynamic> data)? onNotificationOpened;

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const String _soundName = 'audiologoheim';
  static const String _channelId = 'heim_trips_channel_v1';

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

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = Map<String, dynamic>.from(jsonDecode(response.payload!) as Map);
          onNotificationOpened?.call(data);
        }
      },
    );

    _createNotificationChannel();
  }

  Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      'Cargas Nuevas',
      channelDescription: 'Canal exclusivo para ofertas de fletes comerciales',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      icon: 'ic_notification',
      sound: RawResourceAndroidNotificationSound(_soundName),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Nueva carga disponible',
      message.notification?.body ?? 'Revisa los detalles del flete ahora.',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      'Cargas Nuevas',
      description: 'Canal exclusivo para ofertas de fletes comerciales',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_soundName),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔕 Notificación en background');
  print('Título: ${message.notification?.title}');
  print('Mensaje: ${message.notification?.body}');
  print('📦 Data payload: ${message.data}');
  log('📦 Data payload: ${message.data}');

 
}
