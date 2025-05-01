import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DriverMapWidget extends StatefulWidget {
  final void Function(LatLng) onUpdateLocation;
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
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController googleMapController;
  Set<Marker> _markers = {};
  LatLng? _currentLocation;
  bool _mapReady = false;
   BitmapDescriptor? _customIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons().then((_){
        _initMap();
    });
    
  }

  Future<void> _initMap() async {
    if (widget.initialPosition != null) {
      _updateMapWithLatLng(widget.initialPosition!);
    } else {
      await _determinePosition();
    }
  }

   Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _updateMapWithLatLng(LatLng(position.latitude, position.longitude));
  }

   void _updateMapWithLatLng(LatLng latLng) async {
    setState(() {
      _currentLocation = latLng;
      _markers = {
        Marker(
          markerId: const MarkerId("driver"),
          position: latLng,
          icon: _customIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        )
      };
    });

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));

    widget.onUpdateLocation(latLng);
  }

  Future<void> _loadCustomIcons() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(300, 300)),
      'assets/images/location.png',
    );

    setState(() {
      _customIcon = _customIcon;
    });
  }

   @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          myLocationButtonEnabled: true,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
            _controller.complete(controller);
            _mapReady = true;
          },
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition ?? const LatLng(4.709870566194833, -74.07554855445838),
            zoom: 5.5,
          ),
        ),
        // Puedes agregar aquí otros widgets si necesitas
      ],
    );
  }
  /* GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;
  LatLng? _currentLocation;
  bool _mapReady = false;
  bool _isLoading = true;
  Timer? _locationUpdateTimer;

  static const LatLng _defaultLocation = LatLng(3.4881420461628316, -73.43752839500705); // Coordenadas predeterminadas de Colombia

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(covariant DriverMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialPosition != oldWidget.initialPosition || widget.isConnected != oldWidget.isConnected) {
      if (widget.isConnected) {
        _startLocationUpdates();
      } else {
        _stopLocationUpdates();
      }
      _setInitialLocation();
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
              _setMapStyle();
              _mapReady = true;
              if (_currentLocation != null) {
                _moveCamera(_currentLocation!);
              }
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? _defaultLocation,
              zoom: 14,
            ),
            onTap: (LatLng location) {
              // Puedes agregar funcionalidad aquí si es necesario
            },
          ),
      ],
    );
  }

  Future<void> _initializeMap() async {
    await _loadCustomIcon();
    _checkAndSetLocation();
  }

  void _checkAndSetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si el servicio de ubicación está desactivado, usamos las coordenadas predeterminadas
      _setDefaultLocation();
      return;
    }

    // Verificar los permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // Si los permisos están permanentemente denegados, mostrar un mensaje
      _setDefaultLocation();
      return;
    }

    if (permission == LocationPermission.denied) {
      // Si los permisos fueron denegados, solicitarlos
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        // Si no se otorgan permisos, usamos las coordenadas predeterminadas
        _setDefaultLocation();
        return;
      }
    }

    // Si todo está bien, obtener la ubicación
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
    _updateMarkers();
    if (_mapReady) {
      _moveCamera(_currentLocation!);
    }
  }

  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    if (widget.isConnected) {
      _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (_) {
        widget.onUpdateLocation(); // Llamada para actualizar la ubicación en el padre
      });
    }
  }

  void _stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
  }

  Future<void> _loadCustomIcon() async {
    try {
      _customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(250, 250)),
        'assets/images/location.png',
      );
    } catch (e) {
      debugPrint("Error loading custom icon: $e");
      _customIcon = BitmapDescriptor.defaultMarker;
    }
  }

  void _setInitialLocation() {
    final defaultPosition = widget.initialPosition ?? _defaultLocation;
    setState(() {
      _currentLocation = defaultPosition;
      _isLoading = false;
    });
    _updateMarkers();
    if (_mapReady && _currentLocation != null) {
      _moveCamera(_currentLocation!);
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

  void _setDefaultLocation() {
    setState(() {
      _currentLocation = _defaultLocation;
      _isLoading = false;
    });
    _updateMarkers();
  }

  Future<void> _setMapStyle() async {
    try {
      final style = await rootBundle.loadString("assets/maps/maps_style.json");
      _mapController?.setMapStyle(style);
    } catch (e) {
      debugPrint("Error al cargar el estilo del mapa: $e");
    }
  } */
}
