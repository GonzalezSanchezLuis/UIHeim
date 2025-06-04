import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/driver/driver_view.dart';
import 'package:holi/src/view/widget/button/button_card_home_widget.dart';
import 'package:holi/src/view/widget/maps/driver_maps_widget.dart';
import 'package:holi/src/viewmodels/driver/driver_location_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
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
  bool _isConnected = false;
  bool isModalVisible = true;
  LatLng? _currentLatLng;
  bool isLocationLoading = false;
  StreamSubscription<Position>? _locationSubscription;
  ConnectionStatus? driverStatus;

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
        DriverMapWidget(driverLocation: _currentDriverLocation),
        // Botón de perfil con borde dinámico
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

        // Tarjeta inferior con botones
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Consumer<DriverStatusViewmodel>(
            builder: (context, viewModel, child) {
              final bool hasTripData = viewModel.tripData != null && viewModel.tripData!.isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: hasTripData
                    ? MediaQuery.of(context).size.height * 0.47 // MÁS GRANDE SI HAY DATOS DEL VIAJE
                    : MediaQuery.of(context).size.height * 0.20, // ALTURA ACTUAL
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
                  child: viewModel.connectionStatus == null
                      ? const Center(child: CircularProgressIndicator())
                      : hasTripData
                          ? _buildTripDataCard(viewModel.tripData!) // AQUI MUESTRA DATOS
                          : Column(
                              children: [
                                const SizedBox(height: 20),
                                viewModel.connectionStatus!.isConnected ? _buildDisconnectCard() : _buildConnectCard(),
                              ],
                            ),
                ),
              );
            },
          ),
        ),
      ],
    );
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

  Widget _buildTripDataCard(Map<String, dynamic> tripData) {
    String priceString = tripData['price'];
    Decimal price = Decimal.parse(priceString);

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
                  const  Icon(Icons.monetization_on, color: Colors.white,),
                  const SizedBox(width: 8),
                  Expanded(                   
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        'Pago con ${tripData['paymentMethod']}',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                        
                      ],
                    )
                      
                  ),
                  Expanded(
                    child: Text(
                      formatPrice(price),
                      style: const TextStyle(color: Colors.white, fontSize: 25),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child : Column(
                      children: [
                       Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_circle_up_rounded, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${tripData['distance']} (${tripData['estimatedTimeOfArrival']})',
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${tripData['origin']}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      ],
                    )
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Destino
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const  Icon(Icons.arrow_circle_down_rounded, color: Colors.red,),
                  const SizedBox(width: 8),
                  Expanded(                   
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        '${tripData['distanceToDestination']} (${tripData['timeToDestination']})',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                        Text(
                        '${tripData['destination']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),

                      ],
                    )
                      
                  )
                ],
              ),

              const SizedBox(height: 8),

              // Tipo de mudanza
              Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Mudanza ${tripData['typeOfMove']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Avatar, Nombre, Temporizador numérico
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar y nombre
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage("assets/images/profile.jpg"), // Local asset
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${tripData['userName'] ?? "Usuario"}', // Puedes poner un nombre fijo o desde tripData
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),

                  // Temporizador numérico dentro de un círculo
                 Consumer<DriverStatusViewmodel>(
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
                onPressed: () {
                  // Lógica para aceptar el viaje
                  final viewModel = Provider.of<DriverStatusViewmodel>(context, listen: false);
                  viewModel.stopTimer(); // Detiene el temporizador cuando se acepta el viaje

                  // Aquí puedes agregar cualquier lógica adicional que necesites, por ejemplo:
                  // viewModel.acceptTrip(); o navegación a otra pantalla.
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
                  backgroundColor: AppTheme.confirmationscolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
}
