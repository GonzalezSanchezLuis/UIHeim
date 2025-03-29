import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/controllers/drivers/status_controller.dart';
import 'package:holi/src/view/screens/driver/driver.dart';
import 'package:holi/src/view/widget/button/button_card_home.dart';
import 'package:holi/src/view/widget/maps/driver_maps.dart';
import 'package:holi/src/viewmodels/driver/driver_status_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class HomeDriver extends StatefulWidget {
  const HomeDriver({super.key});

  @override
  _HomeDriverState createState() => _HomeDriverState();
}

class _HomeDriverState extends State<HomeDriver> {
  final StatusController statusController = StatusController();
  bool showConnectCard = true;
  int currentPageIndex = 0;
  bool _isConnected = false;
  LatLng? _currentLatLng;
  bool isLocationLoading = false;
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocationServices();
    _loadDriverStatus();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationServices() async {
    await _getInitialLocation();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualiza cada 10 metros
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLatLng = LatLng(position.latitude, position.longitude);
        });
      }
    }, onError: (e) {
      debugPrint("Error en el stream de ubicación: $e");
    });
  }

  Future<void> _getInitialLocation() async {
    setState(() => isLocationLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() => _currentLatLng = LatLng(position.latitude, position.longitude));
    } catch (e) {
      debugPrint("Error obteniendo ubicación inicial: $e");
    } finally {
      setState(() => isLocationLoading = false);
    }
  }

  Future<void> _updateDriverLocation() async {
    setState(() => isLocationLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint("Error actualizando ubicación: $e");
    } finally {
      setState(() => isLocationLoading = false);
    }
  }

  Future<void> _loadDriverStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('status') ?? "Disconnected";

    setState(() {
      _isConnected = (status == "Connected");
      debugPrint("Estado actualizado: $_isConnected");

      // Pausar o reanudar actualizaciones según el estado
      if (_isConnected) {
        _locationSubscription?.resume();
      } else {
        _locationSubscription?.pause();
      }
    });
  }

  Future<bool> _isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  void _showLocationAlert() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Ubicación Desactivada"),
              content: const Text("Para conectarte, debes activar tu ubicación."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Geolocator.openLocationSettings();
                      // Verificar nuevamente después de abrir configuraciones
                      if (await _isLocationEnabled()) {
                        _handleDriverConnectAttempt();
                      }
                    },
                    child: const Text("Activar"))
              ],
            ));
  }

  Future<void> _handleDriverConnectAttempt() async {
    bool locationEnabled = await _isLocationEnabled();
    if (!locationEnabled) {
      _showLocationAlert();
    } else {
      await _updateDriverLocation();

      // Notificar a un Provider si usas uno
      final provider = Provider.of<DriverStatusProvider>(context, listen: false);
      provider.connectDriver();

      _handleDriverConnected();
    }
  }

  void _handleDriverConnected() {
    _loadDriverStatus();
    setState(() {});
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
        _currentLatLng != null
            ? DriverMapWidget(
                onUpdateLocation: _updateDriverLocation,
                initialPosition: _currentLatLng,
                isConnected: _isConnected,
              )
            : const Center(child: CircularProgressIndicator()),

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
                  color:  AppTheme.primarycolor,
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
              color: AppTheme.colorbackgroundview,
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
             child: Consumer<DriverStatusProvider>(
                builder: (context, provider, child) {
                  return provider.isConnected ?  _buildDisconnectCard() :  _buildConnectCard();
                },
              ),
            ),
          ),
        ),

        if (isLocationLoading)
          const Center(
            child: CircularProgressIndicator(),
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
