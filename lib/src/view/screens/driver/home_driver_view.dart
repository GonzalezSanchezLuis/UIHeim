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
import 'package:holi/src/view/screens/move/history_move_view.dart';
import 'package:holi/src/viewmodels/move/restore_move_viewmodel.dart';
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
import 'package:holi/src/viewmodels/move/websocket/move_notification_driver_viewmodel.dart';
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
    initializeStatusFromPrefs();
    BackgroundLocationService.initService();

    final routeDriverViewmodel = Provider.of<RouteDriverViewmodel>(context, listen: false);
    final moveNotificationVM = Provider.of<MoveNotificationDriverViewmodel>(context, listen: false);

    Future.microtask(() async {
      await _validateGpsAndPermissions(context);
      await _setInitialLocation();
      Provider.of<DriverStatusViewmodel>(context, listen: false).loadDriverStatusViewmodel();
      final driverLocationVM = Provider.of<DriverLocationViewmodel>(context, listen: false);
      final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
      final int driverId = int.tryParse(sessionVM.userId?.toString() ?? '0') ?? 0;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('driverId', driverId);

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
        moveNotificationVM.addNotification(data);
        final moveId = data['moveId'];
        // saveActiveMoveId(moveId);

        /*  setState(() {
          _incomingMoveData = data['move'];
          print("INCOMINGDATA $_incomingMoveData");
          // _incomingMoveData = data;
        }); */
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          Consumer<RestoreMoveViewmodel>(
            builder: (context, restoreMoveVM, _) {
              final restoredMove = restoreMoveVM.activeMove;
              if (restoredMove != null && _currentMoveData == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _currentMoveData = restoredMove;
                  });
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
                top: 50.h,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        Container(
                          width: 1.w,
                          height: 35.h,
                          color: Colors.grey.withOpacity(0.3),
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                        ),
                        Consumer<WalletViewmodel>(builder: (context, walletViewModel, _) {
                          if (walletViewModel.isLoading) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: SizedBox(height: 18.h, width: 18.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                            );
                          }

                          final double available = walletViewModel.wallet?.availableBalance ?? 0.00;
                          final double pending = walletViewModel.wallet?.pendingBalance ?? 0.00;

                          final double totalBalance = available + pending;

                          final String formattedBalance = totalBalance.toStringAsFixed(2);
                          final String raw = formatPriceMovingDetails(formattedBalance);

                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletView())),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 160.w),
                              padding: EdgeInsets.only(left: 8.w, right: 15.w, top: 10.h, bottom: 10.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      raw,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.white70),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
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
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Consumer2<RouteDriverViewmodel, DriverStatusViewmodel>(
                      builder: (context, directionsViewModel, driverViewModel, child) {
                        final bool hasMoveData = directionsViewModel.moveData != null && directionsViewModel.moveData!.isNotEmpty && _currentMoveData == null;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                          height: hasMoveData ? MediaQuery.of(context).size.height * 0.52 : MediaQuery.of(context).size.height * 0.16,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius:  BorderRadius.only(
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
                              padding: EdgeInsets.all(16.w),
                              child: driverViewModel.connectionStatus == null
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ))
                                  : hasMoveData
                                      ? MoveRequestCard(
                                          moveData: directionsViewModel.moveData!,
                                          onMoveAccepted: (data) async {
                                            directionsViewModel.stopTimerAndRemoveRequest();
                                            // await BackgroundLocationService.start();
                                            WakelockPlus.enable();
                                            await ScreenHelper.enableTravelMode();
                                            setState(() {
                                              _currentMoveData = data;
                                            });
                                          },
                                        )
                                      : Column(
                                          children: [
                                            Row(
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
                                            ),
                                          ],
                                        )),
                        );
                      },
                    ),
                  )
                : Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
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
                    )),
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
    return Container(
      height: 70.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child:  ConnectButton(onConnected: (LatLng location) {
            final locationVM = Provider.of<DriverLocationViewmodel>(context, listen: false);
            locationVM.setManualLocation(location);
            final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
            final driverId = int.tryParse(sessionVM.userId?.toString() ?? '0') ?? 0;
            locationVM.startLocationUpdates(driverId);
          })
         ),
        ],
      ),
    );
  }

  Widget _buildDisconnectCard() {
    return Container(
      height: 70.h,
      child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DisconnectButton(),
      ],
    )
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
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2)
          ),
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
                  'Ver historial de mudanzas',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),

              SizedBox(height: 15.h),

              // BOTÓN: CERRAR SESIÓN
              OutlinedButton(
                onPressed: () async {
                  final isLoggedOut = await _authService.logout();
                  if (mounted) {
                    Navigator.pop(context);
                    if (isLoggedOut) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginView()),
                        (route) => false,
                      );
                    }
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
