import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/controllers/moves/confirm_move_controller.dart';
import 'package:holi/src/view/screens/move/calculate_price_view.dart';
import 'package:holi/src/view/screens/move/schedule_move_view.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
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
          borderRadius: BorderRadius.circular(15),
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
  const ConnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverStatusViewmodel>(
      builder: (context, provider, _) {
        return ElevatedButton(
          onPressed: provider.isLoading ? null : () => provider.connectDriverViewmodel(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: provider.isLoading ? Colors.grey : AppTheme.confirmationscolor,
            minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),         
          child: provider.isLoading ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ) 
                :
             const Text(
            'Conectarme',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
    final provider = Provider.of<DriverStatusViewmodel>(context);
    if (provider.connectionStatus != ConnectionStatus.CONNECTED) {
      return const SizedBox.shrink();
    }
    return ElevatedButton(
      onPressed: provider.isLoading ? null : provider.disconnectDriverViewmodel,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.warningcolor,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: provider.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            )
          : const Stack(
        alignment: Alignment.center,
        children: [
          Text(
            "Salir",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmButton extends StatelessWidget {
  final String calculatedPrice;
  final String distanceKm;
  final String duration;
  final String typeOfMove;
  final String estimatedTime;
  final List<Map<String, double>> route;
  final double userLat;
  final double userLng;
  final VoidCallback onConfirmed;

  const ConfirmButton({
    required this.calculatedPrice,
    required this.distanceKm,
    required this.duration,
    required this.typeOfMove,
    required this.estimatedTime,
    required this.route,
    required this.userLat,
    required this.userLng,
    required this.onConfirmed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final confirmController = Provider.of<ConfirmMoveController>(context, listen: false);
    return ElevatedButton(
      onPressed: () {
        confirmController.confirmMove(typeOfMove: typeOfMove, calculatedPrice: calculatedPrice, distanceKm: distanceKm, duration: duration, estimatedTime: estimatedTime, route: route, userLat: userLat, userLng: userLng);
        onConfirmed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Buscar un vehículo",
        style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}
