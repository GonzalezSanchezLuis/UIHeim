import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsWidget extends StatefulWidget {
  const GoogleMapsWidget({super.key});

  @override
  State<GoogleMapsWidget> createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  LatLng myCurrentLocation = const LatLng(4.713976515281342, -74.07142868168461);
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  final Set<Polyline> _polylines = {};


  // Lista de puntos para la polilínea
  List<LatLng> pointsOnMap = [
    const LatLng(4.709767037617369, -74.0796480255677),
    const LatLng(4.698957399859014, -74.07427955389299),
    const LatLng(4.696691745387296, -74.08374000225146),
  ];

  @override
  void initState() {
    super.initState();

    // Añadir marcadores y polilíneas a la inicialización
    for (int i = 0; i < pointsOnMap.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: pointsOnMap[i],
          infoWindow: const InfoWindow(
            title: "Lugar en mi país",
            snippet: "Hermoso lugar",
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    }

    _polylines.add(
      Polyline(
        polylineId: const PolylineId("Route"),
        points: pointsOnMap,
        color: const Color(0xFFFF3D00),
        width: 5,
      ),
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
  void dispose(){
    googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mapa de Google
        GoogleMap(
          polylines: _polylines,
          myLocationButtonEnabled: false,
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
            setDarkMode(); // Llamar a setDarkMode al crear el mapa
          },
          initialCameraPosition: CameraPosition(
            target: myCurrentLocation,
            zoom: 14,
          ),
        ),
        // Controles superpuestos
        Positioned(
          width: 50,
          top: 60,
          left: 20,
          child: Column(
            children: [
              // Botón de Mi Ubicación
              FloatingActionButton(
                heroTag: 'location',
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.my_location,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () async {
                  try {
                    Position position = await currentPosition();
                    googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(position.latitude, position.longitude),
                          zoom: 14,
                        ),
                      ),
                    );

                    markers.add(
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: LatLng(position.latitude, position.longitude),
                      ),
                    );

                    setState(() {});
                  } catch (e) {
                    print("Error al obtener la ubicación: $e");
                  }
                },
              ),
              const SizedBox(height: 10),
              // Botón de Zoom In
              FloatingActionButton(
                heroTag: 'zoomIn',
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.zoom_in,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () {
                  googleMapController.animateCamera(
                    CameraUpdate.zoomIn(),
                  );
                },
              ),
              const SizedBox(height: 10),
              // Botón de Zoom Out
              FloatingActionButton(
                heroTag: 'zoomOut',
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.zoom_out,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () {
                  googleMapController.animateCamera(
                    CameraUpdate.zoomOut(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Position> currentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están desactivados');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Permiso de ubicación denegado");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Los permisos de ubicación están permanentemente denegados',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
 
}


