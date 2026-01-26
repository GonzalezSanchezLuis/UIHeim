/*import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

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
  bool _isIconsLoaded = false;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCustomIcons();
    });
  }

  @override
  void didUpdateWidget(covariant DriverMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final hasLocationNow = widget.driverLocation != null;
    final wasLocationNull = oldWidget.driverLocation != null;

    if (wasLocationNull && hasLocationNow) {
      _hasCenteredOnDriver = false; 
    }

    if (!_hasCenteredOnDriver && hasLocationNow && _mapReady) {
      _hasCenteredOnDriver = true;

      Future.delayed(const Duration(milliseconds: 600), () {
        googleMapController?.animateCamera(CameraUpdate.newLatLngZoom(widget.driverLocation!, 16));
      });
    }

    if (hasLocationNow && widget.driverLocation != oldWidget.driverLocation) {
      _updateDriverMarker(widget.driverLocation!);

      // Solo mover cámara si el usuario NO está interactuando
      if (_mapReady && googleMapController != null && !_isUserInteracting) {
        googleMapController!.animateCamera(
          CameraUpdate.newLatLng(widget.driverLocation!),
        );
      }
    }

    // 1. Detectar cambios en la ubicación del conductor (lógica existente)
    final driverChanged = widget.driverLocation != null && widget.driverLocation != oldWidget.driverLocation;

    final mainRoutePointsChanged = widget.route != oldWidget.route;
    final driverToOriginPointsChanged = widget.driverToOriginRoute != oldWidget.driverToOriginRoute;

    if (driverChanged) {
      _updateDriverMarker(widget.driverLocation!);
      if (_mapReady && googleMapController != null && !_isUserInteracting) {
        googleMapController!.animateCamera(
          CameraUpdate.newLatLng(widget.driverLocation!),
        );
      }

      /* if (!_hasCenteredOnDriver && _mapReady && googleMapController != null) {
        _hasCenteredOnDriver = true;
        googleMapController!.animateCamera(
          CameraUpdate.newLatLngZoom(widget.driverLocation!, _activeLocationZoom),
        );
        widget.onDriverConnected?.call(widget.driverLocation!);
      } */
    }

    // 🚨 3. Condición Final: Llamar a _drawRoute si alguna de las listas se actualizó.
    // Esto se ejecutará cada vez que el ViewModel llame a notifyListeners() después de obtener una ruta.
    if (mainRoutePointsChanged || driverToOriginPointsChanged) {
      print("📍 Cambio detectado en las polilíneas. Redibujando...");
      print("VERIFICACIÓN FINAL: Ruta Principal tiene: ${widget.route.length} | Conductor a Origen tiene: ${widget.driverToOriginRoute?.length ?? 0}");
      _drawRoute();
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
          onMapCreated: (GoogleMapController controller) async {
            googleMapController = controller;
            _controller.complete(controller);
            _mapReady = true;
            //setDarkMode();

            if (widget.driverLocation != null && !_hasCenteredOnDriver) {
              _hasCenteredOnDriver = true;
              googleMapController?.animateCamera(
                CameraUpdate.newLatLngZoom(widget.driverLocation!, 16),
              );
            }

            if (widget.driverLocation != null) {
              _updateDriverMarker(widget.driverLocation!);
            }

            await Future.doWhile(() async {
              await Future.delayed(const Duration(milliseconds: 100));
              return !_isIconsLoaded;
            });

            print("🛤 Ruta tiene ${widget.route.length} puntos");

            if (widget.driverLocation != null) {
              _updateDriverMarker(widget.driverLocation!);
            }

            if (widget.route.isNotEmpty) {
              _drawRoute();
            }
          },
          initialCameraPosition: CameraPosition(
            target: widget.driverLocation ?? _defaultLocation,
            zoom: _currentZoom,
          ),
          /*  onCameraMove: (CameraPosition position) {
            _currentZoom = position.zoom;
          }, */
          onCameraMove: (CameraPosition position) {
            _currentZoom = position.zoom;
            if (!_isUserInteracting) {
              setState(() {
                _isUserInteracting = true;
              });
            }
          },
        ),
        if (_isUserInteracting)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isUserInteracting = false;
                });
                if (widget.driverLocation != null) {
                  googleMapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(widget.driverLocation!, 16),
                  );
                }
              },
            ),
          ),
        if (!_mapReady)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  void _updateDriverMarker(LatLng location, {double rotation = 0.0}) async {
    if (!_mapReady || googleMapController == null) return;

    print('✅ CustomIcon status: ${_customIcon != null}');

    final driverMarker = Marker(markerId: const MarkerId("driver_location"), icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), position: location, rotation: rotation, flat: true, anchor: const Offset(0.5, 0.5));

    setState(() {
      _markers.clear();
      _markers.removeWhere((m) => m.markerId.value == "driver_location");
      _markers.add(driverMarker);

      if (location != _defaultLocation) {
        _currentZoom = _activeLocationZoom;
      }
    });

    print("📍 Marcador actualizado. Ícono usado: ${driverMarker.icon}");
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
      _driverIcon = await _getMarkerFromIcon(Icons.navigation, Colors.black, size: 70.0);

      _originIcon = await _getMarkerFromIconOriginToDestination(
        Icons.circle,
        Colors.green,
        size: 70.0,
      );
      _destinationIcon = await _getMarkerFromIconOriginToDestination(
        Icons.circle,
        Colors.blueAccent,
        size: 70.0,
      );
      print("✅ Íconos cargados correctamente");

      _isIconsLoaded = true;

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
    if (!_mapReady) return;

    print("🛣 widget.route: ${widget.route.length} puntos");
    print("🛣 driverToOriginRoute: ${widget.driverToOriginRoute?.length ?? 0} puntos");

    final newPolylines = <Polyline>{};

    if (widget.route.isNotEmpty) {
      newPolylines.add(Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.green,
        width: 7,
        points: widget.route,
        geodesic: true,
      ));
    }

    if (widget.driverToOriginRoute != null && widget.driverToOriginRoute!.isNotEmpty) {
      newPolylines.add(Polyline(
        polylineId: const PolylineId('driver_to_origin'),
        color: Colors.orange,
        width: 7,
        points: widget.driverToOriginRoute!,
        geodesic: true,
      ));
    }

    final newMarkers = <Marker>{};

    if (widget.route.isNotEmpty) {
      newMarkers.add(Marker(
        markerId: const MarkerId('origin'),
        position: widget.route.first,
        icon: _originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));

      newMarkers.add(Marker(
        markerId: const MarkerId('destination'),
        position: widget.route.last,
        icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    if (widget.driverLocation != null) {
      newMarkers.add(Marker(
        markerId: const MarkerId("driver_location"),
        position: widget.driverLocation!,
        icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    setState(() {
      _polylines = newPolylines;
      _markers = newMarkers;
    });

    // Ajustar cámara si hay puntos
    final allPoints = [
      ...widget.route,
      ...?widget.driverToOriginRoute,
    ];

    if (allPoints.length > 1) {
      final bounds = _boundsFromLatLngList(allPoints);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        googleMapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      });
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

  Future<BitmapDescriptor> _getMarkerFromIconOriginToDestination(IconData iconData, Color color, {double size = 80.0}) async {
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
      textPainter.paint(canvas, Offset(size * 0.2, size * 0.1));

      final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) throw Exception("No se pudo generar el ícono");
      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    } catch (e) {
      print("❌ Error generando ícono: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<BitmapDescriptor> _getMarkerFromIcon(
    IconData iconData,
    Color fillColor, {
    double size = 80.0,
    Color borderColor = Colors.white,
    double borderWidth = 6.0,
  }) async {
    try {
      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final iconSize = size;

      final center = Offset(iconSize / 2, iconSize / 2);
      final radius = iconSize / 2;

      // 1. Dibuja el borde
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, borderPaint);

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius - borderWidth, fillPaint);
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      final textStyle = TextStyle(
        fontSize: iconSize * 0.8,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: Colors.white,
      );

      textPainter.text = TextSpan(text: String.fromCharCode(iconData.codePoint), style: textStyle);
      textPainter.layout();
      final iconOffset = Offset(
        center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2),
      );

      textPainter.paint(canvas, iconOffset);

      // 4. Convierte a imagen
      final image = await pictureRecorder.endRecording().toImage(iconSize.toInt(), iconSize.toInt());
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) throw Exception("No se pudo generar el ícono");
      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    } catch (e) {
      print("❌ Error generando ícono con borde: $e");
      return BitmapDescriptor.defaultMarker;
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

      googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: interpolated,
            zoom: 17,
            tilt: 45.0,
            bearing: 0.0,
          ),
        ),
      );

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

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    return (bearing * (180 / 3.141592653589793) + 360) % 360;
  }

  void onConnected(LatLng location) {
    if (!_mapReady || googleMapController == null) return;

    _currentZoom = 15;
    _updateDriverMarker(location);

    googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: _currentZoom,
          tilt: 45.0,
          bearing: 0.0,
        ),
      ),
    );
  }

  void _animateDriverToNewLocation(LatLng start, LatLng end) {
    const int steps = 25;
    const int durationMs = 1500;
    int currentStep = 0;

    Timer.periodic(const Duration(milliseconds: durationMs ~/ steps), (timer) {
      currentStep++;
      double t = currentStep / steps;
      LatLng interpolated = _interpolateLatLng(start, end, t);
      double bearing = _getBearing(start, end);

      _updateDriverMarker(interpolated, rotation: bearing);

      if (currentStep >= steps) {
        timer.cancel();
      }
    });
  }
}*/
/*import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class DriverMapWidget extends StatefulWidget {
  final LatLng? driverLocation;
  final List<LatLng> route;
  final List<LatLng>? driverToOriginRoute;
  final void Function(LatLng)? onDriverConnected;

  const DriverMapWidget({
    super.key,
    required this.driverLocation,
    required this.route,
    this.driverToOriginRoute,
    this.onDriverConnected,
  });

  @override
  State<DriverMapWidget> createState() => _DriverMapWidgetState();
}

class _DriverMapWidgetState extends State<DriverMapWidget> {
  GoogleMapController? _mapController;

  // Estado del Mapa
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _mapReady = false;
  bool _hasCenteredOnDriver = false;
  bool _isUserInteracting = false;

  // Iconos Personalizados
  late BitmapDescriptor _driverIcon;
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;

  // Configuración Visual
  final double _activeZoom = 15.0;
  final double _initialZoom = 5.0;
  final LatLng _defaultLocation = const LatLng(4.709870566194833, -74.07554855445838);

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
  }

  @override
  void didUpdateWidget(covariant DriverMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mapReady) return;

    // 1. Manejo de Ubicación del Conductor
    if (widget.driverLocation != null) {
      _updateDriverMarker(widget.driverLocation!);

      // Enfoque inicial automático
      if (!_hasCenteredOnDriver) {
        _hasCenteredOnDriver = true;
        _animateCamera(widget.driverLocation!, zoom: _activeZoom);
        widget.onDriverConnected?.call(widget.driverLocation!);
      }
      // Seguimiento constante (solo si el usuario no está moviendo el mapa)
      else if (!_isUserInteracting && widget.driverLocation != oldWidget.driverLocation) {
        _animateCamera(widget.driverLocation!);
      }
    }

    // 2. Manejo de Rutas y Polilíneas
    if (widget.route != oldWidget.route || widget.driverToOriginRoute != oldWidget.driverToOriginRoute) {
      _drawRoute();
    }
  }

  // --- LÓGICA DE CÁMARA ---

  void _animateCamera(LatLng target, {double? zoom}) {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      zoom != null ? CameraUpdate.newLatLngZoom(target, zoom) : CameraUpdate.newLatLng(target),
    );
  }

  void _fitRouteBounds() {
    final allPoints = [...widget.route, ...?widget.driverToOriginRoute];
    if (allPoints.length < 2 || _isUserInteracting) return;

    final bounds = _boundsFromLatLngList(allPoints);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  // --- LÓGICA DE DIBUJO ---

  void _updateDriverMarker(LatLng location, {double rotation = 0.0}) {
    final driverMarker = Marker(
      markerId: const MarkerId("driver_location"),
      position: location,
      rotation: rotation,
      icon: _driverIcon,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      zIndex: 5,
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == "driver_location");
      _markers.add(driverMarker);
    });
  }

  void _drawRoute() {
    if (!_mapReady) return;

    final newPolylines = <Polyline>{};
    final newMarkers = <Marker>{};

    // Ruta Principal (Destino Final)
    if (widget.route.isNotEmpty) {
      newPolylines.add(Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.green,
        width: 6,
        points: widget.route,
      ));

      newMarkers.add(Marker(
        markerId: const MarkerId('origin'),
        position: widget.route.first,
        icon: _originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));

      newMarkers.add(Marker(
        markerId: const MarkerId('destination'),
        position: widget.route.last,
        icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    // Ruta Conductor -> Origen (Recogida)
    if (widget.driverToOriginRoute != null && widget.driverToOriginRoute!.isNotEmpty) {
      newPolylines.add(Polyline(
        polylineId: const PolylineId('driver_to_origin'),
        color: Colors.orange,
        width: 6,
        points: widget.driverToOriginRoute!,
      ));
    }

    setState(() {
      _polylines.clear();
      _polylines.addAll(newPolylines);

      // Limpiamos marcadores excepto el del conductor para re-dibujar
      _markers.removeWhere((m) => m.markerId.value != "driver_location");
      _markers.addAll(newMarkers);
    });

    _fitRouteBounds();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.driverLocation ?? _defaultLocation,
            zoom: _initialZoom,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            setState(() => _mapReady = true);

            if (widget.driverLocation != null) {
              _animateCamera(widget.driverLocation!, zoom: _activeZoom);
              _hasCenteredOnDriver = true;
              _updateDriverMarker(widget.driverLocation!);
            }
            if (widget.route.isNotEmpty) _drawRoute();
          },
          onCameraMove: (position) {
            if (!_isUserInteracting) setState(() => _isUserInteracting = true);
          },
        ),

        // Botón para recuperar el enfoque del conductor
        if (_isUserInteracting)
          Positioned(
            bottom: 25,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() => _isUserInteracting = false);
                if (widget.driverLocation != null) {
                  _animateCamera(widget.driverLocation!, zoom: _activeZoom);
                }
              },
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

        if (!_mapReady) const Center(child: CircularProgressIndicator(color: Colors.black)),
      ],
    );
  }

  // --- UTILS Y GENERACIÓN DE ICONOS ---

  Future<void> _loadCustomIcons() async {
    try {
      _driverIcon = await _getMarkerFromIcon(Icons.navigation, Colors.black, size: 80);
      _originIcon = await _getMarkerFromIcon(Icons.location_on, Colors.green, size: 80);
      _destinationIcon = await _getMarkerFromIcon(Icons.flag, Colors.red, size: 80);
      setState(() {});
    } catch (e) {
      _driverIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }

  Future<BitmapDescriptor> _getMarkerFromIcon(IconData iconData, Color color, {double size = 80.0}) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.8,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0, 0));

    final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double minLat = list.first.latitude, maxLat = list.first.latitude;
    double minLng = list.first.longitude, maxLng = list.first.longitude;

    for (var point in list) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}*/
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

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
  // --- CONTROLADORES Y ESTADO ---
  GoogleMapController? _mapController;
  //final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  bool _mapReady = false;
  bool _isIconsLoaded = false;
  bool _hasCenteredOnDriver = false;
  bool _isUserInteracting = false;
  bool _isSimulating = false;

  // --- ICONOS ---
  late BitmapDescriptor _driverIcon;
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;

  // --- CONFIGURACIÓN DE CÁMARA ---
  double _currentZoom = 5.0; 
  final double _activeLocationZoom = 14.0;
  final LatLng _defaultLocation = const LatLng(4.709870566194833, -74.07554855445838);

  // --- TIMERS ---
  Timer? _movementTimer;
  int _currentRouteIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
  }

  @override
  void didUpdateWidget(covariant DriverMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mapReady) return;

    final hasLocationNow = widget.driverLocation != null;
    final locationChanged = widget.driverLocation != oldWidget.driverLocation;

    final routeReceived = widget.route.isNotEmpty && oldWidget.route.isEmpty;
    final driverToOriginReceived = widget.driverToOriginRoute != null && oldWidget.driverToOriginRoute == null;

    if (routeReceived || driverToOriginReceived) {
      _drawRoute(); // Esto llamará a _fitRouteBounds internamente
    }

    if (widget.driverLocation != null && widget.driverLocation != oldWidget.driverLocation) {
      _updateDriverMarker(widget.driverLocation!);
      if (!_isUserInteracting) {
        _animateCamera(widget.driverLocation!);
      }
    }

    if (hasLocationNow) {
      // 1. Actualizar siempre el marcador
      _updateDriverMarker(widget.driverLocation!);

      if (!_hasCenteredOnDriver) {
        _hasCenteredOnDriver = true;
        _animateCamera(widget.driverLocation!, zoom: _activeLocationZoom);
        // Mantenemos tu llamada original al conectar
        widget.onDriverConnected?.call(widget.driverLocation!);
      } else if (!_isUserInteracting && locationChanged) {
        _animateCamera(widget.driverLocation!);
      }
    }
    if (widget.route != oldWidget.route || widget.driverToOriginRoute != oldWidget.driverToOriginRoute) {
      _drawRoute();
    }
  }

  // --- MÉTODOS DE CÁMARA ---

  Future<void> _animateCamera(LatLng target, {double? zoom}) async {
    if (!_mapReady || _mapController == null || !mounted) return;

    try {
      await _mapController!.animateCamera(
        zoom != null ? CameraUpdate.newLatLngZoom(target, zoom) : CameraUpdate.newLatLng(target),
      );
    } catch (_) {
      // Evita crash por mapId temporal
    }
  }

  // --- LÓGICA DE DIBUJO Y MARCADORES ---

  void _updateDriverMarker(LatLng location, {double rotation = 0.0}) {
    if (!_mapReady) return;

    final driverMarker = Marker(
      markerId: const MarkerId("driver_location"),
      icon: _driverIcon,
      position: location,
      rotation: rotation,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      zIndex: 10,
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == "driver_location");
      _markers.add(driverMarker);
    });
  }

  void _drawRoute() {
    if (!_mapReady || !mounted || _mapController == null) return;

    final newPolylines = <Polyline>{};
    final newMarkers = <Marker>{};

    // Polilíneas
    if (widget.route.isNotEmpty) {
      newPolylines.add(Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.green,
        width: 7,
        points: widget.route,
      ));

      newMarkers.add(Marker(
        markerId: const MarkerId('origin'),
        position: widget.route.first,
        icon: _originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));

      newMarkers.add(Marker(
        markerId: const MarkerId('destination'),
        position: widget.route.last,
        icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    if (widget.driverToOriginRoute != null && widget.driverToOriginRoute!.isNotEmpty) {
      newPolylines.add(Polyline(
        polylineId: const PolylineId('driver_to_origin'),
        color: Colors.orange,
        width: 7,
        points: widget.driverToOriginRoute!,
      ));
    }

    if (mounted) {
      setState(() {
        _polylines = newPolylines;
        _markers.removeWhere((m) => m.markerId.value != "driver_location");
        _markers.addAll(newMarkers);
      });
    }

    _fitRouteBounds();
  }
  void _fitRouteBounds() {
    if (!_mapReady || _mapController == null) return;

    final allPoints = [
      ...widget.route,
      ...?widget.driverToOriginRoute,
      if (widget.driverLocation != null) widget.driverLocation!,
    ];

    if (allPoints.length < 2) return;

    final bounds = _boundsFromLatLngList(allPoints);

    // El padding del widget se encarga de que no se tape con la card
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80), // 80 es el margen de seguridad
    );
  }

 /* void _fitRouteBounds() {
    /* final allPoints = [...widget.route, ...?widget.driverToOriginRoute];
    if (allPoints.length < 2 || _isUserInteracting) return;

    final bounds = _boundsFromLatLngList(allPoints);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 110)); */
    final allPoints = [...widget.route, ...?widget.driverToOriginRoute];
    if (allPoints.isEmpty) return;

    if (allPoints.length == 1) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(allPoints.first, _activeLocationZoom),
      );
      return;
    }
    final bounds = _boundsFromLatLngList(allPoints);

    double centerLat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    double centerLng = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
    LatLng center = LatLng(centerLat, centerLng);

    const double cardHeight = 150;
    const double mapHeight = 600; 
    final latOffset = (bounds.northeast.latitude - bounds.southwest.latitude) * (cardHeight / mapHeight) * 2.5;
    centerLat -= latOffset;
    center = LatLng(centerLat, centerLng);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mapReady || _mapController == null) return;
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 110));
        _mapController!.moveCamera(CameraUpdate.newLatLng(center));
    });
  }*/
  // --- GENERACIÓN DE ICONOS (TUS MÉTODOS ORIGINALES) ---

  Future<void> _loadCustomIcons() async {
    try {
      _driverIcon = await _getMarkerFromIcon(Icons.navigation, Colors.black, size: 70.0);
      _originIcon = await _getMarkerFromIconOriginToDestination(Icons.circle, Colors.green, size: 70.0);
      _destinationIcon = await _getMarkerFromIconOriginToDestination(Icons.circle, Colors.blueAccent, size: 70.0);
      _isIconsLoaded = true;
      if (widget.driverLocation != null) _updateDriverMarker(widget.driverLocation!);
      setState(() {});
    } catch (e) {
      _driverIcon = BitmapDescriptor.defaultMarker;
    }
  }

  Future<BitmapDescriptor> _getMarkerFromIconOriginToDestination(IconData iconData, Color color, {double size = 80.0}) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(fontSize: size * 0.8, fontFamily: iconData.fontFamily, color: color),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size * 0.2, size * 0.1));
    final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _getMarkerFromIcon(IconData iconData, Color fillColor, {double size = 80.0, Color borderColor = Colors.white, double borderWidth = 6.0}) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    canvas.drawCircle(center, radius, Paint()..color = borderColor);
    canvas.drawCircle(center, radius - borderWidth, Paint()..color = fillColor);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(fontSize: size * 0.8, fontFamily: iconData.fontFamily, package: iconData.fontPackage, color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)));

    final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // --- LÓGICA DE MOVIMIENTO Y SIMULACIÓN (TUS MÉTODOS ORIGINALES) ---

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
      _updateDriverMarker(interpolated, rotation: _getBearing(start, end));

      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: interpolated, zoom: 17, tilt: 45.0),
      ));

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

  LatLng _interpolateLatLng(LatLng start, LatLng end, double t) => LatLng(
        start.latitude + (end.latitude - start.latitude) * t,
        start.longitude + (end.longitude - start.longitude) * t,
      );

  double _getBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (math.pi / 180);
    final lon1 = start.longitude * (math.pi / 180);
    final lat2 = end.latitude * (math.pi / 180);
    final lon2 = end.longitude * (math.pi / 180);
    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * (180 / math.pi) + 360) % 360;
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _defaultLocation, zoom: _currentZoom),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
         padding: const EdgeInsets.only(bottom: 350, top: 0, right: 0, left: 0),
          onMapCreated: (controller) async {
            _mapController = controller;
            await Future.delayed(const Duration(microseconds: 300));

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              setState(() {
                _mapReady = true;
              });
                         

              if (widget.driverLocation != null) {
                _updateDriverMarker(widget.driverLocation!);
                _animateCamera(widget.driverLocation!, zoom: _activeLocationZoom);
                _hasCenteredOnDriver = true;
              }

              if (widget.route.isNotEmpty) {
                _drawRoute();
              }
            });
          },
          onCameraMove: (position) {
            _currentZoom = position.zoom;
            if (!_isUserInteracting) setState(() => _isUserInteracting = true);
          },
        ),
        if (_isUserInteracting)
          Positioned(
           top: 60,
           right: 20,
            child: FloatingActionButton(
              mini: true,
              elevation: 4,
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() => _isUserInteracting = false);
                if (widget.driverLocation != null) _animateCamera(widget.driverLocation!, zoom: _activeLocationZoom);
              },
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        if (!_mapReady) const Center(child: CircularProgressIndicator(color: Colors.black)),
      ],
    );
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
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _mapController = null;
    super.dispose();
  }
}
