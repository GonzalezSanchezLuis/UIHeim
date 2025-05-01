import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // MANEJO EN BACKGROUND
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('🔕 Notificación en background');
    print('Título: ${message.notification?.title}');
    print('Mensaje: ${message.notification?.body}');
  }

  //general initialization
  static Future<void> init() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Notificación en foreground');
      print('Título: ${message.notification?.title}');
      print('Mensaje: ${message.notification?.body}');
    });

    final token = await _firebaseMessaging.getToken();
    print('📱 Token FCM: $token');
  }
}
