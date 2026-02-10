import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/move/calculate_price_view.dart';
import 'package:holi/src/view/screens/move/schedule_move_view.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:holi/src/viewmodels/move/confirm_move_viewmodel.dart';
import 'package:provider/provider.dart';

class ButtonCalculatePrice extends StatelessWidget {
  const ButtonCalculatePrice({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatePrice()));
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: const Color(0xFFFFBC11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "¡Comencemos!",
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ScheduleMoveWidget extends StatelessWidget {
  const ScheduleMoveWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ScheduleMove()));
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Programar mudanza",
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ButtonLogOut extends StatelessWidget {
  ButtonLogOut({
    super.key,
  });
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final isLoggedOut = await _authService.logout();
        if (isLoggedOut) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al cerrar sesión")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
        backgroundColor: AppTheme.warningcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Text(
        "Cerrar sesión",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

class ConnectButton extends StatelessWidget {
  final Function(LatLng) onConnected;

  const ConnectButton({super.key, required this.onConnected});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverStatusViewmodel>(
      builder: (context, provider, _) {
        // Determina el color del botón
        final Color buttonBackgroundColor = provider.isLoading ? AppTheme.confirmationscolor.withOpacity(0.6) : AppTheme.confirmationscolor;

        final Widget buttonChild = provider.isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Conectando...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Text(
                'Conectarme',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              );

        return ElevatedButton(
          onPressed: () async {
            if (!provider.isLoading) {
              LatLng? newLocation = await provider.connectDriverViewmodel(context);
              if (newLocation != null) {
                onConnected(newLocation);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: SizedBox(
            height: 40,
            child: Center(
              child: buttonChild,
            ),
          ),
        );
      },
    );
  }
}

class DisconnectButton extends StatelessWidget {
  const DisconnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverStatusViewmodel>(
      builder: (context, provider, _) {
        if (provider.connectionStatus != ConnectionStatus.CONNECTED) {
          return const SizedBox.shrink();
        }

        final Color buttonBackgroundColor = provider.isLoading ? AppTheme.warningcolor.withOpacity(0.6) : AppTheme.warningcolor;

        return ElevatedButton(
          onPressed: () {
            if (!provider.isLoading) {
              provider.disconnectDriverViewmodel();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: SizedBox(
            height: 40,
            child: Center(
              child: provider.isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          "Desconectando...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      "Desconectarme",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class ConfirmButton extends StatelessWidget {
  final String calculatedPrice;
  final String distanceKm;
  final String duration;
  final MoveType? typeOfMove;
  final String estimatedTime;
  final List<LatLng> route;
  final LocationViewModel locationViewModel;
  final VoidCallback onConfirmed;
  final double? destinationLat;
  final double? destinationLng;
  final String? originAddressText;
  final String? destinationAddressText;
  final String? paymentMethod;
  final int userId;
  final String? buttonText;

  const ConfirmButton({
    required this.calculatedPrice,
    required this.distanceKm,
    required this.duration,
    required this.typeOfMove,
    required this.estimatedTime,
    required this.route,
    required this.locationViewModel,
    required this.onConfirmed,
    required this.userId,
    this.destinationLat,
    this.destinationLng,
    this.originAddressText,
    this.destinationAddressText,
    this.paymentMethod,
    this.buttonText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ConfirmMoveViewModel>(context, listen: false);
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 100,
        child: ElevatedButton(
          onPressed: viewModel.isLoading
              ? null
              : () async {
                  final result = viewModel.confirmMove(
                      context: context,
                      typeOfMove: typeOfMove!,
                      calculatedPrice: calculatedPrice,
                      distanceKm: distanceKm,
                      duration: duration,
                      estimatedTime: estimatedTime,
                      route: route,
                      locationViewModel: locationViewModel,
                      destinationLat: destinationLat,
                      destinationLng: destinationLng,
                      originAddressText: viewModel.originAddressText,
                      destinationAddressText: viewModel.destinationAddressText,
                      paymentMethod: paymentMethod,
                      userId: userId);

                  onConfirmed();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.confirmationscolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: viewModel.isLoading
              ? const CircularProgressIndicator(color: Colors.black)
              : Text(buttonText ?? "Confirmar y relajarme", style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ));
  }
}
