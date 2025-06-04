import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class GpsValidatorService {
 static Future<bool> ensureLocationServiceAndPermission(BuildContext context) async {
    // 1. Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 2. Detectar si están denegados permanentemente
    if (permission == LocationPermission.deniedForever) {
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permiso requerido'),
          content: const Text('Los permisos de ubicación han sido denegados permanentemente. Por favor, actívalos desde la configuración.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Abrir configuración'),
            ),
          ],
        ),
      );

      if (openSettings == true) {
        await Geolocator.openAppSettings();
      }

      return false;
    }

    if (permission == LocationPermission.denied) {
      // Aún negado después del request
      return false;
    }

    // 3. Verificar si el GPS está activo
    bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      await _showGpsDialog(context);
      gpsEnabled = await Geolocator.isLocationServiceEnabled();
    }

    return gpsEnabled;
  }

   


  static Future<void> _showGpsDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("GPS Requerido", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17.0)),
        content: const Text(
          "Para continuar, el dispositivo necesita usar la precisión de la ubicación",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No, gracias", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(backgroundColor: AppTheme.thirdcolor2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            style: TextButton.styleFrom(backgroundColor: AppTheme.secondarycolor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            child: const Text(
              "Activar GPS",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

  }
}
