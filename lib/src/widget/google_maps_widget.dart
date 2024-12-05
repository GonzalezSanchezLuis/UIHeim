// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class GoogleMapsWidget extends StatefulWidget {
  @override
  _GoogleMapsWidgetState createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  late GoogleMapController _controller;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _loadMapStyle() async {
    final String style =
        await rootBundle.loadString('assets/maps/maps_style.json');
    _controller.setMapStyle(style);
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: _currentPosition!,
        infoWindow: const InfoWindow(title: "Tu ubicación"),
      ));
    });
  }

  Future<bool> _checkLocationPermission() async {
    final status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied ||
        status == LocationPermission.deniedForever) {
      final result = await Geolocator.requestPermission();
      return result == LocationPermission.always ||
          result == LocationPermission.whileInUse;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return _currentPosition == null
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 14,
            ),
          
            markers: _markers,
            onMapCreated: (controller) => {
              _controller = controller,
              _loadMapStyle(),
    

            },
            // Resto de los parámetros del mapa...
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          
          );
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera el controlador
    super.dispose(); // Llama al método de limpieza del padre
  }
}
