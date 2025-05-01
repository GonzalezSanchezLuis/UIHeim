import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class GpsValidatorService {
  static Future<bool> isGpsActuallyEnabled() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        return false;
      }

      // No pedir ubicación aquí, solo confirmamos permiso y servicio activo.
      return true;
    } catch (e) {
      debugPrint("Error en GPS Validator: $e");
      return false;
    }
  }

  static Future<void> showGpsDialog(BuildContext context) async {
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
