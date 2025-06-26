import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        title: const Text("Política de Privacidad", style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Política de Privacidad",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "1. Información que Recopilamos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "- Información personal: nombre, correo, teléfono y dirección.\n"
              "- Datos de uso: cómo interactúas con la aplicación.",
            ),
            SizedBox(height: 16),
            Text(
              "2. Uso de la Información",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Usamos tu información para brindar nuestros servicios, comunicarnos contigo y mejorar la experiencia del usuario.",
            ),
            SizedBox(height: 16),
            Text(
              "3. Compartir Información",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Podemos compartir tus datos con:\n"
              "- Proveedores de servicios de mudanza.\n"
              "- Autoridades legales cuando sea requerido.\n"
              "- Plataformas de pago para procesar transacciones.",
            ),
            SizedBox(height: 16),
            Text(
              "4. Seguridad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Implementamos medidas de seguridad para proteger tus datos, aunque no podemos garantizar seguridad absoluta.",
            ),
            SizedBox(height: 16),
            Text(
              "5. Tus Derechos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Puedes solicitar el acceso, corrección o eliminación de tus datos personales en cualquier momento.",
            ),
            SizedBox(height: 16),
            Text(
              "6. Cambios a esta Política",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Nos reservamos el derecho de actualizar esta política. Te notificaremos sobre cambios importantes.",
            ),
          ],
        ),
      ),
    );
  }
}
