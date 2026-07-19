import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  GoogleMap? _mapWidget;

  final LatLng _defaultLocation = const LatLng(4.709870566194833, -74.07554855445838);

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
  }

  @override
  void didUpdateWidget(covariant UserMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final routeChanged = widget.route != oldWidget.route;
    final driverMoved = widget.driverLocation != oldWidget.driverLocation;

    if ((routeChanged || driverMoved) && _mapReady) {
      // Solo centramos el mapa si la ruta cambió o si es la primera vez que aparece el conductor
      bool shouldCenter = routeChanged || (oldWidget.driverLocation == null && widget.driverLocation != null);
      _drawRoute(shouldCenter: shouldCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🧱 UserMapWidget.build ejecutado con driverLocation: ${widget.driverLocation}");
    return Stack(
      children: [
        //  _mapWidget!,
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.route.isNotEmpty ? widget.origin : _defaultLocation,
            zoom: widget.route.isNotEmpty ? 12 : 5.5,
          ),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          markers: _markers,
          polylines: _polylines,
          padding: EdgeInsets.only(bottom: 250.h, top: 10.h, right: 0, left: 0),
          onMapCreated: (controller) async {
            _mapController = controller;
            _controller.complete(controller);
            _mapReady = true;

            if (widget.driverLocation != null) {
              print("🚀 onMapCreated: driverLocation disponible, creando marcador...");
              _updateDriverMarker(widget.driverLocation!);
              _moveCameraToDriver(widget.driverLocation);
            }
            if (widget.route.isNotEmpty || widget.driverLocation != null) {
              _drawRoute();
            } else {
              _moveCameraToDriver(widget.driverLocation);
            }
          },
        ),
        Positioned(
          top: 140.h,
          right: 10.w,
          child: Column(
            children: [
              SizedBox(
                width: 35.w,
                height: 35.w,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  heroTag: "zoom_in",
                  mini: true,
                  onPressed: () async {
                    final controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: Icon(
                    Icons.add,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: 35.w,
                height: 35.w,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  heroTag: "zoom_out",
                  mini: true,
                  onPressed: () async {
                    final controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomOut());
                  },
                  child: Icon(
                    Icons.remove,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadCustomIcons() async {
    _originIcon = await _getMarkerFromIcon(
      Icons.circle,
      AppTheme.greenColors,
      size: 30.w,
    );
    _destinationIcon = await _getMarkerFromIcon(
      Icons.circle,
      Colors.blueAccent,
      size: 30.w,
    );
    _driverIcon = await _getMarkerFromIconDriver(Icons.circle, Colors.greenAccent, size: 15.w);

    if (_mapReady && widget.driverLocation != null) {
      print("🛠 Desde _loadCustomIcons: Agregando marcador del conductor");
      _updateDriverMarker(widget.driverLocation!);
      _moveCameraToDriver(widget.driverLocation!);
    }
    if (mounted) _drawRoute();
  }

  void _drawRoute({bool shouldCenter = false}) {
    if (!_mapReady) return;

    List<LatLng> pointsToInclude = List.from(widget.route);
    pointsToInclude.add(widget.origin);
    pointsToInclude.add(widget.destination);

    if (widget.driverLocation != null) pointsToInclude.add(widget.driverLocation!);

    final Set<Marker> updatedMarkers = {
      Marker(markerId: const MarkerId('origin'), position: widget.origin, icon: _originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), anchor: const Offset(0.5, 0.5)),
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.route.isNotEmpty ? widget.route.last : widget.destination,
        icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        anchor: const Offset(0.5, 0.5),
      ),
    };

    if (widget.driverLocation != null && _driverIcon != null) {
      updatedMarkers.add(Marker(
        markerId: const MarkerId('driver'),
        position: widget.driverLocation!,
        icon: _driverIcon!,
        rotation: 0,
        anchor: const Offset(0.5, 0.5),
        zIndex: 10,
      ));
    }

    Set<Polyline> updatedPolylines = {};
    if (widget.route.isNotEmpty) {
      updatedPolylines.add(Polyline(
        polylineId: const PolylineId('user_route'),
        color: AppTheme.primarycolor,
        width: 6.w.toInt(),
        points: widget.route,
        geodesic: false,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ));
    }

    setState(() {
      _markers = updatedMarkers;
      _polylines = updatedPolylines;
    });

    if (shouldCenter && pointsToInclude.isNotEmpty) {
      _centerMap(pointsToInclude);
    }
  }

  Future<void> _centerMap(List<LatLng> points) async {
    try {
      if (points.length < 2) {
        print("⚠️ Muy pocos puntos para centrar el mapa");
        if (points.isNotEmpty && _mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(points.first, 16.0),
          );
        }
        return;
      }

      if (_mapController == null) {
        print("⚠️ Controlador de mapa no inicializado");
        return;
      }

      final bounds = _calculateBounds(points);
      double adaptivePadding = 80.w;

      await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, adaptivePadding));
    } catch (e) {
      print("🎯 Error centrando mapa: $e");

      if (points.isNotEmpty && _mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(points.first, 14.0),
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
    if (_driverIcon == null) return;
    print("🚗 [updateDriverMarker] Actualizando marcador a: $location");
    print("🧩 ¿Driver icon está listo? ${_driverIcon != null}");
    print("🎯 Total de marcadores antes: ${_markers.length}");

    final marker = Marker(
      markerId: const MarkerId("driver"),
      position: location,
      icon: _driverIcon!,
      rotation: 0,
      anchor: const Offset(0.5, 0.5),
      zIndex: 10,
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == "driver");
      _markers.add(marker);
    });
  }

  Future<BitmapDescriptor> _getMarkerFromIconDriver(IconData iconData, Color fillColor, {required double size, Color borderColor = Colors.black, double? borderWidth}) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final double centerOffset = size / 2;
    final center = Offset(centerOffset, centerOffset);
    final radius = size / 2;

    final double adaptiveBorder = borderWidth ?? (size * 0.08);

    canvas.drawCircle(center, radius, Paint()..color = borderColor);
    canvas.drawCircle(center, radius - adaptiveBorder, Paint()..color = fillColor);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.8,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: Colors.black,
      ),
    );
    textPainter.layout();

    textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)));

    final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
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

  Future<void> _moveCameraToDriver(LatLng? driverPosition) async {
    try {
      if (driverPosition == null) return;

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
