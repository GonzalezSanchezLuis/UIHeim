import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverMapWidget extends StatefulWidget {
  final VoidCallback onUpdateLocation;
  final LatLng? initialPosition;
  final bool isConnected;

  const DriverMapWidget({
    super.key,
    required this.onUpdateLocation,
    this.initialPosition,
    required this.isConnected,
  });

  @override
  State<DriverMapWidget> createState() => _DriverMapWidgetState();
}

class _DriverMapWidgetState extends State<DriverMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;
  LatLng? _currentLocation;
  bool _mapReady = false;
  bool _isLoading = true;

  // Ubicación por defecto
  static const LatLng _defaultLocation = LatLng(4.713976515281342, -74.07211532714686);

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(DriverMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPosition != oldWidget.initialPosition || widget.isConnected != oldWidget.isConnected) {
      _updateLocationAndMarkers();
    }
  }

  Future<void> _initializeMap() async {
    await _loadCustomIcon();
    _setInitialLocation();
  }

  Future<void> _loadCustomIcon() async {
    try {
      _customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(100, 100)),
        'assets/images/location.png',
      );
    } catch (e) {
      debugPrint("Error loading custom icon: $e");
      _customIcon = BitmapDescriptor.defaultMarker;
    }
  }

  void _setInitialLocation() {
    setState(() {
      _currentLocation = widget.initialPosition ?? _defaultLocation;
      _isLoading = false;
    });
    _updateMarkers();

    if (_mapReady) {
      _moveCamera(_currentLocation!);
    }
  }

  void _updateLocationAndMarkers() {
    if (widget.initialPosition != null) {
      setState(() {
        _currentLocation = widget.initialPosition;
      });
      _updateMarkers();
      _moveCamera(_currentLocation!);
    }
  }

  Future<void> _moveCamera(LatLng position) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 14,
          ),
        ),
      );
    }
  }

  void _updateMarkers() {
    if (_currentLocation == null) return;

    final marker = Marker(
      markerId: const MarkerId('driverLocation'),
      position: _currentLocation!,
      icon: _customIcon ?? BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: widget.isConnected ? 'Tu ubicación' : 'Ubicación por defecto',
      ),
    );

    setState(() {
      _markers = {marker};
    });
  }

  Future<void> _setDarkMode() async {
    try {
      final style = await rootBundle.loadString("assets/maps/maps_style.json");
      _mapController?.setMapStyle(style);
    } catch (e) {
      debugPrint("Error al cargar el estilo del mapa: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: widget.isConnected,
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              _setDarkMode();
              setState(() => _mapReady = true);

              if (_currentLocation != null) {
                _moveCamera(_currentLocation!);
              }
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? _defaultLocation,
              zoom: 14,
            ),
            onTap: (LatLng location) {
              // Mantener esta funcionalidad si es necesaria
            },
          ),
        Positioned(
          bottom: 200,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.my_location, size: 30, color: Colors.white),
            onPressed: widget.onUpdateLocation,
          ),
        ),
      ],
    );
  }
}
