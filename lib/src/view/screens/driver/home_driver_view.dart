import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/service/websocket/websocket_driver_service.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:holi/src/view/screens/driver/driver_view.dart';
import 'package:holi/src/view/screens/driver/wallet_view.dart';
import 'package:holi/src/view/screens/move/history_move_view.dart';
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

    final routeDriverViewmodel = Provider.of<RouteDriverViewmodel>(context, listen: false);
    final moveNotificationVM = Provider.of<MoveNotificationDriverViewmodel>(context, listen: false);

    // _debugSetStatusForTesting();
    Future.microtask(() async {
      await _validateGpsAndPermissions(context);
      await _setInitialLocation();
      Provider.of<DriverStatusViewmodel>(context, listen: false).loadDriverStatusViewmodel();
      final driverLocationViewModel = Provider.of<DriverLocationViewmodel>(context, listen: false);
      final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
      final int driverId = int.tryParse(sessionVM.userId?.toString() ?? '0') ?? 0;

    if (driverId != 0) {
      final driverLocationVM = Provider.of<DriverLocationViewmodel>(context, listen: false);
      driverLocationVM.startLocationUpdates(driverId);
    }
    });

    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final rawUserId = sessionVM.userId;
    final int driverId = int.tryParse(rawUserId?.toString() ?? '1') ?? 1;
    print("ID $driverId");
  

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletViewmodel>(context, listen: false).loadWallet(driverId);
    });

    _socketService = WebSocketDriverService(
      driverId: driverId,
      onMessage: (data) {
        debugPrint("🧲 Mensaje del backend recibido: $data");
        moveNotificationVM.addNotification(data);

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
          _buildHomeScreen(),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Consumer<ProfileDriverViewModel>(builder: (context, profileViewModel, _) {
      final profile = profileViewModel.profile;

      return Consumer<RouteDriverViewmodel>(builder: (context, directionsViewModel, _) {
        final bool isMoveDataPresent = _currentMoveData != null || _incomingMoveData != null || (directionsViewModel.moveData != null && directionsViewModel.moveData!.isNotEmpty);

        return Stack(
          children: [
            Consumer<RouteDriverViewmodel>(builder: (context, directionsViewmodel, _) {
              return DriverMapWidget(
                driverLocation: _currentDriverLocation,
                route: directionsViewmodel.route,
                driverToOriginRoute: directionsViewmodel.driverToOriginRoute,
              );
            }),
            if (!isMoveDataPresent)
              Positioned(
                top: 50,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primarycolor,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
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
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primarycolor,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: profile.urlAvatarProfile != null && profile.urlAvatarProfile!.isNotEmpty ? NetworkImage(profile.urlAvatarProfile!) : null,
                            child: profile.urlAvatarProfile == null || profile.urlAvatarProfile!.isEmpty ? const Icon(Icons.person, size: 36) : null,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Consumer<WalletViewmodel>(builder: (context, walletViewModel, _) {
                        if (walletViewModel.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          );
                        }

                        final double available = walletViewModel.wallet?.availableBalance ?? 0.00;
                        final double pending = walletViewModel.wallet?.pendingBalance ?? 0.00;

                        final double totalBalance = available + pending;

                        final String formattedBalance = totalBalance.toStringAsFixed(2);
                        final String raw = formatPriceMovingDetails(formattedBalance);

                        return SizedBox(
                          width: 150,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const WalletView()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      raw,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

            if (_currentMoveData != null)
              Positioned(
                top: 40,
                left: 5,
                right: 5,
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
                        // final bool hasMoveData = (_incomingMoveData != null || (directionsViewModel.moveData != null && directionsViewModel.moveData!.isNotEmpty)) && _currentMoveData == null;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: hasMoveData ? MediaQuery.of(context).size.height * 0.47 : MediaQuery.of(context).size.height * 0.16,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: driverViewModel.connectionStatus == null
                                ? const Center(
                                    child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ))

                                : hasMoveData
                                    ? MoveRequestCard(
                                        moveData: directionsViewModel.moveData!,
                                        onMoveAccepted: (data) {
                                          //directionsViewModel.clearMoveData();
                                          directionsViewModel.stopTimerAndRemoveRequest();
                                          setState(() {
                                            _currentMoveData = data;
                                          });
                                        },
                                      )
                                    : 
                                      Column(
                                          children: [
                                            Row(
                                              children: [

                                                if (profileViewModel.isDriverActive) ...[
                                                  Expanded(
                                                    child: driverViewModel.connectionStatus!.isConnected ? _buildDisconnectCard() : _buildConnectCard(),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildHistoryButton(),
                                                ]
                                                
                                                else
                                                  const Expanded(
                                                    child: VerifcationPendingCard(),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        )
                          ),
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
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentDriverLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      log("❌ Error al obtener ubicación inicial: $e");
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConnectButton(onConnected: (LatLng location) {
          setState(() {
            _currentDriverLocation = location;
            _isConnected = true;
            driverStatus = ConnectionStatus.CONNECTED;
          });
        }),
      ],
    );
  }

  Widget _buildDisconnectCard() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DisconnectButton(),
      ],
    );
  }

  Widget _buildHistoryButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.black,
          size: 30,
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
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.50,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: const PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      "Historial de Mudanzas",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryMoveView(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Historial de mudanzas',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cerrar sesion',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
