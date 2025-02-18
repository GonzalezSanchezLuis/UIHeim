import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/move/request_vehicle.dart';
import 'package:holi/src/view/screens/move/schedule_move.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/service/auth/login._service.dart';
import 'package:holi/src/service/controllers/drivers/status_controller.dart';

class ButtonRequestVehicle extends StatelessWidget {
  const ButtonRequestVehicle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestVehicle()));
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Solicitar vehículo",
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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

class DisconnectButton extends StatelessWidget {
  const DisconnectButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
        backgroundColor: AppTheme.colorButtonHomeDriver,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Desconectarme",
        style: TextStyle(color: Colors.white, fontSize: 20),
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
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
        backgroundColor: AppTheme.colorButtonHomeDriver,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Cerrar sesión",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

class ConnectButton extends StatefulWidget {
  @override
  _ConnectButtonState createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> {
  bool _isLoading = false; // Variable para manejar el estado de carga

  // Controlador que maneja la actualización de estado
  final StatusController _statusController = StatusController();

  // Método para conectar al conductor
  void _connectDriver() async {
    setState(() {
      _isLoading = true; // Activar el estado de carga
    });

    final response = await _statusController.updateStatus('Conectado');

    setState(() {
      _isLoading = false; // Desactivar el estado de carga
    });

    if (response != null && response['status'] == 'success') {
      // Aquí puedes agregar cualquier acción en caso de éxito (e.g., navegación a otra pantalla)
      print('Conectado exitosamente');
    } else {
      // Mostrar el mensaje de error en el Dialog si algo falla
      _showErrorDialog(response?['message'] ?? 'Error desconocido');
    }
  }

  // Método para mostrar un diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : _connectDriver, // Desactivar el botón si está en estado de carga
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.6, 50),
        backgroundColor: AppTheme.colorButtonConnect,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: _isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Conectando...",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ],
            ) // Mostrar el texto y el indicador de carga
          : const Text(
              "Conectarme",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
    );
  }
}

