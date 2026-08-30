import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/service/location/location_service.dart';
import 'package:holi/src/service/travel/calculate_price_service.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatePriceViewmodel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? formattedPrice;
  String? distanceKm;
  String? timeMin;
  List<Map<String, double>>? route;
  String? addressee;
  String? recipientPhoneNumber;
  String? discountAmount;
  String? discountPercentage;

  Future<void> handleRequestVehicle({
    required BuildContext context,
    required MoveType? typeOfMove,
    required String numberOfRooms,
    required String originAddress,
    required String destinationAddress,
    required LocationService locationService,
    required LocationViewModel locationViewModel,
    required String addressee,
    required String recipientPhoneNumber,
    String? destinationPlaceId,
    int? userId,
    String? destinationLat,
    String? destinationLng,
    String? discountAmount,
    String? discountPercentage,
    String? originalPrice,

  }) async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      errorMessage = "ID de usuario no encontrado";
      isLoading = false;
      notifyListeners();
      return;
    }

    Map<String, double>? originCoords;
    Map<String, double>? destinationCoords;

    if (originAddress.isEmpty) {
      // ignore: use_build_context_synchronously
      final position = await locationViewModel.updateLocation(context);
      if (position != null) {
        originCoords = {"latitude": position.latitude, "longitude": position.longitude};
      }
    } else {
      originCoords = await locationService.getCoordinatesFromAddress(originAddress);
    }

    if (destinationAddress.isNotEmpty) {
      if (destinationPlaceId != null && destinationPlaceId.isNotEmpty) {
        destinationCoords = await locationService.getCoordinatesFromPlaceId(destinationPlaceId);
      } else {
        destinationCoords = await locationService.getCoordinatesFromAddress(destinationAddress);
      }
    }

    if (originCoords == null || destinationCoords == null) {
      errorMessage = "No se pudieron obtener coordenadas";
      isLoading = false;
      notifyListeners();
      return;
    }

    final response = await CalculatePriceService().calculatedPrice(
        typeOfMove: typeOfMove,
        numberOfRooms: numberOfRooms,
        originAddress: originAddress,
        destinationAddress: destinationAddress,
        originLat: originCoords['latitude'],
        originLng: originCoords['longitude'],
        destinationLat: destinationCoords['latitude'],
        destinationLng: destinationCoords['longitude'],
        addressee: addressee,
        recipientPhoneNumber: recipientPhoneNumber,
        userId: userId,
        );

    if (response != null) {
      try {
        formattedPrice = response['formattedPrice'] ?? "N/A";
        distanceKm = response['distanceKm']?.toString() ?? "0.0";
        timeMin = response['timeMin']?.toString() ?? "0";
        discountAmount = response['discountAmount']?.toString() ?? "0";
        discountPercentage = response['discountPercentage']?.toString() ?? "0";
        originalPrice = response['basePrice']?.toString() ?? "0";

        final routeData = List<Map<String, double>>.from(response['route'] ?? []);

        final List<LatLng> route = routeData.map((point) => LatLng(point['lat'] ?? 0.0, point['lng'] ?? 0.0)).toList();

        for (var p in route) {
          print("📍 Punto: ${p.latitude}, ${p.longitude}");
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeUserView(
              calculatedPrice: formattedPrice!,
              distanceKm: distanceKm!,
              duration: timeMin!,
              typeOfMove: typeOfMove,
              estimatedTime: timeMin!,
              route: route ?? [],
              destinationLat: destinationCoords!['latitude']!,
              destinationLng: destinationCoords!['longitude']!,
              origin: LatLng(originCoords!['latitude']!, originCoords['longitude']!),
              destination: LatLng(destinationCoords!['latitude']!, destinationCoords['longitude']!),
              originName: originAddress.isEmpty ? locationViewModel.currentAddress : originAddress,
              destinationName: destinationAddress,
              addressee: addressee,
              recipientPhoneNumber: recipientPhoneNumber,
              discountAmount: discountAmount,
              discountPercentage: discountPercentage,
              originalPrice: originalPrice,
            ),
          ),
        );
      } catch (e) {
        errorMessage = "Error al procesar la respuesta";
      }
    } else {
      errorMessage = "Error en la solicitud";
    }

    isLoading = false;
    notifyListeners();
  }
}
