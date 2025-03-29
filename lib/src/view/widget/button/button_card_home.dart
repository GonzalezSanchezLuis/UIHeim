import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/controllers/moves/confirm_move_controller.dart';
import 'package:holi/src/view/screens/move/calculate_price.dart';
import 'package:holi/src/view/screens/move/schedule_move.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/service/auth/login._service.dart';
import 'package:holi/src/service/controllers/drivers/status_controller.dart';
import 'package:holi/src/viewmodels/driver/driver_status_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        "Solicitar vehículo",
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
            MaterialPageRoute(builder: (context) => const Login()),
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
    final provider = Provider.of<DriverStatusProvider>(context);

    return ElevatedButton(
      onPressed: provider.isConnected || provider.isLoading ? null : provider.connectDriver,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 50),
        backgroundColor: provider.isConnected ? Colors.grey : (AppTheme.confirmationscolor ?? Colors.blue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: provider.isLoading ? 0 : 2,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!provider.isLoading)
            Text(
              provider.isConnected ? "Conectado" : "Conectarme",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (provider.isLoading)
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
        ],
      ),
    );
  }
}



class DisconnectButton extends StatelessWidget {
  const DisconnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverStatusProvider>(context);

    return ElevatedButton(
      onPressed: (!provider.isConnected || provider.isLoading) ? null : provider.disconnectDriver,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 50),
        backgroundColor: !provider.isConnected ? Colors.grey : (AppTheme.warningcolor ?? Colors.blue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: provider.isLoading ? 0 : 2,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!provider.isLoading)
            Text(
              !provider.isConnected ? "Desconectado" : "Desconectarme",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (provider.isLoading)
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
        ],
      ),
    );
  }
}





class ConfrimButton extends StatelessWidget {
  final String calculatedPrice;
  final String distanceKm;
  final String duration;
  final String typeOfMove;
  final String estimatedTime;
  final List<Map<String, double>> route;

  const ConfrimButton({
    required this.calculatedPrice,
    required this.distanceKm,
    required this.duration,
    required this.typeOfMove,
    required this.estimatedTime,
    required this.route,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final confirmController = Provider.of<ConfirmMoveController>(context, listen: false);
    return ElevatedButton(
      onPressed: () {
        confirmController.confirmMove(
          typeOfMove: typeOfMove, 
          calculatedPrice: calculatedPrice,
          distanceKm: distanceKm,
          duration: duration,
          estimatedTime: estimatedTime,
          route: route,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Confirmar",
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}
