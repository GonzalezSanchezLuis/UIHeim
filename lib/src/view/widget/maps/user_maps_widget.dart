import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class UserMapWidget extends StatefulWidget {
  final List<Map<String, double>> route;
  final LatLng origin;
  final LatLng destination;
  final Function(LatLng)? onLocationUpdated;

  const UserMapWidget({super.key, required this.route, required this.origin, required this.destination, this.onLocationUpdated});

  @override
  State<UserMapWidget> createState() => _UserMapWidgetState();
}

class _UserMapWidgetState extends State<UserMapWidget> {
  late GoogleMapController googleMapController;
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? customIcon;
  //BitmapDescriptor? originIcon;
  //BitmapDescriptor? destinationIcon;
  LatLng? currentLocation;
  bool iconLoaded = false;
  bool _gpsEnabled = true;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons().then((_) {
      _initializeMapData();
    });
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
            _controller.complete(controller);
            _mapReady = true;
            //setDarkMode();
            _moveCameraToRoute();
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(4.709870566194833, -74.07554855445838), // Centro aproximado de Colombia
            zoom: 5.5,
          ),
        ),
      ],
    );
  }

  Future<void> _loadCustomIcons() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(300, 300)),
      'assets/images/location.png',
    );

    setState(() {
      customIcon = customIcon;
      iconLoaded = true;
    });
  }

  void _initializeMapData() {
    markers.clear();
    _polylines.clear();

    if (customIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: widget.origin,
          infoWindow: const InfoWindow(title: "Origen"),
          icon: customIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destination,
          icon: customIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    if (widget.route.isNotEmpty) {
      _polylines.add(Polyline(
        polylineId: const PolylineId("route"),
        points: widget.route.map((p) => LatLng(p['lat']!, p['lng']!)).toList(),
        color: AppTheme.secondarycolor,
        width: 2,
      ));
    }

    setState(() {});
  }


  Future<void> _moveCameraToRoute() async {
    if (!_mapReady || widget.route.isEmpty) return;

    final controller = await _controller.future;

    await Future.delayed(Duration.zero);

    final bounds = _calculateRouteBounds();

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100), // 100px de padding
      );
    } catch (e) {
      // Fallback si el bounds es demasiado pequeño
      final center = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(center, 12),
      );
    }
  }

  LatLngBounds _calculateRouteBounds() {
    final allPoints = [widget.origin, widget.destination, ...widget.route.map((p) => LatLng(p['lat']!, p['lng']!))];

    double? minLat, maxLat, minLng, maxLng;

    for (final point in allPoints) {
      minLat = minLat == null ? point.latitude : min(minLat, point.latitude);
      maxLat = maxLat == null ? point.latitude : max(maxLat, point.latitude);
      minLng = minLng == null ? point.longitude : min(minLng, point.longitude);
      maxLng = maxLng == null ? point.longitude : max(maxLng, point.longitude);
    }

    return LatLngBounds(
      northeast: LatLng(maxLat!, maxLng!),
      southwest: LatLng(minLat!, minLng!),
    );
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
  void didUpdateWidget(UserMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.route != oldWidget.route) {
      _initializeMapData(); // Vuelve a inicializar con los nuevos datos
      _moveCameraToRoute();
    }
  }

  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }
}
