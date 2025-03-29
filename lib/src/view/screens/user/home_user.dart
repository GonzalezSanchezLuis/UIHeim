import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/view/screens/move/history_move.dart';
import 'package:holi/src/view/screens/move/select_payment_method.dart';
import 'package:holi/src/view/screens/user/user.dart';
import 'package:holi/src/view/widget/button/button_card_home.dart';
import 'package:holi/src/view/widget/maps/user_maps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeUser extends StatefulWidget {
  final String? calculatedPrice;
  final String? distanceKm;
  final String? duration;
  final String? typeOfMove;
  final String? estimatedTime;
  final List<Map<String, double>>? route;

  const HomeUser({
    super.key,
    this.calculatedPrice,
    this.distanceKm,
    this.duration,
    this.typeOfMove,
    this.estimatedTime,
    this.route,
  });

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int currentPageIndex = 0;
  bool showPriceModal = false;
  bool showHomeButtons = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _updateModalState();
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
                      child: ConfrimButton(
                        typeOfMove: widget.typeOfMove ?? '',
                        calculatedPrice: widget.calculatedPrice ?? '',
                        distanceKm: widget.distanceKm ?? '',
                        duration: widget.duration ?? '',
                        estimatedTime: widget.estimatedTime ?? '',
                        route: widget.route ?? [],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  FloatingActionButton(
                    onPressed: () {
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SelectPaymentMethod()));
                    },
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.attach_money, color: Colors.white),
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
                    return  const TextStyle(color: Color(0xFF8E8E8E));
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
    final LatLng origin = (widget.route != null && widget.route!.isNotEmpty) ? LatLng(widget.route!.first['lat']!, widget.route!.first['lng']!) : const LatLng(4.708501911111123, -74.08653488185519);
    final LatLng destination = (widget.route != null && widget.route!.isNotEmpty) ? LatLng(widget.route!.last['lat']!, widget.route!.last['lng']!) : const LatLng(4.6097100, -74.0817500); // Otra coordenada por defecto

    return LayoutBuilder(
      builder: (context, constraints) {
        double containerHeight = constraints.maxHeight * 0.22;
        return Stack(
          children: [
            UserMapWidget(route: widget.route ?? [], origin: origin, destination: destination),
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
                        const ButtonCalculatePrice(),
                        const SizedBox(height: 10),
                      //  const ScheduleMoveWidget(),
                      ],
                      if (showPriceModal) ...[
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Precio centrado arriba
                              Text(
                                "\$ ${widget.calculatedPrice}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),
                              // Fila con dos columnas de información
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Primera columna
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Distancia:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Duración:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Tipo de mudanza:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Hora estimada:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 5),
                                  // Segunda columna con los valores
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${widget.distanceKm}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "${widget.duration}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "${widget.typeOfMove}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "${widget.estimatedTime}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
