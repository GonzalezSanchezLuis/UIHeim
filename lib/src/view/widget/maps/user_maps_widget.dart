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
    print("🔄 [UserMapWidget] didUpdateWidget: routeChanged = $routeChanged (old: ${oldWidget.route.length}, new: ${widget.route.length})");
    print("🗺️ [UserMapWidget] _mapReady: $_mapReady");

    final driverMoved = widget.driverLocation != oldWidget.driverLocation;

    // Siempre que la ruta cambie o el conductor se mueva, redibujamos y centramos.
    // El centrado es clave para mantener la vista completa.
    if ((routeChanged || driverMoved) && _mapReady) _drawRoute(shouldCenter: true);
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
          padding: EdgeInsets.only(bottom: 150.h, top: 10.h, right: 0, left: 0),
          onMapCreated: (controller) async {
            _mapController = controller;
            _controller.complete(controller);
            _mapReady = true;
            print("✅ [UserMapWidget] onMapCreated: Mapa listo. widget.route.length: ${widget.route.length}");

            // Al crear el mapa, si ya hay datos, los dibujamos y centramos la vista.
            if (widget.route.isNotEmpty || widget.driverLocation != null) {
              // El `shouldCenter: true` asegura que la cámara se posicione correctamente desde el inicio.
              _drawRoute(shouldCenter: true);
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
    }
    if (mounted) _drawRoute();
  }

  void _drawRoute({bool shouldCenter = false}) {
    print("🎨 [UserMapWidget] _drawRoute llamado. _mapReady: $_mapReady, widget.route.length: ${widget.route.length}");
    if (!_mapReady) return;
    print("🎨 [UserMapWidget] _drawRoute: Dibujando ruta con ${widget.route.length} puntos.");

    // Siempre incluimos origen y destino en los marcadores.
    // El destino real es el último punto de la ruta si existe.
    final Set<Marker> updatedMarkers = {
      Marker(markerId: const MarkerId('origin'), position: widget.origin, icon: _originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), anchor: const Offset(0.5, 0.5)),
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.route.isNotEmpty ? widget.route.last : widget.destination,
        icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        anchor: const Offset(0.5, 0.5),
      ),
    };

    print("📍 [UserMapWidget] _drawRoute: Añadiendo marcadores. Origen: ${widget.origin}, Destino: ${widget.destination}");

    // Si tenemos la ubicación del conductor y el ícono está listo, lo agregamos.
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

    // Si hay una ruta, la dibujamos.
    print("เส้น [UserMapWidget] _drawRoute: widget.route.isNotEmpty = ${widget.route.isNotEmpty}");
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

    // Si se debe centrar, calculamos los puntos a incluir en la vista.
    if (shouldCenter) {
      final List<LatLng> pointsToInclude = [];
      if (widget.route.isNotEmpty) {
        pointsToInclude.addAll(widget.route);
      } else {
        pointsToInclude.addAll([widget.origin, widget.destination]);
      }
      if (widget.driverLocation != null) pointsToInclude.add(widget.driverLocation!);
      _centerMap(pointsToInclude);
      if (pointsToInclude.isNotEmpty) _centerMap(pointsToInclude);
    }
  }

  Future<void> _centerMap(List<LatLng> points) async {
    try {
      // Si no hay ruta, mostramos la vista general de Colombia.
      if (widget.route.isEmpty && _mapController != null) {
        print("🗺️ No hay ruta activa. Mostrando vista de Colombia.");
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(const LatLng(4.5709, -74.2973), 5.5), // Coordenadas y zoom para Colombia
        );
        return;
      }

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

      // Check if the bounds represent a single point (or very close to it)
      // This happens when origin and destination are the same, or only one point is provided.
      if (bounds.southwest.latitude == bounds.northeast.latitude &&
          bounds.southwest.longitude == bounds.northeast.longitude) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(bounds.southwest, 14.0), // Default zoom for a single point
        );
        return;
      }
      double adaptivePadding = 80.w;

      await _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, adaptivePadding));
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
