import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/service/controllers/moves/confirm_move_controller.dart';
import 'package:holi/src/service/fcm/firebase_messaging_service.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:holi/src/view/screens/welcome/logo_view.dart';
import 'package:holi/src/viewmodels/user/profile_user_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseMessagingService.init();

  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      print(message);
    };

  }
  
  await FirebaseMessaging.instance.requestPermission();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ProfileViewModel()), ChangeNotifierProvider(create: (context) => LocationViewModel()), ChangeNotifierProvider(create: (context) => ConfirmMoveController()), ChangeNotifierProvider(create: (context) => DriverStatusViewmodel())],
      child: MaterialApp(
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
