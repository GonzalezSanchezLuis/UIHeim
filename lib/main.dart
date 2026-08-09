import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holi/config/app_config.dart';
import 'package:holi/firebase_options.dart';
import 'package:holi/src/core/analytics/analytics_events.dart';
import 'package:holi/src/core/analytics/analytics_service.dart';
import 'package:holi/src/core/dl/dependency_injection.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/service/fcm/firebase_messaging_service.dart';
import 'package:holi/src/service/location/background_location_service.dart';
import 'package:holi/src/service/travel/accept_move_service.dart';
import 'package:holi/src/service/travel/update_status_move_service.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/viewmodels/travel/restore_move_viewmodel.dart';
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
import 'package:holi/src/viewmodels/travel/accept_move_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/calculate_price_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/confirm_move_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/finish_move_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/moving_history_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/moving_details_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/moving_summary_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/update_status_move_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/websocket/move_notification_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/payment/payment_driver_account_viewmodel.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupAnalytics();
  final analytics = locator<IAnalyticsService>();
  analytics.logEvent(AnalyticsEvents.appOpen);
  // FlutterForegroundTask.initCommunicationPort();
//BackgroundLocationService.initService();

  const String env = kReleaseMode ? 'PRODUCTION' : 'DEVELOPMENT';
  configureApp(env);

  print("🌎 ENVIRONMENT: $currentEnvironment");
  print("🔗 API BASE URL: $apiBaseUrl");

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
    print('📲 Notificación abierta desde background');
    _handleNotificationOpen(message.data);
  });

  FirebaseMessagingService.onNotificationOpened = (data) {
    // Tap sobre notificación local (app en foreground)
    _handleNotificationOpen(Map<String, dynamic>.from(data));
  };

  final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  final Map<String, dynamic>? pendingInitialNotification =
      (initialMessage != null && initialMessage.data.isNotEmpty)
          ? Map<String, dynamic>.from(initialMessage.data)
          : null;

  runApp(ChangeNotifierProvider.value(
    value: sessionVM,
    child: App(
      navigatorKey: navigatorKey,
      pendingInitialNotification: pendingInitialNotification,
    ),
  ));
}

void _handleNotificationOpen(Map<String, dynamic> data) {
  if (data.isEmpty) return;
  print('📦 Datos del viaje (notificación): $data');

  void navigate() {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
      return;
    }

    final role = (data['role'] ?? '').toString().toUpperCase();
    final getDriverLocationViewmodel =
        Provider.of<GetDriverLocationViewmodel>(context, listen: false);
         getDriverLocationViewmodel.setMoveData(data);

    if (role == 'DRIVER') {
      final viewModel = Provider.of<RouteDriverViewmodel>(context, listen: false);
      viewModel.updateMoveData(data);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeDriverView()),
        (route) => false,
      );
    } else {
      // USER (u otro): abrir home del usuario con el payload para trazar la ruta
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeUserView(initialIncomingMoveData: data),
        ),
        (route) => false,
      );
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
}

class App extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Map<String, dynamic>? pendingInitialNotification;

  const App({
    super.key,
    required this.navigatorKey,
    this.pendingInitialNotification,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(
    analytics: FirebaseAnalytics.instance,
  );

  @override
  void initState() {
    super.initState();
    final pending = widget.pendingInitialNotification;
    if (pending != null && pending.isNotEmpty) {
      // Cold start: esperar a que el árbol (Providers + navigator) esté listo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          _handleNotificationOpen(pending);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => RestoreMoveViewmodel()),
            Provider<UpdateStatusMoveService>(create: (context) => UpdateStatusMoveService()),
            ChangeNotifierProvider(create: (context) => ProfileUserViewModel()),
            ChangeNotifierProvider(create: (context) => LocationViewModel()),
            ChangeNotifierProvider(create: (context) => ConfirmMoveViewModel()),
            ChangeNotifierProvider(create: (context) => DriverStatusViewmodel()),
            ChangeNotifierProvider(create: (context) => DriverLocationViewmodel()),
            ChangeNotifierProvider(create: (context) => AcceptMoveViewmodel(AcceptMoveService())),
            ChangeNotifierProvider(create: (context) => GetDriverLocationViewmodel()),
            ChangeNotifierProvider(create: (context) => UpdateStatusMoveViewmodel()),
            ChangeNotifierProvider(create: (context) => AuthViewModel(AuthService())),
            ChangeNotifierProvider(create: (context) => CalculatePriceViewmodel()),
            ChangeNotifierProvider(create: (context) => PasswordResetViewmodel()),
            ChangeNotifierProvider(create: (context) => RouteUserViewmodel()),
            ChangeNotifierProvider(create: (_) => ProfileDriverViewModel()..fetchDriverData()),
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
              navigatorKey: widget.navigatorKey,
              theme: ThemeData(
                textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme).copyWith(
                  bodyMedium: GoogleFonts.ubuntu(textStyle: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
              debugShowCheckedModeBanner: false,
              navigatorObservers: [_observer],
              home: const WrapperView()),
        );
      },
    );
  }
}
