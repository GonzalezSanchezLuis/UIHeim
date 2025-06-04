import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverMapWidget extends StatefulWidget {
  final LatLng? driverLocation;

  const DriverMapWidget({
    super.key,
    required this.driverLocation,
  });

  @override
  State<DriverMapWidget> createState() => _DriverMapWidgetState();
}

class _DriverMapWidgetState extends State<DriverMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
   GoogleMapController? googleMapController;
  Set<Marker> _markers = {};
  LatLng? _currentLocation;
  bool _mapReady = false;
  BitmapDescriptor? _customIcon;

  double _currentZoom = 5.0;
  final double _activeLocationZoom = 18.0;

  final _defaultLocation = const LatLng(4.709870566194833, -74.07554855445838);

  @override
  void initState() {
    super.initState();
    // _loadCustomIcons().then((_){});
    //  _initMap();
    _loadCustomIcons();
  }


 @override
void didUpdateWidget(covariant DriverMapWidget oldWidget) {
  super.didUpdateWidget(oldWidget);

  // Verificamos si la ubicación del conductor cambió
  if (widget.driverLocation != null &&
      (oldWidget.driverLocation == null || widget.driverLocation != oldWidget.driverLocation)) {
    log('Updating marker and camera position in didUpdateWidget');

    // Asegúrate de que el controlador ya esté inicializado
    if (_mapReady && mounted && _controller.isCompleted) {
      _updateDriverMarker(widget.driverLocation!);
      googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(widget.driverLocation!, 30),
      );
    } else {
      log("⚠️ Intento de mover la cámara antes de que el mapa esté listo.");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
              _controller.complete(controller);
              _mapReady = true;
              //setDarkMode();

              if (widget.driverLocation != null) {
                _updateDriverMarker(widget.driverLocation!);
              }
            },
            initialCameraPosition: CameraPosition(
              target: widget.driverLocation ?? _defaultLocation,
              zoom: _currentZoom,
            ),
            onCameraMove: (CameraPosition position) {
              _currentZoom = position.zoom;
            }),

          /*   if (!_mapReady)
          const Center(
            child: CircularProgressIndicator(),
          ), */
      ],
    );
  }

  void _updateDriverMarker(LatLng location) async {
    if (!_mapReady || googleMapController == null) {
      print("⚠️ Map not ready yet");
      return;
    }
    print('googleMapController: $googleMapController');

    final marker = Marker(
      markerId: const MarkerId("driver_location"),
      position: location,
      icon: _customIcon ?? BitmapDescriptor.defaultMarker,
    );

    setState(() {
      _markers.clear();
      _markers.add(marker);

      if (location != _defaultLocation) {
        _currentZoom = _activeLocationZoom;
      }
    });

    await Future.delayed(const Duration(milliseconds: 300));
    googleMapController?.animateCamera(CameraUpdate.newLatLngZoom(location, _currentZoom));
  }

  Future<void> setDarkMode() async {
    try {
      String style = await rootBundle.loadString("assets/maps/maps_style.json");
      googleMapController?.setMapStyle(style);
    } catch (e) {
      print("Error al cargar el estilo del mapa");
    }
  }

  Future<void> _loadCustomIcons() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/location.png',
    );
  }
}
