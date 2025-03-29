import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMapWidget extends StatefulWidget {
  final List<Map<String, double>> route;
  final LatLng origin;
  final LatLng destination;

  const UserMapWidget({
    super.key,
    required this.route,
    required this.origin,
    required this.destination,
  });

  @override
  State<UserMapWidget> createState() => _UserMapWidgetState();
}

class _UserMapWidgetState extends State<UserMapWidget> with TickerProviderStateMixin {
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? customIcon;
  LatLng? currentLocation;

  // Animación de latido
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _iconLoaded = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadCustomIcon();
    _initializeMapData();
  }

  void _initializeMapData() {
    List<LatLng> pointsOnMap = widget.route.map((point) {
      return LatLng(point['lat']!, point['lng']!);
    }).toList();

    markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: widget.origin,
        infoWindow: const InfoWindow(title: "Origen"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    _polylines.add(
      Polyline(
        polylineId: const PolylineId("Route"),
        points: pointsOnMap,
        color: const Color(0xFFFF3D00),
        width: 5,
      ),
    );
  }

  Future<void> _loadCustomIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(100, 100)),
      'assets/images/location.png',
    );

    setState(() {
      _iconLoaded = true;
      _updateMarker();
    });

    _animationController.repeat(reverse: true);
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    )..addListener(() {
        if (_iconLoaded) _updateMarker();
      });
  }

  void _updateMarker() {
    if (currentLocation == null) return;

    markers.removeWhere((marker) => marker.markerId.value == 'currentLocation');
    double scale = _scaleAnimation.value;
    double anchorY = 0.5 / scale; // 🔥 Cambia la escala en el eje Y

    markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentLocation!,
        icon: customIcon ?? BitmapDescriptor.defaultMarker,
        anchor: Offset(0.5, anchorY.clamp(0.3, 0.7)),
      ),
    );

    setState(() {});
  }

  Future<void> _updateUserLocation() async {
    try {
      Position position = await currentPosition();
      LatLng newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLocation = newPosition;
      });

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPosition, zoom: 14),
        ),
      );

      _updateMarker();
    } catch (e) {
      print("Error al obtener la ubicación: $e");
    }
  }

  Future<void> setDarkMode() async {
    try {
      String style = await rootBundle.loadString("assets/maps/maps_style.json");
      googleMapController.setMapStyle(style);
    } catch (e) {
      print("Error al cargar el estilo del mapa");
    }
  }

  @override
  void dispose() {
    googleMapController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: _polylines,
          myLocationButtonEnabled: true,
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
            setDarkMode();
          },
          initialCameraPosition: CameraPosition(
            target: widget.origin,
            zoom: 14,
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: FloatingActionButton(
            heroTag: 'location',
            child: const Icon(
              Icons.my_location,
              size: 20,
              color: Colors.black,
            ),
            onPressed: _updateUserLocation,
          ),
        ),
      ],
    );
  }

  Future<Position> currentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están desactivados');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Permiso de ubicación denegado");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Los permisos de ubicación están permanentemente denegados');
    }

    return await Geolocator.getCurrentPosition();
  }
}
