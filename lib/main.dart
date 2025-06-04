import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/service/fcm/firebase_messaging_service.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/viewmodels/auth/auth_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:holi/src/viewmodels/move/calculate_price_viewmodel.dart';
import 'package:holi/src/viewmodels/move/confirm_move_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:holi/src/view/screens/welcome/logo_view.dart';
import 'package:holi/src/viewmodels/user/profile_user_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseMessagingService.init();

  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      print(message);
    };
  }

  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 Notificación abierta por el usuario');

    if (message.data.isNotEmpty) {
      print('📦 Datos del viaje: ${message.data}');

      // Espera a que el contexto esté disponible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          final viewModel = Provider.of<DriverStatusViewmodel>(context, listen: false);
          viewModel.updateTripData(message.data);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeDriverView()),
            (route) => false,
          );
        } else {
          print('⚠️ Contexto no disponible aún');
        }
      });
    }
  });

 RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
if (initialMessage != null && initialMessage.data.isNotEmpty) {
  // Espera a que la app esté completamente inicializada
  Future.delayed(Duration.zero, () {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      final viewModel = Provider.of<DriverStatusViewmodel>(context, listen: false);
      viewModel.updateTripData(initialMessage.data);
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeDriverView()),
        (route) => false,
      );
    }
  });

  }

  

  runApp(App(navigatorKey: navigatorKey));
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const App({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
        ChangeNotifierProvider(create: (context) => LocationViewModel()),
        ChangeNotifierProvider(create: (context) => ConfirmMoveViewModel()),
        ChangeNotifierProvider(create: (context) => DriverStatusViewmodel()),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(AuthService()),
        ),
        ChangeNotifierProvider(create: (context) => CalculatePriceViewmodel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme).copyWith(
            bodyMedium: GoogleFonts.ubuntu(textStyle: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const WelcomeView(),
      ),
    );
  }
}
