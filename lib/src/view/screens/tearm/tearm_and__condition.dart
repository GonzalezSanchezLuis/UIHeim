import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class TearmAndCondition extends StatelessWidget {
  const TearmAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Terminos y condiciones"),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => {Navigator.pop(context)}),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Términos y Condiciones",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "1. Introducción",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Bienvenido a nuestra aplicación de mudanzas. Al usar nuestra aplicación, aceptas estos términos. Si no estás de acuerdo, no utilices los servicios.",
            ),
            SizedBox(height: 16),
            Text(
              "2. Uso de la Aplicación",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "- Debes ser mayor de 18 años para usar la aplicación.\n"
              "- Proporciona información precisa al registrarte.\n"
              "- No uses la aplicación para fines ilegales.",
            ),
            SizedBox(height: 16),
            Text(
              "3. Servicios de Mudanza",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Nuestra aplicación actúa como intermediario entre usuarios y transportistas. No somos responsables de daños o pérdidas causados por terceros.",
            ),
            SizedBox(height: 16),
            Text(
              "4. Pagos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Los pagos deben realizarse a través de las opciones disponibles en la aplicación. El incumplimiento puede resultar en la cancelación del servicio.",
            ),
            SizedBox(height: 16),
            Text(
              "5. Responsabilidad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "No nos hacemos responsables de pérdidas, daños o retrasos causados por terceros.",
            ),
            SizedBox(height: 16),
            Text(
              "6. Modificaciones",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Nos reservamos el derecho de modificar estos términos en cualquier momento. Notificaremos cambios importantes.",
            ),
          ],
        ),
      ),
    );
  }
}
