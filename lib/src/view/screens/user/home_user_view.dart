import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/view/screens/move/history_move_view.dart';
import 'package:holi/src/view/screens/move/select_payment_method_view.dart';
import 'package:holi/src/view/screens/user/user_view.dart';
import 'package:holi/src/view/widget/button/button_card_home_widget.dart';
import 'package:holi/src/view/widget/maps/user_maps_widget.dart';
import 'package:holi/src/view/widget/user/build_waiting_widget.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeUser extends StatefulWidget {
  final String? calculatedPrice;
  final String? distanceKm;
  final String? duration;
  final String? typeOfMove;
  final String? estimatedTime;
  final List<Map<String, double>>? route;
  final double? destinationLat;
  final double? destinationLng;

  const HomeUser({
    super.key,
    this.calculatedPrice,
    this.distanceKm,
    this.duration,
    this.typeOfMove,
    this.estimatedTime,
    this.route,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
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
                      child: ConfirmButton(
                        typeOfMove: widget.typeOfMove ?? '',
                        calculatedPrice: widget.calculatedPrice ?? '',
                        distanceKm: widget.distanceKm ?? '',
                        duration: widget.duration ?? '',
                        estimatedTime: widget.estimatedTime ?? '',
                        route: widget.route ?? [],
                        locationViewModel: locationViewModel,
                        userId: userId!,
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
                    selectedIcon: Icon(Icons.home, color: Colors.black),
                    icon: Icon(Icons.home_outlined, color: Color(0xFF8E8E8E)),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.history, color: Colors.black),
                    icon: Icon(Icons.history, color: Color(0xFF8E8E8E)),
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
    // Si no hay ruta, usamos valores predeterminados
    final LatLng origin = (widget.route != null && widget.route!.isNotEmpty) ? LatLng(widget.route!.first['lat']!, widget.route!.first['lng']!) : const LatLng(3.3784759685695906, -72.95412998954771);
    final LatLng destination = (widget.route != null && widget.route!.isNotEmpty) ? LatLng(widget.route!.last['lat']!, widget.route!.last['lng']!) : const LatLng(3.3784759685695906, -72.95412998954771); // Otra coordenada por defecto

    return LayoutBuilder(
      builder: (context, constraints) {
        double containerHeight = constraints.maxHeight * 0.40;
        return Stack(
          children: [
            UserMapWidget(
              route: widget.route ?? [],
              origin: origin,
              destination: destination,
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
                height: containerHeight,
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
                            "¿Listo para mudarte?",
                            style: TextStyle(color: Colors.white, fontSize: 18.0),
                          ),
                        ),
                        const SizedBox(height: 10),

                        const ButtonCalculatePrice(),
                        const SizedBox(height: 10),
                        //  const ScheduleMoveWidget(),
                      ],
                      if (showPriceModal) ...[
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "\$ ${widget.calculatedPrice}",
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.normal,
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

                              // Fila con dos columnas de información
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.route, color: Colors.white, size: 18),
                                        SizedBox(width: 4),
                                        Text(
                                          "Distancia:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ]),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, color: Colors.white, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            "Duración:",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.local_shipping, color: Colors.white, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            "Tipo de mudanza:",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.schedule, color: Colors.white, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            "Hora estimada:",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 200),
                                  // Segunda columna con los valores
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${widget.distanceKm}",style: const TextStyle(fontSize: 14,color: Colors.white)),
                                      Text("${widget.duration}",style: const TextStyle(fontSize: 14,color: Colors.white,),),
                                      Text("${widget.typeOfMove}",style: const TextStyle(fontSize: 14,color: Colors.white,),),
                                      Text("${widget.estimatedTime}",style: const TextStyle(fontSize: 14,color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              _buildSettingMethodPay(
                                  icon: Icons.monetization_on,
                                  title: "Forma de pago $_selectedPaymentMethod",
                                  onTap: () async {
                                    final selected = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SelectPaymentMethod(
                                                  initialMethod: _selectedPaymentMethod,
                                                )));
                                    if (selected != null) {
                                      setState(() {
                                        _selectedPaymentMethod = selected;
                                      });
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ],
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
                color: Colors.amber,
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
}
