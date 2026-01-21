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
import 'package:holi/src/view/screens/move/driver_information_view.dart';
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
  WebsocketFinishedMoveService? _websocketFinishedMoveService;
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

          if (data['move'] != null) {
            Provider.of<GetDriverLocationViewmodel>(context, listen: false).setMoveData(data['move']);
            print("DATA DENTRO DE GETDRIVERLOCATIONVIEWMODEL $data");
          }
          _moveNotificationUserViewModel.addNotification(data);
          print("DATA DE LA MUDANZA QUE ACEPTA EL CONDUCTOR   $data");

          if (data['move'] != null && data['move']['moveId'] != null) {
            final int moveId = data['move']['moveId'];
            _handleMoveAssigned(moveId);
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
    _websocketFinishedMoveService?.disconnect();
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
              const HistoryMoveView(),
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
                        driverId: _currentActiveMoveData!['driverId'],
                        enrollVehicle: _currentActiveMoveData!['enrollVehicle']?.toString() ?? '',
                        driverImageUrl: _currentActiveMoveData!['driverImageUrl']?.toString() ?? '',
                        vehicleImageUrl: 'assets/images/vehicle.png', 
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
          Positioned(
            left: 16,
            right: 16,
            bottom: 30,
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
      bottomNavigationBar: currentPageIndex == 0
          ? Consumer<GetDriverLocationViewmodel>(
              builder: (context, driverVM, _) {
                final moveData = driverVM.moveData;

                if (driverIsAssigned) {
                  return const SizedBox.shrink();
                }
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

  void _handleMoveAssigned(int moveId) {
    if (_websocketFinishedMoveService == null) {
      _websocketFinishedMoveService = WebsocketFinishedMoveService(
          onMessage: (paymentData) {
            debugPrint("💰 Mensaje de pago recibido: $paymentData");

            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentView(paymentData: paymentData)));
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
    required Widget titleWidget,
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
              Expanded(child: titleWidget),
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
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Colors.grey;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.calculatedPrice!,
                 // formatPriceToHundreds(widget.calculatedPrice ?? '0'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: primaryTextColor,
                  ),
                  textAlign: TextAlign.end,
                ),
                // Divisa (más pequeña y secundaria)
                const Text(
                  ' COP ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila Tamaño
                    Row(children: [
                      Icon(Icons.apartment_rounded, color: secondaryTextColor, size: 20),
                      SizedBox(width: 4),
                      Text(
                        "Tamaño mudanza",
                        style: TextStyle(
                          fontSize: 15,
                          color: secondaryTextColor,
                        ),
                      ),
                    ]),
                    SizedBox(height: 12),
                    // Fila Tiempo
                    Row(
                      children: [
                        Icon(Icons.schedule, color: secondaryTextColor, size: 20),
                        SizedBox(width: 4),
                        Text(
                          "Tiempo estimado",
                          style: TextStyle(
                            fontSize: 15,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.route, color: secondaryTextColor, size: 20),
                        SizedBox(width: 4),
                        Text(
                          "Distancia",
                          style: TextStyle(
                            fontSize: 15,
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
                    Text(widget.typeOfMove?.displayName ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryTextColor)),
                    const SizedBox(height: 12),
                    Text("${widget.estimatedTime}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryTextColor)),
                    const SizedBox(height: 12),
                    Text("${widget.distanceKm}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryTextColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildSettingMethodPay(
              icon: Icons.monetization_on,
              titleWidget: Text.rich(
                TextSpan(
                  text: 'Mi forma de pago es con ',
                  style: const TextStyle(fontSize: 15, color: secondaryTextColor),
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
        ],
      ),
    );
  }
}
