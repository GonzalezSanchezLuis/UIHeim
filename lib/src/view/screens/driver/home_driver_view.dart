import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/gps_validator/gps_validator_service.dart';
import 'package:holi/src/view/screens/driver/driver_view.dart';
import 'package:holi/src/view/widget/button/button_card_home_widget.dart';
import 'package:holi/src/view/widget/maps/driver_maps_widget.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeDriver extends StatefulWidget {
  const HomeDriver({super.key});

  @override
  _HomeDriverState createState() => _HomeDriverState();
}

class _HomeDriverState extends State<HomeDriver> {
  bool showConnectCard = true;
  int currentPageIndex = 0;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) GpsValidatorService.showGpsDialog(context);
    });

    // _debugSetStatusForTesting();
    Future.microtask(() {
      Provider.of<DriverStatusViewmodel>(context, listen: false).loadDriverStatusViewmodel();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _updateDriverLocation(LatLng latLng) {
    print("Nueva ubicación: ${latLng.latitude}, ${latLng.longitude}");
  }

  void toggleModalVisibility() {
    setState(() {
      isModalVisible = !isModalVisible; // Cambiar la visibilidad del modal
    });
  }

  void _debugSetStatusForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driverStatus', ConnectionStatus.CONNECTED.value);
    print("🧪 Estado simulado guardado: ${ConnectionStatus.CONNECTED.value}");
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
    if (driverStatus == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
        DriverMapWidget(
         onUpdateLocation: _updateDriverLocation,
         initialPosition: _currentLatLng, 
          isConnected: _isConnected,
        ),

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showConnectCard ? MediaQuery.of(context).size.height * 0.12 : MediaQuery.of(context).size.height * 0.20,
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
              child: Consumer<DriverStatusViewmodel>(
                builder: (context, viewModel, child) {
                  return Column(
                    children: [
                      if (viewModel.connectionStatus != null)
                        viewModel.connectionStatus!.isConnected ? _buildDisconnectCard() : _buildConnectCard()
                      else
                        // Siempre muestra la tarjeta, y que el botón adentro se encargue de mostrar loader
                        _buildConnectCard(),  
                        if(viewModel.connectionStatus?.isConnected ?? false)
                            IconButton(icon: Icon(Icons.close,color: Colors.white,),
                            onPressed: toggleModalVisibility,)
                        
                    ],
                  );

                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectCard() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConnectButton(),
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
