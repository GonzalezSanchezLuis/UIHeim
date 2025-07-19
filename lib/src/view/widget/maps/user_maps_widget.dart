import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

/*class UserMapWidget extends StatefulWidget {
  final List<Map<String, double>> route;
  final LatLng origin;
  final LatLng destination;
  final Function(LatLng)? onLocationUpdated;
  final LatLng? driverLocation;

  const UserMapWidget({super.key, required this.route, required this.origin, required this.destination, this.onLocationUpdated, this.driverLocation});

  @override
  State<UserMapWidget> createState() => _UserMapWidgetState();
} */

/*class _UserMapWidgetState extends State<UserMapWidget> {
  late GoogleMapController googleMapController;
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? customIcon;
  BitmapDescriptor? originIcon;
  BitmapDescriptor? destinationIcon;
  LatLng? currentLocation;
  bool iconLoaded = false;
  bool _mapReady = false;
  Marker? driverMarker;

  @override
  void initState() {
    super.initState();
    _initializeMapData();
    _loadCustomIcons();
  }

  @override
  void didUpdateWidget(UserMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.route != oldWidget.route) {
      _initializeMapData();
      _moveCameraToRoute();
    }

    if (widget.driverLocation != null && widget.driverLocation != oldWidget.driverLocation) {
      _updateDriverMarker(widget.driverLocation!);
      _moveToCameraToDriver(widget.driverLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: _polylines,
          myLocationButtonEnabled: false,
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
            _controller.complete(controller);
            _mapReady = true;
            //  setDarkMode();
            _moveCameraToRoute();
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(4.709870566194833, -74.07554855445838),
            zoom: 5.5,
          ),
        ),
      ],
    );
  }

  Future<void> _loadCustomIcons() async {
   originIcon =    await _getMarkerFromIcon(Icons.circle, const Color(0xFF076461), size: 75.0);
   destinationIcon =   await _getMarkerFromIcon(Icons.circle, Colors.red, size: 75.0);
  /*  customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(20, 20)),
      'assets/images/location.png',      
    ); */

    setState(() {
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
          icon: originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destination,
          icon: destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    if (widget.route.isNotEmpty) {
      _polylines.add(Polyline(
        polylineId: const PolylineId("route"),
        points: widget.route.map((p) => LatLng(p['lat']!, p['lng']!)).toList(),
        color: AppTheme.primarycolor,
        width: 7,
      ));
    }
    print("🚗 Dibujando ruta con ${widget.route.length} puntos");
    setState(() {});
  }

  Future<void> _moveCameraToRoute() async {
    if (!_mapReady || widget.route.isEmpty) return;

    final controller = await _controller.future;

    await Future.delayed(Duration.zero);

    final bounds = _calculateRouteBounds();

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } catch (e) {
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

  Future<void> _moveToCameraToDriver(LatLng driverPosition) async {
    if (!_mapReady) return;

    final controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newLatLngZoom(driverPosition, 15));
  }

  void _updateDriverMarker(LatLng newPosition) {
    if (widget.driverLocation != null && customIcon != null) {
      final newMarker = Marker(
        markerId: const MarkerId('driver'),
        position: newPosition,
        infoWindow: const InfoWindow(title: "Conductor"),
        icon: customIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      setState(() {
        markers.removeWhere((m) => m.markerId == const MarkerId('driver'));
        markers.add(newMarker);
      });
    }
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

  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }
} */

class UserMapWidget extends StatefulWidget {
  final List<LatLng> route;
  final LatLng origin;
  final LatLng destination;
  final Function(LatLng)? onLocationUpdated;
  final LatLng? driverLocation;

  const UserMapWidget({
    super.key,
    required this.route,
    required this.origin,
    required this.destination,
    this.onLocationUpdated,
    this.driverLocation,
  });

  @override
  State<UserMapWidget> createState() => _UserMapWidgetState();
}

class _UserMapWidgetState extends State<UserMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _mapReady = false;

  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;
  BitmapDescriptor? _driverIcon;

  final LatLng _defaultLocation = const LatLng(4.709870566194833, -74.07554855445838);

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _drawRoute();
    });
  }

  @override
  void didUpdateWidget(covariant UserMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.route != oldWidget.route && _mapReady) {
      _drawRoute();
    }

    if (widget.driverLocation != null && widget.driverLocation != oldWidget.driverLocation && _mapReady) {
      print("📍 [didUpdateWidget] Nueva ubicación del conductor: ${widget.driverLocation}");
      _updateDriverMarker(widget.driverLocation!);
      _moveCameraToDriver(widget.driverLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🧱 UserMapWidget.build ejecutado con driverLocation: ${widget.driverLocation}");
    return Stack(
      children: [
        GoogleMap(
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (controller) async {
            _mapController = controller;
            _controller.complete(controller);
            _mapReady = true;

            await Future.delayed(const Duration(microseconds: 300));

            if (widget.driverLocation != null) {
              print("🚀 onMapCreated: driverLocation disponible, creando marcador...");
              _updateDriverMarker(widget.driverLocation!);
              _moveCameraToDriver(widget.driverLocation!);
            }
            if (widget.route.isNotEmpty) {
              _drawRoute();
            }
          },
          initialCameraPosition: CameraPosition(
            target: widget.route.isNotEmpty ? widget.origin : _defaultLocation,
            zoom: widget.route.isNotEmpty ? 14 : 5.5,
          ),
        ),
        Positioned(
          top: 20,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton(
                backgroundColor: Colors.white,
                heroTag: "zoom_in",
                mini: true,
                onPressed: () async {
                  final controller = await _controller.future;
                  controller.animateCamera(CameraUpdate.zoomIn());
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 1),
              FloatingActionButton(
                backgroundColor: Colors.white,
                heroTag: "zoom_out",
                mini: true,
                onPressed: () async {
                  final controller = await _controller.future;
                  controller.animateCamera(CameraUpdate.zoomOut());
                },
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadCustomIcons() async {
    _originIcon = await _getMarkerFromIcon(Icons.circle, AppTheme.greenColors, size: 30, );
    _destinationIcon = await _getMarkerFromIcon(Icons.circle, Colors.blueAccent, size: 30,);
    _driverIcon = await _getMarkerFromIconDriver(Icons.navigation, Colors.black, size: 50.0);

     if (_mapReady && widget.driverLocation != null) {
      print("🛠 Desde _loadCustomIcons: Agregando marcador del conductor");
      _updateDriverMarker(widget.driverLocation!);
      _moveCameraToDriver(widget.driverLocation!);
    }
  }

  void _drawRoute() {
    if (!_mapReady || widget.route.isEmpty) {
      print("⚠️ No hay suficientes puntos para dibujar la ruta.");
      return;
    }

    Future.delayed(const Duration(microseconds: 300), () {
      _centerMap(widget.route);
    });

    final Set<Marker> newMarkers = {
      Marker(markerId: const MarkerId('origin'), position: widget.origin, icon: _originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), anchor: const Offset(0.5, 0.5)),
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.route.isNotEmpty ? widget.route.last : widget.destination,
        icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        anchor: const Offset(0.5, 0.5),
      ),
    };

    if (widget.driverLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: widget.driverLocation!,
          icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    print("📍 Dibujando ${widget.route.length} puntos en la ruta:");
    for (var i = 0; i < widget.route.length; i++) {
      print("   Punto $i: ${widget.route[i].latitude}, ${widget.route[i].longitude}");
    }

    final Polyline routePolyline = Polyline(
      polylineId: const PolylineId('user_route'),
      color: AppTheme.primarycolor,
      width: 7,
      points: widget.route,
      geodesic: false,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    setState(() {
      _polylines.clear();
      _markers = newMarkers;
      _polylines = {routePolyline};
    });

    _centerMap(widget.route);
  }

  Future<void> _centerMap(List<LatLng> points) async {
    try {
      if (points.length < 2) {
        print("⚠️ Muy pocos puntos para centrar el mapa");
        return;
      }

      if (_mapController == null) {
        print("⚠️ Controlador de mapa no inicializado");
        return;
      }

      final bounds = _calculateBounds(points);

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } catch (e) {
      print("🎯 Error centrando mapa: $e");
      // Fallback: centrar en el primer punto con zoom adecuado
      if (points.isNotEmpty && _mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(points.first, 15),
        );
      }
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
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

  void _updateDriverMarker(LatLng location) {
    print("🚗 [updateDriverMarker] Actualizando marcador a: $location");
    print("🧩 ¿Driver icon está listo? ${_driverIcon != null}");
    print("🎯 Total de marcadores antes: ${_markers.length}");

    final marker = Marker(
      markerId: const MarkerId("driver"),
      position: location,
      icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == "driver");
      _markers.add(marker);
    });
  }

   Future<BitmapDescriptor> _getMarkerFromIconDriver(
    IconData iconData,
    Color fillColor, {
    double size = 80.0,
    Color borderColor = Colors.white, // color del borde
    double borderWidth = 6.0, // grosor del borde
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

      // 2. Dibuja el círculo interior (relleno principal)
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius - borderWidth, fillPaint);

      // 3. Dibuja el icono encima
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      final textStyle = TextStyle(
        fontSize: iconSize * 0.8,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: Colors.white, // color del ícono
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

  Future<void> _moveCameraToDriver(LatLng driverPosition) async {
    try {
      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(driverPosition, 16),
      );
    } catch (e) {
      print("❌ Error al mover la cámara al conductor: $e");
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
