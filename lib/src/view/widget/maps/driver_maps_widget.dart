import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as Math;

class DriverMapWidget extends StatefulWidget {
  final LatLng? driverLocation;
  final List<LatLng> route;
  final List<LatLng>? driverToOriginRoute;
  final void Function(LatLng)? onDriverConnected;

  const DriverMapWidget({super.key, required this.driverLocation, required this.route, this.driverToOriginRoute, this.onDriverConnected});

  @override
  State<DriverMapWidget> createState() => _DriverMapWidgetState();
}

class _DriverMapWidgetState extends State<DriverMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? googleMapController;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  LatLng? _currentLocation;
  bool _mapReady = false;
  late BitmapDescriptor _driverIcon;

  BitmapDescriptor? _customIcon;
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;

  int _currentRouteIndex = 0;
  Timer? _movementTimer;
  bool _isSimulating = false;

  double _currentZoom = 5.0;
  final double _activeLocationZoom = 14.0;
  final _defaultLocation = const LatLng(4.709870566194833, -74.07554855445838);

  bool _hasCenteredOnDriver = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCustomIcons();

      /* if (widget.route.isNotEmpty) {
        _drawRoute();
      } */
    });
  }

  @override
  void didUpdateWidget(covariant DriverMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.driverLocation != null && widget.driverLocation != oldWidget.driverLocation) {
      _updateDriverMarker(widget.driverLocation!);

      if (!_hasCenteredOnDriver && _mapReady && googleMapController != null) {
        _hasCenteredOnDriver = true;
        googleMapController!.animateCamera(
          CameraUpdate.newLatLngZoom(widget.driverLocation!, _activeLocationZoom),
        );

        // Notifica al padre si lo necesita
        widget.onDriverConnected?.call(widget.driverLocation!);

        if (widget.route != oldWidget.route && widget.route.isNotEmpty && _mapReady) {
          _drawRoute();
        }
      }

      // Verificamos si la ubicación del conductor cambió
      /*  if (widget.driverLocation != null && (oldWidget.driverLocation == null || widget.driverLocation != oldWidget.driverLocation)) {
      log('Updating marker and camera position in didUpdateWidget');

      // Asegúrate de que el controlador ya esté inicializado
      if (_mapReady && mounted && googleMapController != null) {
        _updateDriverMarker(widget.driverLocation!);
         googleMapController?.animateCamera(
          CameraUpdate.newLatLngZoom(widget.driverLocation!, 18),
        ); 
      } else {
        log("⚠️ Intento de mover la cámara antes de que el mapa esté listo.");
      }

      if (_mapReady && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _drawRoute();
          //  _simulateDriverMovement(widget.driverToOriginRoute ?? [], stepsPerSegment: 20, stepDurationMs: 150);
        });
      } */
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
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
            _controller.complete(controller);
            _mapReady = true;
            //setDarkMode();

            if (widget.driverLocation != null) {
              _updateDriverMarker(widget.driverLocation!);
            }

            Future.delayed(const Duration(milliseconds: 400), () {
              print("🛤 Ruta tiene ${widget.route.length} puntos");
              if (widget.driverLocation != null) {
                _updateDriverMarker(widget.driverLocation!);
              }

              if (widget.route.isNotEmpty) {
                _drawRoute();
              }
            });
          },
          initialCameraPosition: CameraPosition(
            target: widget.driverLocation ?? _defaultLocation,
            zoom: _currentZoom,
          ),
          onCameraMove: (CameraPosition position) {
            _currentZoom = position.zoom;
          },
        ),

        /*   if (!_mapReady)
          const Center(
            child: CircularProgressIndicator(),
          ), */
      ],
    );
  }

  void _updateDriverMarker(LatLng location, {double rotation = 0.0}) async {
    if (!_mapReady || googleMapController == null) return;

    print('✅ CustomIcon status: ${_customIcon != null}');

    final marker = Marker(markerId: const MarkerId("driver_location"), icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), position: location, anchor: const Offset(0.5, 0.5));

    setState(() {
      _markers.clear();

      _markers.removeWhere((m) => m.markerId.value == "driver_location");
      _markers.add(marker);

      if (location != _defaultLocation) {
        _currentZoom = _activeLocationZoom;
      }
    });

    print("📍 Marcador actualizado. Ícono usado: ${marker.icon}");
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
    try {
      _driverIcon = await _getMarkerFromIcon(Icons.navigation, Colors.black, size: 100.0);
      _originIcon = await _getMarkerFromIcon(Icons.circle, const Color(0xFF076461), size: 75.0);
      _destinationIcon = await _getMarkerFromIcon(Icons.circle, Colors.red, size: 75.0);
      print("✅ Íconos cargados correctamente");

      if (widget.driverLocation != null) {
        _updateDriverMarker(widget.driverLocation!);
      }

      setState(() {});
    } catch (e) {
      print("❌ Error cargando íconos personalizados: $e");
      _driverIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      _originIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _destinationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void _drawRoute() {
    //print('Attempting to draw route. Map ready: $_mapReady, Route points: ${widget.route.length}');
    print("🔍 Ejecutando _drawRoute() con ${widget.route.length} puntos");

    if (widget.route.isEmpty || !_mapReady) return;

    _polylines.clear();

    final Polyline routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.green,
      width: 7,
      points: widget.route,
      geodesic: true,
      consumeTapEvents: true,
    );

    final Polyline? driverToOriginPolyline = (widget.driverToOriginRoute != null && widget.driverToOriginRoute!.isNotEmpty)
        ? Polyline(
            polylineId: const PolylineId('driver_to_origin'),
            color: Colors.orange,
            width: 7,
            points: widget.driverToOriginRoute!,
            geodesic: true,
            consumeTapEvents: false,
          )
        : null;

    final Set<Marker> newMarkers = {
      // Origen
      Marker(markerId: const MarkerId('origin'), position: widget.route.first, icon: _originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), anchor: const Offset(0.5, 0.5)),

      // Destino
      Marker(markerId: const MarkerId('destination'), position: widget.route.last, icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), anchor: const Offset(0.5, 0.5)),
    };

    if (widget.driverLocation != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId("driver_location"),
        position: widget.driverLocation!,
        icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    setState(() {
      _polylines = {
        routePolyline,
        if (driverToOriginPolyline != null) driverToOriginPolyline,
      };
      _markers = newMarkers;
    });

    print('Route drawn successfully');

    final allPoints = [...widget.route, ...?widget.driverToOriginRoute];

    if (allPoints.length > 1) {
      final bounds = _boundsFromLatLngList(allPoints);
      googleMapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  Future<BitmapDescriptor> _getMarkerFromIcon(IconData iconData, Color color, {double size = 80.0}) async {
    try {
      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      final textStyle = TextStyle(
        fontSize: size * 0.8,
        fontFamily: iconData.fontFamily,
        color: color,
      );

      textPainter.text = TextSpan(text: String.fromCharCode(iconData.codePoint), style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(size * 0.2, size * 0.1)); // Mejor centrado

      final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) throw Exception("No se pudo generar el ícono");
      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    } catch (e) {
      print("❌ Fallo al crear ícono: $e");
      return BitmapDescriptor.defaultMarker; // Fallback explícito
    }
  }

  void _simulateDriverMovement(List<LatLng> routePoints, {int stepsPerSegment = 20, int stepDurationMs = 100}) {
    if (_isSimulating || routePoints.length < 2) return;

    _isSimulating = true;
    _currentRouteIndex = 0;

    LatLng start = routePoints[0];
    LatLng end = routePoints[1];
    double t = 0.0;
    int step = 0;

    _movementTimer = Timer.periodic(Duration(milliseconds: stepDurationMs), (timer) {
      if (_currentRouteIndex >= routePoints.length - 1) {
        timer.cancel();
        _isSimulating = false;
        return;
      }

      final interpolated = _interpolateLatLng(start, end, t);
      final bearing = _getBearing(start, end);
      _updateDriverMarker(interpolated, rotation: bearing);
      googleMapController?.animateCamera(CameraUpdate.newLatLngZoom(interpolated, 17));

      step++;
      t = step / stepsPerSegment;

      if (t >= 1.0) {
        _currentRouteIndex++;
        step = 0;
        t = 0.0;
        start = routePoints[_currentRouteIndex];
        end = routePoints[_currentRouteIndex + 1];
      }
    });
  }

  LatLng _interpolateLatLng(LatLng start, LatLng end, double t) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * t,
      start.longitude + (end.longitude - start.longitude) * t,
    );
  }

  double _getBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (3.141592653589793 / 180);
    final lon1 = start.longitude * (3.141592653589793 / 180);
    final lat2 = end.latitude * (3.141592653589793 / 180);
    final lon2 = end.longitude * (3.141592653589793 / 180);

    final dLon = lon2 - lon1;

    final y = Math.sin(dLon) * Math.cos(lat2);
    final x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);

    final bearing = Math.atan2(y, x);
    return (bearing * (180 / 3.141592653589793) + 360) % 360;
  }

  void onConnected(LatLng location) {
    if (!_mapReady || googleMapController == null) return;

    _currentZoom = 15;
    _updateDriverMarker(location);

    googleMapController!.animateCamera(CameraUpdate.newLatLngZoom(location, _currentZoom));
  }
}
