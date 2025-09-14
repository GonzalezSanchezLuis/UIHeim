import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/websocket/websocket_driver_service.dart';
import 'package:holi/src/view/screens/driver/driver_view.dart';
import 'package:holi/src/view/widget/button/button_card_home_widget.dart';
import 'package:holi/src/view/widget/card/bottom_move_card.dart';
import 'package:holi/src/view/widget/card/floating_move_card_wrapper.dart';
import 'package:holi/src/view/widget/card/move_request_card.dart';
import 'package:holi/src/view/widget/maps/driver_maps_widget.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/profile_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/route_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_location_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:holi/src/viewmodels/move/websocket/move_notification_viewmodel.dart';
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
  late final MoveNotificationViewmodel _moveNotificationViewModel;
  Map<String, dynamic>? _incomingMoveData;

  @override
  void initState() {
    super.initState();
    initializeStatusFromPrefs();

    // _debugSetStatusForTesting();
    Future.microtask(() async {
      await _validateGpsAndPermissions(context);
      await _setInitialLocation();
      Provider.of<DriverStatusViewmodel>(context, listen: false).loadDriverStatusViewmodel();
      final driverLocationViewModel = Provider.of<DriverLocationViewmodel>(context, listen: false);
      driverLocationViewModel.startLocationUpdates();
    });

    _moveNotificationViewModel = MoveNotificationViewmodel();

    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final driverId = sessionVM.userId?.toString() ?? '0';

    _socketService = WebSocketDriverService(
      driverId: driverId,
      onMessage: (data) {
        debugPrint("🧲 Mensaje del backend recibido: $data");
        _moveNotificationViewModel.addNotification(data);
        setState(() {
          _incomingMoveData = data['move']; 
        });
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

  /* void _debugSetStatusForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driverStatus', ConnectionStatus.CONNECTED.value);
    print("🧪 Estado simulado guardado: ${ConnectionStatus.CONNECTED.value}");
  }*/

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
      return Stack(
        children: [
          Consumer<RouteDriverViewmodel>(builder: (context, directionsViewmodel, _) {
            return DriverMapWidget(
              driverLocation: _currentDriverLocation,
              route: directionsViewmodel.route,
              driverToOriginRoute: directionsViewmodel.driverToOriginRoute,
            );
          }),

          // Botón de perfil con borde dinámico
          if (_currentMoveData == null)
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Driver()),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primarycolor,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: profile.urlAvatarProfile != null && profile.urlAvatarProfile!.isNotEmpty ? NetworkImage(profile.urlAvatarProfile!) : null,
                    child: profile.urlAvatarProfile == null || profile.urlAvatarProfile!.isEmpty ? const Icon(Icons.person, size: 40) : null,
                  ),
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
                  child: SafeArea(child: Consumer2<RouteDriverViewmodel, DriverStatusViewmodel>(
                    builder: (context, directionsViewModel, driverViewModel, child) {
                     final bool hasMoveData = (_incomingMoveData != null || (directionsViewModel.moveData != null && directionsViewModel.moveData!.isNotEmpty)) && _currentMoveData == null;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: hasMoveData ? MediaQuery.of(context).size.height * 0.47 : MediaQuery.of(context).size.height * 0.13,
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
                              ? const Center(child: CircularProgressIndicator())
                               : _incomingMoveData != null
                                  ? MoveRequestCard(
                                      moveData: _incomingMoveData!,
                                      onMoveAccepted: (data) {
                                        setState(() {
                                          _currentMoveData = data; 
                                          _incomingMoveData = null; 
                                        });
                                      },
                                    )
                              : hasMoveData
                                  ? MoveRequestCard(
                                      moveData: directionsViewModel.moveData!,
                                      onMoveAccepted: (data) {
                                        setState(() {
                                          _currentMoveData = data;
                                        });
                                      },
                                    )

                                  //_buildMoveDataCard(directionsViewModel.moveData!)
                                  : Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        driverViewModel.connectionStatus!.isConnected ? _buildDisconnectCard() : _buildConnectCard(),
                                      ],
                                    ),
                        ),
                      );
                    },
                  ),)
                )
              : Positioned(
                  bottom: 0,
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
                  )),
        ],
      );
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
} 
