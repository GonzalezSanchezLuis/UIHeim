import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/extensions/move_type_extension.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/model/payment/payment_model.dart';
import 'package:holi/src/service/websocket/websocket_finished_move_service.dart';
import 'package:holi/src/service/websocket/websocket_user_service.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/move/calculate_price_view.dart';
import 'package:holi/src/view/screens/move/history_move_view.dart';
import 'package:holi/src/view/screens/move/select_payment_method_view.dart';
import 'package:holi/src/view/screens/payment/payment_view.dart';
import 'package:holi/src/view/screens/user/user_view.dart';
import 'package:holi/src/view/widget/button/button_card_home_widget.dart';
import 'package:holi/src/view/widget/card/driver_info_card.dart';
import 'package:holi/src/view/widget/maps/user_maps_widget.dart';
import 'package:holi/src/view/widget/navbar/custom_bottom_navbar.dart';
import 'package:holi/src/view/widget/user/build_waiting_widget.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:holi/src/viewmodels/move/websocket/move_notification_user_viewmodel.dart';
import 'package:holi/src/viewmodels/user/get_driver_location_viewmodel.dart';
import 'package:holi/src/viewmodels/user/route_user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Map<String, dynamic>? initialIncomingMoveData;

  const HomeUserView({super.key, this.calculatedPrice, this.distanceKm, this.duration, this.typeOfMove, this.estimatedTime, this.route, this.destinationLat, this.destinationLng, this.origin, this.destination, this.initialIncomingMoveData});

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUserView> {
  List<LatLng> _realRoute = [];
  String _selectedPaymentMethod = 'Nequi';

  final LocationViewModel locationViewModel = LocationViewModel();
  late final MoveNotificationUserViewmodel _moveNotificationUserViewModel;
  late final WebsocketUserService _websocketUserService;
  late final WebsocketFinishedMoveService _websocketFinishedMoveService;
  int currentPageIndex = 0;
  bool showPriceModal = false;
  bool showHomeButtons = true;
  bool isWaitingForDriver = false;
  LatLng? userCurrentLocation;
  int? userId;
  Map<String, dynamic>? _currentMoveData;
  Map<String, dynamic>? _currentActiveMoveData;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _updateModalState();
    _loadUserId();
    print("✅ initState ejecutado");
    print("ORIGIN desde widget: ${widget.origin}");
    print("DESTINO desde widget: ${widget.destination}");

    if (widget.origin != null && widget.destination != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchRoute();
      });
    }

    if (widget.initialIncomingMoveData != null) {
      _currentActiveMoveData = widget.initialIncomingMoveData;
    }

    _moveNotificationUserViewModel = MoveNotificationUserViewmodel();
    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final userId = sessionVM.userId?.toString() ?? '0';

    _websocketUserService = WebsocketUserService(
        userId: userId,
        onMessage: (data) {
          debugPrint("🧲 Mensaje del backend recibido: $data");
          _moveNotificationUserViewModel.addNotification(data);
          print("DATA DE DATA   $data");

          if (data['move'] != null && data['move']['moveId'] != null) {
            final int moveId = data['move']['moveId'];

            if (_websocketFinishedMoveService == null) {
              _websocketFinishedMoveService = WebsocketFinishedMoveService(
                onMessage: (dataPay){
                  debugPrint("💰 Mensaje de pago recibido: $dataPay");
                    setState(() {
                      // Por ejemplo, aquí podrías actualizar una variable de estado
                      // para mostrar el modal de pago
                      // _paymentData = dataPay;
                    });
                },
                 moveId: moveId);
                 _websocketFinishedMoveService.connect();

            }
          }

          setState(() {
            _currentActiveMoveData = data['move'];
            print("🧲 Datos de _currentActiveMoveData : $_currentActiveMoveData");
          });
        });
    _websocketUserService.connect();
  }

  @override
  void dispose() {
    _websocketUserService.disconnect();
    _websocketFinishedMoveService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool driverIsAssigned = _currentActiveMoveData != null;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            index: currentPageIndex,
            children: [
              //  const  PaymentView(),
              _buildHomePage(context),
              const CalculatePrice(),
              const HistoryMove(),
              const User(),
            ],
          ),

          Consumer<GetDriverLocationViewmodel>(
            builder: (context, driverVM, _) {
              final moveDataFromViewModel = driverVM.moveData;
              print('_currentActiveMoveData (nuestra fuente única): $_currentActiveMoveData');
              if (currentPageIndex == 0 && driverIsAssigned) {
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      decoration: BoxDecoration(color: AppTheme.primarycolor, borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: DriverInfoCard(
                        enrollVehicle: _currentActiveMoveData!['enrollVehicle']?.toString() ?? '',
                        driverImageUrl: _currentActiveMoveData!['driverImageUrl']?.toString() ?? '',
                        vehicleImageUrl: 'assets/images/vehicle.png', // Esta es estática
                        phone: _currentActiveMoveData!['driverPhone']?.toString() ?? '',
                        nameDriver: _currentActiveMoveData!['driverName']?.toString() ?? '',
                        vehicleType: _currentActiveMoveData!['vehicleType']?.toString() ?? '',
                      ),
                      /*  child: DriverInfoCard(moveData: _incomingMoveData!,
                        vehicleImageUrl: 'assets/images/vehicle.png',
                      ), */
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // BottomNavBar flotante para todas las pantallas
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Consumer<GetDriverLocationViewmodel>(
              builder: (context, driverVM, _) {
                final moveData = driverVM.moveData;

                // Ocultar en estos estados (solo en la página de inicio)
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

      // BottomBar para estados especiales (solo en página de inicio)
      bottomNavigationBar: currentPageIndex == 0
          ? Consumer<GetDriverLocationViewmodel>(
              builder: (context, driverVM, _) {
                final moveData = driverVM.moveData;

                if (driverIsAssigned) {
                  return const SizedBox.shrink();
                }

                /* if (moveData != null) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: Container(
                      decoration: const BoxDecoration(
                       color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DriverInfoCard(
                        plate: moveData['enrollVehicle'] ?? 'Sin placa',
                        vehicleType: moveData['vehicleType'] ?? "NPR",
                        driverImageUrl: 'assets/images/driver.jpg',
                        vehicleImageUrl: 'assets/images/npr.png',
                        phone: moveData['driverPhone'] ?? '',
                        nameDriver: moveData['driverName'] ?? '',
                      ),
                    ),
                  );
                } */

                if (showPriceModal) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
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
                              paymentMethod: _selectedPaymentMethod,
                              onConfirmed: () {
                                setState(() {
                                  showPriceModal = false;
                                  isWaitingForDriver = true;
                                });
                                Future.delayed(const Duration(seconds: 10), () {
                                  if (mounted) {
                                    setState(() {
                                      isWaitingForDriver = false;
                                      showPriceModal = true;
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            )
          : null,
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final bool driverIsAssigned = _currentActiveMoveData != null;

    final LatLng origin = (widget.route != null && widget.route!.isNotEmpty) ? widget.route!.first : const LatLng(3.3784759685695906, -72.95412998954771);
    final LatLng destination = (widget.route != null && widget.route!.isNotEmpty) ? widget.route!.last : const LatLng(3.3784759685695906, -72.95412998954771);

    return LayoutBuilder(
      builder: (context, constraints) {
        final routeVM = Provider.of<RouteUserViewmodel>(context, listen: false);
        final double containerHeight;

        if (driverIsAssigned) {
          containerHeight = 0;
        } else if (showPriceModal) {
          containerHeight = constraints.maxHeight * 0.25;
        } else if (showHomeButtons) {
          containerHeight = constraints.maxHeight * 0.28;
        } else if (isWaitingForDriver) {
          containerHeight = constraints.maxHeight * 0.20;
        } else {
          containerHeight = constraints.maxHeight * 0.20;
        }
        return Stack(
          children: [
            Positioned.fill(
              child: Consumer<GetDriverLocationViewmodel>(builder: (context, getDriverLocation, _) {
                return UserMapWidget(
                  route: _realRoute,
                  origin: origin,
                  destination: destination,
                  driverLocation: getDriverLocation.driverLocation,
                  onLocationUpdated: (location) => {
                    setState(() {
                      userCurrentLocation = location;
                    })
                  },
                );
              }),
            ),
            if ((showPriceModal || isWaitingForDriver) && !driverIsAssigned)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Consumer<GetDriverLocationViewmodel>(
                  builder: (context, driverVM, _) {
                    final moveData = driverVM.moveData;

                    return Container(
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // ✅ Oculta la card si hay moveData
                          /* if (showHomeButtons && moveData == null) ...[
                          const Center(
                            child: Text(
                              "¡Listo, quiero mudarme!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const ButtonCalculatePrice(),
                        ], */

                          if (showPriceModal) ...[
                            _buildDataMove(),
                          ],
                          if (isWaitingForDriver) ...[
                            const WaitingForDriverWidget(),
                          ],
                        ],
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

  Future<void> _fetchRoute() async {
    final routeVM = Provider.of<RouteUserViewmodel>(context, listen: false);
    print("ROUTE VM ${routeVM}");

    try {
      await routeVM.fetchRoute(widget.origin!, widget.destination!);
      if (!mounted) return;
      setState(() {
        _realRoute = routeVM.route;
      });
    } catch (e) {
      print("ERROR AL OBTENER LA RUTA DE GOOGLE: $e");
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
    required String title,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.black,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.greenColors,
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
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

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatPriceToHundreds(widget.calculatedPrice ?? '0'),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          const SizedBox(height: 5),
          const Divider(color: Colors.grey, thickness: 2),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.apartment_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 2),
                    Text(
                      "Tamaño mudanza",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ]),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "Tiempo estimado",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.route, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "Distancia",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 180),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.typeOfMove?.displayName ?? '', style: const TextStyle(fontSize: 17, color: Colors.white)),
                  Text("${widget.estimatedTime}", style: const TextStyle(fontSize: 17, color: Colors.white)),
                  Text("${widget.distanceKm}", style: const TextStyle(fontSize: 17, color: Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSettingMethodPay(
            icon: Icons.monetization_on,
            title: "Forma de pago $_selectedPaymentMethod",
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
        ],
      ),
    );
  }
}
