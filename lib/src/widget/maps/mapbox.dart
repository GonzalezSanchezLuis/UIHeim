import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para cargar recursos desde los assets


/*class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  @override
  void initState() {
  super.initState();
   String accessToken = "sk.eyJ1IjoibHVpc3J1YmVuIiwiYSI6ImNtNHk4aWJwZTB5OW4yanB0ZXFiaWNzNGwifQ.D8rEJbsRC6WIA2GKjU_p3w";
  MapboxMapOptions options = MapboxMapsOptions(
      accessToken: 'YOUR_MAPBOX_ACCESS_TOKEN',  // Asegúrate de reemplazar con tu token de acceso real
    );
  print(accessToken);
  }

  @override
  void dispose() {
    // Libera los recursos del PointAnnotationManager
    pointAnnotationManager?.deleteAll();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Crea un administrador de anotaciones de puntos
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    // Carga la imagen desde los assets
    final ByteData bytes = await rootBundle.load('assets/images/location.png'); // Asegúrate de que el archivo existe
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Opciones para la anotación
    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(coordinates: Position(-74.00913, 40.75183)), // Coordenadas de ejemplo
      image: imageData, // Imagen personalizada
      iconSize: 3.0, // Tamaño del icono
    );

    // Agrega la anotación al mapa
    pointAnnotationManager?.create(pointAnnotationOptions);
  }

  @override
  Widget build(BuildContext context) {
    // Recupera el token desde el entorno
    String accessToken = const String.fromEnvironment("ACCESS_TOKEN");
    MapboxOptions.setAccessToken(accessToken);

    return MapWidget(
      key: const ValueKey("mapWidget"),
      onMapCreated: _onMapCreated,
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(-74.08175, 4.60971)), // Coordenadas iniciales
        zoom: 18.0, // Nivel de zoom inicial
        bearing: 0.0,
        pitch: 0.0,
      ),
    );
  }
}*/


