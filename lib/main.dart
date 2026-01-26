import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:holi/config/app_config.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/service/fcm/firebase_messaging_service.dart';
import 'package:holi/src/service/location/background_location_service.dart';
import 'package:holi/src/service/moves/accept_move_service.dart';
import 'package:holi/src/service/moves/update_status_move_service.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/view/screens/move/restore_move_viewmodel.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';
import 'package:holi/src/view/screens/welcome/wrapper_view.dart';
import 'package:holi/src/viewmodels/auth/auth_viewmodel.dart';
import 'package:holi/src/viewmodels/auth/password_reset_viewmodel.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_data_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/profile_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/route_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_location_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:holi/src/viewmodels/move/accept_move_viewmodel.dart';
import 'package:holi/src/viewmodels/move/calculate_price_viewmodel.dart';
import 'package:holi/src/viewmodels/move/confirm_move_viewmodel.dart';
import 'package:holi/src/viewmodels/move/finish_move_viewmodel.dart';
import 'package:holi/src/viewmodels/move/moving_history_viewmodel.dart';
import 'package:holi/src/viewmodels/move/moving_details_viewmodel.dart';
import 'package:holi/src/viewmodels/move/moving_summary_viewmodel.dart';
import 'package:holi/src/viewmodels/move/update_status_move_viewmodel.dart';
import 'package:holi/src/viewmodels/move/websocket/move_notification_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/payment/payment_driver_account_viewmodel.dart';
import 'package:holi/src/viewmodels/payment/payment_viewmodel.dart';
import 'package:holi/src/viewmodels/payment/wallet_viewmodel.dart';
import 'package:holi/src/viewmodels/user/get_driver_location_viewmodel.dart';
import 'package:holi/src/viewmodels/user/route_user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:holi/src/viewmodels/user/profile_user_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:holi/config/development.dart' as development;
import 'package:holi/config/production.dart' as production;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
 // FlutterForegroundTask.initCommunicationPort();
//BackgroundLocationService.initService();

  const String env = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'DEVELOPMENT');
  configureApp(env);

  final sessionVM = SessionViewModel();
  await sessionVM.loadSession();

  FlutterError.onError = (FlutterErrorDetails details) {
    print('❗️EXCEPCIÓN DE FLUTTER❗️');
    print('EXCEPCIÓN: ${details.exception}');
    print('STACKTRACE:\n${details.stack}');
    FlutterError.dumpErrorToConsole(details);
  };

  await FirebaseMessagingService().initialize();
  await initializeDateFormatting("es", null);

  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      print(message);
    };
  }

  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 Notificación abierta por el conductor');

    if (message.data.isNotEmpty) {
      print('📦 Datos del viaje: ${message.data}');

      final role = message.data['role'];

      // Espera a que el contexto esté disponible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          final viewModel = Provider.of<RouteDriverViewmodel>(context, listen: false);
          final getDriverLocationViewmodel = Provider.of<GetDriverLocationViewmodel>(context, listen: false);
          viewModel.updateMoveData(message.data);
          getDriverLocationViewmodel.setMoveData(message.data);

          if (role == 'DRIVER') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeDriverView()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeUserView()),
              (route) => false,
            );
          }
        } else {
          print('⚠️ Contexto no disponible aún');
        }
      });
    }
  });

  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null && initialMessage.data.isNotEmpty) {
    Future.delayed(Duration.zero, () {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        final viewModel = Provider.of<RouteDriverViewmodel>(context, listen: false);
        viewModel.updateMoveData(initialMessage.data);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeDriverView()),
          (route) => false,
        );
      }
    });
  }

  runApp(ChangeNotifierProvider.value(value: sessionVM, child: App(navigatorKey: navigatorKey)));
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const App({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
         ChangeNotifierProvider(create: (_) => RestoreMoveViewmodel()),
        Provider<UpdateStatusMoveService>(create: (context) => UpdateStatusMoveService()),
        ChangeNotifierProvider(create: (context) => ProfileUserViewModel()),
        ChangeNotifierProvider(create: (context) => LocationViewModel()),
        ChangeNotifierProvider(create: (context) => ConfirmMoveViewModel()),
        ChangeNotifierProvider(create: (context) => DriverStatusViewmodel()),
        // ChangeNotifierProvider(create: (context) => RouteDriverViewmodel()),
        ChangeNotifierProvider(create: (context) => DriverLocationViewmodel()),
        ChangeNotifierProvider(create: (context) => AcceptMoveViewmodel(AcceptMoveService())),
        ChangeNotifierProvider(create: (context) => GetDriverLocationViewmodel()),
        ChangeNotifierProvider(create: (context) => UpdateStatusMoveViewmodel()),
        ChangeNotifierProvider(create: (context) => AuthViewModel(AuthService())),
        ChangeNotifierProvider(create: (context) => CalculatePriceViewmodel()),
        ChangeNotifierProvider(create: (context) => PasswordResetViewmodel()),
        ChangeNotifierProvider(create: (context) => RouteUserViewmodel()),
        ChangeNotifierProvider(create: (_) => ProfileDriverViewModel()..fetchDriverData()),
        ChangeNotifierProvider(create: (context) => PaymentViewmodel()),
        //  ChangeNotifierProvider(create: (context) => MoveNotificationDriverViewmodel()),
        ChangeNotifierProvider(create: (context) => MovingSummaryViewmodel()),
        ChangeNotifierProvider(create: (context) => MovingHistoryViewmodel()),
        ChangeNotifierProvider(create: (context) => MovingDetailsViewmodel()),
        ChangeNotifierProvider(create: (context) => DriverDataViewmodel()),
        ChangeNotifierProvider(create: (context) => WalletViewmodel()),
        ChangeNotifierProvider(create: (context) => MoveNotificationDriverViewmodel()),
        ChangeNotifierProvider(create: (context) => PaymentDriverAccountViewmodel()),
        ChangeNotifierProxyProvider<MoveNotificationDriverViewmodel, RouteDriverViewmodel>(
          create: (context) => RouteDriverViewmodel(),
          update: (context, notificationVM, routeDriverVM) {
            if (notificationVM.latestMoveData != null) {
              routeDriverVM!.handleIncomingMove(notificationVM.latestMoveData!);
              notificationVM.clearLatestMoveData();
            }

            return routeDriverVM!;
          },
        ),
        ChangeNotifierProvider(
            create: (context) => FinishMoveViewmodel(
                  Provider.of<UpdateStatusMoveService>(context, listen: false),
                  Provider.of<RouteDriverViewmodel>(context, listen: false),
                )),
      ],
      child: MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData(
            textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme).copyWith(
              bodyMedium: GoogleFonts.ubuntu(textStyle: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          debugShowCheckedModeBanner: false,
          // home: const WrapperView(),
          home: const WrapperView()),
    );
  }
}
