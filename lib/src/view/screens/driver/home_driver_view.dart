import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/driver/driver_view.dart';
import 'package:holi/src/view/widget/button/button_card_home_widget.dart';
import 'package:holi/src/view/widget/card/bottom_move_card.dart';
import 'package:holi/src/view/widget/maps/driver_maps_widget.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/route_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_location_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:holi/src/viewmodels/move/accept_move_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decimal/decimal.dart';

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
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
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
                child: const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/images/profile.jpg"),
                ),
              ),
            ),
          ),

        if (_currentMoveData != null)
          Positioned(
            top: 40,
            left: 5,
            right: 5,
            child: _buildFloatingMoveCard(context, _currentMoveData!),
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
                            : hasMoveData
                                ? _buildMoveDataCard(directionsViewModel.moveData!)
                                : Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      driverViewModel.connectionStatus!.isConnected ? _buildDisconnectCard() : _buildConnectCard(),
                                    ],
                                  ),
                      ),
                    );
                  },
                ),
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

  Widget _buildMoveDataCard(Map<String, dynamic> moveData) {
    String? priceString = moveData['price'];
    Decimal price = Decimal.tryParse(priceString ?? '0') ?? Decimal.zero;

    String originalAddress = moveData['origin'];
    List<String> parts = originalAddress.split(',');
    String reduced = parts.take(3).join(',').trim();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pago con ${moveData['paymentMethod']}',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  )),
                  Expanded(
                    child: Text(
                      formatPrice(price),
                      style: const TextStyle(color: Colors.white, fontSize: 23),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Divider(color: Colors.grey, thickness: 2),
              const SizedBox(height: 8),

              // Origen
              Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${moveData['distance']} (${moveData['estimatedTimeOfArrival']})',
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  reduced,
                                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                ],
              ),

              const SizedBox(height: 8),

              // Destino
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.circle,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${moveData['distanceToDestination']} (${moveData['timeToDestination']})',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        '${moveData['destination']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ))
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              // Tipo de mudanza
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.truckFront,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mudanza ${moveData['typeOfMove']}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundImage: AssetImage("assets/images/profile.jpg"),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${moveData['userName'] ?? "Usuario"}',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),

                  // Temporizador numérico dentro de un círculo
                  Consumer<RouteDriverViewmodel>(
                    builder: (context, viewModel, child) {
                      int remainingTime = viewModel.remainingTime;

                      Color borderColor;

                      if (remainingTime > 10) {
                        borderColor = Colors.green;
                      } else if (remainingTime > 5) {
                        borderColor = Colors.yellow;
                      } else {
                        borderColor = Colors.red;
                      }

                      return TweenAnimationBuilder<Color>(
                          tween: Tween<Color>(
                            begin: borderColor, // Color inicial
                            end: borderColor, // Color final dinámico
                          ),
                          duration: const Duration(microseconds: 500),
                          builder: (context, color, child) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primarycolor, border: Border.all(color: color ?? Colors.green, width: 4)),
                              alignment: Alignment.center,
                              child: Text(
                                '$remainingTime',
                                style: const TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            );
                          });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  final acceptMoveViewModel = Provider.of<AcceptMoveViewmodel>(context, listen: false);
                  final viewModel = Provider.of<RouteDriverViewmodel>(context, listen: false);
                  viewModel.stopTimer();
                  final moveId = int.tryParse(moveData['moveId'].toString()) ?? 0;

                  final result = await acceptMoveViewModel.acceptMove(moveId);

                  if (result) {
                    setState(() {
                      _currentMoveData = moveData;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al aceptar el viaje')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Column(
                  children: [
                    Text('Aceptar viaje', style: TextStyle(color: Colors.white, fontSize: 25)),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingMoveCard(BuildContext context, Map<String, dynamic> moveData) {
    return Card(
      color: Colors.black.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: AppTheme.primarycolor, width: 2),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text(
                  'Viaje Aceptado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Información resumida del viaje
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Vamos por ${moveData['userName'] ?? 'Usuario'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Origen ${moveData['origin']}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.circle, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Destino ${moveData['destination']}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Botón para continuar
            /*  ElevatedButton(
              onPressed: () {
                // Aquí puedes navegar a la siguiente pantalla o realizar otra acción
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primarycolor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const  Text(
                'Iniciar Navegación',
                style: TextStyle(fontSize: 18),
              ),
            ), */
          ],
        ),
      ),
    );
  }
}
