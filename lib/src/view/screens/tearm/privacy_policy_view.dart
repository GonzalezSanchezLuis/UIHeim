import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        title: const Text("Política de Privacidad", style:  StyleFontsTitle.titleStyle,),
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
              "Política de Privacidad de Heim",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Última actualización: 2026",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "1 . Información que Recopilamos",
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
              "Usamos tu información para gestionar los servicios de transporte de carga, procesar pagos, y garantizar la seguridad del usuario durante el servicio.",
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
              "- Plataformas de pago para procesar transacciones.\n"
              "- Compartimos datos con los conductores asignados para completar el servicio y con plataformas de pago. No vendemos sus datos a terceros."
            ),
            SizedBox(height: 16),
            Text(
              "4. Datos de Ubicación Precisos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Recopilamos datos de ubicación exacta de su dispositivo para facilitar el servicio de acarreos, permitiendo que conductores y usuarios se localicen mutuamente.",
            ),
            SizedBox(height: 16),
            Text(
              "5. Tus Derechos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
               SizedBox(height: 16), 
            Text(
              "Puedes solicitar el acceso, corrección o eliminación de tus datos personales en cualquier momento.  \n"
              "Los usuarios pueden solicitar la eliminación de su cuenta y datos personales en cualquier momento a través de la configuración de la aplicación o enviando un correo a info@heimapp.com.co."
            ),
            SizedBox(height: 16),
            Text(
              "6. Cambios a esta Política",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Nos reservamos el derecho de actualizar esta política. Te notificaremos sobre cambios importantes.",
            ),

            SizedBox(height: 16),
            Text(
              "7. Contacto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Si tiene dudas, contáctenos en: legal@heimapp.com.co",
            ),
          ],
        ),
      ),
    );
  }
}
