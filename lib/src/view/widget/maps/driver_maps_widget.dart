
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  GoogleMapController? _mapController;
  //final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  bool _mapReady = false;
  bool _isIconsLoaded = false;
  bool _hasCenteredOnDriver = false;
  bool _isUserInteracting = false;
  bool _isSimulating = false;

  late BitmapDescriptor _driverIcon;
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;

  double _currentZoom = 5.0;
  double get _activeLocationZoom => 14.5 > 15 ? 15.0 : 14.5.sp;
  final LatLng _defaultLocation = const LatLng(4.709870566194833, -74.07554855445838);

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
      Future.delayed(const Duration(milliseconds: 300), () {
        _drawRoute();
      });
    }

    if (widget.driverLocation != null && widget.driverLocation != oldWidget.driverLocation) {
      _updateDriverMarker(widget.driverLocation!);
      if (!_isUserInteracting) {
        _animateCamera(widget.driverLocation!);
      }
    }

    if (hasLocationNow) {
      _updateDriverMarker(widget.driverLocation!);

      if (!_hasCenteredOnDriver) {
        _hasCenteredOnDriver = true;
        _animateCamera(widget.driverLocation!, zoom: _activeLocationZoom);
        widget.onDriverConnected?.call(widget.driverLocation!);
      } else if (!_isUserInteracting && locationChanged) {
        _animateCamera(widget.driverLocation!);
      }
    }
    if (widget.route != oldWidget.route || widget.driverToOriginRoute != oldWidget.driverToOriginRoute) {
      _drawRoute();
    }
  }



  
  Future<void> _animateCamera(LatLng target, {double? zoom}) async {
    if (!_mapReady || _mapController == null || !mounted) return;

    try {
      await _mapController!.animateCamera(
        zoom != null ? CameraUpdate.newLatLngZoom(target, zoom) : CameraUpdate.newLatLng(target),
      );
    } catch (_) {}
  }

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

    if (mounted) {
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == "driver_location");
        _markers.add(driverMarker);
      });
    }
  }

  void _drawRoute() {
    if (!_mapReady || !mounted || _mapController == null) return;

    final newPolylines = <Polyline>{};
    final newMarkers = <Marker>{};

    final double adaptivePolylineWidth = 6.w.toInt().toDouble();

    if (widget.route.isNotEmpty) {
      newPolylines.add(Polyline(polylineId: const PolylineId('route'), color: Colors.green, width: adaptivePolylineWidth.toInt(), points: widget.route, startCap: Cap.roundCap, endCap: Cap.roundCap));

      newMarkers.add(Marker(
        markerId: const MarkerId('origin'),
        position: widget.route.first,
        icon: _originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        anchor: const Offset(0.5, 0.5),
      ));

      newMarkers.add(Marker(markerId: const MarkerId('destination'), position: widget.route.last, icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), anchor: const Offset(0.5, 0.5)));
    }

    if (widget.driverToOriginRoute != null && widget.driverToOriginRoute!.isNotEmpty) {
      newPolylines.add(Polyline(polylineId: const PolylineId('driver_to_origin'), color: Colors.orange, width: adaptivePolylineWidth.toInt(), points: widget.driverToOriginRoute!, patterns: [PatternItem.dash(20), PatternItem.gap(10)]));
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
    double adaptivePadding = 60.w;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, adaptivePadding),
    );
  }

  Future<void> _loadCustomIcons() async {
    try {
      final double adaptiveSize = 70.w;

      _driverIcon = await _getMarkerFromIcon(Icons.navigation, Colors.black, size: adaptiveSize);
      _originIcon = await _getMarkerFromIconOriginToDestination(Icons.circle, Colors.green, size: adaptiveSize);
      _destinationIcon = await _getMarkerFromIconOriginToDestination(Icons.circle, Colors.blueAccent, size: adaptiveSize);
      _isIconsLoaded = true;
      if (widget.driverLocation != null) _updateDriverMarker(widget.driverLocation!);
      setState(() {});
    } catch (e) {
      _driverIcon = BitmapDescriptor.defaultMarker;
    }
  }

  Future<BitmapDescriptor> _getMarkerFromIconOriginToDestination(IconData iconData, Color color, {required double size}) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(fontSize: size * 0.8, fontFamily: iconData.fontFamily, color: color),
    );
    textPainter.layout();

    textPainter.paint(canvas, Offset(size * 0.1, size * 0.1));
    final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _getMarkerFromIcon(IconData iconData, Color fillColor, {required double size, Color borderColor = Colors.white, double? borderWidth}) async {
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
      style: TextStyle(fontSize: size * 0.8, fontFamily: iconData.fontFamily, package: iconData.fontPackage, color: Colors.white),
    );
    textPainter.layout();

    textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)));

    final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
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

  /*double _getBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (math.pi / 180);
    final lon1 = start.longitude * (math.pi / 180);
    final lat2 = end.latitude * (math.pi / 180);
    final lon2 = end.longitude * (math.pi / 180);
    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * (180 / math.pi) + 360) % 360;
  }*/

  double _getBearing(LatLng start, LatLng end) {
    const double degreesToRadians = math.pi / 180.0;
    const double radiansToDegrees = 180.0 / math.pi;

    final double lat1 = start.latitude * degreesToRadians;
    final double lon1 = start.longitude * degreesToRadians;
    final double lat2 = end.latitude * degreesToRadians;
    final double lon2 = end.longitude * degreesToRadians;

    final double dLon = lon2 - lon1;
    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x) * radiansToDegrees;
    return (bearing + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    final double adaptiveBottomPadding = 340.h;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _defaultLocation, zoom: _currentZoom),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          padding: EdgeInsets.only(bottom: adaptiveBottomPadding, top: MediaQuery.of(context).padding.top + 10.h, right: 10.w, left: 10.w),
          onMapCreated: (controller) async {
            _mapController = controller;
            await Future.delayed(const Duration(microseconds: 500));

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              setState(() {
                _mapReady = true;
              });

              Future.microtask(() {
              if (widget.driverLocation != null) {
                  _updateDriverMarker(widget.driverLocation!);
                  _animateCamera(widget.driverLocation!, zoom: _activeLocationZoom);
                  _hasCenteredOnDriver = true;
                }

              });
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
            top: MediaQuery.of(context).padding.top + 20.h,
            right: 20.w,
            child: SizedBox(
              width: 45.w,
              height: 45.w,
              child: FloatingActionButton(
              mini: true,
              elevation: 4,
              backgroundColor: Colors.black,
              
              shape: const CircleBorder(),
              onPressed: () {
                setState(() => _isUserInteracting = false);
                if (widget.driverLocation != null) _animateCamera(widget.driverLocation!, zoom: _activeLocationZoom);
              },
              child:  Icon(Icons.my_location, color: Colors.white, size: 22.sp,),
            ),
            )
          ),
        if (!_mapReady) Container(
            color: Colors.white.withOpacity(0.8),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 3,
              ),
            ),
          ),
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
