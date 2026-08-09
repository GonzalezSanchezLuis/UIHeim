import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/core/helper/screen_helper.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/service/location/background_location_service.dart';
import 'package:holi/src/service/websocket/websocket_driver_service.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:holi/src/view/screens/driver/driver_view.dart';
import 'package:holi/src/view/screens/driver/wallet_view.dart';
import 'package:holi/src/view/screens/travel/history_move_view.dart';
import 'package:holi/src/viewmodels/fcm/fcm_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/restore_move_viewmodel.dart';
import 'package:holi/src/view/widget/button/button_card_home_widget.dart';
import 'package:holi/src/view/widget/card/bottom_move_card.dart';
import 'package:holi/src/view/widget/card/floating_move_card_wrapper.dart';
import 'package:holi/src/view/widget/card/move_request_card.dart';
import 'package:holi/src/view/widget/card/verifcation_pending_card.dart';
import 'package:holi/src/view/widget/maps/driver_maps_widget.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/profile_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/route_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_location_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/websocket/move_notification_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/payment/wallet_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeDriverView extends StatefulWidget {
  const HomeDriverView({super.key});

  @override
  _HomeDriverState createState() => _HomeDriverState();
}

class _HomeDriverState extends State<HomeDriverView> {
  bool showConnectCard = true;
  int currentPageIndex = 0;
  LatLng? _currentDriverLocation;
  LatLng? _destination;
  bool _isConnected = false;
  bool isModalVisible = true;
  LatLng? _currentLatLng;
  bool isLocationLoading = false;
  StreamSubscription<Position>? _locationSubscription;
  ConnectionStatus? driverStatus;
  Map<String, dynamic>? _currentMoveData;
  bool _isMapReady = false;
  late final WebSocketDriverService _socketService;
  Map<String, dynamic>? _incomingMoveData;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initFcm();
    initializeStatusFromPrefs();
    BackgroundLocationService.initService();

    final routeDriverViewmodel = Provider.of<RouteDriverViewmodel>(context, listen: false);
    final moveNotificationVM = Provider.of<MoveNotificationDriverViewmodel>(context, listen: false);

    Future.microtask(() async {
      await _validateGpsAndPermissions(context);
      await _setInitialLocation();
      Provider.of<DriverStatusViewmodel>(context, listen: false).loadDriverStatusViewmodel();
      final sessionVM = Provider.of<SessionViewModel>(context, listen: false);

      final prefs = await SharedPreferences.getInstance();

      // Sincronización userId -> SharedPreferences
      int? userId = prefs.getInt('userId');
      if (userId == null && sessionVM.userId != null) {
        userId = int.tryParse(sessionVM.userId.toString());
        if (userId != null) await prefs.setInt('userId', userId);
      }

      final int driverId = userId ?? (int.tryParse(sessionVM.userId?.toString() ?? '0') ?? 0);
      await prefs.setInt('driverId', driverId);
      if (prefs.getString('role') == null) await prefs.setString('role', 'driver');

      if (driverId != 0) {
        Provider.of<DriverLocationViewmodel>(context, listen: false).startLocationUpdates(driverId);
      }
    });

    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final rawUserId = sessionVM.userId;
    final int driverId = int.tryParse(rawUserId?.toString() ?? '1') ?? 1;
    print("ID $driverId");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletViewmodel>(context, listen: false).loadWallet(driverId);
      Provider.of<RestoreMoveViewmodel>(context, listen: false).restoreMoveIfExists(driverId);
      Provider.of<ProfileDriverViewModel>(context, listen: false).fetchDriverData();
    });

    _socketService = WebSocketDriverService(
      driverId: driverId,
      onMessage: (data) {
        debugPrint("🧲 Mensaje del backend recibido: $data");

        if (_currentMoveData == null) {
          // 1. Extraemos y aplanamos los datos del viaje (maneja si viene envuelto en 'move')
          final Map<String, dynamic> tripDetails = data.containsKey('move') ? {...data, ...Map<String, dynamic>.from(data['move'])} : Map<String, dynamic>.from(data);

          // 2. Agregamos a la lista de notificaciones
          moveNotificationVM.addNotification(data);

          // 3. Notificamos al ViewModel para mostrar el modal de aceptación (MoveRequestCard)
          log("🛎️ [HomeDriverView] Solicitud entrante. Activando modal de aceptación.");
          routeDriverViewmodel.handleIncomingMove(tripDetails);
        }
      },
    );

    _socketService.connect();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _socketService.disconnect();
    super.dispose();
  }

  void _initFcm() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final role = prefs.getString('role');

    if (userId != null && role != null) {
      final fcmViewModel = FcmViewModel();
      await fcmViewModel.initFcm(userId, role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          Consumer2<RestoreMoveViewmodel, DriverStatusViewmodel>(
            builder: (context, restoreMoveVM, driverStatusVM, _) {
              // Buscamos si hay un viaje persistido en cualquiera de los dos ViewModels
              final restoredMove = driverStatusVM.tripData ?? restoreMoveVM.activeMove;

              // Si el viaje se finalizó (tripData es null) pero aún lo vemos en pantalla, limpiamos
              if (driverStatusVM.tripData == null && restoreMoveVM.activeMove == null && _currentMoveData != null) {
                log("🧹 [HomeDriverView] Limpiando UI: El viaje ha finalizado o se ha borrado.");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _currentMoveData = null);
                });
              }

              if (restoredMove != null && _currentMoveData == null) {
                log("🔄 [HomeDriverView] Sincronizando UI con viaje recuperado");

                final Map<String, dynamic> dataToRestore = restoredMove.containsKey('move') ? Map<String, dynamic>.from(restoredMove['move']) : Map<String, dynamic>.from(restoredMove);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _currentMoveData = dataToRestore;
                    });

                    // Importante: Actualizamos el RouteDriverViewmodel para que el mapa dibuje la ruta
                    final routeVM = Provider.of<RouteDriverViewmodel>(context, listen: false);
                    if (routeVM.moveData == null || routeVM.moveData!.isEmpty) {
                      log("🗺️ [HomeDriverView] Re-hidratando mapa con datos de ruta");
                      // Llama al método encargado de procesar la ruta en tu ViewModel
                      routeVM.updateMoveData(dataToRestore);
                    }
                  }
                });
              }

              return _buildHomeContent();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Consumer<ProfileDriverViewModel>(builder: (context, profileViewModel, _) {
      final profile = profileViewModel.profile;

      return Consumer<RouteDriverViewmodel>(builder: (context, directionsViewModel, _) {
        final bool isMoveDataPresent = _currentMoveData != null || _incomingMoveData != null || (directionsViewModel.moveData != null && directionsViewModel.moveData!.isNotEmpty);

        return Stack(
          children: [
            Consumer2<RouteDriverViewmodel, DriverLocationViewmodel>(builder: (context, directionsViewmodel, locationVM, _) {
              LatLng? driverLatLng;
              if (locationVM.currentLocation != null) {
                driverLatLng = LatLng(locationVM.currentLocation!.latitude, locationVM.currentLocation!.longitude);
              }
              return DriverMapWidget(
                driverLocation: driverLatLng,
                route: directionsViewmodel.route,
                driverToOriginRoute: directionsViewmodel.driverToOriginRoute,
              );
            }),
            if (!isMoveDataPresent)
              Positioned(
                top: 20.h,
                left: 15.w,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primarycolor,
                      borderRadius: BorderRadius.circular(40.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Driver()),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primarycolor,
                              width: 2.w,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 26.r,
                            backgroundImage: profile.urlAvatarProfile != null && profile.urlAvatarProfile!.isNotEmpty ? NetworkImage(profile.urlAvatarProfile!) : null,
                            child: profile.urlAvatarProfile == null || profile.urlAvatarProfile!.isEmpty ? Icon(Icons.person, size: 30.sp) : null,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),

            if (_currentMoveData != null)
              Positioned(
                top: 50.h,
                left: 5.w,
                right: 5.w,
                child: FloatingMoveCardWrapper(moveData: _currentMoveData!),
              ),

            // Tarjeta inferior con botones
            _currentMoveData == null
                ? Positioned(
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 0,
                    right: 0,
                    child: Consumer2<RouteDriverViewmodel, DriverStatusViewmodel>(
                      builder: (context, directionsViewModel, driverViewModel, child) {
                        final bool hasMoveData = directionsViewModel.moveData != null && directionsViewModel.moveData!.isNotEmpty && _currentMoveData == null;
                        final double bottomPanelHeightFactor = hasMoveData ? 0.40 : (profileViewModel.isDriverActive ? 0.12 : 0.22);
                        //  final double bottomInset = MediaQuery.paddingOf(context).bottom;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                          height: MediaQuery.of(context).size.height * bottomPanelHeightFactor,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20.r),
                              topLeft: Radius.circular(20.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              child: driverViewModel.connectionStatus == null
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ))
                                  : hasMoveData
                                      ? MoveRequestCard(
                                          moveData: directionsViewModel.moveData!,
                                          onMoveAccepted: (data) async {
                                            log("🤝 [HomeDriverView] Aceptando viaje. Iniciando persistencia...");
                                            directionsViewModel.stopTimerAndRemoveRequest();
                                            await Provider.of<DriverStatusViewmodel>(context, listen: false).acceptTrip(data);

                                            // await BackgroundLocationService.start();
                                            WakelockPlus.enable();
                                            await ScreenHelper.enableTravelMode();
                                            setState(() {
                                              _currentMoveData = data;
                                            });
                                          },
                                        )
                                      : Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            if (profileViewModel.isDriverActive) ...[
                                              Expanded(
                                                child: driverViewModel.connectionStatus!.isConnected ? _buildDisconnectCard() : _buildConnectCard(),
                                              ),
                                              SizedBox(width: 10.w),
                                              _buildHistoryButton(),
                                            ] else
                                              const Expanded(
                                                child: VerifcationPendingCard(),
                                              ),
                                          ],
                                        )),
                        );
                      },
                    ),
                  )
                : Positioned(
                    // Este es el caso cuando hay un viaje activo (_currentMoveData != null)
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 0,
                    right: 0,
                    child: Consumer<SessionViewModel>(
                      builder: (context, sessionVM, child) {
                        debugPrint("🔥 sessionVM.isInitialized: ${sessionVM.isInitialized}");
                        debugPrint("🔥 _currentMoveData: $_currentMoveData");

                        final rawMoveId = _currentMoveData?['moveId'];
                        final moveId = rawMoveId is int ? rawMoveId : int.tryParse(rawMoveId?.toString() ?? '');

                        print("ID DE LA MUDANZA $moveId");
                        final driverId = sessionVM.userId;

                        if (moveId == null || driverId == null) {
                          return Text('Datos inválidos');
                        }

                        return BottomMoveCard(
                          moveId: moveId,
                          driverId: driverId,
                        );
                      },
                    ),
                  )
          ],
        );
      });
    });
  }

  Future<void> _validateGpsAndPermissions(BuildContext context) async {
    final allowed = await GpsValidatorService.ensureLocationServiceAndPermission(context);
    if (allowed) {
      // _startLocationUpdates();
    }
  }

  Future<void> _setInitialLocation() async {
    try {
      /*   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("El GPS está apagado físicamente.");
        return;
      } */
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, timeLimit: const Duration(seconds: 8));
      /* setState(() {
        _currentDriverLocation = LatLng(position.latitude, position.longitude);
      }); */
      log("📍 Ubicación real encontrada: ${position.latitude}");
      final locationVM = Provider.of<DriverLocationViewmodel>(context, listen: false);
      locationVM.updateInitialPosition(position);
    } catch (e) {
      log("❌ Error al obtener ubicación inicial: $e");
      log("❌ El satélite no respondió: $e");
    }
  }

  void initializeStatusFromPrefs() async {
    print("🔄 Inicializando estado desde SharedPreferences...");

    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getString('driverStatus');

    log("📦 Estado leído desde SharedPreferences: $savedStatus");

    if (savedStatus != null) {
      final parsedStatus = ConnectionStatus.fromString(savedStatus);
      print("✅ Estado cargado en memoria: $driverStatus");

      setState(() {
        driverStatus = parsedStatus;
      });
    } else {
      print("❌ No se encontró 'driverStatus' en SharedPreferences.");
    }
  }

  Widget _buildConnectCard() {
    return SizedBox(
      height: 50.h,
      child: ConnectButton(onConnected: (LatLng location) {
        final locationVM = Provider.of<DriverLocationViewmodel>(context, listen: false);
        locationVM.setManualLocation(location);
        final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
        final driverId = int.tryParse(sessionVM.userId?.toString() ?? '0') ?? 0;
        locationVM.startLocationUpdates(driverId);
      }),
    );
  }

  Widget _buildDisconnectCard() {
    return SizedBox(
      height: 50.h,
      child: const DisconnectButton(),
    );
  }

  Widget _buildHistoryButton() {
    return Container(
      width: 45.w,
      height: 45.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.black,
          size: 32.sp,
        ),
        onPressed: () {
          _showMoveHistoryModal();
        },
      ),
    );
  }

  void _showMoveHistoryModal() {
    final navigator = Navigator.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 20.h,
            left: 20.w,
            right: 20.w,
            top: 15.h,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicador visual superior (Barrita gris)
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                "Opciones de cuenta",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),

              SizedBox(height: 25.h),

              // BOTÓN: IR AL HISTORIAL
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryMoveView()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white, width: 1.5.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Ver historial de viajes',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),

              SizedBox(height: 15.h),

              // BOTÓN: CERRAR SESIÓN
              OutlinedButton(
                onPressed: () async {
                  navigator.pop();
                  final isLoggedOut = await _authService.logout();
                  if (!mounted) return;
                  if (isLoggedOut) {
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginView()),
                      (route) => false,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red, width: 1.5.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveActiveMoveId(int moveId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_move_id', moveId);
  }
}
