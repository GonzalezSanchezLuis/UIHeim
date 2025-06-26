import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:another_flushbar/flushbar.dart';

class GpsValidatorService {
  static Future<bool> ensureLocationServiceAndPermission(BuildContext context) async {
    // 1. Verificar si el GPS está encendido
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _showFlushbar(
          context,
          title: "GPS desactivado",
          message: "Por favor, activa tu ubicación para continuar.",
          actionText: "Ajustes",
          onAction: () => Geolocator.openLocationSettings(),
          icon: Icons.gps_off,
          color: Colors.redAccent,
        );
      }
      return false;
    }

    // 2. Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showFlushbar(
          context,
          title: "Permisos denegados",
          message: "Debes habilitar el permiso de ubicación desde ajustes.",
          actionText: "Ajustes",
          onAction: () => Geolocator.openAppSettings(),
          icon: Icons.location_disabled,
          color: Colors.blueAccent,
        );
      }
      return false;
    }

    return true;
  }

  static void _showFlushbar(
    BuildContext context, {
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
    required IconData icon,
    required Color color,
  }) {
    Flushbar(
      title: title,
      message: message,
      backgroundColor: color,
      icon: Icon(icon, color: Colors.white, size: 28),
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(10),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 400),
      mainButton: TextButton(
        onPressed: onAction,
        child: Text(
          actionText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ).show(context);
  }
}
