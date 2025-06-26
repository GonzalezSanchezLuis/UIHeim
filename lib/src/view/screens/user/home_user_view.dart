import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/move/history_move_view.dart';
import 'package:holi/src/view/screens/move/select_payment_method_view.dart';
import 'package:holi/src/view/screens/user/user_view.dart';
import 'package:holi/src/view/widget/button/button_card_home_widget.dart';
import 'package:holi/src/view/widget/maps/user_maps_widget.dart';
import 'package:holi/src/view/widget/user/build_waiting_widget.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:holi/src/viewmodels/user/get_driver_location_viewmodel.dart';
import 'package:holi/src/viewmodels/user/route_user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeUserView extends StatefulWidget {
  final String? calculatedPrice;
  final String? distanceKm;
  final String? duration;
  final String? typeOfMove;
  final String? estimatedTime;
  final List<LatLng>? route;
  final double? destinationLat;
  final double? destinationLng;
  final LatLng? origin;
  final LatLng? destination;

  const HomeUserView({
    super.key,
    this.calculatedPrice,
    this.distanceKm,
    this.duration,
    this.typeOfMove,
    this.estimatedTime,
    this.route,
    this.destinationLat,
    this.destinationLng,
    this.origin,
    this.destination,
  });

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUserView> {
  List<LatLng> _realRoute = [];
  String _selectedPaymentMethod = 'Nequi';

  final LocationViewModel locationViewModel = LocationViewModel();
  int currentPageIndex = 0;
  bool showPriceModal = false;
  bool showHomeButtons = true;
  bool isWaitingForDriver = false;
  LatLng? userCurrentLocation;
  int? userId;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: showPriceModal
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                  //   child: ButtonCalculatePrice(),

                     child:ConfirmButton(
                        typeOfMove: widget.typeOfMove ?? '',
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
            )
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold);
                    }
                    return const TextStyle(color: Color(0xFF8E8E8E));
                  },
                ),
              ),
              child: NavigationBar(
                backgroundColor: Colors.black,
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                indicatorColor: Colors.amber,
                selectedIndex: currentPageIndex,
                destinations: const <Widget>[
                  NavigationDestination(
                    selectedIcon: Icon(Icons.home_filled, color: Colors.black),
                    icon: Icon(Icons.home_filled, color: Color(0xFF8E8E8E)),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.history_toggle_off_rounded, color: Colors.black,),
                    icon: Icon(Icons.history_toggle_off_rounded, color: Color(0xFF8E8E8E)),
                    label: 'Historial',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.supervised_user_circle, color: Colors.black),
                    icon: Icon(Icons.supervised_user_circle, color: Color(0xFF8E8E8E)),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          _buildHomePage(context),
          const HistoryMove(),
          const User(),
        ],
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final LatLng origin = (widget.route != null && widget.route!.isNotEmpty) ? widget.route!.first : const LatLng(3.3784759685695906, -72.95412998954771);
    final LatLng destination = (widget.route != null && widget.route!.isNotEmpty) ? widget.route!.last : const LatLng(3.3784759685695906, -72.95412998954771);

    return LayoutBuilder(
      builder: (context, constraints) {
        final getDriverLocation = Provider.of<GetDriverLocationViewmodel>(context);
        final routeVM = Provider.of<RouteUserViewmodel>(context, listen: false);
        double containerHeight;

        if (showPriceModal) {
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
            UserMapWidget(
              route: _realRoute,
              origin: origin,
              destination: destination,
              driverLocation: getDriverLocation.driverLocation,
              onLocationUpdated: (location) => {
                setState(() {
                  userCurrentLocation = location;
                })
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      if (showHomeButtons) ...[
                        const Center(
                          child: Text(
                            "¿Listo para un nuevo hogar?",
                            style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const ButtonCalculatePrice(),
                        /*     ElevatedButton(
                          
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  PaymentWebViewScreen(paymentUrl: paymentUrl,)));
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
                      backgroundColor: const Color(0xFFFFBC11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "¡Comencemos!",
                      style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),*/

                        const SizedBox(height: 10),
                        //  const ScheduleMoveWidget(),
                      ],
                      if (showPriceModal) ...[_buildDataMove()],
                      if (isWaitingForDriver) ...[const WaitingForDriverWidget()]
                    ],
                  ),
                ),
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
    Decimal price = Decimal.tryParse(widget.calculatedPrice ?? '0') ?? Decimal.zero;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatPrice(price),
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
                  Text("${widget.typeOfMove}", style: const TextStyle(fontSize: 17, color: Colors.white)),
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
