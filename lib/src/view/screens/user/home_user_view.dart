import 'dart:async';
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/extensions/move_type_extension.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/model/payment/payment_model.dart';
import 'package:holi/src/service/moves/active_move_location_service.dart';
import 'package:holi/src/service/websocket/websocket_finished_move_service.dart';
import 'package:holi/src/service/websocket/websocket_user_service.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/utils/to_double.dart';
import 'package:holi/src/view/screens/move/driver_information_view.dart';
import 'package:holi/src/view/screens/move/calculate_price_view.dart';
import 'package:holi/src/view/screens/move/history_move_view.dart';
import 'package:holi/src/view/screens/move/select_payment_method_view.dart';
import 'package:holi/src/view/screens/payment/payment_view.dart';
import 'package:holi/src/view/screens/user/user_view.dart';
import 'package:holi/src/view/widget/button/button_card_home_widget.dart';
import 'package:holi/src/view/widget/card/driver_info_card.dart';
import 'package:holi/src/view/widget/card/floating_move_card_user.dart';
import 'package:holi/src/view/widget/maps/user_maps_widget.dart';
import 'package:holi/src/view/widget/navbar/custom_bottom_navbar.dart';
import 'package:holi/src/view/widget/user/build_waiting_widget.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/fcm/fcm_viewmodel.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:holi/src/viewmodels/move/websocket/move_notification_user_viewmodel.dart';
import 'package:holi/src/viewmodels/user/get_driver_location_viewmodel.dart';
import 'package:holi/src/viewmodels/user/route_user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeUserView extends StatefulWidget {
  final String? calculatedPrice;
  final String? distanceKm;
  final String? duration;
  final MoveType? typeOfMove;
  final String? estimatedTime;
  final List<LatLng>? route;
  final double? destinationLat;
  final double? destinationLng;
  final LatLng? origin;
  final LatLng? destination;
  final String? originName;
  final String? destinationName;
  final String? accessType;
  final Map<String, dynamic>? initialIncomingMoveData;

  const HomeUserView({super.key, this.calculatedPrice, this.distanceKm, this.duration, this.typeOfMove, this.estimatedTime, this.route, this.destinationLat, this.destinationLng, this.origin, this.destination, this.originName, this.destinationName, this.accessType, this.initialIncomingMoveData});

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUserView> {
  List<LatLng> _realRoute = [];
  String _selectedPaymentMethod = 'Nequi';

  final LocationViewModel locationViewModel = LocationViewModel();
  late final MoveNotificationUserViewmodel _moveNotificationUserViewModel;
  WebsocketUserService? _websocketUserService;
  WebsocketFinishedMoveService? _websocketFinishedMoveService;
  int currentPageIndex = 0;
  bool showPriceModal = false;
  bool showHomeButtons = true;
  bool isWaitingForDriver = false;
  bool noDriverFound = false;
  bool _paymentViewOpened = false;
  LatLng? userCurrentLocation;
  int? userId;
  Map<String, dynamic>? _currentMoveData;
  Map<String, dynamic>? _currentActiveMoveData;
  LatLng? _tripOrigin;
  LatLng? _tripDestination;
  Timer? _driverLocationPollTimer;
  bool _isPollingDriverLocation = false;
  final ActiveMoveLocationService _activeMoveLocationService = ActiveMoveLocationService();

  @override
  void initState() {
    super.initState();
    _initFcm();
    _checkSession();
    _updateModalState();
    print("✅ initState ejecutado");
    print("ORIGIN desde widget: ${widget.origin}");
    print("DESTINO desde widget: ${widget.destination}");

    _rehydrateActiveTrip();

    if (widget.origin != null && widget.destination != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchRoute();
      });
    }

    if (widget.initialIncomingMoveData != null) {
      _currentActiveMoveData = widget.initialIncomingMoveData;
    }

    _moveNotificationUserViewModel = MoveNotificationUserViewmodel();

    // ✅ Inicializar el socket de forma asíncrona garantizando que el ID esté presente
    Future.microtask(() async {
      await _initializeUserSession();
    });
  }

  Future<void> _initializeUserSession() async {
    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    // 1. Sincronización de seguridad: Si el ID no está en el VM pero sí en disco (post-registro), cargarlo.
    if (sessionVM.userId == null || sessionVM.userId == 0) {
      final storedUserId = prefs.getInt('userId');
      if (storedUserId != null && storedUserId != 0) {
        sessionVM.setUserId(storedUserId);
        debugPrint("💾 [HomeUserView] userId sincronizado desde SharedPreferences: $storedUserId");
      }
    }

    // 2. Extraer el ID asegurando que no sea 0 mediante un parseo robusto
    final int intUserId = (double.tryParse(sessionVM.userId?.toString() ?? '0') ?? 0).toInt();

    if (intUserId != 0) {
      final String userIdStr = intUserId.toString();
      debugPrint("🎯 [HomeUserView] Conectando WebSocket al canal: /topic/user/$userIdStr");

      _websocketUserService = WebsocketUserService(userId: userIdStr, onMessage: _onUserWebSocketMessage);
      _websocketUserService?.connect();

      if (mounted) {
        setState(() => userId = intUserId);
      }
    } else {
      debugPrint("⚠️ [HomeUserView] El userId sigue siendo 0. El WebSocket no se conectará correctamente.");
    }
  }

  @override
  void dispose() {
    print("🔌 [WS USER] Desconectando WebSocket");
    _stopDriverLocationPolling();
    _websocketUserService?.disconnect();
    _websocketFinishedMoveService?.disconnect();
    super.dispose();
  }

  Future<void> _onUserWebSocketMessage(Map<String, dynamic> data) async {
    try {
      print("📩 [WS USER] ¡MENSAJE RECIBIDO! -> ${jsonEncode(data)}");

      final driverVM = Provider.of<GetDriverLocationViewmodel>(context, listen: false);
      driverVM.applyPayload(data);

      final dynamic movePayload = data['move'];
      final bool hasMoveProp = movePayload != null && movePayload is Map;
      final bool hasDirectIds = data['driverId'] != null || data['moveId'] != null;

      if (hasMoveProp || hasDirectIds) {
        print("✅ [WS USER] Procesando asignación de mudanza...");

        // Extracción segura del mapa de datos
        final Map<String, dynamic> incomingMove = hasMoveProp ? Map<String, dynamic>.from(movePayload as Map) : data;

        final Map<String, dynamic> updatedMove = {
          ...(_currentActiveMoveData ?? {}),
          ...incomingMove,
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('active_move_data', jsonEncode(updatedMove));
        await _persistActiveMoveRoute();

        if (!mounted) return;
        setState(() {
          print("🚀 [UI UPDATE] Finalizando búsqueda: isWaitingForDriver = false");
          _currentActiveMoveData = updatedMove;
          isWaitingForDriver = false;
          showPriceModal = false;
          showHomeButtons = false;
        });

        final moveId = updatedMove['moveId'];
        if (moveId != null) {
          final int parsedMoveId = moveId is int ? moveId : int.tryParse(moveId.toString()) ?? 0;
          if (parsedMoveId > 0) {
            _handleMoveAssigned(parsedMoveId);
            _startDriverLocationPolling();
          }
        }
      }

      // También procesamos coordenadas (pueden venir solas o dentro del objeto move)
      final double? lat = ToDouble(data['driverLat'] ?? (hasMoveProp ? movePayload['driverLat'] : null));
      final double? lng = ToDouble(data['driverLng'] ?? (hasMoveProp ? movePayload['driverLng'] : null));

      if (lat != null && lng != null && mounted) {
        print("📍 [WS USER] Ubicación del conductor: $lat, $lng");
        driverVM.updateDriverCoordinates(lat, lng);

        if (isWaitingForDriver) {
          print("🚩 [WS USER] Forzando salida de espera por recepción de GPS.");
          setState(() {
            isWaitingForDriver = false;
            showPriceModal = false;
            showHomeButtons = false;
          });
        }

        final moveId = _currentActiveMoveData?['moveId'];
        if (moveId != null) {
          final int parsedMoveId = moveId is int ? moveId : int.tryParse(moveId.toString()) ?? 0;
          if (parsedMoveId > 0) {
            _handleMoveAssigned(parsedMoveId);
          }
        }
        _startDriverLocationPolling();
      }

      _moveNotificationUserViewModel.addNotification(data);
    } catch (e, stack) {
      print("❌ [WS USER ERROR] Fallo crítico al procesar mensaje: $e");
      print(stack);
    }
  }

  void _startDriverLocationPolling() {
    if (_driverLocationPollTimer != null) return;
    _pollDriverLocation();
    _driverLocationPollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _pollDriverLocation());
    debugPrint("🔄 Polling de ubicación del conductor iniciado");
  }

  void _stopDriverLocationPolling() {
    _driverLocationPollTimer?.cancel();
    _driverLocationPollTimer = null;
  }

  Future<void> _pollDriverLocation() async {
    if (_isPollingDriverLocation || !mounted) return;
    final move = _currentActiveMoveData;
    if (move == null || move.isEmpty) return;

    final moveIdRaw = move['moveId'];
    final moveId = moveIdRaw is int ? moveIdRaw : int.tryParse(moveIdRaw?.toString() ?? '');
    if (moveId == null || moveId <= 0) return;

    final driverIdRaw = move['driverId'];
    final int? driverId = driverIdRaw is int ? driverIdRaw : int.tryParse(driverIdRaw?.toString() ?? '');

    _isPollingDriverLocation = true;
    try {
      final latest = await _activeMoveLocationService.fetchLatestMoveState(
        moveId: moveId,
        driverId: driverId,
      );
      if (!mounted || latest == null) return;

      Provider.of<GetDriverLocationViewmodel>(context, listen: false).setMoveData(latest);

      final lat = latest['driverLat'];
      final lng = latest['driverLng'];
      if (lat != null && lng != null) {
        setState(() {
          _currentActiveMoveData = {...move, 'driverLat': lat, 'driverLng': lng};
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('active_move_data', jsonEncode(_currentActiveMoveData));
      }
    } catch (e) {
      debugPrint("⚠️ Error polling ubicación conductor: $e");
    } finally {
      _isPollingDriverLocation = false;
    }
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
    // Consideramos el viaje asignado solo si tenemos el driverId para evitar el crash de tipos
    final bool driverIsAssigned = _currentActiveMoveData != null && (_currentActiveMoveData!['driverId'] != null || _currentActiveMoveData!['moveId'] != null);

    return PopScope(
      canPop: !driverIsAssigned,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            IndexedStack(
              index: currentPageIndex,
              children: [
                _buildHomePage(context),
                const CalculatePrice(),
                const HistoryMoveView(),
                const User(),
              ],
            ),
            if (currentPageIndex == 0 && !driverIsAssigned && !isWaitingForDriver)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10.h,
                left: 0,
                right: 0,
                child: _buildTopCoverageBanner(),
              ),
            Consumer<GetDriverLocationViewmodel>(
              builder: (context, driverVM, _) {
                if (currentPageIndex == 0 && driverIsAssigned) {
                  return Stack(
                    children: [
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 5.h,
                        left: 5.w,
                        right: 5.w,
                        child: FloatingMoveCardUser(
                          moveData: _currentActiveMoveData!,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 30.h,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primarycolor,
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            padding: EdgeInsets.all(10.w),
                            child: DriverInfoCard(
                              driverId: _currentActiveMoveData!['driverId'] ?? 0,
                              enrollVehicle: _currentActiveMoveData!['enrollVehicle'] ?? '',
                              driverImageUrl: _currentActiveMoveData!['driverImageUrl'] ?? '',
                              vehicleImageUrl: 'assets/images/vehicle.png',
                              phone: _currentActiveMoveData!['driverPhone'] ?? '',
                              nameDriver: _currentActiveMoveData!['driverName'] ?? '',
                              vehicleType: _currentActiveMoveData!['vehicleType'] ?? '',
                              amount: ToDouble(_currentActiveMoveData!['amount'] ?? 0),
                              accountNumber: _currentActiveMoveData!['accountNumber'] ?? '',
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 30.h,
              child: Consumer<GetDriverLocationViewmodel>(
                builder: (context, driverVM, _) {
                  final moveData = driverVM.moveData;
                  if (currentPageIndex == 0 && (driverIsAssigned || showPriceModal || isWaitingForDriver)) {
                    return const SizedBox.shrink();
                  }

                  return CustomBottomNavBar(
                    currentIndex: currentPageIndex,
                    onTap: (index) {
                      setState(() {
                        currentPageIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCoverageBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24).withOpacity(0.9),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(Icons.map_outlined, color: Color(0xFF4ADE80), size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  " Aún somos pocos, gracias por tu paciencia si la búsqueda tarda.",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final bool driverIsAssigned = _currentActiveMoveData != null && (_currentActiveMoveData!['driverId'] != null || _currentActiveMoveData!['moveId'] != null);

    final LatLng origin = _resolveMapOrigin();
    final LatLng destination = _resolveMapDestination();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: UserMapWidget(
                route: _realRoute,
                origin: origin,
                destination: destination,
                driverLocation: context.watch<GetDriverLocationViewmodel>().driverLocation,
                onLocationUpdated: (location) {
                  setState(() {
                    userCurrentLocation = location;
                  });
                },
              ),
            ),
            if ((showPriceModal || isWaitingForDriver) && !driverIsAssigned)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Consumer<GetDriverLocationViewmodel>(
                  builder: (context, driverVM, _) {
                    return SafeArea(
                      top: false,
                      minimum: EdgeInsets.only(bottom: 8.h),
                      child: Container(
                        constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.55),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.r),
                            topLeft: Radius.circular(20.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.r,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (noDriverFound) ...[
                                _buildNoDriverRetryBanner(),
                              ],
                              if (showPriceModal) ...[
                                _buildDataMove(),
                              ],
                              if (isWaitingForDriver) ...[
                                const WaitingForDriverWidget(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNoDriverRetryBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      margin: EdgeInsets.only(bottom: 5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: const Color(0xFF1E1E24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: const Color(0xFF4ADE80), size: 18.sp),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              "No nos rendimos. ¿Buscamos de nuevo?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMoveAssigned(int moveId) {
    if (_websocketFinishedMoveService == null) {
      _websocketFinishedMoveService = WebsocketFinishedMoveService(
          onMessage: (paymentData) {
            if (_paymentViewOpened) return;
            _paymentViewOpened = true;

            if (!mounted) return;
            debugPrint("💰 Mensaje de pago recibido: $paymentData");

            _resetMoveState();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PaymentView(paymentData: paymentData)),
              (route) => false,
            );
            setState(() {
              // Por ejemplo, aquí podrías actualizar una variable de estado
              // para mostrar el modal de pago
              // _paymentData = dataPay;
            });
          },
          moveId: moveId);
      _websocketFinishedMoveService?.connect();
    }
  }

  void _updateModalState() {
    setState(() {
      if (widget.calculatedPrice != null && widget.calculatedPrice!.isNotEmpty) {
        showPriceModal = true;
        showHomeButtons = false;
      } else {
        showPriceModal = false;
        showHomeButtons = true;
      }
    });
  }

  LatLng _resolveMapOrigin() {
    if (widget.route != null && widget.route!.isNotEmpty) return widget.route!.first;
    if (widget.origin != null) return widget.origin!;
    if (_tripOrigin != null) return _tripOrigin!;
    return _latLngFromMoveData(_currentActiveMoveData, isDestination: false) ?? const LatLng(3.3784759685695906, -72.95412998954771);
  }

  LatLng _resolveMapDestination() {
    if (widget.route != null && widget.route!.isNotEmpty) return widget.route!.last;
    if (widget.destination != null) return widget.destination!;
    if (_tripDestination != null) return _tripDestination!;
    return _latLngFromMoveData(_currentActiveMoveData, isDestination: true) ?? const LatLng(3.3784759685695906, -72.95412998954771);
  }

  LatLng? _latLngFromMoveData(Map<String, dynamic>? data, {required bool isDestination}) {
    if (data == null || data.isEmpty) return null;
    final latKey = isDestination ? 'destinationLat' : 'originLat';
    final lngKey = isDestination ? 'destinationLng' : 'originLng';
    final lat = data[latKey];
    final lng = data[lngKey];
    if (lat == null || lng == null) return null;
    return LatLng(ToDouble(lat), ToDouble(lng));
  }

  Future<void> _fetchRoute() async {
    if (widget.origin == null || widget.destination == null) return;
    _tripOrigin = widget.origin;
    _tripDestination = widget.destination;
    await _fetchRouteFromCoords(widget.origin!, widget.destination!);
  }

  Future<void> _fetchRouteFromCoords(LatLng origin, LatLng destination) async {
    final routeVM = Provider.of<RouteUserViewmodel>(context, listen: false);

    try {
      await routeVM.fetchRoute(origin, destination);
      if (!mounted) return;
      setState(() {
        _realRoute = routeVM.route;
        _tripOrigin = origin;
        _tripDestination = destination;
      });
      await _persistActiveMoveRoute();
    } catch (e) {
      debugPrint("ERROR AL OBTENER LA RUTA DE GOOGLE: $e");
    }
  }

  Future<void> _persistActiveMoveRoute() async {
    if (_realRoute.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final encoded = _realRoute.map((p) => [p.latitude, p.longitude]).toList();
    await prefs.setString('active_move_route', jsonEncode(encoded));
  }

  List<LatLng>? _loadPersistedRoute(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) {
            if (e is List && e.length >= 2) {
              return LatLng(ToDouble(e[0]), ToDouble(e[1]));
            }
            return null;
          })
          .whereType<LatLng>()
          .toList();
    } catch (e) {
      debugPrint("Error al leer ruta persistida: $e");
      return null;
    }
  }

  Future<void> _checkSession() async {
    if (!await _isLoggedIn()) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt('userId');

    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
    } else {
      print("⚠️ userId no encontrado en SharedPreferences");
    }
  }

  Widget _buildSettingMethodPay({
    required Widget titleWidget,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.black,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 6.h),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.greenColors,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(child: DefaultTextStyle(style: TextStyle(fontSize: 14.sp), child: titleWidget)),
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataMove() {
    print("🔢 Precio bruto recibido: ${widget.calculatedPrice}");
    String? priceString = widget.calculatedPrice?.replaceAll(",", "");
    Decimal correctedPrice = Decimal.tryParse(priceString ?? '0') ?? Decimal.zero;

    print("🔢 Precio real convertido: $correctedPrice");
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Colors.grey;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.calculatedPrice!,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    color: primaryTextColor,
                  ),
                  textAlign: TextAlign.end,
                ),
                Text(
                  ' COP ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Divider(color: Colors.grey.withOpacity(0.3), thickness: 1),
          SizedBox(height: 7.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.local_shipping_outlined, color: secondaryTextColor, size: 18.sp),
                      SizedBox(width: 2.w),
                      Text(
                        "Tamaño de la carga",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: secondaryTextColor,
                        ),
                      ),
                    ]),
                    SizedBox(height: 5.h),
                    // Fila Tiempo
                    Row(
                      children: [
                        Icon(Icons.schedule, color: secondaryTextColor, size: 18.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "Tiempo estimado",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(Icons.route, color: secondaryTextColor, size: 18.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "Distancia",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.typeOfMove?.displayName ?? '', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: primaryTextColor)),
                    SizedBox(height: 5.h),
                    Text("${widget.estimatedTime}", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: primaryTextColor)),
                    SizedBox(height: 5.h),
                    Text("${widget.distanceKm}", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: primaryTextColor)),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.withOpacity(0.3), thickness: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: _buildSettingMethodPay(
              icon: Icons.money,
              titleWidget: Text.rich(
                TextSpan(
                  text: 'Mi forma de pago es con ',
                  style: TextStyle(fontSize: 13.sp, color: secondaryTextColor),
                  children: <TextSpan>[
                    TextSpan(
                      text: _selectedPaymentMethod,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                final selected = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectPaymentMethod(
                      initialMethod: _selectedPaymentMethod,
                    ),
                  ),
                );
                if (selected != null) {
                  setState(() {
                    _selectedPaymentMethod = selected;
                  });
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: SizedBox(
              height: 45.h,
              width: double.infinity,
              child: ConfirmButton(
                typeOfMove: widget.typeOfMove!,
                calculatedPrice: widget.calculatedPrice ?? '',
                distanceKm: widget.distanceKm ?? '',
                duration: widget.duration ?? '',
                estimatedTime: widget.estimatedTime ?? '',
                route: widget.route ?? [],
                locationViewModel: locationViewModel,
                userId: userId ?? 0,
                destinationLat: widget.destinationLat,
                destinationLng: widget.destinationLng,
                originAddressText: widget.originName,
                destinationAddressText: widget.destinationName,
                paymentMethod: _selectedPaymentMethod,
                accessType: widget.accessType,
                buttonText: noDriverFound ? "Reintentar búsqueda" : "Confirmar y continuar",
                onConfirmed: () {
                  setState(() {
                    showPriceModal = false;
                    isWaitingForDriver = true;
                    noDriverFound = false;
                  });
                  Future.delayed(const Duration(seconds: 30), () {
                    if (mounted && _currentActiveMoveData == null) {
                      setState(() {
                        isWaitingForDriver = false;
                        showPriceModal = true;
                        noDriverFound = true;
                      });
                    }
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Future<void> _rehydrateActiveTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedMoveDataRaw = prefs.getString('active_move_data');
    if (savedMoveDataRaw == null || savedMoveDataRaw.isEmpty) return;

    try {
      final Map<String, dynamic> moveData = Map<String, dynamic>.from(jsonDecode(savedMoveDataRaw) as Map);
      if (moveData.isEmpty) return;

      // Si los datos están incompletos (falta driverId), limpiamos para evitar el crash
      if (moveData['driverId'] == null) {
        debugPrint("⚠️ Datos persistidos corruptos detectados. Limpiando...");
        await _clearPersistedActiveTrip();
        return;
      }

      debugPrint("🚨 Recuperando viaje activo del disco local después de un cierre...");

      final origin = _latLngFromMoveData(moveData, isDestination: false);
      final destination = _latLngFromMoveData(moveData, isDestination: true);

      final persistedRoute = _loadPersistedRoute(prefs.getString('active_move_route'));

      if (!mounted) return;

      Provider.of<GetDriverLocationViewmodel>(context, listen: false).setMoveData(moveData);

      setState(() {
        _currentActiveMoveData = moveData;
        _tripOrigin = origin;
        _tripDestination = destination;
        if (persistedRoute != null && persistedRoute.isNotEmpty) {
          _realRoute = persistedRoute;
        }
        isWaitingForDriver = false;
        showPriceModal = false;
        showHomeButtons = false;
      });

      final moveId = moveData['moveId'];
      if (moveId != null) {
        final int parsedMoveId = moveId is int ? moveId : int.tryParse(moveId.toString()) ?? 0;
        if (parsedMoveId > 0) {
          _handleMoveAssigned(parsedMoveId);
          _startDriverLocationPolling();
        }
      }

      if (origin != null && destination != null && (persistedRoute == null || persistedRoute.isEmpty)) {
        await _fetchRouteFromCoords(origin, destination);
      }
    } catch (e) {
      debugPrint("Error al rehidratar viaje activo: $e");
    }
  }

  void _resetMoveState() {
    _stopDriverLocationPolling();
    _clearPersistedActiveTrip();
    setState(() {
      _currentActiveMoveData = null;
      _currentMoveData = null;
      isWaitingForDriver = false;
      showPriceModal = false;
      showHomeButtons = true;
      _paymentViewOpened = false;
      _realRoute = [];
      _tripOrigin = null;
      _tripDestination = null;

      Provider.of<GetDriverLocationViewmodel>(context, listen: false).clear();
    });
  }

  Future<void> _clearPersistedActiveTrip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_move_data');
    await prefs.remove('active_move_route');
  }
}
